CREATE OR REPLACE FUNCTION dbo.if_SENTRY_PROFILE_RULE(
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
		,ProfileID NUMBER(10,0)
		,RuleID NUMBER(10,0)
		,Priority NUMBER(10,0) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.ProfileID
		,t.RuleID
		,t.Priority
FROM src.SENTRY_PROFILE_RULE t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ProfileID,
		RuleID,
		Priority,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.SENTRY_PROFILE_RULE
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ProfileID,
		RuleID,
		Priority) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ProfileID = s.ProfileID
	AND t.RuleID = s.RuleID
	AND t.Priority = s.Priority
WHERE t.DmlOperation <> 'D'

$$;


