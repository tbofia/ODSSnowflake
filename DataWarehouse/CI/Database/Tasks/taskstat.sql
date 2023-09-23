CREATE OR REPLACE TASK ADM.Self_Serve_Performance_Report_Savings
  WAREHOUSE = &SNOWSQL_WH
  SCHEDULE = 'USING CRON 0 23 * * * America/Los_Angeles'
AS
CALL dbo.Self_Serve_Performance_Report_Savings ('AcsOds','Datawarehouse',FALSE);
