CREATE TABLE IF NOT EXISTS src.PlaceOfServiceDictionary (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , PlaceOfServiceCode NUMBER(5, 0) NOT NULL
	 , Description VARCHAR(255) NULL
	 , Facility NUMBER(5, 0) NULL
	 , MHL NUMBER(5, 0) NULL
	 , PlusFour NUMBER(5, 0) NULL
	 , Institution NUMBER(10, 0) NULL
	 , StartDate DATETIME NOT NULL
	 , EndDate DATETIME NULL
);

