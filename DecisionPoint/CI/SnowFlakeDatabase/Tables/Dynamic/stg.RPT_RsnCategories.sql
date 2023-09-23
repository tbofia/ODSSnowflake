CREATE OR REPLACE TABLE stg.RPT_RsnCategories (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , CategoryIdNo NUMBER(5, 0) NOT NULL
	 , CatDesc VARCHAR(50) NULL
	 , Priority NUMBER(5, 0) NULL
);

