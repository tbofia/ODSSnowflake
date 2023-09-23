CREATE OR REPLACE FUNCTION dbo.if_BILLS_DRG(
		if_OdsPostingGroupAuditId INT
)
RETURNS TABLE  (
		 OdsPostingGroupAuditId NUMBER(10,0)
		,OdsCustomerId NUMBER(10,0)
		,OdsCreateDate DATETIME
		,OdsSnapshotDate DATETIME
		,OdsRowIsCurrent INT
		,OdsHashbytesValue BINARY(8000)
		,DmlOperation VARCHAR(1)
		,BillIdNo NUMBER(10,0)
		,PricerPassThru NUMBER(19,4)
		,PricerCapital_Outlier_Amt NUMBER(19,4)
		,PricerCapital_OldHarm_Amt NUMBER(19,4)
		,PricerCapital_IME_Amt NUMBER(19,4)
		,PricerCapital_HSP_Amt NUMBER(19,4)
		,PricerCapital_FSP_Amt NUMBER(19,4)
		,PricerCapital_Exceptions_Amt NUMBER(19,4)
		,PricerCapital_DSH_Amt NUMBER(19,4)
		,PricerCapitalPayment NUMBER(19,4)
		,PricerDSH NUMBER(19,4)
		,PricerIME NUMBER(19,4)
		,PricerCostOutlier NUMBER(19,4)
		,PricerHSP NUMBER(19,4)
		,PricerFSP NUMBER(19,4)
		,PricerTotalPayment NUMBER(19,4)
		,PricerReturnMsg VARCHAR(255)
		,ReturnDRG VARCHAR(3)
		,ReturnDRGDesc VARCHAR(66)
		,ReturnMDC VARCHAR(3)
		,ReturnMDCDesc VARCHAR(66)
		,ReturnDRGWt FLOAT(24)
		,ReturnDRGALOS FLOAT(24)
		,ReturnADX VARCHAR(8)
		,ReturnSDX VARCHAR(8)
		,ReturnMPR VARCHAR(8)
		,ReturnPR2 VARCHAR(8)
		,ReturnPR3 VARCHAR(8)
		,ReturnNOR VARCHAR(8)
		,ReturnNO2 VARCHAR(8)
		,ReturnCOM VARCHAR(255)
		,ReturnCMI NUMBER(5,0)
		,ReturnDCC VARCHAR(8)
		,ReturnDX1 VARCHAR(8)
		,ReturnDX2 VARCHAR(8)
		,ReturnDX3 VARCHAR(8)
		,ReturnMCI NUMBER(5,0)
		,ReturnOR1 VARCHAR(8)
		,ReturnOR2 VARCHAR(8)
		,ReturnOR3 VARCHAR(8)
		,ReturnTRI NUMBER(5,0)
		,SOJ VARCHAR(2)
		,OPCERT VARCHAR(7)
		,BlendCaseInclMalp FLOAT(24)
		,CapitalCost FLOAT(24)
		,HospBadDebt FLOAT(24)
		,ExcessPhysMalp FLOAT(24)
		,SparcsPerCase FLOAT(24)
		,AltLevelOfCare FLOAT(24)
		,DRGWgt FLOAT(24)
		,TransferCapital FLOAT(24)
		,NYDrgType NUMBER(5,0)
		,LOS NUMBER(5,0)
		,TrimPoint NUMBER(5,0)
		,GroupBlendPercentage FLOAT(24)
		,AdjustmentFactor FLOAT(24)
		,HospLongStayGroupPrice FLOAT(24)
		,TotalDRGCharge NUMBER(19,4)
		,BlendCaseAdj FLOAT(24)
		,CapitalCostAdj FLOAT(24)
		,NonMedicareCaseMix FLOAT(24)
		,HighCostChargeConverter FLOAT(24)
		,DischargeCasePaymentRate NUMBER(19,4)
		,DirectMedicalEducation NUMBER(19,4)
		,CasePaymentCapitalPerDiem NUMBER(19,4)
		,HighCostOutlierThreshold NUMBER(19,4)
		,ISAF FLOAT(24)
		,ReturnSOI NUMBER(5,0)
		,CapitalCostPerDischarge NUMBER(19,4)
		,ReturnSOIDesc VARCHAR(20) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.BillIdNo
		,t.PricerPassThru
		,t.PricerCapital_Outlier_Amt
		,t.PricerCapital_OldHarm_Amt
		,t.PricerCapital_IME_Amt
		,t.PricerCapital_HSP_Amt
		,t.PricerCapital_FSP_Amt
		,t.PricerCapital_Exceptions_Amt
		,t.PricerCapital_DSH_Amt
		,t.PricerCapitalPayment
		,t.PricerDSH
		,t.PricerIME
		,t.PricerCostOutlier
		,t.PricerHSP
		,t.PricerFSP
		,t.PricerTotalPayment
		,t.PricerReturnMsg
		,t.ReturnDRG
		,t.ReturnDRGDesc
		,t.ReturnMDC
		,t.ReturnMDCDesc
		,t.ReturnDRGWt
		,t.ReturnDRGALOS
		,t.ReturnADX
		,t.ReturnSDX
		,t.ReturnMPR
		,t.ReturnPR2
		,t.ReturnPR3
		,t.ReturnNOR
		,t.ReturnNO2
		,t.ReturnCOM
		,t.ReturnCMI
		,t.ReturnDCC
		,t.ReturnDX1
		,t.ReturnDX2
		,t.ReturnDX3
		,t.ReturnMCI
		,t.ReturnOR1
		,t.ReturnOR2
		,t.ReturnOR3
		,t.ReturnTRI
		,t.SOJ
		,t.OPCERT
		,t.BlendCaseInclMalp
		,t.CapitalCost
		,t.HospBadDebt
		,t.ExcessPhysMalp
		,t.SparcsPerCase
		,t.AltLevelOfCare
		,t.DRGWgt
		,t.TransferCapital
		,t.NYDrgType
		,t.LOS
		,t.TrimPoint
		,t.GroupBlendPercentage
		,t.AdjustmentFactor
		,t.HospLongStayGroupPrice
		,t.TotalDRGCharge
		,t.BlendCaseAdj
		,t.CapitalCostAdj
		,t.NonMedicareCaseMix
		,t.HighCostChargeConverter
		,t.DischargeCasePaymentRate
		,t.DirectMedicalEducation
		,t.CasePaymentCapitalPerDiem
		,t.HighCostOutlierThreshold
		,t.ISAF
		,t.ReturnSOI
		,t.CapitalCostPerDischarge
		,t.ReturnSOIDesc
FROM src.BILLS_DRG t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		BillIdNo,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.BILLS_DRG
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		BillIdNo) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.BillIdNo = s.BillIdNo
WHERE t.DmlOperation <> 'D'

$$;


