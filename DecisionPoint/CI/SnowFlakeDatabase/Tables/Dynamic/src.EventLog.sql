CREATE TABLE IF NOT EXISTS src.EventLog (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , EventLogId NUMBER(10, 0) NOT NULL
	 , ObjectName VARCHAR(50) NULL
	 , ObjectId NUMBER(10, 0) NULL
	 , UserName VARCHAR(15) NULL
	 , LogDate TIMESTAMP_LTZ(7) NULL
	 , ActionName VARCHAR(20) NULL
	 , OrganizationId VARCHAR(100) NULL
);

