CREATE OR REPLACE FUNCTION dbo.if_NcciBodyPartToHybridBodyPartTranslation(
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
		,NcciBodyPartId NUMBER(3,0)
		,HybridBodyPartId NUMBER(5,0) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.NcciBodyPartId
		,t.HybridBodyPartId
FROM src.NcciBodyPartToHybridBodyPartTranslation t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		NcciBodyPartId,
		HybridBodyPartId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.NcciBodyPartToHybridBodyPartTranslation
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		NcciBodyPartId,
		HybridBodyPartId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.NcciBodyPartId = s.NcciBodyPartId
	AND t.HybridBodyPartId = s.HybridBodyPartId
WHERE t.DmlOperation <> 'D'

$$;


