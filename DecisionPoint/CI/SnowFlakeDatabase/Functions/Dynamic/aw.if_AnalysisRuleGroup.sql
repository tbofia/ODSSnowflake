CREATE OR REPLACE FUNCTION aw.if_AnalysisRuleGroup(
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
		,AnalysisRuleGroupId NUMBER(10,0)
		,AnalysisRuleId NUMBER(10,0)
		,AnalysisGroupId NUMBER(10,0) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.AnalysisRuleGroupId
		,t.AnalysisRuleId
		,t.AnalysisGroupId
FROM src.AnalysisRuleGroup t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		AnalysisRuleGroupId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.AnalysisRuleGroup
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		AnalysisRuleGroupId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.AnalysisRuleGroupId = s.AnalysisRuleGroupId
WHERE t.DmlOperation <> 'D'

$$;


