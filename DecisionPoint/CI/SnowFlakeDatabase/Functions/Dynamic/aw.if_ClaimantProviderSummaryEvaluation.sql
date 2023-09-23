CREATE OR REPLACE FUNCTION aw.if_ClaimantProviderSummaryEvaluation(
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
		,ClaimantProviderSummaryEvaluationId NUMBER(10,0)
		,ClaimantHeaderId NUMBER(10,0)
		,EvaluatedAmount NUMBER(19,4)
		,MinimumEvaluatedAmount NUMBER(19,4)
		,MaximumEvaluatedAmount NUMBER(19,4)
		,Comments VARCHAR(255) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.ClaimantProviderSummaryEvaluationId
		,t.ClaimantHeaderId
		,t.EvaluatedAmount
		,t.MinimumEvaluatedAmount
		,t.MaximumEvaluatedAmount
		,t.Comments
FROM src.ClaimantProviderSummaryEvaluation t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ClaimantProviderSummaryEvaluationId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.ClaimantProviderSummaryEvaluation
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ClaimantProviderSummaryEvaluationId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ClaimantProviderSummaryEvaluationId = s.ClaimantProviderSummaryEvaluationId
WHERE t.DmlOperation <> 'D'

$$;


