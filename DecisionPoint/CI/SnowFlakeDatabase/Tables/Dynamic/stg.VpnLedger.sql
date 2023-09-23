CREATE OR REPLACE TABLE stg.VpnLedger (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , TransactionID NUMBER(19, 0) NOT NULL
	 , TransactionTypeID NUMBER(10, 0) NULL
	 , BillIdNo NUMBER(10, 0) NULL
	 , Line_No NUMBER(5, 0) NULL
	 , Charged NUMBER(19, 4) NULL
	 , DPAllowed NUMBER(19, 4) NULL
	 , VPNAllowed NUMBER(19, 4) NULL
	 , Savings NUMBER(19, 4) NULL
	 , Credits NUMBER(19, 4) NULL
	 , HasOverride BOOLEAN NULL
	 , EndNotes VARCHAR(200) NULL
	 , NetworkIdNo NUMBER(10, 0) NULL
	 , ProcessFlag NUMBER(5, 0) NULL
	 , LineType NUMBER(10, 0) NULL
	 , DateTimeStamp DATETIME NULL
	 , SeqNo NUMBER(10, 0) NULL
	 , VPN_Ref_Line_No NUMBER(5, 0) NULL
	 , SpecialProcessing BOOLEAN NULL
	 , CreateDate DATETIME NULL
	 , LastChangedOn DATETIME NULL
	 , AdjustedCharged NUMBER(19, 4) NULL
);

