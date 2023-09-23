
CREATE OR REPLACE PROCEDURE adm.ETL_Update_Target_Columns_With_Staging(
  "postingGroupAuditId" FLOAT,
  "loadType" STRING,
  "targetSchema" STRING,
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
    let tableNames = [];
    let processIds = [];
    let joinClause = "";
    let totalRowsUpdated = 0;
        
    //get a list of tables to be processed.
    command = "SELECT ARRAY_AGG(P.TARGET_TABLE_NAME) WITHIN GROUP (ORDER BY P.PROCESS_ID ASC) AS tableNames " + linebreak
        + " ,ARRAY_AGG(P.PROCESS_ID) WITHIN GROUP (ORDER BY P.PROCESS_ID ASC) AS processIds " + linebreak
        + "FROM ADM.PROCESS_INJEST_AUDIT PIA " + linebreak
        + "INNER JOIN ADM.PROCESS P " + linebreak
        + " ON PIA.PROCESS_ID = P.PROCESS_ID " + linebreak
		+ " AND P.IS_ACTIVE = 'TRUE'" + linebreak
        + "WHERE PIA.POSTING_GROUP_AUDIT_ID = " + postingGroupAuditId.toString() + linebreak
        + "AND PIA.STATUS = 'I' ;" ;
    statement = snowflake.createStatement({sqlText:command});
    recordSet = statement.execute();
    if(!recordSet.next()){
        output.message.push("table list is empty");
        if(isDebug){
            output.returnStatus = 0;
            output.rowsAffected = -1;
            output.status = "debug";
            
        }else if(output.returnStatus != -1){
            output.rowsAffected = -1;
            output.status = "succeeded";
        }
        return output;
    }
    tableNames = recordSet.getColumnValue(1);
    processIds = recordSet.getColumnValue(2);
    
    try{
        //BEGIN TRANSACTION
        command = "BEGIN TRANSACTION;";
        if(isDebug){
            arrayCommands.push(command);
        }else{
            statement = snowflake.createStatement({sqlText:command});
            statement.execute();
        }

        //this is the transaction wrapping up all tables.
        for(let i = 0; i < tableNames.length; i++){
            if(loadType.toUpperCase() == "INCR"){
				//build the join clause to find the matched records from previous posting group. 
				//when column with timestamp_ntz is part of primary key, cast it to timestamp_ntz(3) in the join clause.
				command = "SELECT LISTAGG( CASE " + linebreak
					+"		WHEN C.DATA_TYPE like 'TIMESTAMP_NTZ%'  " + linebreak
					+"            THEN 'S.'||C.COLUMN_NAME||'::TIMESTAMP_NTZ(3)'|| ' = ' || 'T.' || C.COLUMN_NAME||'::TIMESTAMP_NTZ(3)' " + linebreak
					+"		ELSE 'S.' || C.COLUMN_NAME || ' = ' || 'T.' || C.COLUMN_NAME " + linebreak
					+"	END ,' AND ') AS joinClause " + linebreak
					+"FROM ADM.PROCESS_PRIMARY_KEY PPK " + linebreak
					+"INNER JOIN ADM.PROCESS P " + linebreak
					+"    ON PPK.PROCESS_ID = P.PROCESS_ID " + linebreak
					+"    AND UPPER(P.TARGET_TABLE_NAME) = UPPER('" + tableNames[i] + "') " + linebreak
					+"    AND UPPER(P.TARGET_SCHEMA_NAME) = UPPER('" + targetSchema + "') " + linebreak
					+"INNER JOIN INFORMATION_SCHEMA.COLUMNS C " + linebreak
					+"    ON UPPER(PPK.PRIMARY_KEY_COLUMN) = C.COLUMN_NAME " + linebreak
					+"    AND UPPER(P.TARGET_TABLE_NAME) = C.TABLE_NAME " + linebreak
					+"    AND UPPER(P.TARGET_SCHEMA_NAME) = C.TABLE_SCHEMA " + linebreak
					+"    AND UPPER(PPK.PRIMARY_KEY_COLUMN) != 'ODSPOSTINGGROUPAUDITID';";

				if(isDebug){
					arrayCommands.push("--For table " + tableNames[i] + ", Build the join clause to find the matched records from previous posting group.");
					arrayCommands.push(command);
				}
				statement = snowflake.createStatement({sqlText:command});
				recordSet = statement.execute();
				if(recordSet.next())
					joinClause = recordSet.getColumnValue(1);

				//OdsRowIsCurrent update 1 -> 0.
				command = ""
					+ "UPDATE " + targetSchema + "." + tableNames[i] + " T " + linebreak
					+ "    SET T.OdsRowIsCurrent = 0 " + linebreak
					+ "FROM stg." + tableNames[i] + " S " + linebreak
					+ "WHERE " + joinClause + linebreak
					+ "    AND S.OdsRowIsCurrent = 1 " + linebreak
					+ "    AND T.OdsRowIsCurrent = 1; "

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
				command = "UPDATE " + targetSchema + "." + tableNames[i] + linebreak
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
          //Update adm.process_injest_audit
            command = "UPDATE ADM.PROCESS_INJEST_AUDIT PIA" + linebreak
              + "  SET STATUS = 'FI', " + linebreak
              + "      TOTAL_RECORDS_UPDATED = " + totalRowsUpdated.toString()+ ", " + linebreak
              + "      UPDATE_DATE = CURRENT_TIMESTAMP(), " + linebreak
              + "      LAST_CHANGE_DATE = CURRENT_TIMESTAMP() " + linebreak
              + " FROM (" + linebreak
			  + "        SELECT PROCESS_ID " + linebreak
              + "        FROM ADM.PROCESS_INJEST_AUDIT " + linebreak
              + "        WHERE POSTING_GROUP_AUDIT_ID = " + postingGroupAuditId.toString() + linebreak
              + "         AND PROCESS_ID = " + processIds[i].toString() + linebreak
              + "         AND STATUS = 'I' " + linebreak
              + "        ORDER BY PROCESS_AUDIT_ID DESC LIMIT 1 "+ linebreak
              + "      )S "+ linebreak
              + "  WHERE S.PROCESS_ID = PIA.PROCESS_ID ";

            if(isDebug){
                arrayCommands.push("--For table " + tableNames[i] + ", update PROCESS_INJEST_AUDIT.");
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
        
        if(output.returnStatus != -1){
            //commit transaction
            command = "COMMIT;";
            if(isDebug){
                arrayCommands.push(command);
            }else{
                statement = snowflake.createStatement({sqlText:command});
                statement.execute();
            }
        }else{
            //rollback transaction
            command = "ROLLBACK;";
            if(isDebug){
                arrayCommands.push(command);
            }else{
                statement = snowflake.createStatement({sqlText:command});
                statement.execute();
				return output;
            }
        }
    }catch(err){
        //rollback transaction
        command = "ROLLBACK;";
        if(isDebug){
			arrayCommands.push("Error Message: " + err.message);
            arrayCommands.push(command);
        }else{
            statement = snowflake.createStatement({sqlText:command});
            statement.execute();
			return output;
        }
    }
    
    //Update adm.posting_group_injest_audit
    command = "UPDATE ADM.POSTING_GROUP_INJEST_AUDIT" + linebreak
      + "  SET STATUS = 'FI', " + linebreak
      + "      LAST_CHANGE_DATE = CURRENT_TIMESTAMP() " + linebreak
      + " WHERE POSTING_GROUP_AUDIT_ID = " + postingGroupAuditId.toString() + linebreak
      + "  AND STATUS != 'FI'; ";
  
	if(isDebug){
        arrayCommands.push("--update adm.posting_group_injest_audit.");
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
            }
        }catch(err){
            output.returnStatus = -1;
            output.rowsAffected = -1;
            output.status = "failed";
            output.message.push(command + ". Error: " + err.message);
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

