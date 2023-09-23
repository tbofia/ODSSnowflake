CREATE OR REPLACE FUNCTION dbo.if_EncounterType(
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
		,EncounterTypeId NUMBER(3,0)
		,EncounterTypePriority NUMBER(3,0)
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
		,t.EncounterTypeId
		,t.EncounterTypePriority
		,t.Description
		,t.NarrativeInformation
FROM src.EncounterType t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		EncounterTypeId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.EncounterType
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		EncounterTypeId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.EncounterTypeId = s.EncounterTypeId
WHERE t.DmlOperation <> 'D'

$$;


