CREATE TABLE IF NOT EXISTS src.SentryRuleTypeCriteria (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , RuleTypeId NUMBER(10, 0) NOT NULL
	 , CriteriaId NUMBER(10, 0) NOT NULL
);

