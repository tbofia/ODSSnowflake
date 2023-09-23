CREATE TABLE IF NOT EXISTS src.CreditReasonOverrideENMap (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , CreditReasonOverrideENMapId NUMBER(10, 0) NOT NULL
	 , CreditReasonId NUMBER(10, 0) NULL
	 , OverrideEndnoteId NUMBER(5, 0) NULL
);

