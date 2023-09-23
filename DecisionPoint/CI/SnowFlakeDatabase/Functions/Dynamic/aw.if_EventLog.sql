CREATE OR REPLACE FUNCTION aw.if_EventLog(
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
		,EventLogId NUMBER(10,0)
		,ObjectName VARCHAR(50)
		,ObjectId NUMBER(10,0)
		,UserName VARCHAR(15)
		,LogDate TIMESTAMP_LTZ(7)
		,ActionName VARCHAR(20)
		,OrganizationId VARCHAR(100) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.EventLogId
		,t.ObjectName
		,t.ObjectId
		,t.UserName
		,t.LogDate
		,t.ActionName
		,t.OrganizationId
FROM src.EventLog t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		EventLogId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.EventLog
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		EventLogId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.EventLogId = s.EventLogId
WHERE t.DmlOperation <> 'D'

$$;


