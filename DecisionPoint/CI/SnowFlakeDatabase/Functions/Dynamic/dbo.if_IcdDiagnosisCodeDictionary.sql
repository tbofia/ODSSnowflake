CREATE OR REPLACE FUNCTION dbo.if_IcdDiagnosisCodeDictionary(
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
		,DiagnosisCode VARCHAR(8)
		,IcdVersion NUMBER(3,0)
		,StartDate DATETIME
		,EndDate DATETIME
		,NonSpecific BOOLEAN
		,Traumatic BOOLEAN
		,Duration NUMBER(3,0)
		,Description VARCHAR
		,DiagnosisFamilyId NUMBER(3,0)
		,DiagnosisSeverityId NUMBER(3,0)
		,LateralityId NUMBER(3,0)
		,TotalCharactersRequired NUMBER(3,0)
		,PlaceholderRequired BOOLEAN
		,Flags NUMBER(5,0)
		,AdditionalDigits BOOLEAN
		,Colossus NUMBER(5,0)
		,InjuryNatureId NUMBER(3,0)
		,EncounterSubcategoryId NUMBER(3,0) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.DiagnosisCode
		,t.IcdVersion
		,t.StartDate
		,t.EndDate
		,t.NonSpecific
		,t.Traumatic
		,t.Duration
		,t.Description
		,t.DiagnosisFamilyId
		,t.DiagnosisSeverityId
		,t.LateralityId
		,t.TotalCharactersRequired
		,t.PlaceholderRequired
		,t.Flags
		,t.AdditionalDigits
		,t.Colossus
		,t.InjuryNatureId
		,t.EncounterSubcategoryId
FROM src.IcdDiagnosisCodeDictionary t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		DiagnosisCode,
		IcdVersion,
		StartDate,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.IcdDiagnosisCodeDictionary
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		DiagnosisCode,
		IcdVersion,
		StartDate) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.DiagnosisCode = s.DiagnosisCode
	AND t.IcdVersion = s.IcdVersion
	AND t.StartDate = s.StartDate
WHERE t.DmlOperation <> 'D'

$$;


