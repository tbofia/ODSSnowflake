CREATE OR REPLACE FUNCTION dbo.if_UDFLevelChangeTracking(
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
		,UDFLevelChangeTrackingId NUMBER(10,0)
		,EntityType NUMBER(10,0)
		,EntityId NUMBER(10,0)
		,CorrelationId VARCHAR(50)
		,UDFId NUMBER(10,0)
		,PreviousValue VARCHAR
		,UpdatedValue VARCHAR
		,UserId NUMBER(10,0)
		,ChangeDate DATETIME )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.UDFLevelChangeTrackingId
		,t.EntityType
		,t.EntityId
		,t.CorrelationId
		,t.UDFId
		,t.PreviousValue
		,t.UpdatedValue
		,t.UserId
		,t.ChangeDate
FROM src.UDFLevelChangeTracking t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		UDFLevelChangeTrackingId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.UDFLevelChangeTracking
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		UDFLevelChangeTrackingId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.UDFLevelChangeTrackingId = s.UDFLevelChangeTrackingId
WHERE t.DmlOperation <> 'D'

$$;


