CREATE OR REPLACE FUNCTION dbo.if_Vpn(
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
		,VpnId NUMBER(5,0)
		,NetworkName VARCHAR(50)
		,PendAndSend BOOLEAN
		,BypassMatching BOOLEAN
		,AllowsResends BOOLEAN
		,OdsEligible BOOLEAN )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.VpnId
		,t.NetworkName
		,t.PendAndSend
		,t.BypassMatching
		,t.AllowsResends
		,t.OdsEligible
FROM src.Vpn t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		VpnId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.Vpn
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		VpnId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.VpnId = s.VpnId
WHERE t.DmlOperation <> 'D'

$$;


