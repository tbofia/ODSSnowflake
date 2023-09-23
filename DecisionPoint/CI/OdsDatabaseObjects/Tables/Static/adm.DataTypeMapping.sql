

IF OBJECT_ID('adm.DataTypeMapping', 'U') IS NULL
BEGIN
	CREATE TABLE adm.dataTypeMapping(
		SqlServerDataType VARCHAR(100) NULL,
		SnowflakeDataType VARCHAR(100) NULL,
		StartDate DATETIME2(7) NULL,
		EndDate DATETIME2(7) NULL
	) 
END
GO

