CREATE OR REPLACE FUNCTION aw.if_EventLogDetail(
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
		,EventLogDetailId NUMBER(10,0)
		,EventLogId NUMBER(10,0)
		,PropertyName VARCHAR(50)
		,OldValue VARCHAR
		,NewValue VARCHAR )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.EventLogDetailId
		,t.EventLogId
		,t.PropertyName
		,t.OldValue
		,t.NewValue
FROM src.EventLogDetail t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		EventLogDetailId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.EventLogDetail
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		EventLogDetailId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.EventLogDetailId = s.EventLogDetailId
WHERE t.DmlOperation <> 'D'

$$;


