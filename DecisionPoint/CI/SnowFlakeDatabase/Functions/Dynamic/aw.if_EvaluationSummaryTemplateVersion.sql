CREATE OR REPLACE FUNCTION aw.if_EvaluationSummaryTemplateVersion(
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
		,EvaluationSummaryTemplateVersionId NUMBER(10,0)
		,Template VARCHAR
		,TemplateHash BINARY(32)
		,CreatedDate TIMESTAMP_LTZ(7) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.EvaluationSummaryTemplateVersionId
		,t.Template
		,t.TemplateHash
		,t.CreatedDate
FROM src.EvaluationSummaryTemplateVersion t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		EvaluationSummaryTemplateVersionId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.EvaluationSummaryTemplateVersion
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		EvaluationSummaryTemplateVersionId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.EvaluationSummaryTemplateVersionId = s.EvaluationSummaryTemplateVersionId
WHERE t.DmlOperation <> 'D'

$$;


