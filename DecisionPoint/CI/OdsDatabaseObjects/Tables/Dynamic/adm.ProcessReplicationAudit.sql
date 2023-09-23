IF OBJECT_ID('adm.ProcessReplicationAudit', 'U') IS NULL
    BEGIN
		CREATE TABLE adm.ProcessReplicationAudit(
			ProcessReplicationAuditId int IDENTITY(1,1) NOT NULL,
			ReplicationAuditId int NULL,
			ProcessId int NULL,
			SourceTableName varchar(250) NULL,
			Status varchar(3) NULL,
			TotalNumberOfFiles int NULL,
			TotalRecordsInSource bigint NULL,
			CreateDate datetime2(7) NULL,
			LastChangeDate datetime2(7) NULL
		);
		ALTER TABLE adm.ProcessReplicationAudit ADD 
		CONSTRAINT PK_ProcessReplicationAudit PRIMARY KEY CLUSTERED (ProcessReplicationAuditId);
	END
GO


IF NOT EXISTS ( SELECT  *
                FROM    INFORMATION_SCHEMA.COLUMNS
                WHERE   TABLE_SCHEMA = 'adm'
					AND TABLE_NAME = N'ProcessReplicationAudit'
                    AND COLUMN_NAME = 'TotalRecordsInSource'
					AND DATA_TYPE = 'bigint' )
BEGIN
    ALTER TABLE adm.ProcessReplicationAudit ALTER COLUMN  TotalRecordsInSource BIGINT
END
GO
