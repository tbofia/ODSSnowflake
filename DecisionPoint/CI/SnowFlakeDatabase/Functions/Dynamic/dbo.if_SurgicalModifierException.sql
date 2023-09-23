CREATE OR REPLACE FUNCTION dbo.if_SurgicalModifierException(
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
		,Modifier VARCHAR(2)
		,State VARCHAR(2)
		,CoverageType VARCHAR(2)
		,StartDate DATETIME
		,EndDate DATETIME )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.Modifier
		,t.State
		,t.CoverageType
		,t.StartDate
		,t.EndDate
FROM src.SurgicalModifierException t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		Modifier,
		State,
		CoverageType,
		StartDate,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.SurgicalModifierException
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		Modifier,
		State,
		CoverageType,
		StartDate) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.Modifier = s.Modifier
	AND t.State = s.State
	AND t.CoverageType = s.CoverageType
	AND t.StartDate = s.StartDate
WHERE t.DmlOperation <> 'D'

$$;


