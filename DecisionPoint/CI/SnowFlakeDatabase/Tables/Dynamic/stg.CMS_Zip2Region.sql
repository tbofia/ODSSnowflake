CREATE OR REPLACE TABLE stg.CMS_Zip2Region (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , StartDate DATETIME NOT NULL
	 , EndDate DATETIME NULL
	 , ZIP_Code VARCHAR(5) NOT NULL
	 , State VARCHAR(2) NULL
	 , Region VARCHAR(2) NULL
	 , AmbRegion VARCHAR(2) NULL
	 , RuralFlag NUMBER(5, 0) NULL
	 , ASCRegion NUMBER(5, 0) NULL
	 , PlusFour NUMBER(5, 0) NULL
	 , CarrierId NUMBER(10, 0) NULL
);

