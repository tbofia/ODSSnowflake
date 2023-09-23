CREATE TABLE IF NOT EXISTS src.EvaluationSummaryHistory (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , EvaluationSummaryHistoryId NUMBER(10, 0) NOT NULL
	 , DemandClaimantId NUMBER(10, 0) NULL
	 , EvaluationSummary VARCHAR NULL
	 , CreatedBy VARCHAR(50) NULL
	 , CreatedDate TIMESTAMP_LTZ(7) NULL
);

