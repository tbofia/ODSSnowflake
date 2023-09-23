CREATE OR REPLACE FUNCTION dbo.if_BillsOverride(
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
		,BillsOverrideID NUMBER(10,0)
		,BillIDNo NUMBER(10,0)
		,LINE_NO NUMBER(5,0)
		,UserId NUMBER(10,0)
		,DateSaved DATETIME
		,AmountBefore NUMBER(19,4)
		,AmountAfter NUMBER(19,4)
		,CodesOverrode VARCHAR(50)
		,SeqNo NUMBER(10,0) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.BillsOverrideID
		,t.BillIDNo
		,t.LINE_NO
		,t.UserId
		,t.DateSaved
		,t.AmountBefore
		,t.AmountAfter
		,t.CodesOverrode
		,t.SeqNo
FROM src.BillsOverride t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		BillsOverrideID,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.BillsOverride
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		BillsOverrideID) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.BillsOverrideID = s.BillsOverrideID
WHERE t.DmlOperation <> 'D'

$$;


