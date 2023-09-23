CREATE OR REPLACE FUNCTION aw.if_ClaimantManualProviderSummary(
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
		,ManualProviderId NUMBER(10,0)
		,DemandClaimantId NUMBER(10,0)
		,FirstDateOfService DATETIME
		,LastDateOfService DATETIME
		,Visits NUMBER(10,0)
		,ChargedAmount NUMBER(19,4)
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
		,t.ManualProviderId
		,t.DemandClaimantId
		,t.FirstDateOfService
		,t.LastDateOfService
		,t.Visits
		,t.ChargedAmount
		,t.EvaluatedAmount
		,t.MinimumEvaluatedAmount
		,t.MaximumEvaluatedAmount
		,t.Comments
FROM src.ClaimantManualProviderSummary t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ManualProviderId,
		DemandClaimantId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.ClaimantManualProviderSummary
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ManualProviderId,
		DemandClaimantId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ManualProviderId = s.ManualProviderId
	AND t.DemandClaimantId = s.DemandClaimantId
WHERE t.DmlOperation <> 'D'

$$;


