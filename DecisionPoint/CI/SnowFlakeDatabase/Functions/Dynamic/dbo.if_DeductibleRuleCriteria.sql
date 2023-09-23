CREATE OR REPLACE FUNCTION dbo.if_DeductibleRuleCriteria(
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
		,DeductibleRuleCriteriaId NUMBER(10,0)
		,PricingRuleDateCriteriaId NUMBER(3,0)
		,StartDate DATETIME
		,EndDate DATETIME )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.DeductibleRuleCriteriaId
		,t.PricingRuleDateCriteriaId
		,t.StartDate
		,t.EndDate
FROM src.DeductibleRuleCriteria t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		DeductibleRuleCriteriaId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.DeductibleRuleCriteria
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		DeductibleRuleCriteriaId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.DeductibleRuleCriteriaId = s.DeductibleRuleCriteriaId
WHERE t.DmlOperation <> 'D'

$$;


