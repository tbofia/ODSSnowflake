CREATE OR REPLACE FUNCTION dbo.if_ProcedureServiceCategory(
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
		,ProcedureServiceCategoryId NUMBER(3,0)
		,ProcedureServiceCategoryName VARCHAR(50)
		,ProcedureServiceCategoryDescription VARCHAR(100)
		,LegacyTableName VARCHAR(100)
		,LegacyBitValue NUMBER(10,0) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.ProcedureServiceCategoryId
		,t.ProcedureServiceCategoryName
		,t.ProcedureServiceCategoryDescription
		,t.LegacyTableName
		,t.LegacyBitValue
FROM src.ProcedureServiceCategory t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ProcedureServiceCategoryId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.ProcedureServiceCategory
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ProcedureServiceCategoryId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ProcedureServiceCategoryId = s.ProcedureServiceCategoryId
WHERE t.DmlOperation <> 'D'

$$;


