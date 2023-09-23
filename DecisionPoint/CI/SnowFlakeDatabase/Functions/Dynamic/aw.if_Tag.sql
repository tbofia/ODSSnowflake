CREATE OR REPLACE FUNCTION aw.if_Tag(
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
		,TagId NUMBER(10,0)
		,NAME VARCHAR(50)
		,DateCreated TIMESTAMP_LTZ(7)
		,DateModified TIMESTAMP_LTZ(7)
		,CreatedBy VARCHAR(15)
		,ModifiedBy VARCHAR(15) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.TagId
		,t.NAME
		,t.DateCreated
		,t.DateModified
		,t.CreatedBy
		,t.ModifiedBy
FROM src.Tag t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		TagId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.Tag
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		TagId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.TagId = s.TagId
WHERE t.DmlOperation <> 'D'

$$;


