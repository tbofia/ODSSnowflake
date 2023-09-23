CREATE OR REPLACE FUNCTION dbo.if_BIReportAdjustmentCategoryMapping(
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
		,BIReportAdjustmentCategoryId NUMBER(10,0)
		,Adjustment360SubCategoryId NUMBER(10,0) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.BIReportAdjustmentCategoryId
		,t.Adjustment360SubCategoryId
FROM src.BIReportAdjustmentCategoryMapping t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		BIReportAdjustmentCategoryId,
		Adjustment360SubCategoryId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.BIReportAdjustmentCategoryMapping
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		BIReportAdjustmentCategoryId,
		Adjustment360SubCategoryId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.BIReportAdjustmentCategoryId = s.BIReportAdjustmentCategoryId
	AND t.Adjustment360SubCategoryId = s.Adjustment360SubCategoryId
WHERE t.DmlOperation <> 'D'

$$;


