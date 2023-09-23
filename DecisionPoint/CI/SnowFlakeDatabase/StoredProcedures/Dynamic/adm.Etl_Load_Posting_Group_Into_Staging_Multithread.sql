CREATE OR REPLACE PROCEDURE adm.ETL_LOAD_POSTING_GROUP_INTO_STAGING_multithread(
    "numberOfPipelines" FLOAT,
    "warehouseName" STRING,
    "timeoutInMinutes" FLOAT,
    "checkpointWaitingTimeInSeconds" FLOAT,
    "postingGroupAuditId" STRING, -- output.data, get it from sproc #2.
    "externalStage" STRING, --= 'ACSODS_DEV.STG.@DEV_ETL',
    "isSourceOLTP" BOOLEAN, 
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
        status: "not executed",
        message: []
    };
    
    let command;
    let statement;
    let recordSet;
    let taskNames = [];
    let taskNamePattern = "etl_s3tostg_";
    taskNamePattern = taskNamePattern.toUpperCase();
    
    let linebreak = "\r\n";
    let tab = "\t";
    
    numberOfPipelines = Number(numberOfPipelines);
    timeoutInMinutes = Number(timeoutInMinutes);
    checkpointWaitingTimeInSeconds = Number(checkpointWaitingTimeInSeconds);
    let jsonTablesPipeline = [];
    //postingGroupAuditId = Number(postingGroupAuditId);
        
    let processAuditId = "";
    let auditTableData = "";
    let totalRecodsLoaded = 0;
    let suspendedTaskName = "";
	let actualNumberOfPipelines = -1;
	let fileFolder = "";
        
    let temporary;
    let pipeline = [];

    let tbl_ProcessFileAudit = isSourceOLTP ? "ADM_OLTP.PROCESS_File_AUDIT" : "ADM.PROCESS_File_AUDIT";
    let tbl_ProcessAudit = isSourceOLTP ? "ADM_OLTP.PROCESS_AUDIT" : "ADM.PROCESS_INJEST_AUDIT";
    let tbl_PostingGroupAudit = isSourceOLTP ? "ADM_OLTP.POSTING_GROUP_AUDIT" : "ADM.POSTING_GROUP_INJEST_AUDIT";
    let tbl_tmp_LatestProcessAudit = isSourceOLTP ? "ADM_OLTP.TMP_LATEST_PROCESS_AUDIT" : "ADM.TMP_LATEST_PROCESS_AUDIT";
    
    //cleanup all suspended tasks with correct taskNamePattern
    command = "SHOW TASKS LIKE '%" + taskNamePattern + "%' in STG; ";
    if(isDebug){
        output.message.push("--cleanup all suspended tasks with correct taskNamePattern");
        output.message.push(command);
    }else{
        try{
            statement = snowflake.createStatement({sqlText:command});
            recordSet = statement.execute();
        }catch(err){
            output.returnStatus = -1;
            output.rowsAffected = -1;
            output.status = "failed";
            output.message.push(err.message);
            output.message.push("Error Command: " + command);
        }
    }
    
    command = "SELECT listagg(case when \"state\" = 'started' then \"schema_name\"||'.'||\"name\" else null end,',') as runningTaskName, " + linebreak
        + "listagg(case when \"state\" = 'suspended' then \"schema_name\"||'.'||\"name\" else null end,',') as suspendedTaskName " + linebreak
        + "FROM table(result_scan(last_query_id())) ";    
    if(isDebug){
        output.message.push(command);
    }else{
        try{
            statement = snowflake.createStatement({sqlText:command});
            recordSet = statement.execute();
            if(recordSet.next()){
                if(recordSet.getColumnValue(1).length > 0){
                    output.returnStatus = -1;
                    output.rowsAffected = -1;
                    output.status = "failed";
                    output.message.push("Following tasks are currently running: \r\n\t" + recordSet.getColumnValue(1) + "\r\nPlease try again later.");
                    return output;
                }
                suspendedTaskName = recordSet.getColumnValue(2);
            }
        }catch(err){
            output.returnStatus = -1;
            output.rowsAffected = -1;
            output.status = "failed";
            output.message.push(err.message);
            output.message.push("Error Command: " + command);
            return output;
        }
    }
    
    if(suspendedTaskName.length > 0){
        suspendedTaskName = suspendedTaskName.split(",");
        for(let i = 0; i < suspendedTaskName.length; i++){
            command = "drop task " + suspendedTaskName[i] + ";";
            if(isDebug){
                output.message.push(command);
            }else{
                try{
                    statement = snowflake.createStatement({sqlText:command});
                    recordSet = statement.execute();
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
    }

	//truncate stg tables and balance the load
	command = "CALL ADM.ETL_LOAD_BALANCER(" + linebreak
		+ numberOfPipelines.toString() + "," + linebreak
		+ "'" + postingGroupAuditId + "'," + linebreak
		+ "'" + externalStage + "'," + linebreak
        + "true," + linebreak
        + (isSourceOLTP ? "true," : "false,") + linebreak
		+ "false" + linebreak
		+ ");";
	if(isDebug){
        output.message.push("--balance the load");
        output.message.push(command);
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
			jsonTablesPipeline = recordSet.getColumnValue(1).data;
        }catch(err){
            output.returnStatus = -1;
            output.rowsAffected = -1;
            output.status = "failed";
            output.message.push(err.message);
            output.message.push("Error Command: " + command);
			return output;
        }
    }

	pipeline = jsonTablesPipeline.tableData;
	actualNumberOfPipelines = jsonTablesPipeline.actualNumberOfPipelines;

	//get folder Name
	command = "ls " + externalStage;
	if(isDebug){
        output.message.push("--get folder Name");
        output.message.push(command);
    }else {
		try{
			statement = snowflake.createStatement({sqlText: command});
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

	//dynamically get folder name
	command = " select distinct strtok(\"name\",'/',(Array_size(strtok_to_array(\"name\",'/')))-1) as folderName" + linebreak
		+ " from table(result_scan(last_query_id()))" + linebreak
		+ " where strtok(\"name\",'/',(Array_size(strtok_to_array(\"name\",'/')))) in ('" + pipeline[0].tableData[0].tableFiles[0].fileName + "')" + linebreak
		+ " order by folderName Desc" + linebreak
		+ " limit 1;";
	if(isDebug){
        output.message.push(command);
    }else {
		try{
			statement = snowflake.createStatement({sqlText: command});
            recordSet = statement.execute();
			if(recordSet.next())
				fileFolder = recordSet.getColumnValue(1);
		}catch(err){
			output.returnStatus = -1;
            output.rowsAffected = -1;
            output.status = "failed";
            output.message.push(err.message);   
			output.message.push("Error Command: " + command);
            return output;
		}
	}

	for(let i = 0; i < pipeline.length; i++){
        //initiate task name list.
        taskNames.push("'" + taskNamePattern + (i+1).toString() + "'");
        
        //build command.
        command = "CALL adm.ETL_LOAD_POSTING_GROUP_INTO_STAGING(" + linebreak
            + "'" + JSON.stringify(pipeline[i]) + "'," + linebreak
            + "'" + externalStage + "'," + linebreak
			+ "'" + fileFolder + "'," + linebreak
            + (isSourceOLTP ? "true," : "false,") + linebreak
            + "false" + linebreak
            + ");";
        
        //CREATE TASK.
        command = "CREATE OR REPLACE TASK stg." + taskNamePattern + (i+1).toString() + linebreak
            + "  WAREHOUSE = " + warehouseName + linebreak 
            + "  SCHEDULE = '1 minute' " + linebreak 
            + "  USER_TASK_TIMEOUT_MS = " + (timeoutInMinutes * 60 * 1000).toString() + linebreak 
            + "AS " + linebreak
            + "CALL adm.executeTaskThenSuspend('" + command.replace(/'/g,"''") + "','" + taskNamePattern + (i+1).toString() + "',false);";
        if(isDebug){
            output.message.push("--Create Tasks.");
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
                output.message.push(err.message);
                output.message.push("Error Command: " + command);
                continue;
            }
        }
        
        //resume it.
        command = "ALTER TASK stg." + taskNamePattern + (i+1).toString() + " RESUME; ";
        if(isDebug){
            output.message.push("--Resume Tasks.");
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
                output.message.push(err.message);
                output.message.push("Error Command: " + command);
                continue;
            }
        }
    }
    
	//checkpoint, are all tasks done?
    while(true){
        command = "SHOW TASKS LIKE '%" + taskNamePattern + "%' in STG; ";
        if(isDebug){
            output.message.push("--checkpoint, are all tasks done?");
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
                output.message.push(err.message);
                output.message.push("Error Command: " + command);
            }
        }
    
        command = "select \"name\" as taskName " + linebreak
            + "from table(result_scan(last_query_id())) " + linebreak
            + "where \"state\" = 'started';";
            
        if(isDebug){
            output.message.push("--Checkpoint, are all tasks done?");
            output.message.push(command);
        }else{
            try{
                statement = snowflake.createStatement({sqlText:command});
                recordSet = statement.execute();
            }catch(err){
                output.returnStatus = -1;
                output.rowsAffected = -1;
                output.status = "failed";
                output.message.push(err.message);
                output.message.push("Error Command: " + command);
            }
        }
        
        //Wait for <checkpointWaitingTimeInSeconds> seconds
        command = "call system$wait(" + checkpointWaitingTimeInSeconds.toString() + ");";
        if(isDebug){
            output.message.push("--Wait for seconds");
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
            }
        }
        
        if(isDebug || !recordSet.next())
            break;
    }
    
    //any task failed?
    command = "SHOW TASKS LIKE '%" + taskNamePattern + "%'  in STG; ";
    if(isDebug){
        output.message.push("--Show Tasks for Checking Any Tasks Failed");
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
            output.message.push(err.message);
            output.message.push("Error Command: " + command);
        }
    }
    
    command = " select " + linebreak
        + "   count(case when STATE != 'SUCCEEDED' OR IFNULL(RETURN_VALUE,'') != '' then 1 else null end) as failedJobCount," + linebreak 
        + "   array_agg(distinct (case when STATE != 'SUCCEEDED' " + linebreak 
        + "                       then 'Job Name: ' || DATABASE_NAME || '.' || SCHEMA_NAME || '.' || NAME " + linebreak 
        + "                           || ';\r\n Job Status: ' || STATE " + linebreak 
        + "                           || ';\r\n Error Message: ' || ERROR_MESSAGE " + linebreak 
        + "                       when RETURN_VALUE != '' " + linebreak 
        + "                       then 'Job Name: ' || DATABASE_NAME || '.' || SCHEMA_NAME || '.' || NAME " + linebreak 
        + "                           || ';\r\n Job Status: ' || STATE " + linebreak 
        + "                           || ';\r\n Error Message: ' || RETURN_VALUE " + linebreak 
        + "                       else null end)) as errorMessage," + linebreak 
        + "   count(case when STATE = 'SUCCEEDED' and IFNULL(RETURN_VALUE,'') = '' then 1 else null end) as succeededJobCount" + linebreak 
        + " from table(information_schema.task_history()) A" + linebreak 
        + " INNER JOIN TABLE(RESULT_SCAN(LAST_QUERY_ID())) B" + linebreak
        + " ON A.root_task_id = B.\"id\"" + linebreak
        + " where NAME in (" + taskNames.join(",") + ");";
    
    if(isDebug){
        output.message.push("--Check if all tasks succeeded.");
        output.message.push(command);
    }else{
        try{
            statement = snowflake.createStatement({sqlText:command});
            recordSet = statement.execute();
            recordSet.next();
            if(recordSet.getColumnValue(1) != 0     //1 or more tasks failed.
              || Number(recordSet.getColumnValue(3)) != Math.min(actualNumberOfPipelines,jsonTablesPipeline.totalTableNumber) //not all tasks succeeded
              ){
                output.returnStatus = -1;
                output.rowsAffected = -1;
                output.status = "failed";
                output.message.push(recordSet.getColumnValue(2));
                output.message.push("failedJobCount: " + recordSet.getColumnValue(1).toString());
                output.message.push("succeededJobCount: " + recordSet.getColumnValue(3));
                output.message.push("Error Command: " + command);
            }
        }catch(err){
            output.returnStatus = -1;
            output.rowsAffected = -1;
            output.status = "failed";
            output.message.push(err.message);
            output.message.push("failedJobCount: " + recordSet.getColumnValue(1).toString());
            output.message.push("succeededJobCount: " + recordSet.getColumnValue(3));
            output.message.push("Error Command: " + command);
        }
    }

	//CREATE TEMPORARY TABLE TO HOLD LATEST PROCESSAUDITIDs.
	command = "CREATE OR REPLACE TEMPORARY TABLE " + tbl_tmp_LatestProcessAudit + " AS " + linebreak
		+ "SELECT MAX(PROCESS_AUDIT_ID) AS PROCESS_AUDIT_ID " + linebreak
		+ "FROM " + tbl_ProcessAudit + linebreak
		+ "WHERE POSTING_GROUP_AUDIT_ID IN (" + postingGroupAuditId + ")" + linebreak
		+ "GROUP BY POSTING_GROUP_AUDIT_ID, PROCESS_ID;";
	if(isDebug){
        output.message.push("--CREATE TEMPRARY TABLE TO HOLD LATEST PROCESSAUDITIDs.");
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
        }
    }

	//everything looks good, lets update process_injest_audit with status 'L'
	command = "UPDATE " + tbl_ProcessAudit + " PIA " + linebreak
		+ "SET  " + linebreak
		+ (isSourceOLTP ? "    EXTRACT_ROW_COUNT = B.TOTAL_RECORDS_EXTRACTED, " + linebreak
                        : "    TOTAL_RECORDS_EXTRACTED = B.TOTAL_RECORDS_EXTRACTED, " + linebreak)
        + "    STATUS = 'L', " + linebreak
		+ "    LOAD_DATE = CURRENT_TIMESTAMP(), " + linebreak
		+ "    LAST_CHANGE_DATE = CURRENT_TIMESTAMP() " + linebreak
		+ "FROM ( " + linebreak
		+ "    SELECT PIA.PROCESS_AUDIT_ID, " + linebreak
		+ "        SUM(PFA.TOTAL_RECORDS_EXTRACTED) TOTAL_RECORDS_EXTRACTED, " + linebreak
		+ "        SUM(CASE WHEN PFA.status = 'FI' THEN 0 ELSE 1 END) AS ERROR_COUNT, " + linebreak
		+ "        SUM(CASE WHEN PFA.TOTAL_RECORDS_IN_FILE = PFA.TOTAL_RECORDS_EXTRACTED " + linebreak
		+ "            THEN 0 ELSE 1 END) AS UNMATCHED_FILE_COUNT " + linebreak
		+ "    FROM " + tbl_tmp_LatestProcessAudit + " PIA " + linebreak
		+ "    INNER JOIN " + tbl_ProcessFileAudit + " PFA " + linebreak
		+ "        ON PIA.PROCESS_AUDIT_ID = PFA.PROCESS_AUDIT_ID " + linebreak
		+ "    GROUP BY PIA.PROCESS_AUDIT_ID " + linebreak
		+ ") B " + linebreak
		+ "WHERE PIA.PROCESS_AUDIT_ID = B.PROCESS_AUDIT_ID " + linebreak
		+ "    AND B.ERROR_COUNT + B.UNMATCHED_FILE_COUNT = 0;";
    if(isDebug){
        output.message.push("--everything looks good, lets update process_injest_audit with status 'L'");
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
        }
    }
	
    if(isDebug){
        output.returnStatus = 0;
        output.rowsAffected = -1;
        output.status = "debug";
    }else if(output.returnStatus != -1){
        output.rowsAffected = -1;
        output.status = "succeeded";
    }
    
    return output;

$$;

