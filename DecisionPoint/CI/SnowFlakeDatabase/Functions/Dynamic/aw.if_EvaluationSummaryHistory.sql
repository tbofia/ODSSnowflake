CREATE OR REPLACE FUNCTION aw.if_EvaluationSummaryHistory(
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
		,EvaluationSummaryHistoryId NUMBER(10,0)
		,DemandClaimantId NUMBER(10,0)
		,EvaluationSummary VARCHAR
		,CreatedBy VARCHAR(50)
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
		,t.EvaluationSummaryHistoryId
		,t.DemandClaimantId
		,t.EvaluationSummary
		,t.CreatedBy
		,t.CreatedDate
FROM src.EvaluationSummaryHistory t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		EvaluationSummaryHistoryId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.EvaluationSummaryHistory
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		EvaluationSummaryHistoryId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.EvaluationSummaryHistoryId = s.EvaluationSummaryHistoryId
WHERE t.DmlOperation <> 'D'

$$;


