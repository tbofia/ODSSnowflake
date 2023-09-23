CREATE TABLE IF NOT EXISTS src.BillsOverride (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , BillsOverrideID NUMBER(10, 0) NOT NULL
	 , BillIDNo NUMBER(10, 0) NULL
	 , LINE_NO NUMBER(5, 0) NULL
	 , UserId NUMBER(10, 0) NULL
	 , DateSaved DATETIME NULL
	 , AmountBefore NUMBER(19, 4) NULL
	 , AmountAfter NUMBER(19, 4) NULL
	 , CodesOverrode VARCHAR(50) NULL
	 , SeqNo NUMBER(10, 0) NULL
);

