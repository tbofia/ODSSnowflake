CREATE OR REPLACE FUNCTION dbo.if_VpnBillingCategory(
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
		,VpnBillingCategoryCode VARCHAR(1)
		,VpnBillingCategoryDescription VARCHAR(30) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.VpnBillingCategoryCode
		,t.VpnBillingCategoryDescription
FROM src.VpnBillingCategory t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		VpnBillingCategoryCode,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.VpnBillingCategory
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		VpnBillingCategoryCode) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.VpnBillingCategoryCode = s.VpnBillingCategoryCode
WHERE t.DmlOperation <> 'D'

$$;


