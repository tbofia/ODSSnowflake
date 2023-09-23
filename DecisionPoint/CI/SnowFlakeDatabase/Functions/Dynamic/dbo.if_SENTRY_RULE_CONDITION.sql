CREATE OR REPLACE FUNCTION dbo.if_SENTRY_RULE_CONDITION(
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
		,RuleID NUMBER(10,0)
		,LineNumber NUMBER(10,0)
		,GroupFlag VARCHAR(50)
		,CriteriaID NUMBER(10,0)
		,Operator VARCHAR(50)
		,ConditionValue VARCHAR(60)
		,AndOr VARCHAR(50)
		,UdfConditionId NUMBER(10,0) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.RuleID
		,t.LineNumber
		,t.GroupFlag
		,t.CriteriaID
		,t.Operator
		,t.ConditionValue
		,t.AndOr
		,t.UdfConditionId
FROM src.SENTRY_RULE_CONDITION t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		RuleID,
		LineNumber,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.SENTRY_RULE_CONDITION
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		RuleID,
		LineNumber) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.RuleID = s.RuleID
	AND t.LineNumber = s.LineNumber
WHERE t.DmlOperation <> 'D'

$$;


