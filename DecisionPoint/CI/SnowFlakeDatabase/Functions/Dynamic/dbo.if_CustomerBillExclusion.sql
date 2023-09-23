CREATE OR REPLACE FUNCTION dbo.if_CustomerBillExclusion(
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
		,Customer VARCHAR(50)
		,ReportID NUMBER(3,0)
		,CreateDate DATETIME )
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
		,t.Customer
		,t.ReportID
		,t.CreateDate
FROM src.CustomerBillExclusion t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		BillIdNo,
		Customer,
		ReportID,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.CustomerBillExclusion
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		BillIdNo,
		Customer,
		ReportID) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.BillIdNo = s.BillIdNo
	AND t.Customer = s.Customer
	AND t.ReportID = s.ReportID
WHERE t.DmlOperation <> 'D'

$$;


