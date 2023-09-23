CREATE TABLE IF NOT EXISTS src.ReferenceBillApcLines (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , BillIdNo NUMBER(10, 0) NOT NULL
	 , Line_No NUMBER(5, 0) NOT NULL
	 , PaymentAPC VARCHAR(5) NULL
	 , ServiceIndicator VARCHAR(2) NULL
	 , PaymentIndicator VARCHAR(1) NULL
	 , OutlierAmount NUMBER(19, 4) NULL
	 , PricerAllowed NUMBER(19, 4) NULL
	 , MedicareAmount NUMBER(19, 4) NULL
);

