CREATE OR REPLACE PROCEDURE adm.ETL_Bring_Data_Online(
  "postingGroupAuditId" FLOAT,
  "loadType" STRING,
  "tableNames" STRING,
  "isDebug" BOOLEAN
)
returns VARIANT
language javascript
execute as caller
as
$$

    const output = {
        returnStatus: 1,
        data: "",
        rowsAffected: -1,
        audit: "not logged",
        status: "",
        message: []
    }
    
    let command;
    let arrayCommands = [];
    let statement;
    let recordSet;
    let linebreak = "\r\n";
    let tab = "\t";
    
    postingGroupAuditId = Number(postingGroupAuditId);
    tableNames = tableNames.split(",");
    let processIds = [];
    let joinClauseOdsCustomerId = "";
	let joinClauseOthers = "";
    let totalRowsUpdated = 0;

    for(let i = 0; i < tableNames.length; i++){
        let originalSchemaName = (tableNames[i].split("."))[0].split("_")[0];
		if(loadType.toUpperCase() == "INCR" && originalSchemaName == "SRC"){
            command = "SELECT LISTAGG(CASE " + linebreak
					+ "        WHEN (UPPER(P.TARGET_TABLE_NAME) = 'PROVIDERCLUSTER' AND UPPER(C.COLUMN_NAME) = 'ORGODSCUSTOMERID') " + linebreak
					+ "            OR (UPPER(P.TARGET_TABLE_NAME) != 'PROVIDERCLUSTER' AND UPPER(C.COLUMN_NAME) = 'ODSCUSTOMERID') " + linebreak
					+ "        THEN 'T.' || C.COLUMN_NAME || ' = ' || 'S.' || C.COLUMN_NAME " + linebreak
					+ "        ELSE NULL " + linebreak
					+ "        END, ' AND ') AS joinClauseOdsCustomerId, " + linebreak
					+ "    LISTAGG(CASE " + linebreak
					+ "        WHEN (UPPER(P.TARGET_TABLE_NAME) = 'PROVIDERCLUSTER' AND UPPER(C.COLUMN_NAME) != 'ORGODSCUSTOMERID') " + linebreak
					+ "            OR (UPPER(P.TARGET_TABLE_NAME) != 'PROVIDERCLUSTER' AND UPPER(C.COLUMN_NAME) != 'ODSCUSTOMERID') " + linebreak
					+ "        THEN 'T.' || C.COLUMN_NAME || ' = ' || 'S.' || C.COLUMN_NAME " + linebreak
					+ "        ELSE NULL " + linebreak
					+ "        END, ' AND ') AS joinClauseOthers " + linebreak
					+"FROM ADM.PROCESS_PRIMARY_KEY PPK " + linebreak
					+"INNER JOIN ADM.PROCESS P " + linebreak
					+"    ON PPK.PROCESS_ID = P.PROCESS_ID " + linebreak
					+"    AND UPPER(P.TARGET_TABLE_NAME) = UPPER('" + tableNames[i].split(".")[1] + "') " + linebreak
					+"    AND UPPER(P.TARGET_SCHEMA_NAME) = UPPER('" + originalSchemaName + "') " + linebreak
					+"INNER JOIN INFORMATION_SCHEMA.COLUMNS C " + linebreak
					+"    ON UPPER(PPK.PRIMARY_KEY_COLUMN) = C.COLUMN_NAME " + linebreak
					+"    AND UPPER(P.TARGET_TABLE_NAME) = C.TABLE_NAME " + linebreak
					+"    AND UPPER(P.TARGET_SCHEMA_NAME) = C.TABLE_SCHEMA " + linebreak
					+"    AND UPPER(PPK.PRIMARY_KEY_COLUMN) != 'ODSPOSTINGGROUPAUDITID';";
            if(isDebug){
                arrayCommands.push("--For table " + tableNames[i] + ", Build the join clause to find the matched records from previous posting group.");
				arrayCommands.push(command);
            }
			try {
				statement = snowflake.createStatement({sqlText:command});
				recordSet = statement.execute();
				if (recordSet.next()) {
					joinClauseOdsCustomerId = recordSet.getColumnValue(1);
					joinClauseOthers = recordSet.getColumnValue(2);
				}
			} catch (err) {
				output.returnStatus = -1;
                output.rowsAffected = -1;
                output.status = "failed";
                output.message.push(err.message);
                continue;
			}
            
            //OdsRowIsCurrent update 1 -> 0.
            command = ""
                + "UPDATE " + tableNames[i] + " T " + linebreak
                + "    SET T.OdsRowIsCurrent = 0 " + linebreak
                + "FROM stg." + (tableNames[i].split("."))[1] + " S " + linebreak
                + "WHERE " + joinClauseOdsCustomerId + linebreak
				+ "    AND T.OdsRowIsCurrent = 1 " + linebreak
				+ "    AND " + joinClauseOthers + linebreak
                + "    AND S.OdsRowIsCurrent = 1; ";
                

            if(isDebug){
                arrayCommands.push("--For table " + tableNames[i] + ", update the records from the previous posting group.");
                arrayCommands.push(command);
            }else{
                try{
                  statement = snowflake.createStatement({sqlText:command});
                  recordSet = statement.execute();
                  recordSet.next();
                  totalRowsUpdated = recordSet.getColumnValue(1);
                }catch(err){
                  output.returnStatus = -1;
                  output.rowsAffected = -1;
                  output.status = "failed";
                  output.message.push(err.message);
                  continue;
                }
            }

            //update the records from the latest posting group.
            //OdsRowIsCurrent update -1 -> 1.
            command = "UPDATE " + tableNames[i] + linebreak
                + "SET OdsRowIsCurrent = 1 " + linebreak
                + "WHERE OdsRowIsCurrent = -1; ";

            if(isDebug){
                arrayCommands.push("--For table " + tableNames[i] + ", update the records from the latest posting group.");
                arrayCommands.push(command);
            }else{
                try{
                  statement = snowflake.createStatement({sqlText:command});
                  recordSet = statement.execute();
                }catch(err){
                  output.returnStatus = -1;
                  output.rowsAffected = -1;
                  output.status = "failed";
                  output.message.push(err.message);
                  continue;
                } 
            }
        }

		//INSERT INTO ADM.TRANSIENT_STATUS_BRING_DATA_ONLINE
		command = "INSERT INTO ADM.TRANSIENT_STATUS_BRING_DATA_ONLINE " + linebreak
		    + "SELECT PIA.PROCESS_AUDIT_ID," + linebreak
			+ "    'FI'," + linebreak
			+ "    " + totalRowsUpdated.toString() + "," + linebreak
			+ "    CURRENT_TIMESTAMP" + linebreak
			+ "FROM adm.PROCESS P " + linebreak
			+ "INNER JOIN ADM.PROCESS_INJEST_AUDIT PIA" + linebreak
			+ "    ON P.PROCESS_ID = PIA.PROCESS_ID" + linebreak
			+ "WHERE PIA.POSTING_GROUP_AUDIT_ID = " + postingGroupAuditId.toString() + linebreak
			+ "    AND upper(p.TARGET_TABLE_NAME) = upper('" + (tableNames[i].split("."))[1] + "')" + linebreak
            + "    AND pia.STATUS = 'I' " + linebreak
			+ "ORDER BY pia.PROCESS_AUDIT_ID DESC LIMIT 1;";

		if(isDebug){
            arrayCommands.push("--For table " + tableNames[i] + ", INSERT INTO ADM.TRANSIENT_process_injest_audit.");
            arrayCommands.push(command);
        }else{
            try{
                statement = snowflake.createStatement({sqlText:command});
                recordSet = statement.execute();
                recordSet.next();
                if(recordSet.getColumnValue(1).returnStatus == -1){
                    output.returnStatus = -1;
                    output.rowsAffected = -1;
                    output.status = "failed";
                    output.message.push(command + ". Error: " + recordSet.getColumnValue(1).message);
                    continue;
                }
            }catch(err){
                output.returnStatus = -1;
                output.rowsAffected = -1;
                output.status = "failed";
                output.message.push(command + ". Error: " + err.message);
                continue;
            }
         }
    }
    
    if(isDebug){
        output.returnStatus = 0;
        output.rowsAffected = -1;
        output.status = "debug";
        output.message = arrayCommands;
    }else if(output.returnStatus != -1){
        output.rowsAffected = -1;
        output.status = "succeeded";
        output.audit = "logged";
    }
    
    return output;
$$;
