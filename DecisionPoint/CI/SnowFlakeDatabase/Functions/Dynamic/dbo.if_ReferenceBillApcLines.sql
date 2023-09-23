CREATE OR REPLACE FUNCTION dbo.if_ReferenceBillApcLines(
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
		,PaymentAPC VARCHAR(5)
		,ServiceIndicator VARCHAR(2)
		,PaymentIndicator VARCHAR(1)
		,OutlierAmount NUMBER(19,4)
		,PricerAllowed NUMBER(19,4)
		,MedicareAmount NUMBER(19,4) )
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
		,t.PaymentAPC
		,t.ServiceIndicator
		,t.PaymentIndicator
		,t.OutlierAmount
		,t.PricerAllowed
		,t.MedicareAmount
FROM src.ReferenceBillApcLines t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		BillIdNo,
		Line_No,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.ReferenceBillApcLines
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


