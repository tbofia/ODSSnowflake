CREATE TABLE IF NOT EXISTS src.VpnSavingTransactionType (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , VpnSavingTransactionTypeId NUMBER(10, 0) NOT NULL
	 , VpnSavingTransactionType VARCHAR(50) NULL
);

