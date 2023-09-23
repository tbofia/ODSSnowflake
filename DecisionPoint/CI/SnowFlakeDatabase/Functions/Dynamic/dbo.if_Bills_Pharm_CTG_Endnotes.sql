CREATE OR REPLACE FUNCTION dbo.if_Bills_Pharm_CTG_Endnotes(
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
		,EndNote NUMBER(5,0)
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
		,t.BillIDNo
		,t.LINE_NO
		,t.EndNote
		,t.RuleType
		,t.RuleId
		,t.PreCertAction
		,t.PercentDiscount
		,t.ActionId
FROM src.Bills_Pharm_CTG_Endnotes t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		BillIDNo,
		LINE_NO,
		EndNote,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.Bills_Pharm_CTG_Endnotes
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		BillIDNo,
		LINE_NO,
		EndNote) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.BillIDNo = s.BillIDNo
	AND t.LINE_NO = s.LINE_NO
	AND t.EndNote = s.EndNote
WHERE t.DmlOperation <> 'D'

$$;


