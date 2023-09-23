CREATE OR REPLACE TABLE stg.DeductibleRuleCriteriaCoverageType (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , DeductibleRuleCriteriaId NUMBER(10, 0) NOT NULL
	 , CoverageType VARCHAR(5) NOT NULL
);

