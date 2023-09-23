CREATE TABLE IF NOT EXISTS src.Claimant_ClientRef (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , CmtIdNo NUMBER(10, 0) NOT NULL
	 , CmtSuffix VARCHAR(50) NULL
	 , ClaimIdNo NUMBER(10, 0) NULL
);

