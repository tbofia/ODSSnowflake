CREATE OR REPLACE FUNCTION dbo.if_SentryRuleTypeCriteria(
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
		,RuleTypeId NUMBER(10,0)
		,CriteriaId NUMBER(10,0) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.RuleTypeId
		,t.CriteriaId
FROM src.SentryRuleTypeCriteria t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		RuleTypeId,
		CriteriaId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.SentryRuleTypeCriteria
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		RuleTypeId,
		CriteriaId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.RuleTypeId = s.RuleTypeId
	AND t.CriteriaId = s.CriteriaId
WHERE t.DmlOperation <> 'D'

$$;


