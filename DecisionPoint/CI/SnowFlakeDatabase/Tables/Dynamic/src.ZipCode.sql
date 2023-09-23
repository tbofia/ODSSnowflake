CREATE TABLE IF NOT EXISTS src.ZipCode (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , ZipCode VARCHAR(5) NOT NULL
	 , PrimaryRecord BOOLEAN NULL
	 , STATE VARCHAR(2) NULL
	 , City VARCHAR(30) NULL
	 , CityAlias VARCHAR(30) NOT NULL
	 , County VARCHAR(30) NULL
	 , Cbsa VARCHAR(5) NULL
	 , CbsaType VARCHAR(5) NULL
	 , ZipCodeRegionId NUMBER(3, 0) NULL
);

