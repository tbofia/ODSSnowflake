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


