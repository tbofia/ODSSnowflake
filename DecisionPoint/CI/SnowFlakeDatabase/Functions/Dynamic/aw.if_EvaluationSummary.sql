CREATE OR REPLACE FUNCTION aw.if_EvaluationSummary(
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
		,DemandClaimantId NUMBER(10,0)
		,Details VARCHAR
		,CreatedBy VARCHAR(50)
		,CreatedDate TIMESTAMP_LTZ(7)
		,ModifiedBy VARCHAR(50)
		,ModifiedDate TIMESTAMP_LTZ(7)
		,EvaluationSummaryTemplateVersionId NUMBER(10,0) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.DemandClaimantId
		,t.Details
		,t.CreatedBy
		,t.CreatedDate
		,t.ModifiedBy
		,t.ModifiedDate
		,t.EvaluationSummaryTemplateVersionId
FROM src.EvaluationSummary t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		DemandClaimantId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.EvaluationSummary
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		DemandClaimantId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.DemandClaimantId = s.DemandClaimantId
WHERE t.DmlOperation <> 'D'

$$;


