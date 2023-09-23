CREATE TABLE IF NOT EXISTS src.ClaimantManualProviderSummary (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , ManualProviderId NUMBER(10, 0) NOT NULL
	 , DemandClaimantId NUMBER(10, 0) NOT NULL
	 , FirstDateOfService DATETIME NULL
	 , LastDateOfService DATETIME NULL
	 , Visits NUMBER(10, 0) NULL
	 , ChargedAmount NUMBER(19, 4) NULL
	 , EvaluatedAmount NUMBER(19, 4) NULL
	 , MinimumEvaluatedAmount NUMBER(19, 4) NULL
	 , MaximumEvaluatedAmount NUMBER(19, 4) NULL
	 , Comments VARCHAR(255) NULL
);

