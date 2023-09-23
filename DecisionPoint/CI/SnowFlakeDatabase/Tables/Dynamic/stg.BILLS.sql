CREATE OR REPLACE TABLE stg.Bills( 
	   OdsPostingGroupAuditId NUMBER(10,0) NOT NULL
	 , OdsCustomerId NUMBER(10,0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , BillIDNo NUMBER (10,0) NULL
	 , LINE_NO NUMBER (5,0) NULL
	 , LINE_NO_DISP NUMBER (5,0) NULL
	 , OVER_RIDE NUMBER (5,0) NULL
	 , DT_SVC DATETIME NULL
	 , PRC_CD VARCHAR (7) NULL
	 , UNITS FLOAT NULL
	 , TS_CD VARCHAR (14) NULL
	 , CHARGED NUMBER (19,4) NULL
	 , ALLOWED NUMBER (19,4) NULL
	 , ANALYZED NUMBER (19,4) NULL
	 , REASON1 NUMBER (10,0) NULL
	 , REASON2 NUMBER (10,0) NULL
	 , REASON3 NUMBER (10,0) NULL
	 , REASON4 NUMBER (10,0) NULL
	 , REASON5 NUMBER (10,0) NULL
	 , REASON6 NUMBER (10,0) NULL
	 , REASON7 NUMBER (10,0) NULL
	 , REASON8 NUMBER (10,0) NULL
	 , REF_LINE_NO NUMBER (5,0) NULL
	 , SUBNET VARCHAR (9) NULL
	 , OverrideReason NUMBER (5,0) NULL
	 , FEE_SCHEDULE NUMBER (19,4) NULL
	 , POS_RevCode VARCHAR (4) NULL
	 , CTGPenalty NUMBER (19,4) NULL
	 , PrePPOAllowed NUMBER (19,4) NULL
	 , PPODate DATETIME NULL
	 , PPOCTGPenalty NUMBER (19,4) NULL
	 , UCRPerUnit NUMBER (19,4) NULL
	 , FSPerUnit NUMBER (19,4) NULL
	 , HCRA_Surcharge NUMBER (19,4) NULL
	 , EligibleAmt NUMBER (19,4) NULL
	 , DPAllowed NUMBER (19,4) NULL
	 , EndDateOfService DATETIME NULL
	 , AnalyzedCtgPenalty NUMBER (19,4) NULL
	 , AnalyzedCtgPpoPenalty NUMBER (19,4) NULL
	 , RepackagedNdc VARCHAR (13) NULL
	 , OriginalNdc VARCHAR (13) NULL
	 , UnitOfMeasureId NUMBER (3,0) NULL
	 , PackageTypeOriginalNdc VARCHAR (2) NULL
	 , ServiceCode VARCHAR (25) NULL
	 , PreApportionedAmount NUMBER (19,4) NULL
	 , DeductibleApplied NUMBER (19,4) NULL
	 , BillReviewResults NUMBER (19,4) NULL
	 , PreOverriddenDeductible NUMBER (19,4) NULL
	 , RemainingBalance NUMBER (19,4) NULL
	 , CtgCoPayPenalty NUMBER (19,4) NULL
	 , PpoCtgCoPayPenaltyPercentage NUMBER (19,4) NULL
	 , AnalyzedCtgCoPayPenalty NUMBER (19,4) NULL
	 , AnalyzedPpoCtgCoPayPenaltyPercentage NUMBER (19,4) NULL
	 , CtgVunPenalty NUMBER (19,4) NULL
	 , PpoCtgVunPenaltyPercentage NUMBER (19,4) NULL
	 , AnalyzedCtgVunPenalty NUMBER (19,4) NULL
	 , AnalyzedPpoCtgVunPenaltyPercentage NUMBER (19,4) NULL
	 , RenderingNpi VARCHAR (15) NULL
 ); 
