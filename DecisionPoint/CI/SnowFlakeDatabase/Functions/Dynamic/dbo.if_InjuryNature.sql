CREATE OR REPLACE FUNCTION dbo.if_InjuryNature(
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
		,InjuryNatureId NUMBER(3,0)
		,InjuryNaturePriority NUMBER(3,0)
		,Description VARCHAR(100)
		,NarrativeInformation VARCHAR )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.InjuryNatureId
		,t.InjuryNaturePriority
		,t.Description
		,t.NarrativeInformation
FROM src.InjuryNature t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		InjuryNatureId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.InjuryNature
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		InjuryNatureId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.InjuryNatureId = s.InjuryNatureId
WHERE t.DmlOperation <> 'D'

$$;


