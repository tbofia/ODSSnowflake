CREATE OR REPLACE FUNCTION dbo.if_SEC_RightGroups(
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
		,RightGroupId NUMBER(10,0)
		,RightGroupName VARCHAR(50)
		,RightGroupDescription VARCHAR(150)
		,CreatedDate DATETIME
		,CreatedBy VARCHAR(50) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.RightGroupId
		,t.RightGroupName
		,t.RightGroupDescription
		,t.CreatedDate
		,t.CreatedBy
FROM src.SEC_RightGroups t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		RightGroupId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.SEC_RightGroups
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		RightGroupId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.RightGroupId = s.RightGroupId
WHERE t.DmlOperation <> 'D'

$$;


