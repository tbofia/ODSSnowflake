IF SCHEMA_ID('adm') IS NULL
EXEC ('CREATE SCHEMA adm')
GO

IF SCHEMA_ID('stg') IS NULL
EXEC ('CREATE SCHEMA stg')
GO

IF SCHEMA_ID('rpt') IS NULL
EXEC ('CREATE SCHEMA rpt')
GO


