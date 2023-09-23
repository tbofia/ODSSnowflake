CREATE TABLE IF NOT EXISTS src.Bills_Tax (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , BillsTaxId NUMBER(10, 0) NOT NULL
	 , TableType NUMBER(5, 0) NULL
	 , BillIdNo NUMBER(10, 0) NULL
	 , Line_No NUMBER(5, 0) NULL
	 , SeqNo NUMBER(5, 0) NULL
	 , TaxTypeId NUMBER(5, 0) NULL
	 , ImportTaxRate NUMBER(5, 5) NULL
	 , Tax NUMBER(19, 4) NULL
	 , OverridenTax NUMBER(19, 4) NULL
	 , ImportTaxAmount NUMBER(19, 4) NULL
);

