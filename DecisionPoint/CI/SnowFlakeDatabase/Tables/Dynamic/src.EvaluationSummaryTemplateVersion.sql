CREATE TABLE IF NOT EXISTS src.EvaluationSummaryTemplateVersion (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , EvaluationSummaryTemplateVersionId NUMBER(10, 0) NOT NULL
	 , Template VARCHAR NULL
	 , TemplateHash BINARY(32) NULL
	 , CreatedDate TIMESTAMP_LTZ(7) NULL
);

