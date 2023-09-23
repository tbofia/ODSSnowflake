CREATE OR REPLACE FUNCTION dbo.if_Prf_CustomIcdAction(
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
		,CustomIcdActionId NUMBER(10,0)
		,ProfileId NUMBER(10,0)
		,IcdVersionId NUMBER(3,0)
		,Action NUMBER(5,0)
		,StartDate DATETIME
		,EndDate DATETIME )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.CustomIcdActionId
		,t.ProfileId
		,t.IcdVersionId
		,t.Action
		,t.StartDate
		,t.EndDate
FROM src.Prf_CustomIcdAction t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		CustomIcdActionId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.Prf_CustomIcdAction
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		CustomIcdActionId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.CustomIcdActionId = s.CustomIcdActionId
WHERE t.DmlOperation <> 'D'

$$;


