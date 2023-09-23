CREATE OR REPLACE FUNCTION dbo.if_ProviderNetworkEventLog(
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
		,IDField NUMBER(10,0)
		,LogDate DATETIME
		,EventId NUMBER(10,0)
		,ClaimIdNo NUMBER(10,0)
		,BillIdNo NUMBER(10,0)
		,UserId NUMBER(10,0)
		,NetworkId NUMBER(10,0)
		,FileName VARCHAR(255)
		,ExtraText VARCHAR(1000)
		,ProcessInfo NUMBER(5,0)
		,TieredTypeID NUMBER(5,0)
		,TierNumber NUMBER(5,0) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.IDField
		,t.LogDate
		,t.EventId
		,t.ClaimIdNo
		,t.BillIdNo
		,t.UserId
		,t.NetworkId
		,t.FileName
		,t.ExtraText
		,t.ProcessInfo
		,t.TieredTypeID
		,t.TierNumber
FROM src.ProviderNetworkEventLog t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		IDField,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.ProviderNetworkEventLog
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		IDField) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.IDField = s.IDField
WHERE t.DmlOperation <> 'D'

$$;


