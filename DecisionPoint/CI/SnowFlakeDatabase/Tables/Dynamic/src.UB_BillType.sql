CREATE TABLE IF NOT EXISTS src.UB_BillType (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , TOB VARCHAR(4) NOT NULL
	 , Description VARCHAR NULL
	 , Flag NUMBER(10, 0) NULL
	 , UB_BillTypeID NUMBER(10, 0) NULL
);

