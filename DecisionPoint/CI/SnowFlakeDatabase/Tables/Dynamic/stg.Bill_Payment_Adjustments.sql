CREATE OR REPLACE TABLE stg.Bill_Payment_Adjustments (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , Bill_Payment_Adjustment_ID NUMBER(10, 0) NOT NULL
	 , BillIDNo NUMBER(10, 0) NULL
	 , SeqNo NUMBER(5, 0) NULL
	 , InterestFlags NUMBER(10, 0) NULL
	 , DateInterestStarts DATETIME NULL
	 , DateInterestEnds DATETIME NULL
	 , InterestAdditionalInfoReceived DATETIME NULL
	 , Interest NUMBER(19, 4) NULL
	 , Comments VARCHAR(1000) NULL
);

