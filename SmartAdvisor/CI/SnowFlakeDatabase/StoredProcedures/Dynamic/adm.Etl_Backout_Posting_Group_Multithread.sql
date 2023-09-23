CREATE OR REPLACE PROCEDURE adm.Etl_Backout_Posting_Group_Multithread(
    "postingGroupAuditId" FLOAT,
    "numberOfPipelines" FLOAT,
    "warehouseName" STRING,
    "timeoutInMinutes" FLOAT,
    "checkpointWaitingTimeInSeconds" FLOAT,
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
    let taskNamePattern = "etl_backoutSrc_";
    taskNamePattern = taskNamePattern.toUpperCase();
    warehouseName = warehouseName.toUpperCase();
	timestampInTargetSchemaName = (timestampInTargetSchemaName.trim().length == 0 ? "" : "_" + timestampInTargetSchemaName);
    
    let previousCutoffPostingGroupauditId = -1;
    let tableNames = "";
    let tmpTableNames = "";
    let pipeline = [];
    let suspendedTaskName = "";
    
    postingGroupAuditId = Number(postingGroupAuditId);
    numberOfPipelines = Number(numberOfPipelines);
    timeoutInMinutes = Number(timeoutInMinutes);
    checkpointWaitingTimeInSeconds = Number(checkpointWaitingTimeInSeconds);
    
    //get previous cutoff posting group audit id
    command = "SELECT IFNULL((SELECT POSTING_GROUP_AUDIT_ID "
        + "FROM ADM.POSTING_GROUP_INJEST_AUDIT " + linebreak
        + "WHERE POSTING_GROUP_AUDIT_ID = " + postingGroupAuditId.toString() + "),-1) AS PGAID," + linebreak
        + "(SELECT ODS_CUTOFF_POSTING_GROUP_AUDIT_ID AS CPGAID "
        + " FROM ADM.POSTING_GROUP_INJEST_AUDIT " + linebreak
        + " WHERE POSTING_GROUP_AUDIT_ID < " + postingGroupAuditId.toString() + linebreak
        + " ORDER BY POSTING_GROUP_AUDIT_ID DESC LIMIT 1) AS previousCutoffPGAID";
    if(isDebug){
        output.message.push("--get previous cutoff posting group audit id.");
        output.message.push(command);
    }else{
        try{
            statement = snowflake.createStatement({sqlText:command});
            recordSet = statement.execute(); 
            if(recordSet.next()){
                postingGroupAuditId = recordSet.getColumnValue(1);
                previousCutoffPostingGroupauditId = recordSet.getColumnValue(2);
            }
            if(postingGroupAuditId == -1){
                output.returnStatus = -1;
                output.rowsAffected = -1;
                output.status = "failed";
                output.message.push("Given posting group is invalid.");
                return output;
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
            statement.execute();
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
    
    //get list of table names
    command = "select listagg(upper(TARGET_SCHEMA_NAME||'" + timestampInTargetSchemaName + "')||'.'||upper(target_Table_name),',')" + linebreak
        + "from adm.process where is_active = 'true';";
    if(isDebug){
        output.message.push("--get list of table names");
        output.message.push(command);
    }else{
        try{
            statement = snowflake.createStatement({sqlText:command});
            recordSet = statement.execute();
            if(recordSet.next()){
                tableNames = recordSet.getColumnValue(1);
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
    
    tableNames = tableNames.split(",");
    
    for(let i = 0; i < numberOfPipelines; i++){
        pipeline[i] = Math.floor(tableNames.length / numberOfPipelines);
    }
    
    for(let i = 0; i < tableNames.length % numberOfPipelines; i++){
        pipeline[i] += 1;
    }
    
    for(let i = 0, j = 0; i < tableNames.length; i += pipeline[j++]){
        tmpTableNames = tableNames.slice(i, i + pipeline[j]).join(",");
        
        //initiate task name list.
        taskNames.push("'" + taskNamePattern + (j+1).toString() + "'");
        
        //build command.
        command = "CALL adm.Etl_Backout_Posting_Group_By_Delete(" + linebreak
            + postingGroupAuditId.toString() + "," + linebreak
            + previousCutoffPostingGroupauditId.toString() + "," + linebreak
            + "'" + tmpTableNames + "'," + linebreak
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
				return output;
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
				return output;
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
				return output;
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
              || Number(recordSet.getColumnValue(3)) != Math.min(numberOfPipelines,tableNames.length) //not all tasks succeeded
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
    
    //back out the admin tables.
    //back out from process_file_audit
    command = ""
        + " delete from adm.process_File_audit pfa" + linebreak
        + " using(" + linebreak
        + "     select process_audit_id" + linebreak
        + "     from adm.process_injest_audit " + linebreak
        + "     where posting_group_audit_id >= " + postingGroupAuditId.toString() + ") b" + linebreak
        + " where pfa.process_audit_id = b.process_audit_id;";
    if(isDebug){
        output.message.push("--back out from process_file_audit");
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
    
    //back out from process_injest_audit
    command = ""
        + " delete from adm.process_injest_audit " + linebreak
        + " where posting_group_audit_id >= " + postingGroupAuditId.toString() + ";";
    if(isDebug){
        output.message.push("--back out from process_injest_audit");
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
    
    //back out from posting_group_injest_audit
    command = ""
        + " delete from adm.posting_group_injest_audit" + linebreak
        + " where posting_group_audit_id >= " + postingGroupAuditId.toString() + ";";
    if(isDebug){
        output.message.push("--back out from posting_group_injest_audit");
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
    
    if(isDebug){
        output.returnStatus = 0;
        output.status = "debug";
    }else if(output.returnStatus != -1){
        output.status = "succeeded";
    }
    
    return output;
$$;