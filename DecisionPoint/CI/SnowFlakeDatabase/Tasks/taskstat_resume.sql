ALTER TASK ADM.ETL_Snowflake_Ods_Load SET USER_TASK_TIMEOUT_MS = 10800000; 
ALTER TASK ADM.ETL_Snowflake_Ods_Load RESUME; 
ALTER TASK ADM.Task_ETL_Log_Errors RESUME; 