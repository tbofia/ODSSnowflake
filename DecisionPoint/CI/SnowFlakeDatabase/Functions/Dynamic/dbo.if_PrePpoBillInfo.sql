CREATE OR REPLACE FUNCTION dbo.if_PrePpoBillInfo(
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
		,DateSentToPPO DATETIME
		,ClaimNo VARCHAR(50)
		,ClaimIDNo NUMBER(10,0)
		,CompanyID NUMBER(10,0)
		,OfficeIndex NUMBER(10,0)
		,CV_Code VARCHAR(2)
		,DateLoss DATETIME
		,Deductible NUMBER(19,4)
		,PaidCoPay NUMBER(19,4)
		,PaidDeductible NUMBER(19,4)
		,LossState VARCHAR(2)
		,CmtIDNo NUMBER(10,0)
		,CmtCoPaymentMax NUMBER(19,4)
		,CmtCoPaymentPercentage NUMBER(5,0)
		,CmtDedType NUMBER(5,0)
		,CmtDeductible NUMBER(19,4)
		,CmtFLCopay NUMBER(5,0)
		,CmtPolicyLimit NUMBER(19,4)
		,CmtStateOfJurisdiction VARCHAR(2)
		,PvdIDNo NUMBER(10,0)
		,PvdTIN VARCHAR(15)
		,PvdSPC_List VARCHAR(50)
		,PvdTitle VARCHAR(5)
		,PvdFlags NUMBER(10,0)
		,DateSaved DATETIME
		,DateRcv DATETIME
		,InvoiceDate DATETIME
		,NoLines NUMBER(5,0)
		,AmtCharged NUMBER(19,4)
		,AmtAllowed NUMBER(19,4)
		,Region VARCHAR(50)
		,FeatureID NUMBER(10,0)
		,Flags NUMBER(10,0)
		,WhoCreate VARCHAR(15)
		,WhoLast VARCHAR(15)
		,CmtPaidDeductible NUMBER(19,4)
		,InsPaidLimit NUMBER(19,4)
		,StatusFlag VARCHAR(2)
		,CmtPaidCoPay NUMBER(19,4)
		,Category NUMBER(10,0)
		,CatDesc VARCHAR(1000)
		,CreateDate DATETIME
		,PvdZOS VARCHAR(12)
		,AdmissionDate DATETIME
		,DischargeDate DATETIME
		,DischargeStatus NUMBER(5,0)
		,TypeOfBill VARCHAR(4)
		,PaymentDecision NUMBER(5,0)
		,PPONumberSent NUMBER(5,0)
		,BillIDNo NUMBER(10,0)
		,LINE_NO NUMBER(5,0)
		,LINE_NO_DISP NUMBER(5,0)
		,OVER_RIDE NUMBER(5,0)
		,DT_SVC DATETIME
		,PRC_CD VARCHAR(7)
		,UNITS FLOAT(24)
		,TS_CD VARCHAR(14)
		,CHARGED NUMBER(19,4)
		,ALLOWED NUMBER(19,4)
		,ANALYZED NUMBER(19,4)
		,REF_LINE_NO NUMBER(5,0)
		,SUBNET VARCHAR(9)
		,FEE_SCHEDULE NUMBER(19,4)
		,POS_RevCode VARCHAR(4)
		,CTGPenalty NUMBER(19,4)
		,PrePPOAllowed NUMBER(19,4)
		,PPODate DATETIME
		,PPOCTGPenalty NUMBER(19,4)
		,UCRPerUnit NUMBER(19,4)
		,FSPerUnit NUMBER(19,4)
		,HCRA_Surcharge NUMBER(19,4)
		,NDC VARCHAR(13)
		,PriceTypeCode VARCHAR(2)
		,PharmacyLine NUMBER(5,0)
		,Endnotes VARCHAR(50)
		,SentryEN VARCHAR(250)
		,CTGEN VARCHAR(250)
		,CTGRuleType VARCHAR(250)
		,CTGRuleID VARCHAR(250)
		,OverrideEN VARCHAR(50)
		,UserId NUMBER(10,0)
		,DateOverriden DATETIME
		,AmountBeforeOverride NUMBER(19,4)
		,AmountAfterOverride NUMBER(19,4)
		,CodesOverriden VARCHAR(50)
		,NetworkID NUMBER(10,0)
		,BillSnapshot VARCHAR(30)
		,PPOSavings NUMBER(19,4)
		,RevisedDate DATETIME
		,ReconsideredDate DATETIME
		,TierNumber NUMBER(5,0)
		,PPOBillInfoID NUMBER(10,0)
		,PrePPOBillInfoID NUMBER(10,0)
		,CtgCoPayPenalty NUMBER(19,4) 
	    ,PpoCtgCoPayPenaltyPercentage NUMBER(19,4) 
	    ,CtgVunPenalty NUMBER(19,4) 
	    ,PpoCtgVunPenaltyPercentage NUMBER(19,4) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.DateSentToPPO
		,t.ClaimNo
		,t.ClaimIDNo
		,t.CompanyID
		,t.OfficeIndex
		,t.CV_Code
		,t.DateLoss
		,t.Deductible
		,t.PaidCoPay
		,t.PaidDeductible
		,t.LossState
		,t.CmtIDNo
		,t.CmtCoPaymentMax
		,t.CmtCoPaymentPercentage
		,t.CmtDedType
		,t.CmtDeductible
		,t.CmtFLCopay
		,t.CmtPolicyLimit
		,t.CmtStateOfJurisdiction
		,t.PvdIDNo
		,t.PvdTIN
		,t.PvdSPC_List
		,t.PvdTitle
		,t.PvdFlags
		,t.DateSaved
		,t.DateRcv
		,t.InvoiceDate
		,t.NoLines
		,t.AmtCharged
		,t.AmtAllowed
		,t.Region
		,t.FeatureID
		,t.Flags
		,t.WhoCreate
		,t.WhoLast
		,t.CmtPaidDeductible
		,t.InsPaidLimit
		,t.StatusFlag
		,t.CmtPaidCoPay
		,t.Category
		,t.CatDesc
		,t.CreateDate
		,t.PvdZOS
		,t.AdmissionDate
		,t.DischargeDate
		,t.DischargeStatus
		,t.TypeOfBill
		,t.PaymentDecision
		,t.PPONumberSent
		,t.BillIDNo
		,t.LINE_NO
		,t.LINE_NO_DISP
		,t.OVER_RIDE
		,t.DT_SVC
		,t.PRC_CD
		,t.UNITS
		,t.TS_CD
		,t.CHARGED
		,t.ALLOWED
		,t.ANALYZED
		,t.REF_LINE_NO
		,t.SUBNET
		,t.FEE_SCHEDULE
		,t.POS_RevCode
		,t.CTGPenalty
		,t.PrePPOAllowed
		,t.PPODate
		,t.PPOCTGPenalty
		,t.UCRPerUnit
		,t.FSPerUnit
		,t.HCRA_Surcharge
		,t.NDC
		,t.PriceTypeCode
		,t.PharmacyLine
		,t.Endnotes
		,t.SentryEN
		,t.CTGEN
		,t.CTGRuleType
		,t.CTGRuleID
		,t.OverrideEN
		,t.UserId
		,t.DateOverriden
		,t.AmountBeforeOverride
		,t.AmountAfterOverride
		,t.CodesOverriden
		,t.NetworkID
		,t.BillSnapshot
		,t.PPOSavings
		,t.RevisedDate
		,t.ReconsideredDate
		,t.TierNumber
		,t.PPOBillInfoID
		,t.PrePPOBillInfoID
		,t.CtgCoPayPenalty 
		,t.PpoCtgCoPayPenaltyPercentage 
		,t.CtgVunPenalty
		,t.PpoCtgVunPenaltyPercentage
FROM src.PrePpoBillInfo t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		PrePPOBillInfoID,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.PrePpoBillInfo
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		PrePPOBillInfoID) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.PrePPOBillInfoID = s.PrePPOBillInfoID
WHERE t.DmlOperation <> 'D'

$$;


