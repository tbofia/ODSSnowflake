/* CALL ADM.ETL_MASTER_SNOWFLAKE_ODS_LOAD ('@ACSODS_DEV.stg.etl_dev','ADM.COMMAFORMATFILES','ACSODS_DEV.STG.PIPEFORMATFILE',False)
*/
create or replace procedure adm.ETL_MASTER_SNOWFLAKE_ODS_LOAD(
  "externalStage" VARCHAR, 
  "controlFileFormatFile" VARCHAR, 
  "isDebug" BOOLEAN
)
returns variant
language javascript
execute as caller
as
$$
    const output = {
        returnStatus: 1,
        data: [],
        rowsAffected: -1,
        audit: "not logged",
        status: "not executed",
        message: []
    };

    const emailContent ={
        eventId:-1,
        postingGroupAuditId:-1,
        data: ""
    }

    let command;
    let snapshotDates = output;
    let snapshotDate;
    let s3ToStgStatus;
    let stgToSrcStatus;
    let dataOnlineStatus;
    let completeTableList;
    let tableFileList;
    let postingGroupAuditId = -1;
    let previousFullLoadPostingGroupAuditId;
    let loadType;

    let statement;
    let recordSet;

    let linebreak = "\r\n";
    let tab = "\t";

    //Get list of snapshotdates to be loaded
    command = "CALL ADM.ETL_GET_CONTROLFILES (" + linebreak
        + "'"+externalStage+"'," + linebreak
        + "'"+controlFileFormatFile+"'," + linebreak
        + "False)";

    if(isDebug){
        output.message.push("--Get list of snapshotdates to be loaded");
        output.message.push(command);
    }else{
        statement = snowflake.createStatement({sqlText:command});
        recordSet = statement.execute();
        recordSet.next();
        snapshotDates = recordSet.getColumnValue(1);
        if(recordSet.getColumnValue(1).returnStatus == -1){
            output.returnStatus = -1;
            output.rowsAffected = -1;
            output.status = "failed";
            output.message.push(recordSet.getColumnValue(1).message);   
            output.message.push("Error Command: " + command);
        }
    }
   
    //process each snapshot date returned 
    for(let i=0; i<snapshotDates.data.length && output.returnStatus != -1; i++){
        //get all process files for given snapshot into staging
        snapshotDate = snapshotDates.data[i];
        
        //Check if a fulload already loaded into src
        command = "SELECT DISTINCT LOAD_TYPE, " + linebreak
            + "  (SELECT COALESCE(MAX(POSTING_GROUP_AUDIT_ID),-1)" + linebreak
            + "    FROM ADM.POSTING_GROUP_INJEST_AUDIT" + linebreak
            + "    WHERE STATUS = 'FI'AND INJEST_TYPE_ID = 0) previousFullLoadPostingGroupAuditId" + linebreak
            + "  FROM STG.ETL_CONTROLFILES" + linebreak
            + "  WHERE SNAPSHOT_DATE  = '"+snapshotDate+"'";
        if(isDebug){
            output.message.push("--Check if a fulload already loaded into src");
            output.message.push(command);
        }else{
            statement = snowflake.createStatement({sqlText:command});
            recordSet = statement.execute();
            recordSet.next();
            loadType = recordSet.getColumnValue(1);
            previousFullLoadPostingGroupAuditId = recordSet.getColumnValue(2);
        }
         
        if (loadType == "FULL" && previousFullLoadPostingGroupAuditId != -1) 
            break;
        
        command = "CALL ADM.ETL_GET_PROCESS_FILES (" + linebreak
            + "'"+snapshotDate+"'," + linebreak
            + "False)";
        if(isDebug){
            output.message.push("--Get list of tables to be loaded");
            output.message.push(command);
        }else{
            statement = snowflake.createStatement({sqlText:command});
            recordSet = statement.execute();
            recordSet.next();
            tableFileList = recordSet.getColumnValue(1);
            if(recordSet.getColumnValue(1).returnStatus == -1){
                output.returnStatus = -1;
                output.rowsAffected = -1;
                output.status = "failed";
                output.message.push(recordSet.getColumnValue(1).message);   
                output.message.push("Error Command: " + command);
                break;
            }
        }
        
        // if all tables have been loaded to staging then skip
        if(typeof(tableFileList.data) != "string"){
            //get postingGroupAuditId
            postingGroupAuditId = tableFileList.data.postingGroupAuditId;
            
            //load process files to staging
            command = "CALL ADM.ETL_LOAD_POSTING_GROUP_INTO_STAGING (" + linebreak
            + "'"+JSON.stringify(tableFileList.data)+"'," + linebreak
            + "'"+externalStage+"'," + linebreak
            + "False)"
            if(isDebug){
                output.message.push("--Get list of snapshotdates to be loaded");
                output.message.push(command);
            }else{
                statement = snowflake.createStatement({sqlText:command});
                recordSet = statement.execute();
                recordSet.next();
                if(recordSet.getColumnValue(1).returnStatus == -1){
                    output.returnStatus = -1;
                    output.rowsAffected = -1;
                    output.status = "failed";
                    output.message.push(recordSet.getColumnValue(1).message);   
                    output.message.push("Error Command: " + command);
                    break;
                }
            }
        }
         
        //Check if any Errors when loading from S3 to staging
        command = "WITH CTE_CONTROL_FILE_PROCESSES AS(" + linebreak
            + " SELECT DISTINCT  TARGET_TABLE_NAME" + linebreak
            + "                 ,SNAPSHOT_DATE" + linebreak
            + " FROM STG.ETL_CONTROLFILES" + linebreak
            + " WHERE DATEDIFF(ms, SNAPSHOT_DATE, '"+snapshotDate+"') = 0" + linebreak
            + " )" + linebreak
            + " SELECT COUNT(DISTINCT P.PROCESS_ID) = COUNT(PIA.PROCESS_ID)" + linebreak
            + " FROM CTE_CONTROL_FILE_PROCESSES CF" + linebreak
            + " INNER JOIN ADM.PROCESS P" + linebreak
            + "     ON UPPER(P.TARGET_TABLE_NAME) = UPPER(CF.TARGET_TABLE_NAME)" + linebreak
            + "     AND P.IS_ACTIVE = 'TRUE'" + linebreak
			+ " INNER JOIN ADM.POSTING_GROUP_INJEST_AUDIT PGA" + linebreak
            + "     ON DATEDIFF(ms, PGA.SNAPSHOT_DATE, CF.SNAPSHOT_DATE) = 0" + linebreak
            + " LEFT OUTER JOIN ADM.PROCESS_INJEST_AUDIT PIA" + linebreak
            + "     ON P.PROCESS_ID = PIA.PROCESS_ID" + linebreak
            + "     AND PIA.POSTING_GROUP_AUDIT_ID = PGA.POSTING_GROUP_AUDIT_ID" + linebreak
            + "     AND PIA.STATUS IN ('L','I','FI');";
        if(isDebug){
            output.message.push("--Check if any Errors when loading from S3 to staging");
            output.message.push(command);
        }else{
            statement = snowflake.createStatement({sqlText:command});
            recordSet = statement.execute();
            recordSet.next();
            s3ToStgStatus = recordSet.getColumnValue(1);
            if(recordSet.getColumnValue(1).returnStatus == -1){
                output.returnStatus = -1;
                output.rowsAffected = -1;
                output.status = "failed";
                output.message.push(recordSet.getColumnValue(1).message);   
                output.message.push("Error Command: " + command);
                break;
            }
        }
       
        // if status is true, all table files were succesfully loaded to staging  
        if (s3ToStgStatus){
            //Get all tables and files that need to be copied to target
            command = " WITH CTE as (" + linebreak
                +" SELECT" + linebreak
                +"     PGA.POSTING_GROUP_AUDIT_ID,"   + linebreak
                +"     CF.LOAD_TYPE," + linebreak
                +"     object_construct('targetTableName',P.TARGET_TABLE_NAME) as jsObject" + linebreak
                +" FROM STG.ETL_CONTROLFILES CF" + linebreak
                +" INNER JOIN ADM.PROCESS P" + linebreak
                +" ON UPPER(P.TARGET_TABLE_NAME) = UPPER(CF.TARGET_TABLE_NAME)" + linebreak
                + "     AND P.IS_ACTIVE = 'TRUE'" + linebreak
				+" LEFT OUTER JOIN ADM.POSTING_GROUP_INJEST_AUDIT PGA" + linebreak
                +" ON DATEDIFF(ms, PGA.SNAPSHOT_DATE, CF.SNAPSHOT_DATE) = 0" + linebreak
                +" LEFT OUTER JOIN ADM.PROCESS_INJEST_AUDIT PA" + linebreak
                +" ON PGA.POSTING_GROUP_AUDIT_ID = PA.POSTING_GROUP_AUDIT_ID" + linebreak
                +" AND P.PROCESS_ID = PA.PROCESS_ID" + linebreak
                +" AND PA.STATUS IN ('L')" + linebreak
                +" WHERE DATEDIFF(ms, CF.SNAPSHOT_DATE, '"+snapshotDate+"') = 0" + linebreak
                +"   AND PA.POSTING_GROUP_AUDIT_ID IS NOT NULL" + linebreak
                +"   GROUP BY PGA.POSTING_GROUP_AUDIT_ID,CF.LOAD_TYPE,P.TARGET_TABLE_NAME,CF.SNAPSHOT_DATE,P.PROCESS_ID,PA.STATUS" + linebreak
                +" )" + linebreak
                +" SELECT"  + linebreak
                +"     object_construct('postingGroupAuditId',POSTING_GROUP_AUDIT_ID," + linebreak
                +"                      'loadType',LOAD_TYPE," + linebreak
                +"                      'tableData',ARRAY_AGG(jsObject))" + linebreak
                +" FROM cte" + linebreak
                +" GROUP BY POSTING_GROUP_AUDIT_ID,LOAD_TYPE;"

            if(isDebug){
                output.message.push("--Get all tables and files that need to be copied to target");
                output.message.push(command);
            }else{
              statement = snowflake.createStatement({sqlText:command});
              recordSet = statement.execute();
              if(recordSet.next())                  
                completeTableList = recordSet.getColumnValue(1);
              else 
                completeTableList = ""
            }     

            if (typeof(completeTableList) != "string"){
                // Load all tables to target schema
                command = "CALL ADM.ETL_LOAD_POSTING_GROUP_INTO_TARGET (" + linebreak
                    + "'"+JSON.stringify(completeTableList)+"'," + linebreak
                    + "False)";
                if(isDebug){
                    output.message.push("--Load all tables to target schema");
                    output.message.push(command);
                }else{
                    statement = snowflake.createStatement({sqlText:command});
                    recordSet = statement.execute();
                    recordSet.next();
                    if(recordSet.getColumnValue(1).returnStatus == -1){
                        output.returnStatus = -1;
                        output.rowsAffected = -1;
                        output.status = "failed";
                        output.message.push(recordSet.getColumnValue(1).message);   
                        output.message.push("Error Command: " + command);
                        break;
                    }
                }
            }

            //Check if any Errors when loading from staging to target
            command = "WITH CTE_CONTROL_FILE_PROCESSES AS(" + linebreak
                + " SELECT DISTINCT  TARGET_TABLE_NAME" + linebreak
                + "                 ,SNAPSHOT_DATE" + linebreak
                + " FROM STG.ETL_CONTROLFILES" + linebreak
                + " WHERE DATEDIFF(ms, SNAPSHOT_DATE, '"+snapshotDate+"') = 0" + linebreak
                + " )" + linebreak
                + " SELECT COUNT(DISTINCT P.PROCESS_ID) = COUNT(PIA.PROCESS_ID)" + linebreak
                + " FROM CTE_CONTROL_FILE_PROCESSES CF" + linebreak
                + " INNER JOIN ADM.PROCESS P" + linebreak
                + "     ON UPPER(P.TARGET_TABLE_NAME) = UPPER(CF.TARGET_TABLE_NAME)" + linebreak
                + "     AND P.IS_ACTIVE = 'TRUE'" + linebreak
				+ " INNER JOIN ADM.POSTING_GROUP_INJEST_AUDIT PGA" + linebreak
                + "     ON DATEDIFF(ms, PGA.SNAPSHOT_DATE, CF.SNAPSHOT_DATE) = 0" + linebreak
                + " LEFT OUTER JOIN ADM.PROCESS_INJEST_AUDIT PIA" + linebreak
                + "     ON P.PROCESS_ID = PIA.PROCESS_ID" + linebreak
                + "     AND PIA.POSTING_GROUP_AUDIT_ID = PGA.POSTING_GROUP_AUDIT_ID" + linebreak
                + "     AND PIA.STATUS IN ('I','FI');";

            if(isDebug){
                output.message.push("--Check if any Errors when loading from staging to target");
                output.message.push(command);
            }else{
                statement = snowflake.createStatement({sqlText:command});
                recordSet = statement.execute();
                recordSet.next();
                stgToSrcStatus = recordSet.getColumnValue(1);
            }

            if(stgToSrcStatus){
                // bring data online 
                command = "CALL ADM.ETL_Update_Target_Columns_With_Staging (" + linebreak
                    + postingGroupAuditId.toString()+"," + linebreak
                    + "'"+loadType+"'," + linebreak
                    + "'src'," + linebreak
                    + "False)";
                if(isDebug){
                    output.message.push("--bring data online");
                    output.message.push(command);
                }else{
                    statement = snowflake.createStatement({sqlText:command});
                    recordSet = statement.execute();
                    recordSet.next();
                    if(recordSet.getColumnValue(1).returnStatus == -1){
                        output.returnStatus = -1;
                        output.rowsAffected = -1;
                        output.status = "failed";
                        output.message.push(recordSet.getColumnValue(1).message);   
                        output.message.push("Error Command: " + command);
                        break;
                    }
                }

                //Check if any Errors when bringing Data Online
                command = "WITH CTE_CONTROL_FILE_PROCESSES AS(" + linebreak
                    + " SELECT DISTINCT  TARGET_TABLE_NAME" + linebreak
                    + "                 ,SNAPSHOT_DATE" + linebreak
                    + " FROM STG.ETL_CONTROLFILES" + linebreak
                    + " WHERE DATEDIFF(ms, SNAPSHOT_DATE, '"+snapshotDate+"') = 0" + linebreak
                    + " )" + linebreak
                    + " SELECT COUNT(DISTINCT P.PROCESS_ID) = COUNT(PIA.PROCESS_ID)" + linebreak
                    + " FROM CTE_CONTROL_FILE_PROCESSES CF" + linebreak
                    + " INNER JOIN ADM.PROCESS P" + linebreak
                    + "     ON UPPER(P.TARGET_TABLE_NAME) = UPPER(CF.TARGET_TABLE_NAME)" + linebreak
                    + "     AND P.IS_ACTIVE = 'TRUE'" + linebreak
					+ " INNER JOIN ADM.POSTING_GROUP_INJEST_AUDIT PGA" + linebreak
                    + "    ON DATEDIFF(ms, PGA.SNAPSHOT_DATE, '"+snapshotDate+"') = 0" + linebreak
                    + " LEFT OUTER JOIN ADM.PROCESS_INJEST_AUDIT PIA" + linebreak
                    + "     ON P.PROCESS_ID = PIA.PROCESS_ID" + linebreak
                    + "     AND PIA.POSTING_GROUP_AUDIT_ID = PGA.POSTING_GROUP_AUDIT_ID" + linebreak
                    + "     AND PIA.STATUS IN ('FI');";

                if(isDebug){
                    output.message.push("--Check if any Errors when bringing Data Online");
                    output.message.push(command);
                }else{
                    statement = snowflake.createStatement({sqlText:command});
                    recordSet = statement.execute();
                    recordSet.next();
                    dataOnlineStatus = recordSet.getColumnValue(1);
                }

                if(dataOnlineStatus){
                    continue;
                }else{//Data not brought online successfully
                    output.message.push("--Data not brought online successfully");
                    output.message.push(command);
                    break;
                }
            }else{//Data not copied from stg to src successfully
                output.message.push("--Data not copied from stg to src successfully");
                output.message.push(command);
                break;
            }
        }else{//Data not copies from s3 to stg successfully
            output.message.push("--Data not copies from s3 to stg successfully");
            output.message.push(command);
            break;
        }
    }
    
               
    //Debug mode, output the message
    if(isDebug){
        output.returnStatus = 0;
        output.status = "debug";
    }else if(output.returnStatus == 1) {
        output.status = "succeeded";
    }else{
        //insert any error messages into adm.Error_Log
        command = "INSERT INTO ADM.ERROR_LOG" + linebreak
            + "(OBJECT_AUDIT_KEY,EVENT_ID,ERROR_MESSAGE,LOG_DATE)" + linebreak
            //+ "SELECT " + (postingGroupAuditId == -1 ? 
            //                postingGroupAuditId.toString() 
            //                : "(SELECT MAX(POSTING_GROUP_AUDIT_ID) FROM ADM.POSTING_GROUP_INJEST_AUDIT), ") + "," + linebreak
            + "SELECT " + postingGroupAuditId.toString() + ", " + linebreak
            + "20," + linebreak
            + "'" + JSON.stringify(output.message).replace(/'/g,"''") + "'," + linebreak
            + "current_timestamp::timestamp_ntz;";
        if(isDebug){
            output.message.push("--insert any error messages into adm.Error_Log");
            output.message.push(command);
        }else{
            try{
                statement = snowflake.createStatement({sqlText:command});
                statement.execute();
                output.audit = "logged";
            }catch(err){
                output.message.push(err.message);
                output.message.push("Error command: " + command);
            }
        }
    }

    return output;
 
$$;

