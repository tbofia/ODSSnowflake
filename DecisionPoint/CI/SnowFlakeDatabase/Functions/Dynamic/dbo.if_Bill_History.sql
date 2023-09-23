CREATE OR REPLACE FUNCTION dbo.if_Bill_History(
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
		,SeqNo NUMBER(10,0)
		,DateCommitted DATETIME
		,AmtCommitted NUMBER(19,4)
		,UserId VARCHAR(15)
		,AmtCoPay NUMBER(19,4)
		,AmtDeductible NUMBER(19,4)
		,Flags NUMBER(10,0)
		,AmtSalesTax NUMBER(19,4)
		,AmtOtherTax NUMBER(19,4)
		,DeductibleOverride BOOLEAN
		,PricingState VARCHAR(2)
		,ApportionmentPercentage NUMBER(5,2)
		,FloridaDeductibleRuleEligible BOOLEAN )
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
		,t.SeqNo
		,t.DateCommitted
		,t.AmtCommitted
		,t.UserId
		,t.AmtCoPay
		,t.AmtDeductible
		,t.Flags
		,t.AmtSalesTax
		,t.AmtOtherTax
		,t.DeductibleOverride
		,t.PricingState
		,t.ApportionmentPercentage
		,t.FloridaDeductibleRuleEligible
FROM src.Bill_History t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		BillIdNo,
		SeqNo,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.Bill_History
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		BillIdNo,
		SeqNo) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.BillIdNo = s.BillIdNo
	AND t.SeqNo = s.SeqNo
WHERE t.DmlOperation <> 'D'

$$;


