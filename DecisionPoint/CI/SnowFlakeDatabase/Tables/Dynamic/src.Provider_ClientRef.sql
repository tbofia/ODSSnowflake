CREATE TABLE IF NOT EXISTS src.Provider_ClientRef (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , PvdIdNo NUMBER(10, 0) NOT NULL
	 , ClientRefId VARCHAR(50) NULL
	 , ClientRefId2 VARCHAR(100) NULL
);

