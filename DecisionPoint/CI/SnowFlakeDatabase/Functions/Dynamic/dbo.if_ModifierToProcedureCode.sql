CREATE OR REPLACE FUNCTION dbo.if_ModifierToProcedureCode(
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
		,ProcedureCode VARCHAR(5)
		,Modifier VARCHAR(2)
		,StartDate DATETIME
		,EndDate DATETIME
		,SojFlag NUMBER(5,0)
		,RequiresGuidelineReview BOOLEAN
		,Reference VARCHAR(255)
		,Comments VARCHAR(255) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.ProcedureCode
		,t.Modifier
		,t.StartDate
		,t.EndDate
		,t.SojFlag
		,t.RequiresGuidelineReview
		,t.Reference
		,t.Comments
FROM src.ModifierToProcedureCode t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ProcedureCode,
		Modifier,
		StartDate,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.ModifierToProcedureCode
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ProcedureCode,
		Modifier,
		StartDate) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ProcedureCode = s.ProcedureCode
	AND t.Modifier = s.Modifier
	AND t.StartDate = s.StartDate
WHERE t.DmlOperation <> 'D'

$$;


