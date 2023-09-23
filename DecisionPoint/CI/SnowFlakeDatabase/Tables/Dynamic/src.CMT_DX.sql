CREATE TABLE IF NOT EXISTS src.CMT_DX (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , BillIDNo NUMBER(10, 0) NOT NULL
	 , DX VARCHAR(8) NOT NULL
	 , SeqNum NUMBER(5, 0) NULL
	 , POA VARCHAR(1) NULL
	 , IcdVersion NUMBER(3, 0) NOT NULL
);

