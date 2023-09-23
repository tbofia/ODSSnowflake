IF OBJECT_ID('adm.ProcessReplicationAudit', 'U') IS NULL
    BEGIN
		CREATE TABLE adm.ProcessReplicationAudit(
			ProcessReplicationAuditId int IDENTITY(1,1) NOT NULL,
			ReplicationAuditId int NULL,
			ProcessId int NULL,
			SourceTableName varchar(250) NULL,
			Status varchar(3) NULL,
			TotalNumberOfFiles int NULL,
			TotalRecordsInSource BIGINT NULL,
			CreateDate datetime2(7) NULL,
			LastChangeDate datetime2(7) NULL
		);
		ALTER TABLE adm.ProcessReplicationAudit ADD 
		CONSTRAINT PK_ProcessReplicationAudit PRIMARY KEY CLUSTERED (ProcessReplicationAuditId);
	END
GO


