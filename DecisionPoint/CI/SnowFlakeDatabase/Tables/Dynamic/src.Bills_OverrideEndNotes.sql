CREATE TABLE IF NOT EXISTS src.Bills_OverrideEndNotes (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , OverrideEndNoteID NUMBER(10, 0) NOT NULL
	 , BillIdNo NUMBER(10, 0) NULL
	 , Line_No NUMBER(5, 0) NULL
	 , OverrideEndNote NUMBER(5, 0) NULL
	 , PercentDiscount FLOAT(24) NULL
	 , ActionId NUMBER(5, 0) NULL
);

