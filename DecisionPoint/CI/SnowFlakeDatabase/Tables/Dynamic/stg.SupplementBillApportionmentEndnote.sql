CREATE OR REPLACE TABLE stg.SupplementBillApportionmentEndnote (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , BillId NUMBER(10, 0) NOT NULL
	 , SequenceNumber NUMBER(5, 0) NOT NULL
	 , LineNumber NUMBER(5, 0) NOT NULL
	 , Endnote NUMBER(10, 0) NOT NULL
);

