CREATE OR REPLACE TABLE stg.BILLS_DRG (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , BillIdNo NUMBER(10, 0) NOT NULL
	 , PricerPassThru NUMBER(19, 4) NULL
	 , PricerCapital_Outlier_Amt NUMBER(19, 4) NULL
	 , PricerCapital_OldHarm_Amt NUMBER(19, 4) NULL
	 , PricerCapital_IME_Amt NUMBER(19, 4) NULL
	 , PricerCapital_HSP_Amt NUMBER(19, 4) NULL
	 , PricerCapital_FSP_Amt NUMBER(19, 4) NULL
	 , PricerCapital_Exceptions_Amt NUMBER(19, 4) NULL
	 , PricerCapital_DSH_Amt NUMBER(19, 4) NULL
	 , PricerCapitalPayment NUMBER(19, 4) NULL
	 , PricerDSH NUMBER(19, 4) NULL
	 , PricerIME NUMBER(19, 4) NULL
	 , PricerCostOutlier NUMBER(19, 4) NULL
	 , PricerHSP NUMBER(19, 4) NULL
	 , PricerFSP NUMBER(19, 4) NULL
	 , PricerTotalPayment NUMBER(19, 4) NULL
	 , PricerReturnMsg VARCHAR(255) NULL
	 , ReturnDRG VARCHAR(3) NULL
	 , ReturnDRGDesc VARCHAR(66) NULL
	 , ReturnMDC VARCHAR(3) NULL
	 , ReturnMDCDesc VARCHAR(66) NULL
	 , ReturnDRGWt FLOAT(24) NULL
	 , ReturnDRGALOS FLOAT(24) NULL
	 , ReturnADX VARCHAR(8) NULL
	 , ReturnSDX VARCHAR(8) NULL
	 , ReturnMPR VARCHAR(8) NULL
	 , ReturnPR2 VARCHAR(8) NULL
	 , ReturnPR3 VARCHAR(8) NULL
	 , ReturnNOR VARCHAR(8) NULL
	 , ReturnNO2 VARCHAR(8) NULL
	 , ReturnCOM VARCHAR(255) NULL
	 , ReturnCMI NUMBER(5, 0) NULL
	 , ReturnDCC VARCHAR(8) NULL
	 , ReturnDX1 VARCHAR(8) NULL
	 , ReturnDX2 VARCHAR(8) NULL
	 , ReturnDX3 VARCHAR(8) NULL
	 , ReturnMCI NUMBER(5, 0) NULL
	 , ReturnOR1 VARCHAR(8) NULL
	 , ReturnOR2 VARCHAR(8) NULL
	 , ReturnOR3 VARCHAR(8) NULL
	 , ReturnTRI NUMBER(5, 0) NULL
	 , SOJ VARCHAR(2) NULL
	 , OPCERT VARCHAR(7) NULL
	 , BlendCaseInclMalp FLOAT(24) NULL
	 , CapitalCost FLOAT(24) NULL
	 , HospBadDebt FLOAT(24) NULL
	 , ExcessPhysMalp FLOAT(24) NULL
	 , SparcsPerCase FLOAT(24) NULL
	 , AltLevelOfCare FLOAT(24) NULL
	 , DRGWgt FLOAT(24) NULL
	 , TransferCapital FLOAT(24) NULL
	 , NYDrgType NUMBER(5, 0) NULL
	 , LOS NUMBER(5, 0) NULL
	 , TrimPoint NUMBER(5, 0) NULL
	 , GroupBlendPercentage FLOAT(24) NULL
	 , AdjustmentFactor FLOAT(24) NULL
	 , HospLongStayGroupPrice FLOAT(24) NULL
	 , TotalDRGCharge NUMBER(19, 4) NULL
	 , BlendCaseAdj FLOAT(24) NULL
	 , CapitalCostAdj FLOAT(24) NULL
	 , NonMedicareCaseMix FLOAT(24) NULL
	 , HighCostChargeConverter FLOAT(24) NULL
	 , DischargeCasePaymentRate NUMBER(19, 4) NULL
	 , DirectMedicalEducation NUMBER(19, 4) NULL
	 , CasePaymentCapitalPerDiem NUMBER(19, 4) NULL
	 , HighCostOutlierThreshold NUMBER(19, 4) NULL
	 , ISAF FLOAT(24) NULL
	 , ReturnSOI NUMBER(5, 0) NULL
	 , CapitalCostPerDischarge NUMBER(19, 4) NULL
	 , ReturnSOIDesc VARCHAR(20) NULL
);

