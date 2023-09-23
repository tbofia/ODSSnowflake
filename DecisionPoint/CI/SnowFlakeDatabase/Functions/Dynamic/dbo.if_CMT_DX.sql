CREATE OR REPLACE FUNCTION dbo.if_CMT_DX(
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
		,DX VARCHAR(8)
		,SeqNum NUMBER(5,0)
		,POA VARCHAR(1)
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
		,t.DX
		,t.SeqNum
		,t.POA
		,t.IcdVersion
FROM src.CMT_DX t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		BillIDNo,
		DX,
		IcdVersion,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.CMT_DX
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		BillIDNo,
		DX,
		IcdVersion) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.BillIDNo = s.BillIDNo
	AND t.DX = s.DX
	AND t.IcdVersion = s.IcdVersion
WHERE t.DmlOperation <> 'D'

$$;


