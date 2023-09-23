
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

