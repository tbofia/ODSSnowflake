CREATE OR REPLACE PROCEDURE adm.Etl_Insert_Process_Into_Target_From_Staging_oltp
(
    "tableName" VARCHAR(100),
    "injestTypeId" FLOAT, --0 is full load, 1 is incremental load.
    "postingGroupAuditId" FLOAT,
    "isDebug" BOOLEAN
)
returns variant
language javascript
EXECUTE AS CALLER
as
$$
    const output = {
        returnStatus: -1,
        rowsAffected: -1,
        audit: "not logged",
        status: "not executed",
        message: []
    };
    
    let command;
    let statement;
    let recordSet;
    let stringColumnListTarget;
	let stringColumnListTargetReplace;
    let stringColumnListStg;
    let totalRecordsInTarget = 0 ;
    let targetSchemaName = "";

	let linebreak = "\r\n";
	let tab = "\t";
	let specialChar = "\\\\x00"; 
    
    injestTypeId = Number(injestTypeId);
    postingGroupAuditId = Number(postingGroupAuditId);
       
    //get column names
    command = "SELECT LISTAGG(COLUMN_NAME,',')WITHIN GROUP (ORDER BY ORDINAL_POSITION ASC) AS TARGET_COLUME_LIST," + linebreak
		+ "LISTAGG(CASE " + linebreak
		+ "    WHEN ORDINAL_POSITION < 8 THEN COLUMN_NAME " + linebreak
		+ "    WHEN DATA_TYPE != 'TEXT' THEN COLUMN_NAME" + linebreak
		+ "    ELSE 'REGEXP_REPLACE('||COLUMN_NAME||',''" + specialChar + "'','''')'" + linebreak
		+ "END,',')WITHIN GROUP (ORDER BY ORDINAL_POSITION ASC) AS TARGET_COLUME_LIST_REPLACE," + linebreak
		+ "LISTAGG(CASE " + linebreak
		+ "    WHEN COLUMN_NAME = 'ODSROWISCURRENT' THEN 'CASE WHEN ODSROWISCURRENT = 0 THEN 0 WHEN ODSROWISCURRENT = 1 THEN -1 ELSE ODSROWISCURRENT END'" + linebreak
		+ "    WHEN ORDINAL_POSITION < 8 THEN COLUMN_NAME " + linebreak
		+ "    WHEN DATA_TYPE != 'TEXT' THEN COLUMN_NAME" + linebreak
		+ "    ELSE 'REGEXP_REPLACE('||COLUMN_NAME||',''" + specialChar + "'','''')'" + linebreak
		+ "END,',')WITHIN GROUP (ORDER BY ORDINAL_POSITION ASC) AS STG_COLUME_LIST," + linebreak
		+ "ANY_VALUE(TABLE_SCHEMA) AS TABLE_SCHEMA" + linebreak
		+ "FROM INFORMATION_SCHEMA.COLUMNS "
		+ "WHERE TABLE_NAME = '" + tableName.toUpperCase() + "' "
		+ "AND TABLE_SCHEMA IN ('SRC'); ";
    if (isDebug) {
		output.message.push("--get column names");
		output.message.push(command);
	}
	try {
		statement = snowflake.createStatement({sqlText:command});
		recordSet = statement.execute();
		recordSet.next();
		stringColumnListTarget = recordSet.getColumnValue("TARGET_COLUME_LIST");
		stringColumnListTargetReplace = recordSet.getColumnValue("TARGET_COLUME_LIST_REPLACE");
		stringColumnListStg = recordSet.getColumnValue("STG_COLUME_LIST");
		targetSchemaName = recordSet.getColumnValue("TABLE_SCHEMA");
	} catch (err) {
		output.returnStatus = -1;
		output.rowsAffected = -1;
		output.status = 'failed';
		output.message.push(err.message);
		output.message.push("Error Command: " + command);
		return output;
	}
    
    
    command = "INSERT INTO " + targetSchemaName.toUpperCase() + "." + tableName.toUpperCase() + linebreak
            + "( " + linebreak
            + stringColumnListTarget + linebreak
            + ") " + linebreak
            + "SELECT " + linebreak
            + (injestTypeId == 0 ? stringColumnListTargetReplace : stringColumnListStg) + linebreak
            + "FROM STG." + tableName.toUpperCase();
            
    if(isDebug){
            output.message.push("--insert query");
			output.message.push(command + linebreak);
         }else{
            try{
				//if incremental load from stg to src with odsrowiscurrent 0 -> 0, 1 -> -1.
				//if full load from stg to src with odsrowiscurrent as it is.
				statement = snowflake.createStatement({sqlText:command});
				recordSet = statement.execute();
				recordSet.next();
			}catch(err){
				output.returnStatus = -1;
				output.rowsAffected = -1;
				output.status = 'failed';
				output.message.push(err.message);
				output.message.push("Error Command: " + command);
				return output;
			}
        }
            
    //get totalRecordsLoaded to Src table
     command = "SELECT $1 FROM TABLE(RESULT_SCAN(LAST_QUERY_ID()));"
     
     if(isDebug){
			output.message.push("--get totalRecordsLoaded to Src table");
            output.message.push(command + linebreak);
         }else{
            try{
				statement = snowflake.createStatement({sqlText:command});
				recordSet = statement.execute();
				recordSet.next();
				totalRecordsInTarget = recordSet.getColumnValue(1);
			}catch(err){
				output.returnStatus = -1;
				output.rowsAffected = -1;
				output.status = 'failed';
				output.message.push(err.message);
				output.message.push("Error Command: " + command);
				return output;
			}
         }
     
	 //INSERT INTO ADM.TRANSIENT_process_injest_audit
		command = "INSERT INTO ADM.TRANSIENT_STATUS_LOAD_INTO_TARGET " + linebreak
		    + "SELECT PIA.PROCESS_AUDIT_ID," + linebreak
			+ "    'I'," + linebreak
			+ "    " + totalRecordsInTarget.toString() + "," + linebreak
			+ "    CURRENT_TIMESTAMP" + linebreak
			+ "FROM adm.PROCESS P " + linebreak
			+ "INNER JOIN ADM.PROCESS_INJEST_AUDIT PIA" + linebreak
			+ "    ON P.PROCESS_ID = PIA.PROCESS_ID" + linebreak
			+ "WHERE PIA.POSTING_GROUP_AUDIT_ID = " + postingGroupAuditId.toString() + linebreak
			+ "    AND upper(p.TARGET_TABLE_NAME) = upper('" +tableName + "')" + linebreak
            + "    AND pia.STATUS = 'L' " + linebreak
			+ "ORDER BY pia.PROCESS_AUDIT_ID DESC LIMIT 1;";

     if(isDebug){
		output.message.push("--Update ADM.PROCESS_INJEST_AUDIT");
        output.message.push(command + linebreak);
        output.returnStatus = 0;
        output.rowsAffected = -1;
        output.status = "debug";
    }else{
       try{ 
           statement = snowflake.createStatement({sqlText:command});
           recordSet = statement.execute();
           recordSet.next();

          if(recordSet.getColumnValue(1).returnStatus == -1){
              output.returnStatus = -1;
              output.rowsAffected = -1;
              output.status = "failed";
              output.message.push(recordSet.getColumnValue(1).message);   
              output.message.push("Error Command: " + command);
              return output;
          }

            output.returnStatus = 1;
            output.rowsAffected = totalRecordsInTarget;
            output.status = 'succeeded';
           
        }catch(err){
            //Log into a file - call stored procedure.
            
            output.returnStatus = -1;
            output.rowsAffected = -1;
            output.status = 'failed';
            output.message.push(err.message);
        }
   }
    return output;
$$;
