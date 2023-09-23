CREATE OR REPLACE FUNCTION dbo.if_Bills_OverrideEndNotes(
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
		,OverrideEndNoteID NUMBER(10,0)
		,BillIdNo NUMBER(10,0)
		,Line_No NUMBER(5,0)
		,OverrideEndNote NUMBER(5,0)
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
		,t.OverrideEndNoteID
		,t.BillIdNo
		,t.Line_No
		,t.OverrideEndNote
		,t.PercentDiscount
		,t.ActionId
FROM src.Bills_OverrideEndNotes t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		OverrideEndNoteID,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.Bills_OverrideEndNotes
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		OverrideEndNoteID) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.OverrideEndNoteID = s.OverrideEndNoteID
WHERE t.DmlOperation <> 'D'

$$;


