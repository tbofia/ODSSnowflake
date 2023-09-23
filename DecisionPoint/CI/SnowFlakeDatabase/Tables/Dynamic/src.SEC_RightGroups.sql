CREATE TABLE IF NOT EXISTS src.SEC_RightGroups (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , RightGroupId NUMBER(10, 0) NOT NULL
	 , RightGroupName VARCHAR(50) NULL
	 , RightGroupDescription VARCHAR(150) NULL
	 , CreatedDate DATETIME NULL
	 , CreatedBy VARCHAR(50) NULL
);

