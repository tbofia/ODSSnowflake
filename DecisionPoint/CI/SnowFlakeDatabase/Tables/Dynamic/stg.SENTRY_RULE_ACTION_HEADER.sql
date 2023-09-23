CREATE OR REPLACE TABLE stg.SENTRY_RULE_ACTION_HEADER (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , RuleID NUMBER(10, 0) NOT NULL
	 , EndnoteShort VARCHAR(50) NULL
	 , EndnoteLong VARCHAR NULL
);

