CREATE OR REPLACE PROCEDURE adm.ETL_LOG_ERRORS(
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

