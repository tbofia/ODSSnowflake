CREATE TABLE IF NOT EXISTS src.AnalysisRuleGroup (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , AnalysisRuleGroupId NUMBER(10, 0) NOT NULL
	 , AnalysisRuleId NUMBER(10, 0) NULL
	 , AnalysisGroupId NUMBER(10, 0) NULL
);

