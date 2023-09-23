CREATE OR REPLACE FUNCTION dbo.if_SEC_User_OfficeGroups(
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
		,SECUserOfficeGroupId NUMBER(10,0)
		,UserId NUMBER(10,0)
		,OffcGroupId NUMBER(10,0) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.SECUserOfficeGroupId
		,t.UserId
		,t.OffcGroupId
FROM src.SEC_User_OfficeGroups t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		SECUserOfficeGroupId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.SEC_User_OfficeGroups
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		SECUserOfficeGroupId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.SECUserOfficeGroupId = s.SECUserOfficeGroupId
WHERE t.DmlOperation <> 'D'

$$;


