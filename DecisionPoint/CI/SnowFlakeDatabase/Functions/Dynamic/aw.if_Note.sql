CREATE OR REPLACE FUNCTION aw.if_Note(
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
		,NoteId NUMBER(10,0)
		,DateCreated TIMESTAMP_LTZ(7)
		,DateModified TIMESTAMP_LTZ(7)
		,CreatedBy VARCHAR(15)
		,ModifiedBy VARCHAR(15)
		,Flag NUMBER(3,0)
		,Content VARCHAR(250)
		,NoteContext NUMBER(5,0)
		,DemandClaimantId NUMBER(10,0) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.NoteId
		,t.DateCreated
		,t.DateModified
		,t.CreatedBy
		,t.ModifiedBy
		,t.Flag
		,t.Content
		,t.NoteContext
		,t.DemandClaimantId
FROM src.Note t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		NoteId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.Note
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		NoteId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.NoteId = s.NoteId
WHERE t.DmlOperation <> 'D'

$$;


