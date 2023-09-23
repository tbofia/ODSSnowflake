CREATE OR REPLACE FUNCTION dbo.if_VpnProcessFlagType(
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
		,VpnProcessFlagTypeId NUMBER(5,0)
		,VpnProcessFlagType VARCHAR(50) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.VpnProcessFlagTypeId
		,t.VpnProcessFlagType
FROM src.VpnProcessFlagType t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		VpnProcessFlagTypeId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.VpnProcessFlagType
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		VpnProcessFlagTypeId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.VpnProcessFlagTypeId = s.VpnProcessFlagTypeId
WHERE t.DmlOperation <> 'D'

$$;


