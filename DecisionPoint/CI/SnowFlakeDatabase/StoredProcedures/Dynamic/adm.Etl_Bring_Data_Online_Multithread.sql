CREATE OR REPLACE PROCEDURE adm.ETL_Bring_Data_Online_Multithread(
  "numberOfPipelines" FLOAT,
  "warehouseName" STRING,
  "timeoutInMinutes" FLOAT,
  "checkpointWaitingTimeInSeconds" FLOAT,
  "postingGroupAuditId" FLOAT,
  "loadType" STRING,
  "timestampInTargetSchemaName" STRING,
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
    let statement;
    let recordSet;
    let linebreak = "\r\n";
    let tab = "\t";
    let taskNames = [];
    let taskNamePattern = "etl_bringDataOnline_";
    taskNamePattern = taskNamePattern.toUpperCase();
    warehouseName = warehouseName.toUpperCase();
    loadType = loadType.toUpperCase();
    timestampInTargetSchemaName = (timestampInTargetSchemaName.trim().length == 0 ? "" : "_" + timestampInTargetSchemaName);

    let previousCutoffPostingGroupauditId = -1;
    let targetTableNames = "";
    let tmptargetTableNames = "";
    let pipeline = [];
    let suspendedTaskName = "";
	let tableExists = false;
    
    postingGroupAuditId = Number(postingGroupAuditId);
    numberOfPipelines = Number(numberOfPipelines);
    timeoutInMinutes = Number(timeoutInMinutes);
    checkpointWaitingTimeInSeconds = Number(checkpointWaitingTimeInSeconds);
    
    //cleanup all suspended tasks with correct taskNamePattern
    command = "SHOW TASKS LIKE '%" + taskNamePattern + "%' in STG; ";
    if(isDebug){
        output.message.push("--cleanup all suspended tasks with correct taskNamePattern");
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
    
    command = "SELECT listagg(case when \"state\" = 'started' then \"schema_name\"||'.'||\"name\" else null end,',') as runningTaskName, " + linebreak
        + "    listagg(case when \"state\" = 'suspended' then \"schema_name\"||'.'||\"name\" else null end,',') as suspendedTaskName " + linebreak
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
    }
	//does ADM.TRANSIENT_STATUS_BRING_DATA_ONLINE exist?
	command = "SELECT " + linebreak
		+ "    CASE " + linebreak
		+ "        WHEN COUNT(1) > 0 THEN TRUE " + linebreak
		+ "        ELSE FALSE " + linebreak
		+ "    END AS TABLE_EXISTS" + linebreak
		+ "FROM INFORMATION_SCHEMA.TABLES" + linebreak
		+ "WHERE TABLE_NAME = 'TRANSIENT_STATUS_BRING_DATA_ONLINE'" + linebreak
		+ "AND TABLE_CATALOG = CURRENT_DATABASE();";
	if(isDebug){
        output.message.push("--does ADM.TRANSIENT_STATUS_BRING_DATA_ONLINE exist?");
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
			+ "    TOTAL_RECORDS_UPDATED = B.TOTAL_RECORDS_UPDATED," + linebreak
			+ "    UPDATE_DATE = B.UPDATE_DATE," + linebreak
			+ "    LAST_CHANGE_DATE = B.UPDATE_DATE" + linebreak
			+ "FROM (" + linebreak
			+ "    SELECT" + linebreak
			+ "        PROCESS_AUDIT_ID," + linebreak
			+ "        STATUS," + linebreak
			+ "        TOTAL_RECORDS_UPDATED," + linebreak
			+ "        UPDATE_DATE" + linebreak
			+ "    FROM ADM.TRANSIENT_STATUS_BRING_DATA_ONLINE"
			+ ") B" + linebreak
			+ "WHERE PIA.PROCESS_AUDIT_ID = B.PROCESS_AUDIT_ID" + linebreak
			+ "    AND PIA.STATUS = 'I';";
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

    //get list of table names
    command = "SELECT listagg(upper(TARGET_SCHEMA_NAME||'" +timestampInTargetSchemaName+ "')||'.'||upper(target_Table_name),',')" + linebreak
        + "FROM adm.process p" + linebreak
        + "INNER JOIN ADM.PROCESS_INJEST_AUDIT PIA" + linebreak
        + "    ON PIA.PROCESS_ID = P.PROCESS_ID " + linebreak
        + "    AND P.IS_ACTIVE = 'TRUE'" + linebreak
        + "WHERE PIA.POSTING_GROUP_AUDIT_ID = " + postingGroupAuditId.toString() + linebreak
        + "AND PIA.STATUS = 'I' ;";
    if(isDebug){
        output.message.push("--get list of table names");
        output.message.push(command);
    }else{
        try{
            statement = snowflake.createStatement({sqlText:command});
            recordSet = statement.execute();
            if(recordSet.next()){
                targetTableNames = recordSet.getColumnValue(1);
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
    
	//create transient table to hold status for each table per current PG
	command = "CREATE OR REPLACE TRANSIENT TABLE ADM.TRANSIENT_STATUS_BRING_DATA_ONLINE " + linebreak
        + "AS SELECT " + linebreak
		+ "    PROCESS_AUDIT_ID, " + linebreak
		+ "    STATUS, " + linebreak
		+ "    TOTAL_RECORDS_UPDATED, " + linebreak
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

    targetTableNames = targetTableNames.split(",");
    
    for(let i = 0; i < numberOfPipelines; i++){
        pipeline[i] = Math.floor(targetTableNames.length / numberOfPipelines);
    }
    
    for(let i = 0; i < targetTableNames.length % numberOfPipelines; i++){
        pipeline[i] += 1;
    }
    
    for(let i = 0, j = 0; i < targetTableNames.length; i += pipeline[j++]){
        tmptargetTableNames = targetTableNames.slice(i, i + pipeline[j]).join(",");
        
        //initiate task name list.
        taskNames.push("'" + taskNamePattern + (j+1).toString() + "'");
        
        //build command.
        command = "call adm.ETL_Bring_Data_Online(" + linebreak
            + postingGroupAuditId.toString() + "," + linebreak
            + "'" + loadType + "'," + linebreak
            + "'" + tmptargetTableNames + "'," + linebreak
            + "false);";
        
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
		+ "    TOTAL_RECORDS_UPDATED = B.TOTAL_RECORDS_UPDATED," + linebreak
		+ "    UPDATE_DATE = B.UPDATE_DATE," + linebreak
		+ "    LAST_CHANGE_DATE = B.UPDATE_DATE" + linebreak
		+ "FROM (" + linebreak
		+ "    SELECT" + linebreak
		+ "        PROCESS_AUDIT_ID," + linebreak
		+ "        STATUS," + linebreak
		+ "        TOTAL_RECORDS_UPDATED," + linebreak
		+ "        UPDATE_DATE" + linebreak
		+ "    FROM ADM.TRANSIENT_STATUS_BRING_DATA_ONLINE"
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
			return output;
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
              || Number(recordSet.getColumnValue(3)) != Math.min(numberOfPipelines,targetTableNames.length) //not all tasks succeeded
              ){
                output.returnStatus = -1;
                output.rowsAffected = -1;
                output.status = "failed";
                output.message.push(recordSet.getColumnValue(2));
                output.message.push("failedJobCount: " + recordSet.getColumnValue(1).toString());
                output.message.push("succeededJobCount: " + recordSet.getColumnValue(3));
                output.message.push("Error Command: " + command);
				return output;
            }
        }catch(err){
            output.returnStatus = -1;
            output.rowsAffected = -1;
            output.status = "failed";
            output.message.push(err.message);
            output.message.push("failedJobCount: " + recordSet.getColumnValue(1).toString());
            output.message.push("succeededJobCount: " + recordSet.getColumnValue(3));
            output.message.push("Error Command: " + command);
			return output;
        }
    }
    
    //Update adm.posting_group_injest_audit
    command = "UPDATE ADM.POSTING_GROUP_INJEST_AUDIT" + linebreak
		+ "SET STATUS = 'FI', " + linebreak
		+ "    LAST_CHANGE_DATE = CURRENT_TIMESTAMP() " + linebreak
		+ "WHERE POSTING_GROUP_AUDIT_ID = " + postingGroupAuditId.toString() + linebreak
		+ "AND STATUS != 'FI'; ";
	if(isDebug){
        output.message.push("--update adm.posting_group_injest_audit.");
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
    
    if(isDebug){
        output.returnStatus = 0;
        output.status = "debug";
    }else if(output.returnStatus != -1){
        output.status = "succeeded";
    }
    
    return output;
$$;