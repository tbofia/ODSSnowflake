IF SCHEMA_ID('adm') IS NULL
EXEC ('CREATE SCHEMA adm')
GO

IF SCHEMA_ID('src') IS NULL
EXEC ('CREATE SCHEMA src')
GO

IF SCHEMA_ID('stg') IS NULL
EXEC ('CREATE SCHEMA stg')
GO

IF SCHEMA_ID('aw') IS NULL
EXEC ('CREATE SCHEMA aw')
GO
