CREATE OR REPLACE TABLE stg.Bills_Pharm( 
	   OdsPostingGroupAuditId NUMBER(10,0) NOT NULL
	 , OdsCustomerId NUMBER(10,0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , BillIdNo NUMBER (10,0) NULL
	 , Line_No NUMBER (5,0) NULL
	 , LINE_NO_DISP NUMBER (5,0) NULL
	 , DateOfService DATETIME NULL
	 , NDC VARCHAR (13) NULL
	 , PriceTypeCode VARCHAR (2) NULL
	 , Units FLOAT NULL
	 , Charged NUMBER (19,4) NULL
	 , Allowed NUMBER (19,4) NULL
	 , EndNote VARCHAR (20) NULL
	 , Override NUMBER (5,0) NULL
	 , Override_Rsn VARCHAR (10) NULL
	 , Analyzed NUMBER (19,4) NULL
	 , CTGPenalty NUMBER (19,4) NULL
	 , PrePPOAllowed NUMBER (19,4) NULL
	 , PPODate DATETIME NULL
	 , POS_RevCode VARCHAR (4) NULL
	 , DPAllowed NUMBER (19,4) NULL
	 , HCRA_Surcharge NUMBER (19,4) NULL
	 , EndDateOfService DATETIME NULL
	 , RepackagedNdc VARCHAR (13) NULL
	 , OriginalNdc VARCHAR (13) NULL
	 , UnitOfMeasureId NUMBER (3,0) NULL
	 , PackageTypeOriginalNdc VARCHAR (2) NULL
	 , PpoCtgPenalty NUMBER (19,4) NULL
	 , ServiceCode VARCHAR (25) NULL
	 , PreApportionedAmount NUMBER (19,4) NULL
	 , DeductibleApplied NUMBER (19,4) NULL
	 , BillReviewResults NUMBER (19,4) NULL
	 , PreOverriddenDeductible NUMBER (19,4) NULL
	 , RemainingBalance NUMBER (19,4) NULL
	 , CtgCoPayPenalty NUMBER (19,4) NULL
	 , PpoCtgCoPayPenaltyPercentage NUMBER (19,4) NULL
	 , CtgVunPenalty NUMBER (19,4) NULL
	 , PpoCtgVunPenaltyPercentage NUMBER (19,4) NULL
	 , RenderingNpi VARCHAR (15) NULL
 ); 
