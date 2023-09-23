CREATE OR REPLACE FUNCTION dbo.if_SEC_User_RightGroups(
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
		,SECUserRightGroupId NUMBER(10,0)
		,UserId NUMBER(10,0)
		,RightGroupId NUMBER(10,0) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.SECUserRightGroupId
		,t.UserId
		,t.RightGroupId
FROM src.SEC_User_RightGroups t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		SECUserRightGroupId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.SEC_User_RightGroups
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		SECUserRightGroupId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.SECUserRightGroupId = s.SECUserRightGroupId
WHERE t.DmlOperation <> 'D'

$$;


