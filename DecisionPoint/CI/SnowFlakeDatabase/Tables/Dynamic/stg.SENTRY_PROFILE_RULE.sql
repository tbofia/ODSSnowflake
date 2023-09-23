CREATE OR REPLACE TABLE stg.SENTRY_PROFILE_RULE (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , ProfileID NUMBER(10, 0) NOT NULL
	 , RuleID NUMBER(10, 0) NOT NULL
	 , Priority NUMBER(10, 0) NOT NULL
);

