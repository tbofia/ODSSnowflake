CREATE OR REPLACE FUNCTION dbo.if_RevenueCodeCategory(
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
		,t.RevenueCodeCategoryId
		,t.Description
		,t.NarrativeInformation
FROM src.RevenueCodeCategory t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		RevenueCodeCategoryId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.RevenueCodeCategory
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		RevenueCodeCategoryId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.RevenueCodeCategoryId = s.RevenueCodeCategoryId
WHERE t.DmlOperation <> 'D'

$$;


