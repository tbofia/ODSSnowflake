CREATE OR REPLACE FUNCTION dbo.if_CMT_ICD9(
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
		,SeqNo NUMBER(5,0)
		,ICD9 VARCHAR(7)
		,IcdVersion NUMBER(3,0) )
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
		,t.SeqNo
		,t.ICD9
		,t.IcdVersion
FROM src.CMT_ICD9 t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		BillIDNo,
		SeqNo,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.CMT_ICD9
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		BillIDNo,
		SeqNo) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.BillIDNo = s.BillIDNo
	AND t.SeqNo = s.SeqNo
WHERE t.DmlOperation <> 'D'

$$;


