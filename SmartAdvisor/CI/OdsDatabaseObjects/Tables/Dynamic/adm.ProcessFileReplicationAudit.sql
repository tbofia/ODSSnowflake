IF OBJECT_ID('adm.ProcessFileReplicationAudit', 'U') IS NULL
    BEGIN
		CREATE TABLE adm.ProcessFileReplicationAudit(
			ProcessFileReplicationAuditId int IDENTITY(1,1) NOT NULL,
			ProcessReplicationAuditId int NULL,
			FileNumber int NULL,
			Status varchar(3) NULL,
			TotalRecordsInFile BIGINT NULL,
			LoadDate datetime2(7) NULL,
			CreateDate datetime2(7) NULL,
			LastChangeDate datetime2(7) NULL,
			FileSize numeric(10, 3) NULL
		); 
		ALTER TABLE adm.ProcessFileReplicationAudit ADD 
		CONSTRAINT PK_ProcessFileReplicationAudit PRIMARY KEY CLUSTERED (ProcessFileReplicationAuditId);
	END
GO


