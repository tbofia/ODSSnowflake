create or replace procedure adm.ETL_MASTER_SNOWFLAKE_ODS_LOAD_multithread(
  "numberOfPipelines" FLOAT,
  "warehouseName" STRING,
  "timeoutInMinutes" FLOAT,
  "checkpointWaitingTimeInSeconds" FLOAT,
  "externalStage" VARCHAR, 
  "product" VARCHAR,
  "controlFileFormatFile" VARCHAR, 
  "isSourceOLTP" BOOLEAN,
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

	let completeTableList;
	let currentdate;
	let currentTimestamp;
	let customer;
	let customers;
	let dataOnlineStatus;
	let listProblematicCustomers = [];
	let loadType;
	let maxCountOfPostingGroups;
	let newSchemaNameForRpt = "RPT";
	let newSchemaNameForSrc = "SRC";
	let postingGroupAuditId = -1;
    let previousFullLoadPostingGroupAuditId;
	let s3ToStgStatus;
	let snapshotDate;
    let snapshotDates = output;
	let snapshotDatesPerCustomer = [];
    let stgToSrcStatus;
	let tableExists = false;
	let tableFileList;

    numberOfPipelines = Number(numberOfPipelines);
    timeoutInMinutes = Number(timeoutInMinutes);
    checkpointWaitingTimeInSeconds = Number(checkpointWaitingTimeInSeconds);
	
	let command;
    let statement;
    let recordSet;
    let linebreak = "\r\n";
    let tab = "\t";

	let schema_staging = isSourceOLTP ? "STG_OLTP" : "STG";
	externalStage = (externalStage.substring(externalStage.length-1,externalStage.length) == "/"?externalStage:externalStage + "/");
	externalStage += (isSourceOLTP ? "OLTP_SNOWFLAKE/" : "ODS_SNOWFLAKE/") + product + "/";

    //Get list of snapshotdates to be loaded
    command = "CALL ADM.ETL_GET_CONTROLFILES (" + linebreak
        + "'" + externalStage + "'," + linebreak
        + "'" + controlFileFormatFile + "'," + linebreak
        + (isSourceOLTP ? "true," : "false,") + linebreak
		+ "False)";

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
			return output;
        }
		customers = recordSet.getColumnValue(1).data.customers;
        snapshotDates = recordSet.getColumnValue(1).data.snapshotDates;
		maxCountOfPostingGroups = recordSet.getColumnValue(1).data.maxCountOfPostingGroups;
    }

	
   
    for(let i = 0; i < maxCountOfPostingGroups && output.returnStatus != -1; i++){
        //get all process files for given snapshot into staging
        customer = customers[i];
		snapshotDatesPerCustomer = snapshotDates[i];
		snapshotDate = snapshotDates[0][i];

		if (isSourceOLTP) {
			//OLTP -> SNOWFLAKE
			//get all the posting groups to be processed in current iteration.
			command = "CREATE OR REPLACE TRANSIENT TABLE STG_OLTP.TRANSIENT_CURRENT_ETL_ControlFiles" + linebreak
				+ "AS " + linebreak
				+ "WITH CTE_BaseInfo AS (" + linebreak
				+ "    SELECT DISTINCT " + linebreak
				+ "        UPPER(ARRAY_TO_STRING(ARRAY_SLICE(STRTOK_TO_ARRAY(CONTROL_FILE_NAME, '_')" + linebreak
				+ "            , 0" + linebreak
				+ "            , (ARRAY_SIZE(STRTOK_TO_ARRAY(CONTROL_FILE_NAME, '_'))) - 3), '_')) AS CUSTOMER_NAME" + linebreak
				+ "        , SNAPSHOT_DATE" + linebreak
				+ "        , LOAD_TYPE" + linebreak
				+ "    FROM STG_OLTP.ETL_CONTROLFILES" + linebreak
				+ ")" + linebreak
				+ ", CTE AS (" + linebreak
				+ "    SELECT *" + linebreak
				+ "        , ROW_NUMBER()OVER(PARTITION BY CUSTOMER_NAME ORDER BY SNAPSHOT_DATE) AS RID" + linebreak
				+ "    FROM CTE_BaseInfo" + linebreak
				+ ")" + linebreak
				+ ", CTE_PGIA AS (" + linebreak
				+ "    SELECT *" + linebreak
				+ "        , ROW_NUMBER()OVER(PARTITION BY CUSTOMER_ID ORDER BY SNAPSHOT_DATE DESC) AS RID" + linebreak
				+ "    FROM ADM_OLTP.POSTING_GROUP_AUDIT" + linebreak
				+ ")" + linebreak
				+ "SELECT DISTINCT" + linebreak
				+ "    CTE.CUSTOMER_NAME" + linebreak
				+ "    , CTE.SNAPSHOT_DATE" + linebreak
				+ "    , CTE.LOAD_TYPE" + linebreak
				+ "    , SUM(CASE WHEN CTE.LOAD_TYPE = 'INCR' AND PIA.POSTINGGROUPAUDITID IS NULL THEN 1 ELSE 0 END) AS Tables_Without_Preceding_Full_Load" + linebreak
				+ "    , SUM(CASE " + linebreak
				+ "        WHEN IFNULL(CTE_PGIA.SNAPSHOT_DATE, '1900-01-01') <= CF.SNAPSHOT_DATE " + linebreak
				+ "        THEN 1" + linebreak
				+ "        ELSE 0" + linebreak
				+ "    END) :: BOOLEAN  AS Is_Current_Replication_Qualified " + linebreak
				+ "FROM CTE" + linebreak
				+ "INNER JOIN STG_OLTP.ETL_CONTROLFILES CF" + linebreak
				+ "    ON CTE.SNAPSHOT_DATE = CF.SNAPSHOT_DATE" + linebreak
				+ "    AND UPPER(CF.CONTROL_FILE_NAME) LIKE CTE.CUSTOMER_NAME || '%'" + linebreak
				+ "    AND RID = 1" + linebreak
				+ "INNER JOIN ADM.CUSTOMER AS C" + linebreak
				+ "    ON UPPER(CTE.CUSTOMER_NAME) = UPPER(C.CUSTOMER_DATABASE)" + linebreak
				+ "INNER JOIN ADM.PROCESS AS P " + linebreak
				+ "    ON UPPER(CF.TARGET_TABLE_NAME) = UPPER(P.TARGET_TABLE_NAME)" + linebreak
				+ "LEFT OUTER JOIN RPT.POSTINGGROUPAUDIT AS PGIA" + linebreak
				+ "    ON PGIA.DATAEXTRACTTYPEID = 0" + linebreak
				+ "    AND PGIA.CUSTOMERID = C.CUSTOMER_ID" + linebreak
				+ "    AND PGIA.STATUS = 'FI'" + linebreak
				+ "LEFT OUTER JOIN RPT.PROCESSAUDIT AS PIA" + linebreak
				+ "    ON PIA.POSTINGGROUPAUDITID = PGIA.POSTINGGROUPAUDITID" + linebreak
				+ "    AND PIA.PROCESSID = P.PROCESS_ID" + linebreak
				+ "LEFT OUTER JOIN CTE_PGIA " + linebreak
				+ "    ON CTE_PGIA.RID = 1" + linebreak
				+ "    AND CTE_PGIA.CUSTOMER_ID = C.CUSTOMER_ID  " + linebreak
				+ "WHERE UPPER(CTE.CUSTOMER_NAME) NOT IN ('" + listProblematicCustomers.join("', '") + "')" + linebreak
				+ "GROUP BY CTE.CUSTOMER_NAME, CTE.SNAPSHOT_DATE, CTE.LOAD_TYPE;";
			if(isDebug){
				output.message.push("--get all the posting groups to be processed in current iteration.");
				output.message.push(command);
			}else{
				try{
					statement = snowflake.createStatement({sqlText:command});
					recordSet = statement.execute();
					recordSet.next();
				}catch(err){
					output.returnStatus = -1;
					output.rowsAffected = -1;
					output.status = "failed";
					output.message.push(command + ". Error: " + err.message);
				}
			}

			//Incremental load without preceding successful full load? 
			//If so, add them to a list and skip their following PGAs. 
			//As a result, their PGAs will hang in ETL_ControlFiles table and will not be processed.
			command = "SELECT " + linebreak
				+ "    ARRAY_AGG(UPPER(CUSTOMER_NAME)) AS CustomerNames" + linebreak
				+ "FROM STG_OLTP.TRANSIENT_CURRENT_ETL_ControlFiles" + linebreak
				+ "WHERE Tables_Without_Preceding_Full_Load > 0;";
			if(isDebug){
				output.message.push("--Incremental load without preceding successful full load? ");
				output.message.push("--If so, add them to a list and skip their following PGAs.");
				output.message.push("--As a result, their PGAs will hang in ETL_ControlFiles table and will not be processed. ");
				output.message.push(command);
			}else{
				try{
					statement = snowflake.createStatement({sqlText:command});
					recordSet = statement.execute();
					recordSet.next();
					Array.prototype.push.apply(listProblematicCustomers, recordSet.getColumnValue(1));
				}catch(err){
					output.returnStatus = -1;
					output.rowsAffected = -1;
					output.status = "failed";
					output.message.push(command + ". Error: " + err.message);
				}
			}
		} else {
			//ODS -> SNOWFLAKE
			//Check if a fulload already loaded into src
			command = "SELECT DISTINCT UPPER(LOAD_TYPE), " + linebreak
				+ "  (SELECT COALESCE(MAX(POSTING_GROUP_AUDIT_ID),-1)" + linebreak
				+ "    FROM ADM.POSTING_GROUP_INJEST_AUDIT" + linebreak
				+ "    WHERE STATUS = 'FI'AND INJEST_TYPE_ID = 0) previousFullLoadPostingGroupAuditId" + linebreak
				+ "  FROM STG.ETL_CONTROLFILES" + linebreak
				+ "  WHERE SNAPSHOT_DATE = '" + snapshotDate + "'";
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
		}
		
        //Insert into PGIA and PGA audit tables.
		//1. For MSSQL ODS -> Snowflake, please call ADM.ETL_GET_PROCESS_FILES('<date>',false,false);
		//2. For MSSQL OLTP -> Snowflake, please call ADM.ETL_GET_PROCESS_FILES('',true,false);
        command = "CALL ADM.ETL_GET_PROCESS_FILES (" + linebreak
            + (isSourceOLTP ? "''," : "'" + snapshotDate + "',") + linebreak
			+ (isSourceOLTP ? "true," : "false,") + linebreak
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
		let adder = (accumulator, currentValue) => accumulator + currentValue;
        if ((!isSourceOLTP && tableFileList.data.totalFileCount > 0) 
			||(isSourceOLTP && tableFileList.data.totalFileCount.length > 0 && tableFileList.data.totalFileCount.reduce(adder) > 0)){
            //load process files to staging
            command = "CALL ADM.ETL_LOAD_POSTING_GROUP_INTO_STAGING_MULTITHREAD (" + linebreak
            + numberOfPipelines.toString() + "," + linebreak
            + "'" + warehouseName.toUpperCase() + "'," + linebreak
            + timeoutInMinutes.toString() + ", " + linebreak
            + checkpointWaitingTimeInSeconds.toString() + ", " + linebreak
            + "'" + (isSourceOLTP ? tableFileList.data.postingGroupAuditId.join(',').toString() 
				: tableFileList.data.postingGroupAuditId.toString()) + "'," + linebreak
            + "'"+externalStage+"'," + linebreak
			+ (isSourceOLTP ? "true," : "false,") + linebreak
            + "False);"

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
        
		//get postingGroupAuditId
		command = "SELECT MAX(POSTING_GROUP_AUDIT_ID) " + linebreak
			+ "FROM ADM.POSTING_GROUP_INJEST_AUDIT " + linebreak
			+ "WHERE SNAPSHOT_DATE = '" + snapshotDate + "';";
		if(isDebug){
            output.message.push("--get postingGroupAuditId");
            output.message.push(command);
        }else{
            statement = snowflake.createStatement({sqlText:command});
            recordSet = statement.execute();
            if(recordSet.next())
				postingGroupAuditId = recordSet.getColumnValue(1);
		}

        //Check if any Errors when loading from S3 to staging
        command = isSourceOLTP ? ""
			+ "WITH CTE_CONTROL_FILE_PROCESSES AS(" + linebreak
			+ "    SELECT DISTINCT  CF.TARGET_TABLE_NAME" + linebreak
			+ "        ,TCEC.SNAPSHOT_DATE" + linebreak
			+ "        ,TCEC.CUSTOMER_NAME" + linebreak
			+ "    FROM STG_OLTP.TRANSIENT_CURRENT_ETL_ControlFiles TCEC" + linebreak
			+ "    INNER JOIN STG_OLTP.ETL_CONTROLFILES CF" + linebreak
			+ "        ON UPPER(CF.CONTROL_FILE_NAME) LIKE '%'||UPPER(TCEC.CUSTOMER_NAME)||'%'" + linebreak
			+ "        AND DATEDIFF(SECOND, CF.SNAPSHOT_DATE, TCEC.SNAPSHOT_DATE) = 0" + linebreak
			+ ")" + linebreak
			+ "SELECT CF.CUSTOMER_NAME, CF.SNAPSHOT_DATE, COUNT(DISTINCT P.PROCESS_ID) = COUNT(PIA.PROCESS_ID)" + linebreak
			+ "FROM CTE_CONTROL_FILE_PROCESSES CF" + linebreak
			+ "INNER JOIN ADM.CUSTOMER C" + linebreak
			+ "    ON UPPER(CF.CUSTOMER_NAME) = UPPER(C.CUSTOMER_DATABASE)" + linebreak
			+ "INNER JOIN ADM.PROCESS P" + linebreak
			+ "    ON UPPER(P.TARGET_TABLE_NAME) = UPPER(CF.TARGET_TABLE_NAME)" + linebreak
			+ "    AND P.IS_ACTIVE = 'TRUE'" + linebreak
			+ "INNER JOIN ADM_OLTP.POSTING_GROUP_AUDIT PGA" + linebreak
			+ "    ON DATEDIFF(SECOND, PGA.SNAPSHOT_DATE, CF.SNAPSHOT_DATE) = 0" + linebreak
			+ "    AND PGA.CUSTOMER_ID = C.CUSTOMER_ID" + linebreak
			+ "LEFT OUTER JOIN ADM_OLTP.PROCESS_AUDIT PIA" + linebreak
			+ "    ON P.PROCESS_ID = PIA.PROCESS_ID" + linebreak
			+ "    AND PIA.POSTING_GROUP_AUDIT_ID = PGA.POSTING_GROUP_AUDIT_ID" + linebreak
			+ "    AND PIA.STATUS IN ('L','I','FI')" + linebreak
			+ "GROUP BY CF.CUSTOMER_NAME, CF.SNAPSHOT_DATE;"
			
			: "WITH CTE_CONTROL_FILE_PROCESSES AS(" + linebreak
            + " SELECT DISTINCT  TARGET_TABLE_NAME" + linebreak
            + "                 ,SNAPSHOT_DATE" + linebreak
            + " FROM STG.ETL_CONTROLFILES" + linebreak
            + " WHERE SNAPSHOT_DATE = '"+snapshotDate+"'" + linebreak
            + " )" + linebreak
            + " SELECT COUNT(DISTINCT P.PROCESS_ID) = COUNT(PIA.PROCESS_ID)" + linebreak
            + " FROM CTE_CONTROL_FILE_PROCESSES CF" + linebreak
            + " INNER JOIN ADM.PROCESS P" + linebreak
            + "     ON UPPER(P.TARGET_TABLE_NAME) = UPPER(CF.TARGET_TABLE_NAME)" + linebreak
			+ "     AND P.IS_ACTIVE = 'TRUE'" + linebreak
            + " INNER JOIN ADM.POSTING_GROUP_INJEST_AUDIT PGA" + linebreak
            + "     ON PGA.SNAPSHOT_DATE = CF.SNAPSHOT_DATE" + linebreak
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
            if(recordSet.next()) {
                s3ToStgStatus = recordSet.getColumnValue(1);
            } else {
                s3ToStgStatus = false;
            }
        }
       
        // if status is true, all table files were succesfully loaded to staging  
        if (s3ToStgStatus){
            //does ADM.TRANSIENT_STATUS_LOAD_INTO_TARGET exist?
			command = "SELECT " + linebreak
				+ "    CASE " + linebreak
				+ "        WHEN COUNT(1) > 0 THEN TRUE " + linebreak
				+ "        ELSE FALSE " + linebreak
				+ "    END AS TABLE_EXISTS" + linebreak
				+ "FROM INFORMATION_SCHEMA.TABLES" + linebreak
				+ "WHERE TABLE_NAME = 'TRANSIENT_STATUS_LOAD_INTO_TARGET'" + linebreak
				+ "AND TABLE_CATALOG = CURRENT_DATABASE();";
			if(isDebug){
				output.message.push("--does ADM.TRANSIENT_STATUS_LOAD_INTO_TARGET exist?");
				output.message.push(command);
			}else{
				try{
					statement = snowflake.createStatement({sqlText:command});
					recordSet = statement.execute();
					recordSet.next();
					tableExists = recordSet.getColumnValue("TABLE_EXISTS");
				}catch(err){
					output.returnStatus = -1;
					output.rowsAffected = -1;
					output.status = "failed";
					output.message.push(command + ". Error: " + err.message);
				}
			}
			
			if (tableExists) {
				//UPDATE PROCESS_INJEST_AUDIT in case that last run got aborted.
				command = "UPDATE ADM.PROCESS_INJEST_AUDIT PIA" + linebreak
					+ "SET STATUS = B.STATUS," + linebreak
					+ "    TOTAL_RECORDS_LOADED = B.TOTAL_RECORDS_LOADED," + linebreak
					+ "    LAST_CHANGE_DATE = B.UPDATE_DATE" + linebreak
					+ "FROM (" + linebreak
					+ "    SELECT" + linebreak
					+ "        PROCESS_AUDIT_ID," + linebreak
					+ "        STATUS," + linebreak
					+ "        TOTAL_RECORDS_LOADED," + linebreak
					+ "        UPDATE_DATE" + linebreak
					+ "    FROM ADM.TRANSIENT_STATUS_LOAD_INTO_TARGET"
					+ ") B" + linebreak
					+ "WHERE PIA.PROCESS_AUDIT_ID = B.PROCESS_AUDIT_ID" + linebreak
					+ "    AND PIA.STATUS = 'L';";
				if(isDebug){
					output.message.push("--update adm.PROCESS_INJEST_AUDIT in case that last run got aborted.");
					output.message.push(command);
				}else{
					try{
						statement = snowflake.createStatement({sqlText:command});
						recordSet = statement.execute();
						recordSet.next();
					}catch(err){
						output.returnStatus = -1;
						output.rowsAffected = -1;
						output.status = "failed";
						output.message.push(command + ". Error: " + err.message);
					}
				}
			}
			
			//Get all tables and files that need to be copied to target
            command = " WITH CTE as (" + linebreak
                +" SELECT" + linebreak
                +"     PGA.POSTING_GROUP_AUDIT_ID,"   + linebreak
                +"     CF.LOAD_TYPE," + linebreak
                +"     object_construct('targetTableName',P.TARGET_TABLE_NAME) as jsObject" + linebreak
                +" FROM STG.ETL_CONTROLFILES CF" + linebreak
                +" INNER JOIN ADM.PROCESS P" + linebreak
                +" ON UPPER(P.TARGET_TABLE_NAME) = UPPER(CF.TARGET_TABLE_NAME)" + linebreak
                +"     AND P.IS_ACTIVE = 'TRUE'" + linebreak
				+" LEFT OUTER JOIN ADM.POSTING_GROUP_INJEST_AUDIT PGA" + linebreak
                +"     ON PGA.SNAPSHOT_DATE = CF.SNAPSHOT_DATE" + linebreak
				+" LEFT OUTER JOIN ADM.PROCESS_INJEST_AUDIT PA" + linebreak
                +"     ON PGA.POSTING_GROUP_AUDIT_ID = PA.POSTING_GROUP_AUDIT_ID" + linebreak
                +"     AND P.PROCESS_ID = PA.PROCESS_ID" + linebreak
                +"     AND PA.STATUS IN ('L')" + linebreak
                +" WHERE CF.SNAPSHOT_DATE = '"+snapshotDate+"'" + linebreak
                +"     AND PA.POSTING_GROUP_AUDIT_ID IS NOT NULL" + linebreak
                +"     GROUP BY PGA.POSTING_GROUP_AUDIT_ID,CF.LOAD_TYPE,P.TARGET_TABLE_NAME,CF.SNAPSHOT_DATE,P.PROCESS_ID,PA.STATUS" + linebreak
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
                command = "CALL ADM.ETL_LOAD_POSTING_GROUP_INTO_TARGET_MULTITHREAD (" + linebreak
                    + numberOfPipelines.toString() + "," + linebreak
                    + "'" + warehouseName.toUpperCase() + "'," + linebreak
                    + timeoutInMinutes.toString() + ", " + linebreak
                    + checkpointWaitingTimeInSeconds.toString() + ", " + linebreak
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
                + " WHERE SNAPSHOT_DATE = '" + snapshotDate + "'" + linebreak
                + " )" + linebreak
                + " SELECT COUNT(DISTINCT P.PROCESS_ID) = COUNT(PIA.PROCESS_ID)" + linebreak
                + " FROM CTE_CONTROL_FILE_PROCESSES CF" + linebreak
                + " INNER JOIN ADM.PROCESS P" + linebreak
                + "     ON UPPER(P.TARGET_TABLE_NAME) = UPPER(CF.TARGET_TABLE_NAME)" + linebreak
                + "     AND P.IS_ACTIVE = 'TRUE'" + linebreak
				+ " INNER JOIN ADM.POSTING_GROUP_INJEST_AUDIT PGA" + linebreak
                + "		ON PGA.SNAPSHOT_DATE = CF.SNAPSHOT_DATE" + linebreak
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
				if(loadType != "FULL"){
					//clone SRC schema
					currentdate = new Date();
					currentTimestamp = currentdate.getFullYear().toString()
									 + (currentdate.getMonth()+1 < 10? "0":"") + (currentdate.getMonth()+1).toString()
									 + (currentdate.getDate() < 10? "0":"") + currentdate.getDate().toString() + "_"
									 + (currentdate.getHours() < 10? "0":"") + currentdate.getHours().toString()
									 + (currentdate.getMinutes() < 10? "0":"") + currentdate.getMinutes().toString()
									 + (currentdate.getSeconds() < 10? "0":"") + currentdate.getSeconds().toString();
					newSchemaNameForSrc = "SRC_" + currentTimestamp;
					newSchemaNameForRpt = "RPT_" + currentTimestamp;
					command = "create schema " + newSchemaNameForSrc + " clone SRC;";
					if(isDebug){
						output.message.push("--clone SRC schema to " + newSchemaNameForSrc);
						output.message.push(command);
					}else{
						try{
							statement = snowflake.createStatement({sqlText:command});
							statement.execute();
						}catch(err){
							output.returnStatus = -1;
							output.rowsAffected = -1;
							output.status = "failed";
							output.message.push(err.message);
							output.message.push("Error Command: " + command);
							return output;
						}
					}

					//clone RPT schema
					command = "create schema " + newSchemaNameForRpt + " clone RPT;";
					if(isDebug){
						output.message.push("--clone RPT schema to " + newSchemaNameForRpt);
						output.message.push(command);
					}else{
						try{
							statement = snowflake.createStatement({sqlText:command});
							statement.execute();
						}catch(err){
							output.returnStatus = -1;
							output.rowsAffected = -1;
							output.status = "failed";
							output.message.push(err.message);
							output.message.push("Error Command: " + command);
							return output;
						}
					}

					//swap SRC schema
					command = "ALTER SCHEMA SRC SWAP WITH " + newSchemaNameForSrc + ";"
					if(isDebug){
						output.message.push("--swap SRC schema with " + newSchemaNameForSrc);
						output.message.push(command);
					}else{
						try{
							statement = snowflake.createStatement({sqlText:command});
							statement.execute();
						}catch(err){
							output.returnStatus = -1;
							output.rowsAffected = -1;
							output.status = "failed";
							output.message.push(err.message);
							output.message.push("Error Command: " + command);
							return output;
						}
					}

					//swap RPT schema
					command = "ALTER SCHEMA RPT SWAP WITH " + newSchemaNameForRpt + ";"
					if(isDebug){
						output.message.push("--swap RPT schema with " + newSchemaNameForRpt);
						output.message.push(command);
					}else{
						try{
							statement = snowflake.createStatement({sqlText:command});
							statement.execute();
						}catch(err){
							output.returnStatus = -1;
							output.rowsAffected = -1;
							output.status = "failed";
							output.message.push(err.message);
							output.message.push("Error Command: " + command);
							return output;
						}
					}
				}
                
				// bring data online
				command = "CALL ADM.ETL_Bring_Data_Online_Multithread (" + linebreak
                     + numberOfPipelines.toString() + "," + linebreak
                    + "'" + warehouseName.toUpperCase() + "'," + linebreak
                    + timeoutInMinutes.toString() + ", " + linebreak
                    + checkpointWaitingTimeInSeconds.toString() + ", " + linebreak
					+ postingGroupAuditId.toString() + "," + linebreak
                    + "'" + loadType + "'," + linebreak
                    + "'" + currentTimestamp + "'," + linebreak
                    + "False);";
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
                    }
                }
				
                //Check if any Errors when bringing Data Online
                command = "WITH CTE_CONTROL_FILE_PROCESSES AS(" + linebreak
                    + " SELECT DISTINCT  TARGET_TABLE_NAME" + linebreak
                    + "                 ,SNAPSHOT_DATE" + linebreak
                    + " FROM STG.ETL_CONTROLFILES" + linebreak
                    + " WHERE SNAPSHOT_DATE = '" + snapshotDate + "'" + linebreak
                    + " )" + linebreak
                    + " SELECT COUNT(DISTINCT P.PROCESS_ID) = COUNT(PIA.PROCESS_ID)" + linebreak
                    + " FROM CTE_CONTROL_FILE_PROCESSES CF" + linebreak
                    + " INNER JOIN ADM.PROCESS P" + linebreak
                    + "     ON UPPER(P.TARGET_TABLE_NAME) = UPPER(CF.TARGET_TABLE_NAME)" + linebreak
                    + "     AND P.IS_ACTIVE = 'TRUE'" + linebreak
					+ " INNER JOIN ADM.POSTING_GROUP_INJEST_AUDIT PGA" + linebreak
                    + "    ON PGA.SNAPSHOT_DATE = '" + snapshotDate + "'" + linebreak
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
				
				if(loadType != "FULL"){
					if(!dataOnlineStatus){
						//Data not brought online successfully
						output.message.push("--Data not brought online successfully");
						output.message.push(command);

						//clone the schema as a backup to investigate
						command = "create schema " + newSchemaNameForSrc + "_Incomplete clone " + newSchemaNameForSrc + ";";
						if(isDebug){
							output.message.push("--clone " + newSchemaNameForSrc + " schema to " + newSchemaNameForSrc + "_Incomplete.");
							output.message.push(command);
						}else{
							try{
								statement = snowflake.createStatement({sqlText:command});
								statement.execute();
							}catch(err){
								output.returnStatus = -1;
								output.rowsAffected = -1;
								output.status = "failed";
								output.message.push(err.message);
								output.message.push("Error Command: " + command);
								return output;
							}
						}

						command = "create schema " + newSchemaNameForRpt + "_Incomplete clone " + newSchemaNameForRpt + ";";
						if(isDebug){
							output.message.push("--clone " + newSchemaNameForRpt + " schema to " + newSchemaNameForRpt + "_Incomplete.");
							output.message.push(command);
						}else{
							try{
								statement = snowflake.createStatement({sqlText:command});
								statement.execute();
							}catch(err){
								output.returnStatus = -1;
								output.rowsAffected = -1;
								output.status = "failed";
								output.message.push(err.message);
								output.message.push("Error Command: " + command);
								return output;
							}
						}

						command = "create schema ADM_" + currentTimestamp + "_Incomplete clone ADM;";
						if(isDebug){
							output.message.push("--clone ADM schema to ADM_" + currentTimestamp + "_Incomplete.");
							output.message.push(command);
						}else{
							try{
								statement = snowflake.createStatement({sqlText:command});
								statement.execute();
							}catch(err){
								output.returnStatus = -1;
								output.rowsAffected = -1;
								output.status = "failed";
								output.message.push(err.message);
								output.message.push("Error Command: " + command);
								return output;
							}
						}

						//backout the posting group
						command = "CALL adm.Etl_Backout_Posting_Group_Multithread(" 
							+ postingGroupAuditId.toString() + "," + linebreak
							+ numberOfPipelines.toString() + "," + linebreak
							+ "'" + warehouseName.toUpperCase() + "'," + linebreak
							+ timeoutInMinutes.toString() + ", " + linebreak
							+ checkpointWaitingTimeInSeconds.toString() + ", " + linebreak
							+ "'"+newSchemaNameForSrc+"'," + linebreak
							+ "False);";
						if(isDebug){
							output.message.push("--backout the posting group.");
							output.message.push(command);
						}else{
							try{
								statement = snowflake.createStatement({sqlText:command});
								statement.execute();
							}catch(err){
								output.returnStatus = -1;
								output.rowsAffected = -1;
								output.status = "failed";
								output.message.push(err.message);
								output.message.push("Error Command: " + command);
								return output;
							}
						}
					}
					//swap the schema back
					command = "ALTER SCHEMA " + newSchemaNameForSrc + " SWAP WITH SRC;"
					if(isDebug){
						output.message.push("--swap SRC schema with " + newSchemaNameForSrc);
						output.message.push(command);
					}else{
						try{
							statement = snowflake.createStatement({sqlText:command});
							statement.execute();
						}catch(err){
							output.returnStatus = -1;
							output.rowsAffected = -1;
							output.status = "failed";
							output.message.push(err.message);
							output.message.push("Error Command: " + command);
							return output;
						}
					}

					command = "ALTER SCHEMA " + newSchemaNameForRpt + " SWAP WITH RPT;"
					if(isDebug){
						output.message.push("--swap SRC schema with " + newSchemaNameForRpt);
						output.message.push(command);
					}else{
						try{
							statement = snowflake.createStatement({sqlText:command});
							statement.execute();
						}catch(err){
							output.returnStatus = -1;
							output.rowsAffected = -1;
							output.status = "failed";
							output.message.push(err.message);
							output.message.push("Error Command: " + command);
							return output;
						}
					}

					//drop the created schema
					command = "DROP SCHEMA IF EXISTS " + newSchemaNameForSrc + ";"
					if(isDebug){
						output.message.push("--drop the created schema " + newSchemaNameForSrc);
						output.message.push(command);
					}else{
						try{
							statement = snowflake.createStatement({sqlText:command});
							statement.execute();
						}catch(err){
							output.returnStatus = -1;
							output.rowsAffected = -1;
							output.status = "failed";
							output.message.push(err.message);
							output.message.push("Error Command: " + command);
							return output;
						}
					}

					command = "DROP SCHEMA IF EXISTS " + newSchemaNameForRpt + ";"
					if(isDebug){
						output.message.push("--drop the created schema " + newSchemaNameForRpt);
						output.message.push(command);
					}else{
						try{
							statement = snowflake.createStatement({sqlText:command});
							statement.execute();
						}catch(err){
							output.returnStatus = -1;
							output.rowsAffected = -1;
							output.status = "failed";
							output.message.push(err.message);
							output.message.push("Error Command: " + command);
							return output;
						}
					}
				}

				if(!dataOnlineStatus){
					break;
				}
            }else{//Data not copied from stg to src successfully
                output.message.push("--Data not copied from stg to src successfully");
                output.message.push(command);
                break;
            }
        }else{//Data not copies from s3 to stg successfully
            output.message.push("--Data not copies from s3 to stg successfully.");
			output.message.push(isSourceOLTP ? "--Please confirm the replication process finished first." : "");
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

