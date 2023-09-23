CREATE OR REPLACE PROCEDURE adm.ETL_LOAD_POSTING_GROUP_INTO_TARGET_Multithread(
    "numberOfPipelines" FLOAT,
    "warehouseName" STRING,
    "timeoutInMinutes" FLOAT,
    "checkpointWaitingTimeInSeconds" FLOAT,
    "jsonTables" STRING, -- output.data, get it from sproc #2.
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
    let commands = [];
    let statement;
    let recordSet;
    let targetTableName;
    let injestTypeId;
    let taskNames = [];
    let pipeline = [];
    let taskNamePattern = "etl_stgtosrc_";
    taskNamePattern = taskNamePattern.toUpperCase();
    let suspendedTaskName = "";

    let linebreak = "\r\n";
    
    numberOfPipelines = Number(numberOfPipelines);
    timeoutInMinutes = Number(timeoutInMinutes);
    checkpointWaitingTimeInSeconds = Number(checkpointWaitingTimeInSeconds);
    let jsonTablesPipeline = JSON.parse(jsonTables);
    jsonTables = JSON.parse(jsonTables);
    
    injestTypeId = jsonTables.loadType == 'FULL'? 0 : 1;
 
    let postingGroupAuditId = jsonTables.postingGroupAuditId;
    
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
			return output;
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

	//create transient table to hold status for each table per current PG
	command = "CREATE OR REPLACE TRANSIENT TABLE ADM.TRANSIENT_STATUS_LOAD_INTO_TARGET " + linebreak
        + "AS SELECT " + linebreak
		+ "    PROCESS_AUDIT_ID, " + linebreak
		+ "    STATUS, " + linebreak
		+ "    TOTAL_RECORDS_LOADED, " + linebreak
		+ "    UPDATE_DATE " + linebreak
		+ "FROM ADM.PROCESS_INJEST_AUDIT " + linebreak
        + "WHERE 1 = 0;";
    if(isDebug){
        output.message.push("--create transient table to hold status for each table per current PG");
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

    for(let i = 0; i < numberOfPipelines; i++){
        pipeline[i] = Math.floor(jsonTables.tableData.length / numberOfPipelines);
    }
    
    for(let i = 0; i < jsonTables.tableData.length % numberOfPipelines; i++){
        pipeline[i] += 1;
    }
    
    for(let i = 0, j = 0; i < jsonTables.tableData.length; i += pipeline[j++]){
        jsonTablesPipeline.tableData = jsonTables.tableData.slice(i, i + pipeline[j]);
        
        //initiate task name list.
        taskNames.push("'" + taskNamePattern + (j+1).toString() + "'");
        
        //build command.
        command = "CALL ADM.ETL_LOAD_POSTING_GROUP_INTO_TARGET (" + linebreak
            + "'"+JSON.stringify(jsonTablesPipeline)+"'," + linebreak
            + "False)";
            
        //CREATE TASK.
        command = "CREATE OR REPLACE TASK stg." + taskNamePattern + (j+1).toString() + linebreak
            + "  WAREHOUSE = " + warehouseName + linebreak 
            + "  SCHEDULE = '1 minute' " + linebreak 
            + "  USER_TASK_TIMEOUT_MS = " + (timeoutInMinutes * 60 * 1000).toString() + linebreak 
            + "AS " + linebreak
            + "CALL adm.executeTaskThenSuspend('" + command.replace(/'/g,"''") + "','" + taskNamePattern + (j+1).toString() + "',false);";
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
        command = "ALTER TASK stg." + taskNamePattern + (j+1).toString() + " RESUME; ";
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
    
	//Update ADM.PROCESS_INJEST_AUDIT
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
		+ "WHERE PIA.PROCESS_AUDIT_ID = B.PROCESS_AUDIT_ID";
	if(isDebug){
        output.message.push("--update adm.PROCESS_INJEST_AUDIT.");
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
                output.message.push(command + ". Error: " + recordSet.getColumnValue(1).message);
            }
        }catch(err){
            output.returnStatus = -1;
            output.rowsAffected = -1;
            output.status = "failed";
            output.message.push(command + ". Error: " + err.message);
        }
    }

    //any task failed?
    command = "SHOW TASKS LIKE '%" + taskNamePattern + "%' in STG; ";
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
              || Number(recordSet.getColumnValue(3)) != Math.min(numberOfPipelines,jsonTables.tableData.length) //not all tasks succeeded
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