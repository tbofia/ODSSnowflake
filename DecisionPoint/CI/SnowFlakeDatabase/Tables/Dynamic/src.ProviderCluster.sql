CREATE TABLE IF NOT EXISTS src.ProviderCluster (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , PvdIDNo NUMBER(10, 0) NOT NULL
	 , OrgOdsCustomerId NUMBER(10, 0) NOT NULL
	 , MitchellProviderKey VARCHAR(200) NULL
	 , ProviderClusterKey VARCHAR(200) NULL
	 , ProviderType VARCHAR(30) NULL
);

