CREATE OR REPLACE FUNCTION dbo.if_Bill_Payment_Adjustments(
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
		,Bill_Payment_Adjustment_ID NUMBER(10,0)
		,BillIDNo NUMBER(10,0)
		,SeqNo NUMBER(5,0)
		,InterestFlags NUMBER(10,0)
		,DateInterestStarts DATETIME
		,DateInterestEnds DATETIME
		,InterestAdditionalInfoReceived DATETIME
		,Interest NUMBER(19,4)
		,Comments VARCHAR(1000) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.Bill_Payment_Adjustment_ID
		,t.BillIDNo
		,t.SeqNo
		,t.InterestFlags
		,t.DateInterestStarts
		,t.DateInterestEnds
		,t.InterestAdditionalInfoReceived
		,t.Interest
		,t.Comments
FROM src.Bill_Payment_Adjustments t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		Bill_Payment_Adjustment_ID,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.Bill_Payment_Adjustments
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		Bill_Payment_Adjustment_ID) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.Bill_Payment_Adjustment_ID = s.Bill_Payment_Adjustment_ID
WHERE t.DmlOperation <> 'D'

$$;


