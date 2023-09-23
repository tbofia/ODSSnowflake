CREATE OR REPLACE TABLE stg.PrePPOBillInfo( 
	   OdsPostingGroupAuditId NUMBER(10,0) NOT NULL
	 , OdsCustomerId NUMBER(10,0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , DateSentToPPO DATETIME NULL
	 , ClaimNo VARCHAR (50) NULL
	 , ClaimIDNo NUMBER (10,0) NULL
	 , CompanyID NUMBER (10,0) NULL
	 , OfficeIndex NUMBER (10,0) NULL
	 , CV_Code VARCHAR (2) NULL
	 , DateLoss DATETIME NULL
	 , Deductible NUMBER (19,4) NULL
	 , PaidCoPay NUMBER (19,4) NULL
	 , PaidDeductible NUMBER (19,4) NULL
	 , LossState VARCHAR (2) NULL
	 , CmtIDNo NUMBER (10,0) NULL
	 , CmtCoPaymentMax NUMBER (19,4) NULL
	 , CmtCoPaymentPercentage NUMBER (5,0) NULL
	 , CmtDedType NUMBER (5,0) NULL
	 , CmtDeductible NUMBER (19,4) NULL
	 , CmtFLCopay NUMBER (5,0) NULL
	 , CmtPolicyLimit NUMBER (19,4) NULL
	 , CmtStateOfJurisdiction VARCHAR (2) NULL
	 , PvdIDNo NUMBER (10,0) NULL
	 , PvdTIN VARCHAR (15) NULL
	 , PvdSPC_List VARCHAR (50) NULL
	 , PvdTitle VARCHAR (5) NULL
	 , PvdFlags NUMBER (10,0) NULL
	 , DateSaved DATETIME NULL
	 , DateRcv DATETIME NULL
	 , InvoiceDate DATETIME NULL
	 , NoLines NUMBER (5,0) NULL
	 , AmtCharged NUMBER (19,4) NULL
	 , AmtAllowed NUMBER (19,4) NULL
	 , Region VARCHAR (50) NULL
	 , FeatureID NUMBER (10,0) NULL
	 , Flags NUMBER (10,0) NULL
	 , WhoCreate VARCHAR (15) NULL
	 , WhoLast VARCHAR (15) NULL
	 , CmtPaidDeductible NUMBER (19,4) NULL
	 , InsPaidLimit NUMBER (19,4) NULL
	 , StatusFlag VARCHAR (2) NULL
	 , CmtPaidCoPay NUMBER (19,4) NULL
	 , Category NUMBER (10,0) NULL
	 , CatDesc VARCHAR (1000) NULL
	 , CreateDate DATETIME NULL
	 , PvdZOS VARCHAR (12) NULL
	 , AdmissionDate DATETIME NULL
	 , DischargeDate DATETIME NULL
	 , DischargeStatus NUMBER (5,0) NULL
	 , TypeOfBill VARCHAR (4) NULL
	 , PaymentDecision NUMBER (5,0) NULL
	 , PPONumberSent NUMBER (5,0) NULL
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
	 , REF_LINE_NO NUMBER (5,0) NULL
	 , SUBNET VARCHAR (9) NULL
	 , FEE_SCHEDULE NUMBER (19,4) NULL
	 , POS_RevCode VARCHAR (4) NULL
	 , CTGPenalty NUMBER (19,4) NULL
	 , PrePPOAllowed NUMBER (19,4) NULL
	 , PPODate DATETIME NULL
	 , PPOCTGPenalty NUMBER (19,4) NULL
	 , UCRPerUnit NUMBER (19,4) NULL
	 , FSPerUnit NUMBER (19,4) NULL
	 , HCRA_Surcharge NUMBER (19,4) NULL
	 , NDC VARCHAR (13) NULL
	 , PriceTypeCode VARCHAR (2) NULL
	 , PharmacyLine NUMBER (5,0) NULL
	 , Endnotes VARCHAR (50) NULL
	 , SentryEN VARCHAR (250) NULL
	 , CTGEN VARCHAR (250) NULL
	 , CTGRuleType VARCHAR (250) NULL
	 , CTGRuleID VARCHAR (250) NULL
	 , OverrideEN VARCHAR (50) NULL
	 , UserId NUMBER (10,0) NULL
	 , DateOverriden DATETIME NULL
	 , AmountBeforeOverride NUMBER (19,4) NULL
	 , AmountAfterOverride NUMBER (19,4) NULL
	 , CodesOverriden VARCHAR (50) NULL
	 , NetworkID NUMBER (10,0) NULL
	 , BillSnapshot VARCHAR (30) NULL
	 , PPOSavings NUMBER (19,4) NULL
	 , RevisedDate DATETIME NULL
	 , ReconsideredDate DATETIME NULL
	 , TierNumber NUMBER (5,0) NULL
	 , PPOBillInfoID NUMBER (10,0) NULL
	 , PrePPOBillInfoID NUMBER (10,0) NULL
	 , CtgCoPayPenalty NUMBER (19,4) NULL
	 , PpoCtgCoPayPenaltyPercentage NUMBER (19,4) NULL
	 , CtgVunPenalty NUMBER (19,4) NULL
	 , PpoCtgVunPenaltyPercentage NUMBER (19,4) NULL
 ); 
