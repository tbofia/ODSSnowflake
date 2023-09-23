

IF OBJECT_ID('adm.AppVersion', 'U') IS NULL
BEGIN

    CREATE TABLE adm.AppVersion
        (
            AppVersionId INT IDENTITY(1, 1) ,
            AppVersion VARCHAR(10) NULL ,
            AppVersionDate DATETIME2(7) NULL
        );

    ALTER TABLE adm.AppVersion ADD 
    CONSTRAINT PK_AppVersion PRIMARY KEY CLUSTERED (AppVersionId);

END
GO

IF OBJECT_ID('adm.PostingGroupReplicationAudit', 'U') IS NULL
    BEGIN
		CREATE TABLE adm.PostingGroupReplicationAudit(
			ReplicationAuditId int IDENTITY(1,1) NOT NULL,
			ProductName varchar(6) NULL,
			OdsCutoffPostingGroupAuditId int NULL,
			SnapshotName varchar(255) NULL,
			Status varchar(3) NULL,
			DataExtractTypeId int NULL,
			OdsVersion varchar(10) NULL,
			SnapshotDate datetime2(7) NULL,
			DataExtractDate datetime2(7) NULL,
			CreateDate datetime2(7) NULL,
			LastChangeDate datetime2(7) NULL
		);

		ALTER TABLE adm.PostingGroupReplicationAudit ADD 
		CONSTRAINT PK_PostingGroupReplicationAudit PRIMARY KEY CLUSTERED (ReplicationAuditId);
	END
GO


IF OBJECT_ID('adm.ProcessFileReplicationAudit', 'U') IS NULL
    BEGIN
		CREATE TABLE adm.ProcessFileReplicationAudit(
			ProcessFileReplicationAuditId int IDENTITY(1,1) NOT NULL,
			ProcessReplicationAuditId int NULL,
			FileNumber int NULL,
			Status varchar(3) NULL,
			TotalRecordsInFile int NULL,
			LoadDate datetime2(7) NULL,
			CreateDate datetime2(7) NULL,
			LastChangeDate datetime2(7) NULL,
			FileSize numeric(10, 3) NULL
		); 
		ALTER TABLE adm.ProcessFileReplicationAudit ADD 
		CONSTRAINT PK_ProcessFileReplicationAudit PRIMARY KEY CLUSTERED (ProcessFileReplicationAuditId);
	END
GO


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
