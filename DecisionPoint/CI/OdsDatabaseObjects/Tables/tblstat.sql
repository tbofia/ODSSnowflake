

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


IF OBJECT_ID('adm.ProcessColumn','U') IS NULL
BEGIN
	CREATE TABLE adm.ProcessColumn(
		ProcessId INT NOT NULL,
		ColumnName VARCHAR(128) NOT NULL,
		ColumnDescription VARCHAR(8000) NULL,
		HoldsPII INT NOT NULL,
		ObfuscateWithValue VARCHAR(255) NULL,
		UseForBatchProcessing INT NULL
	);

	ALTER TABLE adm.ProcessColumn ADD
	CONSTRAINT PK_ProcessColumn PRIMARY KEY CLUSTERED (ProcessId,ColumnName);
END
GO

