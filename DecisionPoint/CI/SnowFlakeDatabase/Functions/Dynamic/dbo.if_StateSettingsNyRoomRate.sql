CREATE OR REPLACE FUNCTION dbo.if_StateSettingsNyRoomRate(
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
		,StateSettingsNyRoomRateId NUMBER(10,0)
		,StartDate DATETIME
		,EndDate DATETIME
		,RoomRate NUMBER(19,4) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.StateSettingsNyRoomRateId
		,t.StartDate
		,t.EndDate
		,t.RoomRate
FROM src.StateSettingsNyRoomRate t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		StateSettingsNyRoomRateId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.StateSettingsNyRoomRate
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		StateSettingsNyRoomRateId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.StateSettingsNyRoomRateId = s.StateSettingsNyRoomRateId
WHERE t.DmlOperation <> 'D'

$$;


