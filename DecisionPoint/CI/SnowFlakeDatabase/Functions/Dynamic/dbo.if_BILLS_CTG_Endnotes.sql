CREATE OR REPLACE FUNCTION dbo.if_BILLS_CTG_Endnotes(
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
		,Endnote NUMBER(10,0)
		,RuleType VARCHAR(2)
		,RuleId NUMBER(10,0)
		,PreCertAction NUMBER(5,0)
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
		,t.BillIdNo
		,t.Line_No
		,t.Endnote
		,t.RuleType
		,t.RuleId
		,t.PreCertAction
		,t.PercentDiscount
		,t.ActionId
FROM src.BILLS_CTG_Endnotes t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		BillIdNo,
		Line_No,
		Endnote,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.BILLS_CTG_Endnotes
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		BillIdNo,
		Line_No,
		Endnote) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.BillIdNo = s.BillIdNo
	AND t.Line_No = s.Line_No
	AND t.Endnote = s.Endnote
WHERE t.DmlOperation <> 'D'

$$;


