CREATE TABLE IF NOT EXISTS src.SPECIALTY (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , SpcIdNo NUMBER(10, 0) NULL
	 , Code VARCHAR(50) NOT NULL
	 , Description VARCHAR(70) NULL
	 , PayeeSubTypeID NUMBER(10, 0) NULL
	 , TieredTypeID NUMBER(5, 0) NULL
);

