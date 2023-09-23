CREATE OR REPLACE TABLE stg.BillAdjustment (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , BillLineAdjustmentId NUMBER(19, 0) NOT NULL
	 , BillIdNo NUMBER(10, 0) NULL
	 , LineNumber NUMBER(10, 0) NULL
	 , Adjustment NUMBER(19, 4) NULL
	 , EndNote NUMBER(10, 0) NULL
	 , EndNoteTypeId NUMBER(10, 0) NULL
);

