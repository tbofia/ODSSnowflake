CREATE TABLE IF NOT EXISTS src.DeductibleRuleExemptEndnote (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , Endnote NUMBER(10, 0) NOT NULL
	 , EndnoteTypeId NUMBER(3, 0) NOT NULL
);

