CREATE TABLE IF NOT EXISTS rpt.PostingGroupAudit (
	  PostingGroupAuditId NUMBER(10, 0) NOT NULL
	, OltpPostingGroupAuditId NUMBER(10, 0) NOT NULL
	, PostingGroupId NUMBER(3, 0) NOT NULL
	, CustomerId NUMBER(10, 0) NOT NULL
	, Status VARCHAR(2) NOT NULL
	, DataExtractTypeId NUMBER(10, 0) NOT NULL
	, OdsVersion VARCHAR(10) NULL
	, SnapshotCreateDate DATETIME NULL
	, CoreDBVersionId NUMBER(10,0) NULL
	, CreateDate DATETIME NOT NULL
	, LastChangeDate DATETIME NOT NULL
);
