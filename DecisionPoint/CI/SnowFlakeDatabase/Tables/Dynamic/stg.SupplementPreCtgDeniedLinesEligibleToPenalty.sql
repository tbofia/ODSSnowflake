CREATE OR REPLACE TABLE stg.SupplementPreCtgDeniedLinesEligibleToPenalty( 
	   OdsPostingGroupAuditId NUMBER(10,0) NOT NULL
	 , OdsCustomerId NUMBER(10,0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , BillIdNo NUMBER (10,0) NULL
	 , LineNumber NUMBER (5,0) NULL
	 , CtgPenaltyTypeId NUMBER (3,0) NULL
	 , SeqNo NUMBER (5,0) NULL
 ); 
