CREATE OR REPLACE TABLE stg.ny_Pharmacy (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , NDCCode VARCHAR(13) NOT NULL
	 , StartDate DATETIME NOT NULL
	 , EndDate DATETIME NULL
	 , Description VARCHAR(125) NULL
	 , Fee NUMBER(19, 4) NOT NULL
	 , TypeOfDrug NUMBER(5, 0) NOT NULL
);

