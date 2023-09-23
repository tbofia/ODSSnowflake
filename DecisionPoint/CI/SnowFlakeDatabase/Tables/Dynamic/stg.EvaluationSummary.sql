CREATE OR REPLACE TABLE stg.EvaluationSummary (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , DemandClaimantId NUMBER(10, 0) NOT NULL
	 , Details VARCHAR NULL
	 , CreatedBy VARCHAR(50) NULL
	 , CreatedDate TIMESTAMP_LTZ(7) NULL
	 , ModifiedBy VARCHAR(50) NULL
	 , ModifiedDate TIMESTAMP_LTZ(7) NULL
	 , EvaluationSummaryTemplateVersionId NUMBER(10, 0) NULL
);

