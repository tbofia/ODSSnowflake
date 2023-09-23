CREATE TABLE IF NOT EXISTS src.SENTRY_RULE_CONDITION (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , RuleID NUMBER(10, 0) NOT NULL
	 , LineNumber NUMBER(10, 0) NOT NULL
	 , GroupFlag VARCHAR(50) NULL
	 , CriteriaID NUMBER(10, 0) NULL
	 , Operator VARCHAR(50) NULL
	 , ConditionValue VARCHAR(60) NULL
	 , AndOr VARCHAR(50) NULL
	 , UdfConditionId NUMBER(10, 0) NULL
);

