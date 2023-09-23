CREATE TABLE IF NOT EXISTS src.Tag (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , TagId NUMBER(10, 0) NOT NULL
	 , NAME VARCHAR(50) NULL
	 , DateCreated TIMESTAMP_LTZ(7) NULL
	 , DateModified TIMESTAMP_LTZ(7) NULL
	 , CreatedBy VARCHAR(15) NULL
	 , ModifiedBy VARCHAR(15) NULL
);

