CREATE OR REPLACE TABLE stg.CoverageType (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , LongName VARCHAR(30) NULL
	 , ShortName VARCHAR(2) NOT NULL
	 , CbreCoverageTypeCode VARCHAR(2) NULL
	 , CoverageTypeCategoryCode VARCHAR(4) NULL
	 , PricingMethodId NUMBER(3, 0) NULL
);

