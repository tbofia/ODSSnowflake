CREATE OR REPLACE FUNCTION dbo.if_BILLS(
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
		,REASON1 NUMBER(10,0)
		,REASON2 NUMBER(10,0)
		,REASON3 NUMBER(10,0)
		,REASON4 NUMBER(10,0)
		,REASON5 NUMBER(10,0)
		,REASON6 NUMBER(10,0)
		,REASON7 NUMBER(10,0)
		,REASON8 NUMBER(10,0)
		,REF_LINE_NO NUMBER(5,0)
		,SUBNET VARCHAR(9)
		,OverrideReason NUMBER(5,0)
		,FEE_SCHEDULE NUMBER(19,4)
		,POS_RevCode VARCHAR(4)
		,CTGPenalty NUMBER(19,4)
		,PrePPOAllowed NUMBER(19,4)
		,PPODate DATETIME
		,PPOCTGPenalty NUMBER(19,4)
		,UCRPerUnit NUMBER(19,4)
		,FSPerUnit NUMBER(19,4)
		,HCRA_Surcharge NUMBER(19,4)
		,EligibleAmt NUMBER(19,4)
		,DPAllowed NUMBER(19,4)
		,EndDateOfService DATETIME
		,AnalyzedCtgPenalty NUMBER(19,4)
		,AnalyzedCtgPpoPenalty NUMBER(19,4)
		,RepackagedNdc VARCHAR(13)
		,OriginalNdc VARCHAR(13)
		,UnitOfMeasureId NUMBER(3,0)
		,PackageTypeOriginalNdc VARCHAR(2)
		,ServiceCode VARCHAR(25)
		,PreApportionedAmount NUMBER(19,4)
		,DeductibleApplied NUMBER(19,4)
		,BillReviewResults NUMBER(19,4)
		,PreOverriddenDeductible NUMBER(19,4)
		,RemainingBalance NUMBER(19,4) 
		,CtgCoPayPenalty NUMBER(19,4) 
	    ,PpoCtgCoPayPenaltyPercentage NUMBER(19,4) 
	    ,AnalyzedCtgCoPayPenalty NUMBER(19,4) 
	    ,AnalyzedPpoCtgCoPayPenaltyPercentage NUMBER(19,4) 
	    ,CtgVunPenalty NUMBER(19,4) 
	    ,PpoCtgVunPenaltyPercentage NUMBER(19,4) 
	    ,AnalyzedCtgVunPenalty NUMBER(19,4) 
	    ,AnalyzedPpoCtgVunPenaltyPercentage NUMBER(19,4)
		,RenderingNpi  VARCHAR(15) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
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
		,t.REASON1
		,t.REASON2
		,t.REASON3
		,t.REASON4
		,t.REASON5
		,t.REASON6
		,t.REASON7
		,t.REASON8
		,t.REF_LINE_NO
		,t.SUBNET
		,t.OverrideReason
		,t.FEE_SCHEDULE
		,t.POS_RevCode
		,t.CTGPenalty
		,t.PrePPOAllowed
		,t.PPODate
		,t.PPOCTGPenalty
		,t.UCRPerUnit
		,t.FSPerUnit
		,t.HCRA_Surcharge
		,t.EligibleAmt
		,t.DPAllowed
		,t.EndDateOfService
		,t.AnalyzedCtgPenalty
		,t.AnalyzedCtgPpoPenalty
		,t.RepackagedNdc
		,t.OriginalNdc
		,t.UnitOfMeasureId
		,t.PackageTypeOriginalNdc
		,t.ServiceCode
		,t.PreApportionedAmount
		,t.DeductibleApplied
		,t.BillReviewResults
		,t.PreOverriddenDeductible
		,t.RemainingBalance
		,t.CtgCoPayPenalty 
		,t.PpoCtgCoPayPenaltyPercentage 
		,t.AnalyzedCtgCoPayPenalty 
		,t.AnalyzedPpoCtgCoPayPenaltyPercentage 
		,t.CtgVunPenalty 
		,t.PpoCtgVunPenaltyPercentage 
		,t.AnalyzedCtgVunPenalty 
		,t.AnalyzedPpoCtgVunPenaltyPercentage 
		,t.RenderingNpi
FROM src.BILLS t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		BillIDNo,
		LINE_NO,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.BILLS
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		BillIDNo,
		LINE_NO) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.BillIDNo = s.BillIDNo
	AND t.LINE_NO = s.LINE_NO
WHERE t.DmlOperation <> 'D'

$$;


