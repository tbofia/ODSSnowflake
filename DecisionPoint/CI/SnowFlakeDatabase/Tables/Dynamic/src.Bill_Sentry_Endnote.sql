CREATE TABLE IF NOT EXISTS src.BILL_SENTRY_ENDNOTE (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , BillID NUMBER(10, 0) NOT NULL
	 , Line NUMBER(10, 0) NOT NULL
	 , RuleID NUMBER(10, 0) NOT NULL
	 , PercentDiscount FLOAT(24) NULL
	 , ActionId NUMBER(5, 0) NULL
);

