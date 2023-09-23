CREATE OR REPLACE FUNCTION dbo.if_RevenueCodeSubCategory(
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
		,RevenueCodeSubcategoryId NUMBER(3,0)
		,RevenueCodeCategoryId NUMBER(3,0)
		,Description VARCHAR(100)
		,NarrativeInformation VARCHAR(1000) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.RevenueCodeSubcategoryId
		,t.RevenueCodeCategoryId
		,t.Description
		,t.NarrativeInformation
FROM src.RevenueCodeSubCategory t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		RevenueCodeSubcategoryId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.RevenueCodeSubCategory
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		RevenueCodeSubcategoryId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.RevenueCodeSubcategoryId = s.RevenueCodeSubcategoryId
WHERE t.DmlOperation <> 'D'

$$;


