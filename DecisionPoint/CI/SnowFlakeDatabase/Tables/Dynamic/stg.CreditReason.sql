CREATE OR REPLACE TABLE stg.CreditReason (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , CreditReasonId NUMBER(10, 0) NOT NULL
	 , CreditReasonDesc VARCHAR(100) NULL
	 , IsVisible BOOLEAN NULL
);

