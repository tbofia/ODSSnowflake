CREATE OR REPLACE TABLE stg.SEC_User_OfficeGroups (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , SECUserOfficeGroupId NUMBER(10, 0) NOT NULL
	 , UserId NUMBER(10, 0) NULL
	 , OffcGroupId NUMBER(10, 0) NULL
);

