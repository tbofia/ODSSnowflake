CREATE TABLE IF NOT EXISTS src.SEC_User_RightGroups (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , SECUserRightGroupId NUMBER(10, 0) NOT NULL
	 , UserId NUMBER(10, 0) NULL
	 , RightGroupId NUMBER(10, 0) NULL
);

