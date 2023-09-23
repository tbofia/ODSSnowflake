CREATE OR REPLACE FUNCTION dbo.if_SENTRY_ACTION_CATEGORY(
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
		,ActionCategoryIDNo NUMBER(10,0)
		,Description VARCHAR(60) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.ActionCategoryIDNo
		,t.Description
FROM src.SENTRY_ACTION_CATEGORY t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ActionCategoryIDNo,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.SENTRY_ACTION_CATEGORY
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ActionCategoryIDNo) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ActionCategoryIDNo = s.ActionCategoryIDNo
WHERE t.DmlOperation <> 'D'

$$;


