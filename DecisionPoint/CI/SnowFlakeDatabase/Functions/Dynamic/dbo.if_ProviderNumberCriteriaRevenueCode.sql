CREATE OR REPLACE FUNCTION dbo.if_ProviderNumberCriteriaRevenueCode(
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
		,ProviderNumberCriteriaId NUMBER(5,0)
		,RevenueCode VARCHAR(4)
		,MatchingProfileNumber NUMBER(3,0)
		,AttributeMatchTypeId NUMBER(3,0) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.ProviderNumberCriteriaId
		,t.RevenueCode
		,t.MatchingProfileNumber
		,t.AttributeMatchTypeId
FROM src.ProviderNumberCriteriaRevenueCode t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ProviderNumberCriteriaId,
		RevenueCode,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.ProviderNumberCriteriaRevenueCode
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ProviderNumberCriteriaId,
		RevenueCode) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ProviderNumberCriteriaId = s.ProviderNumberCriteriaId
	AND t.RevenueCode = s.RevenueCode
WHERE t.DmlOperation <> 'D'

$$;


