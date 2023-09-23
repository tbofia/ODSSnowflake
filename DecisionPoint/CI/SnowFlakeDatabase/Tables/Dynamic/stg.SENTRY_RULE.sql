CREATE OR REPLACE TABLE stg.SENTRY_RULE (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , RuleID NUMBER(10, 0) NOT NULL
	 , Name VARCHAR(50) NULL
	 , Description VARCHAR NULL
	 , CreatedBy VARCHAR(50) NULL
	 , CreationDate DATETIME NULL
	 , PostFixNotation VARCHAR NULL
	 , Priority NUMBER(10, 0) NULL
	 , RuleTypeID NUMBER(5, 0) NULL
);

