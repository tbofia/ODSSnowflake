CREATE TABLE IF NOT EXISTS src.ClaimantProviderSummaryEvaluation (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , ClaimantProviderSummaryEvaluationId NUMBER(10, 0) NOT NULL
	 , ClaimantHeaderId NUMBER(10, 0) NULL
	 , EvaluatedAmount NUMBER(19, 4) NULL
	 , MinimumEvaluatedAmount NUMBER(19, 4) NULL
	 , MaximumEvaluatedAmount NUMBER(19, 4) NULL
	 , Comments VARCHAR(255) NULL
);

