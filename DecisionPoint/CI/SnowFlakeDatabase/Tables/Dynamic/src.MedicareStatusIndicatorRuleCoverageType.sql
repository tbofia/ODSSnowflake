CREATE TABLE IF NOT EXISTS src.MedicareStatusIndicatorRuleCoverageType (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , MedicareStatusIndicatorRuleId NUMBER(10, 0) NOT NULL
	 , ShortName VARCHAR(2) NOT NULL
);

