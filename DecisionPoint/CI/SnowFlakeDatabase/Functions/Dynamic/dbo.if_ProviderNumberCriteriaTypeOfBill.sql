CREATE OR REPLACE FUNCTION dbo.if_ProviderNumberCriteriaTypeOfBill(
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
		,TypeOfBill VARCHAR(4)
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
		,t.TypeOfBill
		,t.MatchingProfileNumber
		,t.AttributeMatchTypeId
FROM src.ProviderNumberCriteriaTypeOfBill t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ProviderNumberCriteriaId,
		TypeOfBill,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.ProviderNumberCriteriaTypeOfBill
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ProviderNumberCriteriaId,
		TypeOfBill) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ProviderNumberCriteriaId = s.ProviderNumberCriteriaId
	AND t.TypeOfBill = s.TypeOfBill
WHERE t.DmlOperation <> 'D'

$$;


