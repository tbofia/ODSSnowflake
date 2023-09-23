CREATE OR REPLACE FUNCTION dbo.if_Bills_Pharm(
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
		,Line_No NUMBER(5,0)
		,LINE_NO_DISP NUMBER(5,0)
		,DateOfService DATETIME
		,NDC VARCHAR(13)
		,PriceTypeCode VARCHAR(2)
		,Units FLOAT(24)
		,Charged NUMBER(19,4)
		,Allowed NUMBER(19,4)
		,EndNote VARCHAR(20)
		,Override NUMBER(5,0)
		,Override_Rsn VARCHAR(10)
		,Analyzed NUMBER(19,4)
		,CTGPenalty NUMBER(19,4)
		,PrePPOAllowed NUMBER(19,4)
		,PPODate DATETIME
		,POS_RevCode VARCHAR(4)
		,DPAllowed NUMBER(19,4)
		,HCRA_Surcharge NUMBER(19,4)
		,EndDateOfService DATETIME
		,RepackagedNdc VARCHAR(13)
		,OriginalNdc VARCHAR(13)
		,UnitOfMeasureId NUMBER(3,0)
		,PackageTypeOriginalNdc VARCHAR(2)
		,PpoCtgPenalty NUMBER(19,4)
		,ServiceCode VARCHAR(25)
		,PreApportionedAmount NUMBER(19,4)
		,DeductibleApplied NUMBER(19,4)
		,BillReviewResults NUMBER(19,4)
		,PreOverriddenDeductible NUMBER(19,4)
		,RemainingBalance NUMBER(19,4) 
		,CtgCoPayPenalty NUMBER(19,4) 
	    ,PpoCtgCoPayPenaltyPercentage NUMBER(19,4) 
	    ,CtgVunPenalty NUMBER(19,4) 
	    ,PpoCtgVunPenaltyPercentage NUMBER(19,4)
		,RenderingNpi VARCHAR(15) )
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
		,t.Line_No
		,t.LINE_NO_DISP
		,t.DateOfService
		,t.NDC
		,t.PriceTypeCode
		,t.Units
		,t.Charged
		,t.Allowed
		,t.EndNote
		,t.Override
		,t.Override_Rsn
		,t.Analyzed
		,t.CTGPenalty
		,t.PrePPOAllowed
		,t.PPODate
		,t.POS_RevCode
		,t.DPAllowed
		,t.HCRA_Surcharge
		,t.EndDateOfService
		,t.RepackagedNdc
		,t.OriginalNdc
		,t.UnitOfMeasureId
		,t.PackageTypeOriginalNdc
		,t.PpoCtgPenalty
		,t.ServiceCode
		,t.PreApportionedAmount
		,t.DeductibleApplied
		,t.BillReviewResults
		,t.PreOverriddenDeductible
		,t.RemainingBalance
		,t.CtgCoPayPenalty 
		,t.PpoCtgCoPayPenaltyPercentage 
		,t.CtgVunPenalty
		,t.PpoCtgVunPenaltyPercentage
		,t.RenderingNpi
FROM src.Bills_Pharm t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		BillIdNo,
		Line_No,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.Bills_Pharm
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		BillIdNo,
		Line_No) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.BillIdNo = s.BillIdNo
	AND t.Line_No = s.Line_No
WHERE t.DmlOperation <> 'D'

$$;


