CREATE OR REPLACE FUNCTION dbo.if_ModifierDictionary(
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
		,ModifierDictionaryId NUMBER(10,0)
		,Modifier VARCHAR(2)
		,StartDate DATETIME
		,EndDate DATETIME
		,Description VARCHAR(100)
		,Global BOOLEAN
		,AnesMedDirect BOOLEAN
		,AffectsPricing BOOLEAN
		,IsCoSurgeon BOOLEAN
		,IsAssistantSurgery BOOLEAN )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.ModifierDictionaryId
		,t.Modifier
		,t.StartDate
		,t.EndDate
		,t.Description
		,t.Global
		,t.AnesMedDirect
		,t.AffectsPricing
		,t.IsCoSurgeon
		,t.IsAssistantSurgery
FROM src.ModifierDictionary t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ModifierDictionaryId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.ModifierDictionary
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ModifierDictionaryId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ModifierDictionaryId = s.ModifierDictionaryId
WHERE t.DmlOperation <> 'D'

$$;


