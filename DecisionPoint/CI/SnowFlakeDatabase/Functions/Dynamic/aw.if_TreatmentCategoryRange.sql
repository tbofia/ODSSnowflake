CREATE OR REPLACE FUNCTION aw.if_TreatmentCategoryRange(
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
		,TreatmentCategoryRangeId NUMBER(10,0)
		,TreatmentCategoryId NUMBER(3,0)
		,StartRange VARCHAR(7)
		,EndRange VARCHAR(7) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.TreatmentCategoryRangeId
		,t.TreatmentCategoryId
		,t.StartRange
		,t.EndRange
FROM src.TreatmentCategoryRange t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		TreatmentCategoryRangeId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.TreatmentCategoryRange
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		TreatmentCategoryRangeId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.TreatmentCategoryRangeId = s.TreatmentCategoryRangeId
WHERE t.DmlOperation <> 'D'

$$;


