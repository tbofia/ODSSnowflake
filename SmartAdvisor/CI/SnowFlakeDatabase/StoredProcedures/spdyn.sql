CREATE OR REPLACE PROCEDURE ADM.DropConstraints("constraintType" VARCHAR)
RETURNS STRING
LANGUAGE JAVASCRIPT
AS
$$
    let cmd, stmt, rs;
    let linebreak = "\r\n";
    try{
        cmd = "SELECT 'ALTER TABLE '||TABLE_SCHEMA||'.'||TABLE_NAME||' DROP CONSTRAINT \"'||CONSTRAINT_NAME||'\";'" + linebreak
            + "FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS" + linebreak
            + "WHERE CONSTRAINT_TYPE = '" + constraintType.toUpperCase() + "';";
        stmt = snowflake.createStatement({sqlText:cmd});
        rs = stmt.execute();

        while(rs.next()){
            cmd = rs.getColumnValue(1);
            stmt = snowflake.createStatement({sqlText:cmd});
            try{
				stmt.execute();
			}catch(err){
				cmd = "";
			}
        }
        return "All foreign keys have successfully dropped.";
    }catch(err){
        return "Failed to drop foreign keys. " + err.message;
    }
$$;

CREATE OR REPLACE PROCEDURE adm.Etl_Backout_Posting_Group(
 "postingGroupAuditId" FLOAT,
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
        message: ""
    }
    
    let command;
    let arrayCommands = [];
    let statement;
    let recordSet;
    let linebreak = "\r\n";
    let tab = "\t";
    let lastChangeDate;
    let localTimeZone = "America/Los_Angeles";
    let localTimestamp;
    let schemaCreateDate;
    let schemaNames = ['RPT','ADM','SRC'];
       
    postingGroupAuditId = Number(postingGroupAuditId);
    
    //get schemaCreateDate
    command = "SHOW SCHEMAS LIKE 'ADM';";
    if(isDebug){
        arrayCommands.push("--get schemaCreateDate");
        arrayCommands.push(command);
        statement = snowflake.createStatement({sqlText:command});
        recordSet = statement.execute();
        recordSet.next();
    }else{
        statement = snowflake.createStatement({sqlText:command});
        recordSet = statement.execute();
        recordSet.next();
    }
    
    command = "SELECT \"created_on\"::timestamp_ntz" + linebreak
            + "FROM TABLE(RESULT_SCAN(LAST_QUERY_ID()));";
    if(isDebug){
        arrayCommands.push("--get schemaCreateDate");
        arrayCommands.push(command);
        statement = snowflake.createStatement({sqlText:command});
        recordSet = statement.execute();
        recordSet.next();
        schemaCreateDate = recordSet.getColumnValue(1);
    }else{
        statement = snowflake.createStatement({sqlText:command});
        recordSet = statement.execute();
        recordSet.next();
        schemaCreateDate = recordSet.getColumnValue(1);
    }
    
    //Get the Lastchange date for the Posting group audit 
    command = "SELECT to_varchar(convert_timezone('" + localTimeZone + "', 'UTC', CREATE_DATE::timestamp_ntz)::TIMESTAMP_LTZ,'DY, DD MON YYYY HH24:MI:SS.FF9 TZHTZM') AS localTimestamp," + linebreak
        + "   MAX(LAST_CHANGE_DATE) AS lastChangeDate" + linebreak
        + "FROM ADM.POSTING_GROUP_INJEST_AUDIT " + linebreak
        + "WHERE POSTING_GROUP_AUDIT_ID = " + postingGroupAuditId.toString() + linebreak
        + "GROUP BY CREATE_DATE;";

    if(isDebug){
        arrayCommands.push("--Get the Lastchange date for the Posting group audit");
        arrayCommands.push(command);
        statement = snowflake.createStatement({sqlText:command});
        recordSet = statement.execute();
        recordSet.next();
        localTimestamp = recordSet.getColumnValue(1);
        lastChangeDate = recordSet.getColumnValue(2);
    }else{
        statement = snowflake.createStatement({sqlText:command});
        recordSet = statement.execute();
        recordSet.next();
        localTimestamp = recordSet.getColumnValue(1);
        lastChangeDate = recordSet.getColumnValue(2);
    }
    
    if(lastChangeDate <= schemaCreateDate){
        output.rowsAffected = -1;
        output.status = "not executed";
        output.message = "schema create date is later than last change date of current posting group (" + postingGroupAuditId.toString() + ")";
        return output;
    }
    
    //For each schame name create restored schema as of the timestamp
    try{
        //BEGIN TRANSACTION
        command = "BEGIN TRANSACTION;";
        if(isDebug){
            arrayCommands.push(command);
        }else{
            statement = snowflake.createStatement({sqlText:command});
            statement.execute();
        }     
        for(let i= 0; i< schemaNames.length ;i++){
            //Create the restored  schemas
            command ="CREATE OR REPLACE SCHEMA restored_" + schemaNames[i] +" CLONE " + schemaNames[i] +" AT(timestamp =>'"+ localTimestamp +"'::timestamp);" ;

            if(isDebug){
                arrayCommands.push("--For each schame name create restored schema as of the timestamp");  
                arrayCommands.push(command);
            }else{
                statement = snowflake.createStatement({sqlText:command});
                recordSet = statement.execute();
                recordSet.next();
            }

            //Rename the exsiting schema to _BAK
            command ="ALTER SCHEMA " + schemaNames[i] +" RENAME TO " + schemaNames[i] +"_BAK;"; 

            if(isDebug){
                arrayCommands.push("--Rename the exsiting schema to _BAK");
                arrayCommands.push(command);
            }else{
                statement = snowflake.createStatement({sqlText:command});
                recordSet = statement.execute();
                recordSet.next();
            }

            //Rename the restored schema to the original schema
            command ="ALTER SCHEMA restored_" + schemaNames[i] +" RENAME TO " + schemaNames[i] + ";"; 

            if(isDebug){
                arrayCommands.push("--Rename the restored schema to the original schema");
                arrayCommands.push(command);
            }else{
                statement = snowflake.createStatement({sqlText:command});
                recordSet = statement.execute();
                recordSet.next();
            }

            //Drop the Backup schemas
            command = " DROP SCHEMA " + schemaNames[i] + "_BAK;";
            if(isDebug){
                arrayCommands.push("--Drop the backup schemas");
                arrayCommands.push(command);
            }else{
                statement = snowflake.createStatement({sqlText:command});
                recordSet = statement.execute();
                recordSet.next();
            }
        }

        //check and remove its record in adm.posting_group_injest_audit
        command = "DELETE FROM ADM.POSTING_GROUP_INJEST_AUDTI" + linebreak
                + "WHERE STATUS = 'S'" + linebreak
                + "AND POSTING_GROUP_AUDIT_ID =" + postingGroupAuditId.toString();
        if(isDebug){
            arrayCommands.push("--check and remove its record in adm.posting_group_injest_audit");
            arrayCommands.push(command);
        }else{
            statement = snowflake.createStatement({sqlText:command});
            statement.execute();
        }

        //commit transaction
        command = "COMMIT;";
        if(isDebug){
            arrayCommands.push("--commit transaction");
            arrayCommands.push(command);
        }else{
            statement = snowflake.createStatement({sqlText:command});
            statement.execute();
        }
    }catch(err){
        //rollback transaction
        command = "ROLLBACK;";
        if(isDebug){
            arrayCommands.push("--rollback transaction");
            arrayCommands.push(command);
        }else{
            statement = snowflake.createStatement({sqlText:command});
            statement.execute();
        }
    }
    
    if(isDebug){
        output.returnStatus = 0;
        output.rowsAffected = -1;
        output.status = "debug";
        output.message = arrayCommands;
    }else{
        output.rowsAffected = -1;
        output.status = "succeeded";
        output.audit = "logged";
    }
    
    return output;
$$;
    
 CREATE OR REPLACE PROCEDURE adm.Etl_Backout_Posting_Group_By_Delete(
  "postingGroupAuditId" FLOAT,
  "previousCutoffPostingGroupauditId" FLOAT,
  "tableNames" VARCHAR,
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
    
    let tableName = "";
    let schemaName = "";
    let localTimestamp;
    let lastChangeDate;
    let localTimeZone = "America/Los_Angeles";
    let joinClause = "";
    let innerJoinClause = "";
    let outerJoinCluase = "";
    let columnList = "";
    tableNames = tableNames.split(",");
    postingGroupAuditId = Number(postingGroupAuditId);
    previousCutoffPostingGroupauditId = Number(previousCutoffPostingGroupauditId);
    
    //Get the Lastchange date for the Posting group audit 
    command = "SELECT to_varchar(convert_timezone('" + localTimeZone + "', 'UTC', CREATE_DATE::timestamp_ntz)::TIMESTAMP_LTZ,'DY, DD MON YYYY HH24:MI:SS.FF9 TZHTZM') AS localTimestamp," + linebreak
        + "   MAX(LAST_CHANGE_DATE) AS lastChangeDate" + linebreak
        + "FROM ADM.POSTING_GROUP_INJEST_AUDIT " + linebreak
        + "WHERE POSTING_GROUP_AUDIT_ID = " + postingGroupAuditId.toString() + linebreak
        + "GROUP BY CREATE_DATE;";

    if(isDebug){
        output.message.push("--Get the Lastchange date for the Posting group audit");
        output.message.push(command);
    }
    statement = snowflake.createStatement({sqlText:command});
    recordSet = statement.execute();
    recordSet.next();
    localTimestamp = recordSet.getColumnValue(1);
    lastChangeDate = recordSet.getColumnValue(2);
    
    //backout posting_group in each table.
    for(let i = 0; i < tableNames.length; i++){
        tableName = tableNames[i].toUpperCase();
        schemaName = (tableName.split("."))[0];
        
		if(schemaName.split("_")[0].toUpperCase() != "RPT"){
            //when column with timestamp_ntz is part of primary key, cast it to timestamp_ntz(3) in the join clause.
            command = "SELECT  " + linebreak
				+"    LISTAGG( 'S.' || C.COLUMN_NAME || ' = ' || 'T.' || C.COLUMN_NAME ,' AND ') AS outerJoinClause,  " + linebreak
				+"    LISTAGG( CASE  " + linebreak
				+"        WHEN C.COLUMN_NAME = 'ODSPOSTINGGROUPAUDITID'  " + linebreak
				+"            THEN NULL  " + linebreak
				+"        ELSE 'A.' || C.COLUMN_NAME || ' = ' || 'B.' || C.COLUMN_NAME " + linebreak
				+"        END ,' AND ') AS innerJoinClause,  " + linebreak
				+"    LISTAGG( 'B.' || C.COLUMN_NAME ,',')||',B.ODSROWISCURRENT' AS columnList  " + linebreak
				+"FROM ADM.PROCESS_PRIMARY_KEY PPK " + linebreak
				+"INNER JOIN ADM.PROCESS P " + linebreak
				+"    ON PPK.PROCESS_ID = P.PROCESS_ID " + linebreak
				+"    AND UPPER(P.TARGET_TABLE_NAME) = UPPER('" + tableName.split(".")[1] + "') " + linebreak
				+"    AND UPPER(P.TARGET_SCHEMA_NAME) = UPPER('" + schemaName.split("_")[0] + "') " + linebreak
				+"INNER JOIN INFORMATION_SCHEMA.COLUMNS C " + linebreak
				+"    ON UPPER(PPK.PRIMARY_KEY_COLUMN) = C.COLUMN_NAME " + linebreak
				+"    AND UPPER(P.TARGET_TABLE_NAME) = C.TABLE_NAME " + linebreak
				+"    AND UPPER(P.TARGET_SCHEMA_NAME) = C.TABLE_SCHEMA;";
			
			if(isDebug){
                output.message.push("--For table " + tableNames[i] + ", Build the join clause to find the matched records from previous posting group.");
				output.message.push(command);
            }
            statement = snowflake.createStatement({sqlText:command});
            recordSet = statement.execute();
            if(recordSet.next()){
                outerJoinClause = recordSet.getColumnValue(1);
                innerJoinClause = recordSet.getColumnValue(2);
                columnList = recordSet.getColumnValue(3);
            }
            
            //flip back the odsrowiscurrent, OdsRowIsCurrent update 0 -> 1.
            command = " update " + tableName + " S" + linebreak
                + " set odsrowiscurrent = 1" + linebreak
                + " from (select " + columnList + linebreak
                + "       from " + tableName + " AT (timestamp => '" + localTimestamp + "'::timestamp) B" + linebreak
                + "       join " + tableName + " A" + linebreak
                + "           on " + innerJoinClause + linebreak
                + "           and A.odsrowiscurrent = 1" + linebreak
                + "           and B.odsrowiscurrent = 1" + linebreak
                + "           and A.odspostinggroupauditid > " + previousCutoffPostingGroupauditId.toString() + ") T" + linebreak
                + " where " + outerJoinClause + linebreak
                + "     and S.odsrowiscurrent = 0" + linebreak
                + "     and T.odsrowiscurrent = 1;";
            if(isDebug){
                output.message.push("--flip back the odsrowiscurrent, OdsRowIsCurrent update 0 -> 1.");
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
                    continue;
                }
            }
        }
        
        //delete the records of the latest postinggroup
        command = "DELETE FROM " + tableName + linebreak
            + "WHERE " + (schemaName.split("_")[0].toUpperCase() == "RPT" ? "POSTINGGROUPAUDITID" : "ODSPOSTINGGROUPAUDITID")
            + " > " + previousCutoffPostingGroupauditId.toString() + ";";
        if(isDebug){
            output.message.push("--delete the records of the latest postinggroup.");
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
                continue;
            }
        }
    }
    
    if(isDebug){
        output.returnStatus = 0;
        output.status = "debug";
    }else if(output.returnStatus == 1){
        output.status = "succeeded";
    }
    
    return output;
$$;
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
$$;CREATE OR REPLACE PROCEDURE adm.ETL_Bring_Data_Online(
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
    let joinClause = "";
    let totalRowsUpdated = 0;

    for(let i = 0; i < tableNames.length; i++){
        let originalSchemaName = (tableNames[i].split("."))[0].split("_")[0];
		if(loadType.toUpperCase() == "INCR" && originalSchemaName == "SRC"){
            command = "SELECT LISTAGG( 'S.' || C.COLUMN_NAME || ' = ' || 'T.' || C.COLUMN_NAME,' AND ') AS joinClause " + linebreak
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
					joinClause = recordSet.getColumnValue(1);
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
$$;/*

call ADM.ETL_GET_CONTROLFILES (
            '@ACSODS_DEV.stg.etl_dev'
            ,'ADM.COMMAFORMATFILES'
            ,true)

*/

CREATE OR REPLACE PROCEDURE ADM.ETL_GET_CONTROLFILES(
"externalStage"  string,
"formatFile"   string,
"isDebug" BOOLEAN
  
)
returns VARIANT
language javascript
execute as caller
as     
$$ 
    const output = {
        returnStatus: -1,
        data: "",
        rowsAffected: -1,
        audit: "not logged",
        status: "not executed",
        message: []
    };
   
    let command = "";
    let statement;
    let recordSet;
	let controlFileNames = "";

	let linebreak = "\r\n";

	externalStage = (externalStage.substring(externalStage.length-1,externalStage.length) == "/"?externalStage:externalStage + "/");
  
	//Truncate stg.Etl_ControlFiles table 
    command = " TRUNCATE TABLE STG.ETL_CONTROLFILES;";
    if(isDebug){
		output.returnStatus = 0;
        output.rowsAffected = -1;
        output.status = "debug";
        output.message.push("--Truncate stg.Etl_ControlFiles table");
		output.message.push(command);
	}else{
		try{
            statement = snowflake.createStatement({sqlText: command});
            statement.execute();
		}catch(err){
			output.returnStatus = -1;
            output.rowsAffected = -1;
			output.audit= 'logged';
            output.status = 'failed';
            output.message.push(err.message);
			return output;
		}
	}

	//Load All Control files from the external stage
    command = "ls " + externalStage + linebreak
		+ "pattern = '.*.ctl.gz';";        
	if(isDebug){
		output.message.push("--Load All Control files from the external stage");
		output.message.push(command);
	}else{
		try{
            statement = snowflake.createStatement({sqlText: command});
            statement.execute();
		}catch(err){
			output.returnStatus = -1;
            output.rowsAffected = -1;
			output.audit= "logged";
            output.status = "failed";
            output.message.push(err.message);
			output.message.push("Error Command: " + command);
			return output;
		}
	}	
	
	command = "SELECT LISTAGG(strtok(\"name\", '/', (Array_size(strtok_to_array(\"name\",'/'))) - 1)||"
		+ "'/'||strtok(\"name\", '/', (Array_size(strtok_to_array(\"name\",'/')))),''',''')" + linebreak
		+ "FROM TABLE(RESULT_SCAN(LAST_QUERY_ID()))" + linebreak
		+ "WHERE strtok(strtok(\"name\", '/', (Array_size(strtok_to_array(\"name\",'/')))),'_',2) " + linebreak
		+ "    > (SELECT TO_VARCHAR(IFNULL(MAX(SNAPSHOT_DATE),'1900-01-01'),'yyyymmddhhmiss')" + linebreak
		+ "        FROM ADM.POSTING_GROUP_INJEST_AUDIT" + linebreak
		+ "		   WHERE STATUS = 'FI');";
	if(isDebug){
		output.message.push(command);
	}else{
		try{
            statement = snowflake.createStatement({sqlText: command});
            recordSet = statement.execute();
			if(recordSet.next()){
				controlFileNames = recordSet.getColumnValue(1);
			}
		}catch(err){
			output.returnStatus = -1;
            output.rowsAffected = -1;
			output.audit= "logged";
            output.status = "failed";
            output.message.push(err.message);
			output.message.push("Error Command: " + command);
			return output;
		}
	}	

	command = " COPY INTO STG.ETL_CONTROLFILES" + linebreak
		+ " FROM "+  externalStage + linebreak
		+ " FILES = ('" + controlFileNames + "')" + linebreak
		+ " FILE_FORMAT = ( FORMAT_NAME = "+ formatFile + ")" + linebreak
		+ " ON_ERROR = CONTINUE;";   
	if(isDebug){
		output.message.push(command);
	}else{
		try{
            statement = snowflake.createStatement({sqlText: command});
            statement.execute();
		}catch(err){
			output.returnStatus = -1;
            output.rowsAffected = -1;
			output.audit= "logged";
            output.status = "failed";
            output.message.push(err.message);
			output.message.push("Error Command: " + command);
			return output;
		}
	}
               
	//Get Control file names to be loaded
    command = "SELECT array_agg(DISTINCT S.SNAPSHOT_DATE)WITHIN GROUP(ORDER BY S.SNAPSHOT_DATE) " + linebreak
		+ " FROM STG.ETL_CONTROLFILES S " + linebreak
		+ " LEFT OUTER JOIN ADM.POSTING_GROUP_INJEST_AUDIT P " + linebreak
		+ " ON S.SNAPSHOT_DATE = P.SNAPSHOT_DATE" + linebreak
		+ " WHERE P.STATUS <> 'FI' OR P.POSTING_GROUP_AUDIT_ID IS NULL;";
	if(isDebug){
		output.message.push("--Get Control file names to be loaded");
		output.message.push(command);
	}else{
		try{
            statement = snowflake.createStatement({sqlText: command});
            recordSet = statement.execute();
            recordSet.next();
            
            output.returnStatus = 1;
            output.data = recordSet.getColumnValue(1);
            output.audit= "logged";
            output.status = "succeeded";
            output.message = "";
		}catch(err){
			output.returnStatus = -1;
            output.rowsAffected = -1;
			output.audit= "logged";
            output.status = "failed";
            output.message.push(err.message);
			output.message.push("Error Command: " + command);
		}
	}

	return output;
 
 $$;

CREATE OR REPLACE PROCEDURE ADM.ETL_GET_PROCESS_FILES(
"snapShotDate"  string,
"isDebug" BOOLEAN
)
returns VARIANT
language javascript
execute as caller
as     
$$ 
	const output = {
		returnStatus: -1,
		data: "",
		rowsAffected: -1,
		audit: "not logged",
		status: "not executed",
		message: ""
	};
   
    let arrayCommands = [];
    let command;
    let statement;
    let recordSet;
    
    let linebreak = "\r\n";
    let tab = "\t";
	let jsData;
    let postingGroupAuditId;
	let totalFileCount;
    
    command = "CALL ADM.ETL_GET_REPLICATION_INFO ('"+snapShotDate+"','False')"
    statement = snowflake.createStatement({sqlText: command });
    recordSet = statement.execute();
    recordSet.next();
    jsData = recordSet.getColumnValue(1).data;
    
    if ((jsData.postingGroupAuditId == -1) && ((jsData.currentReplicationId == jsData.previousReplicationId) || (jsData.previousReplicationId == -1))) {
		// Insert Into POSTING_GROUP_INJEST_AUDIT if the snapshot does not have an entry in postinggroupaudit table
        command = "INSERT INTO ADM.POSTING_GROUP_INJEST_AUDIT("   + linebreak
			+"    ODS_CUTOFF_POSTING_GROUP_AUDIT_ID,"   + linebreak
			+"    CURRENT_REPLICATION_ID,"   + linebreak
			+"    STATUS,"   + linebreak
			+"	  INJEST_TYPE_ID,"   + linebreak
			+"	  ODS_VERSION,"   + linebreak
            +"	  SNAPSHOT_DATE,"   + linebreak
            +"	  CREATE_DATE,"   + linebreak
            +"    LAST_CHANGE_DATE )"   + linebreak
            +"SELECT DISTINCT" + linebreak
			+"    ODS_CUTOFF_POSTING_GROUP_AUDIT_ID," + linebreak
			+"    CURRENT_REPLICATION_ID," + linebreak
			+"    'S'," + linebreak
			+"    CASE WHEN UPPER(LOAD_TYPE) = 'FULL' THEN 0 WHEN UPPER(LOAD_TYPE) = 'INCR' THEN 1 ELSE -1 END," + linebreak
			+"    ODS_VERSION," + linebreak
			+"    SNAPSHOT_DATE," + linebreak
			+"    CURRENT_TIMESTAMP() ," + linebreak
			+"    CURRENT_TIMESTAMP() " + linebreak
			+"FROM STG.ETL_CONTROLFILES" + linebreak
			+"WHERE SNAPSHOT_DATE = '" + snapShotDate + "';";
	    if(isDebug){
			arrayCommands.push("--Insert Record into Posting group audit table");
			arrayCommands.push(command);
	    }
	    statement = snowflake.createStatement({sqlText:command});
		recordSet = statement.execute();
		recordSet.next();
	}
     
    if ((jsData.currentReplicationId == jsData.previousReplicationId) || (jsData.previousReplicationId == -1)){ 
		// Insert Records into Process Injest 
		command = "INSERT INTO ADM.PROCESS_INJEST_AUDIT("   + linebreak
			+"  POSTING_GROUP_AUDIT_ID,"   + linebreak
			+"  PROCESS_ID,"   + linebreak
			+"  STATUS,"   + linebreak
			+"	TOTAL_RECORDS_IN_SOURCE,"   + linebreak
			+"  TOTAL_NUMBER_OF_FILES,"   + linebreak
			+"	CREATE_DATE,"   + linebreak
			+"	LAST_CHANGE_DATE)"   + linebreak

			+"	WITH CTE_LATEST_PROCESSAUDIT AS("   + linebreak
			+"	  SELECT POSTING_GROUP_AUDIT_ID, PROCESS_ID, MAX(PROCESS_AUDIT_ID) PROCESS_AUDIT_ID"   + linebreak
			+"	  FROM ADM.PROCESS_INJEST_AUDIT"   + linebreak
			+"	  GROUP BY POSTING_GROUP_AUDIT_ID,PROCESS_ID),"   + linebreak

			+"	CTE_PROCESS_INJEST_AUDIT AS("   + linebreak
			+"	  SELECT PA.PROCESS_ID,PA.STATUS,PA.POSTING_GROUP_AUDIT_ID"   + linebreak
			+"	  FROM ADM.PROCESS_INJEST_AUDIT PA"   + linebreak
			+"	  INNER JOIN CTE_LATEST_PROCESSAUDIT CTE"   + linebreak
			+"	  ON PA.POSTING_GROUP_AUDIT_ID = CTE.POSTING_GROUP_AUDIT_ID"   + linebreak
			+"	  AND PA.PROCESS_ID = CTE.PROCESS_ID"   + linebreak
			+"	  AND PA.PROCESS_AUDIT_ID = CTE.PROCESS_AUDIT_ID)"   + linebreak

			+"	SELECT DISTINCT "   + linebreak
			+"		PGA.POSTING_GROUP_AUDIT_ID,"   + linebreak
			+"		P.PROCESS_ID,"   + linebreak
			+"		'S' STATUS,"   + linebreak
			+"		CF.TOTAL_RECORDS_IN_SOURCE,"   + linebreak
			+"		CF.TOTAL_FILES,"   + linebreak
			+"		CURRENT_TIMESTAMP(),"   + linebreak
			+"		CURRENT_TIMESTAMP()"   + linebreak
			+"	FROM STG.ETL_CONTROLFILES CF"   + linebreak
			+"	INNER JOIN ADM.PROCESS P"   + linebreak
			+"	    ON UPPER(P.TARGET_TABLE_NAME) = UPPER(CF.TARGET_TABLE_NAME)"   + linebreak
			+"	    AND P.IS_ACTIVE = 'TRUE'"   + linebreak
			+"	LEFT OUTER JOIN ADM.POSTING_GROUP_INJEST_AUDIT PGA"   + linebreak
			+"	    ON CF.SNAPSHOT_DATE = PGA.SNAPSHOT_DATE"   + linebreak
			+"	LEFT OUTER JOIN CTE_PROCESS_INJEST_AUDIT PA"   + linebreak
			+"	    ON PGA.POSTING_GROUP_AUDIT_ID = PA.POSTING_GROUP_AUDIT_ID"   + linebreak
			+"	    AND P.PROCESS_ID = PA.PROCESS_ID"   + linebreak
			+"	WHERE CF.SNAPSHOT_DATE = '" + snapShotDate + "'"   + linebreak
			+"	    AND (PA.POSTING_GROUP_AUDIT_ID IS NULL OR PA.STATUS = 'S');"

		if(isDebug){
			arrayCommands.push("--Insert Records into Process Injest");
			arrayCommands.push(command);
		} else {
			statement = snowflake.createStatement({sqlText:command});
			recordSet = statement.execute();
			recordSet.next();
		}
		
		//GET POSTING GROUP AUDIT ID
		command = "WITH CTE_LATEST_PROCESSAUDIT AS( " + linebreak
			+ "    SELECT POSTING_GROUP_AUDIT_ID, PROCESS_ID, MAX(PROCESS_AUDIT_ID) PROCESS_AUDIT_ID  " + linebreak
			+ "    FROM ADM.PROCESS_INJEST_AUDIT  " + linebreak
			+ "    GROUP BY POSTING_GROUP_AUDIT_ID,PROCESS_ID),  " + linebreak
			+ "CTE_PROCESS_INJEST_AUDIT AS(  " + linebreak
			+ "    SELECT PA.PROCESS_ID,PA.STATUS,PA.POSTING_GROUP_AUDIT_ID  " + linebreak
			+ "    FROM ADM.PROCESS_INJEST_AUDIT PA   " + linebreak
			+ "    INNER JOIN CTE_LATEST_PROCESSAUDIT CTE  " + linebreak
			+ "        ON PA.POSTING_GROUP_AUDIT_ID = CTE.POSTING_GROUP_AUDIT_ID  " + linebreak
			+ "        AND PA.PROCESS_ID = CTE.PROCESS_ID  " + linebreak
			+ "        AND PA.PROCESS_AUDIT_ID = CTE.PROCESS_AUDIT_ID)   " + linebreak
			+ "SELECT  " + linebreak
			+ "    IFNULL(ANY_VALUE(PGA.POSTING_GROUP_AUDIT_ID),-1) AS POSTING_GROUP_AUDIT_ID, " + linebreak
			+ "    COUNT(1) AS TOTAL_FILE_COUNT " + linebreak
			+ "FROM STG.ETL_CONTROLFILES CF  " + linebreak
			+ "INNER JOIN ADM.PROCESS P  " + linebreak
			+ "    ON UPPER(P.TARGET_TABLE_NAME) = UPPER(CF.TARGET_TABLE_NAME)  " + linebreak
			+ "    AND P.IS_ACTIVE = 'TRUE'  " + linebreak
			+ "INNER JOIN ADM.POSTING_GROUP_INJEST_AUDIT PGA  " + linebreak
			+ "    ON CF.SNAPSHOT_DATE = PGA.SNAPSHOT_DATE " + linebreak
			+ "LEFT OUTER JOIN CTE_PROCESS_INJEST_AUDIT PA  " + linebreak
			+ "    ON PGA.POSTING_GROUP_AUDIT_ID = PA.POSTING_GROUP_AUDIT_ID  " + linebreak
			+ "    AND P.PROCESS_ID = PA.PROCESS_ID  " + linebreak
			+ "WHERE CF.SNAPSHOT_DATE = '" + snapShotDate + "' " + linebreak
			+ "    AND (PA.POSTING_GROUP_AUDIT_ID IS NULL OR PA.STATUS = 'S');"

		if(isDebug){
			arrayCommands.push("--GET POSTING GROUP AUDIT ID");
			arrayCommands.push(command);
		}else{
			statement = snowflake.createStatement({sqlText:command});
			recordSet = statement.execute();
			if(recordSet.next()) {
				postingGroupAuditId = recordSet.getColumnValue("POSTING_GROUP_AUDIT_ID");
				totalFileCount = recordSet.getColumnValue("TOTAL_FILE_COUNT");
			} else {
				postingGroupAuditId = -1;
				totalFileCount = 0;
			}
		}
	} 
             
	//Debug mode, output the message
	if(isDebug){
            output.returnStatus = 0;
            output.rowsAffected = -1;
            output.status = 'debug';
            output.message = arrayCommands;
    }else{
            output.returnStatus = 1;
            output.data = {
				"postingGroupAuditId" : postingGroupAuditId,
				"totalFileCount" : totalFileCount
			};
            output.audit= 'logged';
            output.status = 'succeeded';
            output.message = '';
     }

	return output;
$$;

CREATE OR REPLACE PROCEDURE ADM.ETL_GET_REPLICATION_INFO(
"snapShotDate"  string,
"isDebug" BOOLEAN
  
)
//returns varchar not null
returns VARIANT
language javascript
execute as caller
as     
$$ 
     const output = {
        returnStatus: -1,
        data: "",
        rowsAffected: -1,
        audit: "not logged",
        status: "not executed",
        message: ""
    };
   
    let dmlCommand;
    let statement;
    let recordSet;
	let linebreak = "\r\n";
    
	// Get PostingGroupAuditId for Given Snapshot if already created and also get current and previous replicationids
    dmlCommand =  "SELECT object_construct('postingGroupAuditId',IFNULL((SELECT POSTING_GROUP_AUDIT_ID"
                      +" FROM ADM.POSTING_GROUP_INJEST_AUDIT"
                      +" WHERE SNAPSHOT_DATE = '" + snapShotDate + "'),-1)," + linebreak
                      +" 'currentReplicationId',IFNULL((SELECT MAX(CURRENT_REPLICATION_ID) AS CURRENTREPLICATIONID"
                      +" FROM ADM.POSTING_GROUP_INJEST_AUDIT "
					  +" WHERE SNAPSHOT_DATE < '" + snapShotDate + "'),-1)," + linebreak
                      +" 'previousReplicationId',(SELECT DISTINCT PREVIOUS_REPLICATION_ID"
                      +" FROM STG.ETL_CONTROLFILES"
                      +" WHERE SNAPSHOT_DATE = '" + snapShotDate + "'));";
      
    //Debug mode, output the message
   if(isDebug){
            output.returnStatus = 0;
            output.rowsAffected = -1;
            output.status = 'debug';
            output.message = dmlCommand;
    }else {
        //execution
        try{
            statement = snowflake.createStatement({
            sqlText: dmlCommand
                            });
            recordSet = statement.execute();
            recordSet.next();
            
            output.returnStatus = 1;
            output.data = recordSet.getColumnValue(1);
            output.audit= 'logged';
            output.status = 'succeeded';
            output.message = '';
        }catch(err){        
                      
            output.returnStatus = -1;
            output.rowsAffected = -1;
			output.audit= 'logged';
            output.status = 'failed';
            output.message = err.message;   
         }
     }

  return output;
 
 $$;

CREATE OR REPLACE PROCEDURE adm.Etl_Insert_Process_Into_Target_From_Staging
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
		+ "AND TABLE_SCHEMA IN ('SRC','RPT'); ";
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
CREATE OR REPLACE PROCEDURE adm.ETL_Load_Balancer(
  "numberOfPipelines" FLOAT,
  "postingGroupAuditId" FLOAT,
  "isTruncate" BOOLEAN,
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
    
    let cmd, stmt, rs;
    let linebreak = "\r\n";
    
    postingGroupAuditId = Number(postingGroupAuditId).toString();
    numberOfPipelines = Number(numberOfPipelines);
    
    let data = [];
    let size = [];
    let sumOfEachPipeline = [];
    let tableNames = new Set();
    let entry = [];
    let totalFileSize, threshold;
    let loadType, snapshotDate, snapshotDateTime, totalTableNumber;
    let i = 0;
    
    let count = 0, sum = 0;
    let pipeline = [];
    let tmp = [];
    
    for (i = 0; i < numberOfPipelines; i++) {
        sumOfEachPipeline.push(0);
		pipeline[i] = [];
    }
    
    i = 0;
    //get process files information.
    cmd = "WITH CTE_LATEST_PROCESSAUDIT AS( " + linebreak 
		+ "    SELECT POSTING_GROUP_AUDIT_ID, PROCESS_ID, MAX(PROCESS_AUDIT_ID) PROCESS_AUDIT_ID " + linebreak 
		+ "    FROM ADM.PROCESS_INJEST_AUDIT " + linebreak 
		+ "    GROUP BY POSTING_GROUP_AUDIT_ID,PROCESS_ID), " + linebreak 
		+ "CTE_PROCESS_INJEST_AUDIT AS( " + linebreak 
		+ "    SELECT PA.PROCESS_ID,PA.STATUS,PA.POSTING_GROUP_AUDIT_ID " + linebreak 
		+ "    FROM ADM.PROCESS_INJEST_AUDIT PA  " + linebreak 
		+ "    INNER JOIN CTE_LATEST_PROCESSAUDIT CTE " + linebreak 
		+ "        ON PA.POSTING_GROUP_AUDIT_ID = CTE.POSTING_GROUP_AUDIT_ID " + linebreak 
		+ "        AND PA.PROCESS_ID = CTE.PROCESS_ID " + linebreak 
		+ "        AND PA.PROCESS_AUDIT_ID = CTE.PROCESS_AUDIT_ID), " + linebreak 
		+ "CTE AS(" + linebreak 
		+ "    SELECT " + linebreak 
		+ "        ANY_VALUE(CF.LOAD_TYPE) AS LOADTYPE, " + linebreak 
		+ "        ANY_VALUE(TO_VARCHAR(CF.snapshot_date,'yyyy-mm-dd')) AS SNAPSHOTDATE, " + linebreak 
		+ "        ANY_VALUE(TO_VARCHAR(CF.snapshot_date,'yyyymmddhhmiss')) AS SNAPSHOTDATETIME, " + linebreak 
		+ "        ANY_VALUE(P.PROCESS_ID) AS PROCESSID, " + linebreak 
		+ "        ANY_VALUE(P.TARGET_TABLE_NAME) AS TARGETTABLENAME, " + linebreak 
		+ "        OBJECT_CONSTRUCT('processId',P.PROCESS_ID," + linebreak 
		+ "            'targetTableName',ANY_VALUE(P.TARGET_TABLE_NAME)," + linebreak 
		+ "            'tableFiles',ARRAY_AGG(OBJECT_CONSTRUCT(" + linebreak 
		+ "                'fileNumber',CF.FILE_NUMBER," + linebreak 
		+ "                'fileName',CF.FILE_NAME||'.gz'," + linebreak 
		+ "                'totalRowCount',CF.TOTAL_ROW_COUNT))) as jsObject," + linebreak 
		+ "        SUM(CF.FILE_SIZE) AS TABLEFILESIZE" + linebreak
		+ "    FROM STG.ETL_CONTROLFILES CF " + linebreak 
		+ "    INNER JOIN ADM.PROCESS P " + linebreak 
		+ "        ON UPPER(P.TARGET_TABLE_NAME) = UPPER(CF.TARGET_TABLE_NAME) " + linebreak 
		+ "        AND P.IS_ACTIVE = 'TRUE' " + linebreak 
		+ "    INNER JOIN ADM.POSTING_GROUP_INJEST_AUDIT PGA " + linebreak 
		+ "        ON PGA.POSTING_GROUP_AUDIT_ID = " + postingGroupAuditId.toString() + linebreak 
		+ "        AND CF.SNAPSHOT_DATE = PGA.SNAPSHOT_DATE " + linebreak 
		+ "    LEFT OUTER JOIN CTE_PROCESS_INJEST_AUDIT PA " + linebreak 
		+ "        ON PGA.POSTING_GROUP_AUDIT_ID = PA.POSTING_GROUP_AUDIT_ID " + linebreak 
		+ "        AND P.PROCESS_ID = PA.PROCESS_ID " + linebreak 
		+ "    WHERE PA.POSTING_GROUP_AUDIT_ID IS NULL OR PA.STATUS = 'S' " + linebreak 
		+ "    GROUP BY P.PROCESS_ID)" + linebreak 
		+ "SELECT " + linebreak 
		+ "    LOADTYPE," + linebreak 
		+ "    SNAPSHOTDATE," + linebreak 
		+ "    SNAPSHOTDATETIME, " + linebreak 
		+ "    PROCESSID, " + linebreak 
		+ "    TARGETTABLENAME, " + linebreak
		+ "    JSOBJECT," + linebreak 
		+ "    COUNT(1)OVER() AS TOTALTABLENUMBER," + linebreak 
		+ "    TABLEFILESIZE," + linebreak 
		+ "    SUM(TABLEFILESIZE)OVER() AS TOTALFILESIZE" + linebreak 
		+ "FROM CTE" + linebreak 
		+ "ORDER BY TABLEFILESIZE DESC," + linebreak 
		+ "    PROCESSID ASC;";
    if (isDebug) {
        output.message.push("--get process files information.");
        output.message.push(cmd);
    }
    try {
        stmt = snowflake.createStatement({sqlText: cmd});
        rs = stmt.execute();
        while (true) {
            if(!rs.next()) {
                if (size.length == 0) {
                    //no records returned.
                    output.returnStatus = -1;
                    output.rowsAffected = -1;
                    output.status = "failed";
                    output.message.push("Error Message: no records returned.");
                    output.message.push("Error Command: " + cmd);
                    return output;
                } else {
                    //no more records and quit the loop.
                    break;
                }
            } else if (size.length == 0) {
                totalFileSize = rs.getColumnValue("TOTALFILESIZE");
                threshold = Math.ceil(totalFileSize * 1.0 / numberOfPipelines);
                loadType = rs.getColumnValue("LOADTYPE");
                snapshotDate = rs.getColumnValue("SNAPSHOTDATE");
                snapshotDateTime = rs.getColumnValue("SNAPSHOTDATETIME");
                totalTableNumber = rs.getColumnValue("TOTALTABLENUMBER");
            }
            size.push(rs.getColumnValue("TABLEFILESIZE"));
            tableNames.add(rs.getColumnValue("TARGETTABLENAME").toUpperCase());
            entry[i++] = rs.getColumnValue("JSOBJECT");
        }
    } catch (err) {
        output.returnStatus = -1;
        output.rowsAffected = -1;
        output.status = "failed";
        output.message.push(err.message);
        output.message.push("Error Command: " + cmd);
        return output;
    }
    
    //truncate table if enabled.
    if (isTruncate) {
        for (let tableName of tableNames) {
            cmd = "TRUNCATE TABLE STG." + tableName + ";";
            if (isDebug) {
                output.message.push("--truncate table if enabled.");
                output.message.push(cmd);
            } else {
                try {
                    stmt = snowflake.createStatement({sqlText: cmd});
                    stmt.execute();
                } catch (err) {
                    output.returnStatus = -1;
                    output.rowsAffected = -1;
                    output.status = "failed";
                    output.message.push(err.message);
                    output.message.push("Error Command: " + cmd);
                    return output;
                }
            }
        }
    }
        
    //balance the load.  
	let j = 0
	let l = sumOfEachPipeline.length;
    for (i = 0; i < size.length; i++) {
        //find first available pipeline
		while (sumOfEachPipeline[j] >= threshold) {
			j = (j + 1) % l; 
		}

		pipeline[j].push(entry[i]);
		sumOfEachPipeline[j] += size[i];
		j = (j + 1) % l;
    }
    
    for (i = 0; i < pipeline.length; i++) {
        pipeline[i] = {
            "loadType" : loadType,
            "postingGroupAuditId" : postingGroupAuditId,
            "snapshotDate" : snapshotDate,
            "snapshotDateTime" : snapshotDateTime,
            "pipelineTotalSize" : sumOfEachPipeline[i].toFixed(3).toString(),
            "tableData" : pipeline[i]
        }
    }
    
    if(isDebug){
        output.returnStatus = 0;
        output.rowsAffected = -1;
        output.status = "debug";
    }else if(output.returnStatus != -1){
        output.rowsAffected = -1;
        output.status = "succeeded";
        output.data = {
            "totalTableNumber" : totalTableNumber.toString(),
            "totalFileSize" : totalFileSize.toString(),
            "threshold" : threshold.toString(),
            "tableData" : pipeline,
			"actualNumberOfPipelines" : pipeline.length
        };
    }
    
    return output;
$$;

CREATE OR REPLACE PROCEDURE adm.Etl_Load_File_Into_Staging (
  "processAuditId" FLOAT,
  "tableName" VARCHAR(100),
  "snapshotDateTime" STRING,
  "externalStage" STRING,
  "fileFolder" STRING,
  "arrayFiles" ARRAY,
  "truncateStg" BOOLEAN,
  "isDebug" BOOLEAN
)
returns variant
language javascript
execute as caller
as     
$$  
    const output = {
        returnStatus: 0,
        rowsAffected: -1,
        audit: "not logged",
		data: "",
        status: "not executed",
        message: []
    };
    
    const auditData = {
        identity:"",
        identityValue:"",
        jsData:{}
    };
    
    let commandTruncate;
    let commandCopy;
	let command = "";
    let statement;
    let recordSet;  
	let linebreak = "\r\n";
	let tab = "\t";

	let fullTableName = "";
    let arrayFileNames = [];
    let stringFileNames = "";
	let formatFileName = "";
    
    processAuditId = Number(processAuditId);
    arrayFiles.forEach(fileItem => arrayFileNames.push(fileItem.fileName));
    stringFileNames = "'" + arrayFileNames.join("','") + "'";
	externalStage = (externalStage.substring(externalStage.length-1,externalStage.length) == "/"?externalStage:externalStage + "/");
    
	//get format file name
	command = "SELECT FORMAT_FILE_NAME," + linebreak
		+ "    P.TARGET_SCHEMA_NAME||'.'||P.TARGET_TABLE_NAME AS FULL_TABLE_NAME" + linebreak
		+ "FROM ADM.PROCESS_FORMAT_FILES PFF" + linebreak
		+ "INNER JOIN ADM.PROCESS P" + linebreak
		+ "    ON PFF.PROCESS_ID = P.PROCESS_ID" + linebreak
		+ "    AND UPPER(P.TARGET_TABLE_NAME) = UPPER('" + tableName + "');";
	if(isDebug){
		output.returnStatus = 0;
        output.rowsAffected = -1;
        output.status = "debug";
        output.message.push("--get format file name for table " + tableName);
        output.message.push(command);
	}else{
		try{
			statement = snowflake.createStatement({sqlText: command});
            recordSet = statement.execute();
            if(recordSet.next()){
				formatFileName = recordSet.getColumnValue("FORMAT_FILE_NAME");
				fullTableName = recordSet.getColumnValue("FULL_TABLE_NAME");
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

	//load data into STG
    commandTruncate = "TRUNCATE TABLE STG." + tableName.toUpperCase() + " ; ";
    
    commandCopy = "COPY INTO STG." + tableName.toUpperCase() + " " + linebreak
                + "FROM " + externalStage + fileFolder + "/ " + linebreak 
                + "FILES = (" + stringFileNames + ") " + linebreak
                + "FILE_FORMAT=(FORMAT_NAME = " + formatFileName + ") " + linebreak
                + "ON_ERROR = SKIP_FILE; ";
        
    if(isDebug){
        output.message.push("--load data into STG");
        output.message.push((truncateStg?commandTruncate:"")  + linebreak + commandCopy + linebreak);
    }else {
        //execution
        try{
            if(truncateStg){
                statement = snowflake.createStatement({sqlText: commandTruncate});
                recordSet = statement.execute();
            }   
            
            statement = snowflake.createStatement({sqlText: commandCopy});
            recordSet = statement.execute();
            recordSet.next();
            
            command = "select SUM($4) FROM TABLE(RESULT_SCAN(LAST_QUERY_ID()));"
            statement = snowflake.createStatement({sqlText: command});
            recordSet = statement.execute();
            recordSet.next();
            output.rowsAffected = recordSet.getColumnValue(1);
         }catch(err){        
            output.returnStatus = -1;
            output.rowsAffected = -1;
            output.status = "failed";
            output.message.push(err.message);   
			output.message.push("Error Command: " + command);
            return output;
        }
    }
    
  	//create left table stg.tempLoadHistory
	command = "CREATE OR REPLACE TEMPORARY TABLE STG.tempLoadHistory " + linebreak
		+ "AS SELECT " + linebreak
		+ tab + "FILE_NAME, " + linebreak
		+ tab + "STATUS, " + linebreak
		+ tab + "ROW_COUNT, " + linebreak
		+ tab + "LAST_LOAD_TIME, " + linebreak
		+ tab + "FIRST_ERROR_MESSAGE, " + linebreak
		+ tab + "ROW_NUMBER()OVER(PARTITION BY strtok(file_name,'/',(Array_size(strtok_to_array(file_name,'/')))) " + linebreak
		+ tab + tab + " ORDER BY LAST_LOAD_TIME DESC) AS RID " + linebreak
		+ "FROM INFORMATION_SCHEMA.LOAD_HISTORY " + linebreak
		+ "WHERE FILE_NAME LIKE '%" + snapshotDateTime + "%' " + linebreak
		+ "AND FILE_NAME LIKE '%/" + fileFolder + "/%'" + linebreak
		+ "AND TABLE_NAME  = UPPER('" + tableName + "');";
	if(isDebug){
        output.message.push("--build json to update adm.Process_File_Audit");
		output.message.push("--create left table stg.tempLoadHistory");
        output.message.push(command + linebreak);
    }else{
		try{
            statement = snowflake.createStatement({sqlText: command});
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

	//create right table stg.tempArrayFiles
	command = "CREATE OR REPLACE TEMPORARY TABLE STG.tempArrayFiles " + linebreak
		+ "AS SELECT * "  + linebreak
		+ "FROM LATERAL FLATTEN(parse_json('" + JSON.stringify(arrayFiles) + "'));";
	if(isDebug){
        output.message.push("--create right table stg.tempArrayFiles");
        output.message.push(command + linebreak);
    }else{
		try{
            statement = snowflake.createStatement({sqlText: command});
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

	//create temp table STG.tempInsert used in Insert Stmt
	command = "CREATE OR REPLACE TEMPORARY TABLE STG.tempInsert " + linebreak
		+ "AS SELECT  " + linebreak
        + "     SUM(CASE " + linebreak
        + "             WHEN f.value:totalRowCount != lh.row_count THEN 1 " + linebreak
		+ "             WHEN lh.Status = 'LOADED' THEN 0 " + linebreak
        + "             WHEN lh.Status = 'LOAD_FAILED' THEN 1 " + linebreak
        + "             ELSE 0 " + linebreak
        + "         END) AS errorCount," + linebreak
        + "     LISTAGG(CASE " + linebreak
        + "             WHEN f.value:totalRowCount != lh.row_count THEN 'Row count does not match between Files and Extracted.' " + linebreak
		+ "             WHEN lh.Status = 'LOADED' THEN '' " + linebreak
        + "             WHEN lh.Status = 'LOAD_FAILED' THEN lh.FIRST_ERROR_MESSAGE " + linebreak
        + "             ELSE null " + linebreak
        + "         END,'|') AS errorMessage," + linebreak
        + "     f.value:fileNumber AS fileNumber, " + linebreak
        + "     CASE WHEN lh.Status = 'LOADED' THEN 'FI' " + linebreak
        + "          WHEN lh.Status = 'LOAD_FAILED' THEN 'ER' " + linebreak
        + "             ELSE 'NA' " + linebreak
        + "           END AS Status, " + linebreak
        + "     f.value:totalRowCount AS totalRecordsInFile, " + linebreak
        + "     lh.row_count AS totalRecordsExtracted, " + linebreak
        + "     lh.Last_load_time AS loadDate " + linebreak
        + " FROM STG.tempArrayFiles f " + linebreak
		+ " LEFT OUTER JOIN STG.tempLoadHistory lh " + linebreak
		+ "		ON lh.file_name LIKE '%' || f.value:fileName || '%' " + linebreak
		+ " WHERE lh.RID = 1 " + linebreak
        + " GROUP BY f.value,lh.Status,lh.row_count,lh.Last_load_time; ";

    if(isDebug){
      output.message.push("--create temp table STG.tempInsert using inserting to Audit tbl");
      output.message.push(command + linebreak);
    }else{
		try{
            statement = snowflake.createStatement({sqlText: command});
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
    
    //Check for any ErrorCount and Errormessage
    command = "SELECT errorCount ,errorMessage FROM STG.tempInsert; ";

    if(isDebug){
        output.message.push("--Check for any ErrorCount and Errormessage");
        output.message.push(command + linebreak);
    }else{
        try{
            statement = snowflake.createStatement({sqlText: command});
            recordSet = statement.execute();
            recordSet.next();
            
            output.status = Number(recordSet.getColumnValue(1)) == 0 ? "succeeded" : "failed";
            output.message.push(Number(recordSet.getColumnValue(1)) == 0 ? "" : recordSet.getColumnValue(2));
            output.returnStatus = Number(recordSet.getColumnValue(1)) == 0 ? 1 : -1;
            output.audit = "logged";
            
            //Log into a file - call stored procedure.
        }catch(err){        
            //Log into a file - call stored procedure.
            
            output.returnStatus = -1;
            output.rowsAffected = -1;
            output.status = "failed";
            output.message.push(err.message);   
			output.message.push("Error Command: " + command);
			return output;
        }
    }

	//Insert to adm.Process_File_Audit
     command = "INSERT INTO ADM.PROCESS_FILE_AUDIT("   + linebreak
			+"   PROCESS_AUDIT_ID,"   + linebreak
			+"   FILE_NUMBER,"   + linebreak
			+"   STATUS,"   + linebreak
			+"	 TOTAL_RECORDS_IN_FILE,"   + linebreak
			+"	 TOTAL_RECORDS_EXTRACTED,"   + linebreak
            +"	 TOTAL_RECORDS_WITH_ERRORS,"   + linebreak
            +"	 LOAD_DATE,"   + linebreak
            +"	 CREATE_DATE,"   + linebreak
            +"   LAST_CHANGE_DATE )"   + linebreak
            +" SELECT " + processAuditId.toString() +"," + linebreak
			+"   fileNumber," + linebreak
			+"   Status," + linebreak
			+"   totalRecordsInFile," + linebreak
			+"   totalRecordsExtracted," + linebreak
			+"   0," + linebreak
            +"   loadDate," + linebreak
			+"   CURRENT_TIMESTAMP() ," + linebreak
			+"   CURRENT_TIMESTAMP() " + linebreak
			+" FROM STG.tempInsert ;";
			     
        if(isDebug){
            output.message.push("--Insert adm.Process_File_Audit");
            output.message.push(command + linebreak);
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

	//Verify primary key constraints
	command = "CALL ADM.ETL_VERIFY_PK_VIOLATION('" 
		+ fullTableName +  "', " + processAuditId.toString() + ", false);";
	if(isDebug){
        output.message.push("--Verify primary key constraints");
        output.message.push(command + linebreak);
    }else{
		statement = snowflake.createStatement({sqlText:command});
        recordSet = statement.execute();
        recordSet.next();
        if(recordSet.getColumnValue(1).returnStatus == 2){
			output.returnStatus = -1;
            output.rowsAffected = -1;
            output.status = "failed";
            output.message.push(command + ". Error: Primary key violation.");
        }else if(recordSet.getColumnValue(1).returnStatus == -1){
            output.returnStatus = -1;
            output.rowsAffected = -1;
            output.status = "failed";
            output.message.push(command + ". Error: Failed.");
        }
	}

    return output;
$$;

CREATE OR REPLACE PROCEDURE adm.ETL_LOAD_POSTING_GROUP_INTO_STAGING(
    "jsonTables" STRING, -- output.data, get it from sproc #2.
    "externalStage" STRING, --= 'ACSODS_DEV.STG.@DEV_ETL',
	"fileFolder" STRING,
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
    
    let linebreak = "\r\n";
    let tab = "\t";
    
    jsonTables = JSON.parse(jsonTables);
    let processAuditId = "";
    let auditTableData = "";
    let totalRecodsLoaded = 0;
        
    for(let i = 0; i < jsonTables.tableData.length; i++) {
		//get processAuditId
        command = "SELECT PROCESS_AUDIT_ID FROM ADM.PROCESS_INJEST_AUDIT " + linebreak
			+ " WHERE POSTING_GROUP_AUDIT_ID = " + jsonTables.postingGroupAuditId.toString() + linebreak
			+ " AND PROCESS_ID = " + jsonTables.tableData[i].processId.toString() + linebreak
			+ " AND STATUS = 'S' " + linebreak
			+ " ORDER BY PROCESS_AUDIT_ID DESC LIMIT 1;";
        if(isDebug){
			output.message.push("--get processAuditId for " + jsonTables.tableData[i].targetTableName);
			output.message.push(command);
        }else{
			//execution
			try{
				statement = snowflake.createStatement({sqlText:command});
				recordSet = statement.execute();
				recordSet.next();
				processAuditId = recordSet.getColumnValue(1);
			}catch(err){
				output.returnStatus = -1;
				output.rowsAffected = -1;
				output.status = "failed";
				output.message.push(command + ". Error: " + err.message);
				continue;
			}
        }
         
		//load it into STG table
        command = "CALL adm.Etl_Load_File_Into_Staging( " + linebreak
			+ processAuditId.toString() + linebreak
			+ ", '" + jsonTables.tableData[i].targetTableName + "'" + linebreak
			+ ", '" + jsonTables.snapshotDateTime + "'" + linebreak
			+ ",'" + externalStage + "'" + linebreak
			+ ",'" + fileFolder + "'" + linebreak
			+ ",parse_json('" + JSON.stringify(jsonTables.tableData[i].tableFiles) + "')" + linebreak
			+ ",false" + linebreak
			+ ",false);";
         
        if(isDebug){
			output.message.push("--load it into STG table for " + jsonTables.tableData[i].targetTableName);
			output.message.push(command);
        }else{
			try{
				statement = snowflake.createStatement({sqlText:command});
				recordSet = statement.execute();
				recordSet.next();
				totalRecodsLoaded = recordSet.getColumnValue(1).rowsAffected;
				if(recordSet.getColumnValue(1).returnStatus == -1){
					output.returnStatus = -1;
					output.rowsAffected = -1;
					output.status = "failed";
					output.message.push(recordSet.getColumnValue(1).message);
					output.message.push("Error Command: " + command);
					continue;
				}
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

CREATE OR REPLACE PROCEDURE adm.ETL_LOAD_POSTING_GROUP_INTO_STAGING_multithread(
    "numberOfPipelines" FLOAT,
    "warehouseName" STRING,
    "timeoutInMinutes" FLOAT,
    "checkpointWaitingTimeInSeconds" FLOAT,
    "postingGroupAuditId" STRING, -- output.data, get it from sproc #2.
    "externalStage" STRING, --= 'ACSODS_DEV.STG.@DEV_ETL',
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
    postingGroupAuditId = Number(postingGroupAuditId);
        
    let processAuditId = "";
    let auditTableData = "";
    let totalRecodsLoaded = 0;
    let suspendedTaskName = "";
	let actualNumberOfPipelines = -1;
	let fileFolder = "";
        
    let temporary;
    let pipeline = [];
    
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
		+ postingGroupAuditId.toString() + "," + linebreak
		+ "true," + linebreak
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
	command = "CREATE OR REPLACE TEMPORARY TABLE ADM.TMP_LATEST_PROCESS_AUDIT AS " + linebreak
		+ "SELECT MAX(PROCESS_AUDIT_ID) AS PROCESS_AUDIT_ID " + linebreak
		+ "FROM ADM.PROCESS_INJEST_AUDIT " + linebreak
		+ "WHERE POSTING_GROUP_AUDIT_ID = " + postingGroupAuditId.toString() + linebreak
		+ "GROUP BY PROCESS_ID;";
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
	command = "UPDATE ADM.PROCESS_INJEST_AUDIT PIA " + linebreak
		+ "SET  " + linebreak
		+ "    TOTAL_RECORDS_EXTRACTED = B.TOTAL_RECORDS_EXTRACTED, " + linebreak
		+ "    STATUS = 'L', " + linebreak
		+ "    LOAD_DATE = CURRENT_TIMESTAMP(), " + linebreak
		+ "    LAST_CHANGE_DATE = CURRENT_TIMESTAMP() " + linebreak
		+ "FROM ( " + linebreak
		+ "    SELECT PIA.PROCESS_AUDIT_ID, " + linebreak
		+ "        SUM(PFA.TOTAL_RECORDS_EXTRACTED) TOTAL_RECORDS_EXTRACTED, " + linebreak
		+ "        SUM(CASE WHEN PFA.status = 'FI' THEN 0 ELSE 1 END) AS ERROR_COUNT, " + linebreak
		+ "        SUM(CASE WHEN PFA.TOTAL_RECORDS_IN_FILE = PFA.TOTAL_RECORDS_EXTRACTED " + linebreak
		+ "            THEN 0 ELSE 1 END) AS UNMATCHED_FILE_COUNT " + linebreak
		+ "    FROM ADM.TMP_LATEST_PROCESS_AUDIT PIA " + linebreak
		+ "    INNER JOIN ADM.PROCESS_FILE_AUDIT PFA " + linebreak
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

CREATE OR REPLACE PROCEDURE adm.ETL_LOAD_POSTING_GROUP_INTO_TARGET(
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
    
    jsonTables = JSON.parse(jsonTables);
    let injestTypeId;
    
    injestTypeId = jsonTables.loadType == 'FULL'? 0 : 1;
 
    let postingGroupAuditId = jsonTables.postingGroupAuditId;
        
    for(let i = 0; i < jsonTables.tableData.length; i++) {
         targetTableName = jsonTables.tableData[i].targetTableName;
         
         command = "CALL ADM.ETL_INSERT_PROCESS_INTO_TARGET_FROM_STAGING ('"+targetTableName+"',"+injestTypeId+","+postingGroupAuditId+",'False')";
         
         if(isDebug){
            output.message.push("--For table " + targetTableName + ", insert into SRC from STG.");
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
                    continue;
                }
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
     
    if(isDebug){
        output.returnStatus = 0;
        output.rowsAffected = -1;
        output.status = "debug";
        output.message = commands;
    }else if(output.returnStatus != -1){
        output.rowsAffected = -1;
        output.status = "succeeded";
        //output.message = "";
    }
    
    return output;

$$;

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

$$;CREATE OR REPLACE PROCEDURE adm.ETL_LOG_ERRORS(
  "masterProcedureTaskName" VARCHAR,
  "masterProcedureSchemaName" VARCHAR,
  "logErrorsTaskName" VARCHAR,
  "logErrorsSchemaName" VARCHAR,
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
    
    let command, statement, recordSet;
    let masterProcedureTaskState = "";
    let currentTime = new Date();
	let nextDay = new Date();
    nextDay.setDate(new Date().getDate()+1);
    let dateOfMonthOfNextDay = String(nextDay.getDate());
    let monthOfNextDay = String(nextDay.getMonth()+1);;
	let dailySchedule = "USING CRON 0,10,20,30,40,50 18-22";
	let isLastRun = (Number(currentTime.getHours()) == 22 && Number(currentTime.getMinutes()) >= 50) 
		|| (Number(currentTime.getHours()) > 22) ? true:false;

    let linebreak = "\r\n";
    
    //Get All Errors since last run.
    
    command = "INSERT INTO ADM.ERROR_LOG" + linebreak
        + "SELECT IFNULL((SELECT MAX(POSTING_GROUP_AUDIT_ID) FROM ADM.POSTING_GROUP_INJEST_AUDIT WHERE STATUS = 'S'),-1) POSTING_GROUP_AUDIT_ID" + linebreak
        + "    ,10 EVENT_ID" + linebreak
        + "    ,ERROR_MESSAGE" + linebreak
        + "    ,CURRENT_TIMESTAMP::TIMESTAMP_NTZ LOG_DATE" + linebreak
        + "FROM TABLE(information_schema.task_history())" + linebreak
        + "WHERE name = UPPER('"+masterProcedureTaskName+"')" + linebreak
        + "    AND SCHEMA_NAME = UPPER('"+masterProcedureSchemaName+"')" + linebreak
        + "    AND STATE <> 'SUCCEEDED'" + linebreak
        + "    AND COMPLETED_TIME::TIMESTAMP_NTZ > IFNULL((SELECT MAX(LOG_DATE) FROM ADM.ERROR_LOG WHERE EVENT_ID = 10),'1900-01-01');";

    if(isDebug){
        output.message.push("--Get All Errors since last run.");
        output.message.push(command);
    }else{
        try{
            statement = snowflake.createStatement({sqlText: command});
            statement.execute();
        }catch(err){        
            output.returnStatus = -1;
            output.rowsAffected = -1;
            output.audit= 'not logged';
            output.status = 'failed';
            output.message.push(err.message);
			output.message.push("Error Command: " + command);
			return output;
        }
    }
    
    //Get latest state of the master task, 
    command = "SELECT STATE" + linebreak
        + "FROM TABLE(INFORMATION_SCHEMA.TASK_HISTORY())" + linebreak
        + "WHERE NAME = UPPER('"+masterProcedureTaskName+"')" + linebreak
        + "    AND SCHEMA_NAME = UPPER('"+masterProcedureSchemaName+"')" + linebreak
        + "ORDER BY SCHEDULED_TIME DESC" + linebreak
        + "LIMIT 1;";
    if(isDebug){
        output.message.push("--Get latest state of the master task,");
        output.message.push(command);
    }else{
        try{
            statement = snowflake.createStatement({sqlText: command});
            recordSet = statement.execute();
            if(recordSet.next())
                masterProcedureTaskState = recordSet.getColumnValue(1);
        }catch(err){
            output.returnStatus = -1;
            output.rowsAffected = -1;
            output.audit= 'not logged';
            output.status = 'failed';
            output.message.push(err.message);
			output.message.push("Error Command: " + command);
			return output;
        }
    }
    
    //suspend task before altering its schedule
    command = "ALTER TASK IF EXISTS " + logErrorsSchemaName + "." + logErrorsTaskName + " SUSPEND;";
    if(isDebug){
        output.message.push("--Suspend task before altering its schedule.");
        output.message.push(command);
    }else{
        if((masterProcedureTaskState != "EXECUTING" && masterProcedureTaskState != "") || isLastRun){
			try{
				statement = snowflake.createStatement({sqlText: command});
				statement.execute();
			}catch(err){
				output.returnStatus = -1;
				output.rowsAffected = -1;
				output.audit= 'not logged';
				output.status = 'failed';
				output.message.push(err.message);
				output.message.push("Error Command: " + command);
				return output;
			}
		}
    }
    
    //if not executing, then reschedule logError task to next day.
    command = "ALTER TASK IF EXISTS " + logErrorsSchemaName + "." + logErrorsTaskName + linebreak
        + "SET SCHEDULE = 'USING CRON 0,10,20,30,40,50 18-22 " + dateOfMonthOfNextDay + " " 
        + monthOfNextDay + " * America/Los_Angeles';";
    if(isDebug){
        output.message.push("--If not executing, then reschedule logError task to next day.");
        output.message.push(command);
    }else{
        if((masterProcedureTaskState != "EXECUTING" && masterProcedureTaskState != "") || isLastRun){
            try{
                statement = snowflake.createStatement({sqlText: command});
                statement.execute();
            }catch(err){
                output.returnStatus = -1;
                output.rowsAffected = -1;
                output.audit= 'not logged';
                output.status = 'failed';
                output.message.push(err.message);
				output.message.push("Error Command: " + command);
				return output;
            }
        }
    }
    
    //resume task after altering its schedule
    command = "ALTER TASK IF EXISTS " + logErrorsSchemaName + "." + logErrorsTaskName + " RESUME;";
    if(isDebug){
        output.message.push("--Resume task after altering its schedule.");
        output.message.push(command);
    }else{
        if((masterProcedureTaskState != "EXECUTING" && masterProcedureTaskState != "") || isLastRun){
			try{
				statement = snowflake.createStatement({sqlText: command});
				statement.execute();
			}catch(err){
				output.returnStatus = -1;
				output.rowsAffected = -1;
				output.audit= 'not logged';
				output.status = 'failed';
				output.message.push(err.message);
				output.message.push("Error Command: " + command);
				return output;
			}
		}
    }
    
    if(isDebug){
        output.returnStatus = 0;
        output.status = 'debug';
    }else if(output.returnStatus == 1){
        output.returnStatus = 1;
        output.audit= 'not logged';
        output.status = 'succeeded';
        output.message = '';
    }
    
    return output;
 
 $$; 

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

create or replace procedure adm.ETL_MASTER_SNOWFLAKE_ODS_LOAD_multithread(
  "numberOfPipelines" FLOAT,
  "warehouseName" STRING,
  "timeoutInMinutes" FLOAT,
  "checkpointWaitingTimeInSeconds" FLOAT,
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
	let currentdate;
	let currentTimestamp;
	let newSchemaNameForSrc = "SRC";
	let newSchemaNameForRpt = "RPT";
	let tableExists = false;

    numberOfPipelines = Number(numberOfPipelines);
    timeoutInMinutes = Number(timeoutInMinutes);
    checkpointWaitingTimeInSeconds = Number(checkpointWaitingTimeInSeconds);

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
        if(tableFileList.data.totalFileCount > 0){
            //load process files to staging
            command = "CALL ADM.ETL_LOAD_POSTING_GROUP_INTO_STAGING_MULTITHREAD (" + linebreak
            + numberOfPipelines.toString() + "," + linebreak
            + "'" + warehouseName.toUpperCase() + "'," + linebreak
            + timeoutInMinutes.toString() + ", " + linebreak
            + checkpointWaitingTimeInSeconds.toString() + ", " + linebreak
            + "'"+tableFileList.data.postingGroupAuditId.toString()+"'," + linebreak
            + "'"+externalStage+"'," + linebreak
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
        command = "WITH CTE_CONTROL_FILE_PROCESSES AS(" + linebreak
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

CREATE OR REPLACE PROCEDURE ADM.ETL_VERIFY_PK_VIOLATION(
   "fullTableName" STRING,
   "processAuditId" FLOAT,
   "isDebug" BOOLEAN
)
returns VARIANT
language javascript
execute as caller
as
$$

    const output = {
        returnStatus: 1, // 2-ErrorIdentified
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
    let pkColumns = "";
	let isCoreTable = false;
         
    //Get the PK Columns for Src/Rpt Schema
    command = "SELECT LISTAGG(C.COLUMN_NAME, ' ,') within group (ORDER BY C.ORDINAL_POSITION) AS pkColumns," + linebreak
		+ "    P.IS_SNAPSHOT AS isCoreTable" + linebreak
		+ "FROM ADM.PROCESS_PRIMARY_KEY PPK " + linebreak
		+ "INNER JOIN ADM.PROCESS P " + linebreak
		+ "    ON PPK.PROCESS_ID = P.PROCESS_ID " + linebreak
		+ "    AND UPPER(P.TARGET_TABLE_NAME) = UPPER('" + fullTableName.split(".")[1] + "') " + linebreak
		+ "    AND UPPER(P.TARGET_SCHEMA_NAME) = UPPER('" + fullTableName.split(".")[0] + "') " + linebreak
		+ "INNER JOIN INFORMATION_SCHEMA.COLUMNS C " + linebreak
		+ "    ON UPPER(PPK.PRIMARY_KEY_COLUMN) = C.COLUMN_NAME " + linebreak
		+ "    AND UPPER(P.TARGET_TABLE_NAME) = C.TABLE_NAME " + linebreak
		+ "    AND UPPER(P.TARGET_SCHEMA_NAME) = C.TABLE_SCHEMA " + linebreak
		+ "    AND UPPER(PPK.PRIMARY_KEY_COLUMN) != 'ODSPOSTINGGROUPAUDITID'" + linebreak
		+ "GROUP BY P.IS_SNAPSHOT;";

	if(isDebug){
		arrayCommands.push("--Get the PK Columns from Src Schema")
		arrayCommands.push(command);
	}else if(output.returnStatus > -1){
		try{
			statement = snowflake.createStatement({sqlText:command});
			recordSet = statement.execute();
			recordSet.next();
			pkColumns = recordSet.getColumnValue(1);
			isCoreTable = recordSet.getColumnValue(2);
		}catch(err){
			output.returnStatus = -1;
			output.rowsAffected = -1;
			output.audit= 'not logged';
			output.status = 'failed';
			output.message.push(err.message);   
			output.message.push("Error Command: " + command);
		}
	}

    //Find any duplicates in the stg where odsRowIsCurrent = 1 based on the PK from the src
    command = "INSERT INTO ADM.ERROR_LOG" + linebreak
        + "SELECT  " + processAuditId + ", 1,  CONCAT_WS(','," + pkColumns +"), CURRENT_DATE()" + linebreak
        + "FROM stg." + fullTableName.split(".")[1] + linebreak
        + "WHERE 1 = 1 " + linebreak
        + (fullTableName.split(".")[0].toUpperCase() == "SRC" ? "    AND ODSROWISCURRENT = 1 " + linebreak : "")
		+ "GROUP BY " + pkColumns + linebreak
		+ (isCoreTable ? "    , ODSPOSTINGGROUPAUDITID" + linebreak : "")
        + "HAVING COUNT(*) > 1; "

   if(isDebug){
        arrayCommands.push("--Find any duplicates in the stg where odsRowIsCurrent = 1 based on the PK from the src")
        arrayCommands.push(command);
        output.returnStatus = 0;
        output.rowsAffected = -1;
        output.status = "debug";
        output.message = arrayCommands;
    }else if(output.returnStatus > -1){
        //execution
        try{
			statement = snowflake.createStatement({sqlText:command});
			recordSet = statement.execute();
			recordSet.next();

			//Check if the table has a duplicate inserted into Process_Error_Log table
			command = "SELECT $1 FROM TABLE(RESULT_SCAN(LAST_QUERY_ID()));" 
			statement = snowflake.createStatement({sqlText:command});
			recordSet = statement.execute();
			recordSet.next();
			output.rowsAffected = recordSet.getColumnValue(1);
			if( output.rowsAffected > 0){
				output.returnStatus = 2; 
			}else{
				output.returnStatus = 1; 
			}
			output.audit= 'logged';
			output.status = 'succeeded';
			output.message = '';
		}catch(err){        
			output.returnStatus = -1;
			output.rowsAffected = -1;
			output.audit= 'logged';
			output.status = 'failed';
			output.message = err.message;   
		}
 }

  return output
    
$$;

create or replace procedure adm.executeTaskThenSuspend(
  "taskStatements" string,
  "taskName" string,
  "isDebug" boolean
)
returns variant
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

    let cmd, stmt, rs;
    let linebreak = "\r\n";

    taskStatements = taskStatements.split("~$~");

    for(let i = 0; i < taskStatements.length; i++){
        if(isDebug){
            output.message.push(taskStatements[i]);
        }else{
            try{
                cmd = taskStatements[i];
                stmt = snowflake.createStatement({sqlText:cmd});
                rs = stmt.execute();
                if(rs.next()){
                    if(rs.getColumnValue(1).status == "failed"){
                        output.returnStatus = -1;
                        output.message.push(rs.getColumnValue(1).message);
                    }
                }
            }catch(err){
                output.returnStatus = -1;
                output.message.push(err.message);
                output.message.push(cmd);
            }
        }
    }

    cmd = "ALTER TASK " + taskName + " SUSPEND;";
    if(isDebug){
        output.message.push(cmd);
    }else{
        stmt = snowflake.createStatement({sqlText:cmd});
        rs = stmt.execute();
    }

    if(output.returnStatus == -1){
        cmd = "call system$set_return_value('" + output.message.join(";\r\n").replace(/'/g,"''") + "');";
        if(isDebug){
            output.message.push(cmd);
        }else{
            stmt = snowflake.createStatement({sqlText:cmd});
            rs = stmt.execute();
        }
    }
    
    return output;

$$;