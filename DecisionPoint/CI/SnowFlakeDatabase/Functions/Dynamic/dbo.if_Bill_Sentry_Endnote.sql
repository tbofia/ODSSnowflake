CREATE OR REPLACE FUNCTION dbo.if_Bill_Sentry_Endnote(
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
		,BillID NUMBER(10,0)
		,Line NUMBER(10,0)
		,RuleID NUMBER(10,0)
		,PercentDiscount FLOAT(24)
		,ActionId NUMBER(5,0) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.BillID
		,t.Line
		,t.RuleID
		,t.PercentDiscount
		,t.ActionId
FROM src.Bill_Sentry_Endnote t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		BillID,
		Line,
		RuleID,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.Bill_Sentry_Endnote
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		BillID,
		Line,
		RuleID) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.BillID = s.BillID
	AND t.Line = s.Line
	AND t.RuleID = s.RuleID
WHERE t.DmlOperation <> 'D'

$$;


