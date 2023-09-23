CREATE OR REPLACE FUNCTION aw.if_AnalysisRule(
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
		,AnalysisRuleId NUMBER(10,0)
		,Title VARCHAR(200)
		,AssemblyQualifiedName VARCHAR(200)
		,MethodToInvoke VARCHAR(50)
		,DisplayMessage VARCHAR(200)
		,DisplayOrder NUMBER(10,0)
		,IsActive BOOLEAN
		,CreateDate TIMESTAMP_LTZ(7)
		,LastChangedOn TIMESTAMP_LTZ(7)
		,MessageToken VARCHAR(200) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.AnalysisRuleId
		,t.Title
		,t.AssemblyQualifiedName
		,t.MethodToInvoke
		,t.DisplayMessage
		,t.DisplayOrder
		,t.IsActive
		,t.CreateDate
		,t.LastChangedOn
		,t.MessageToken
FROM src.AnalysisRule t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		AnalysisRuleId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.AnalysisRule
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		AnalysisRuleId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.AnalysisRuleId = s.AnalysisRuleId
WHERE t.DmlOperation <> 'D'

$$;


