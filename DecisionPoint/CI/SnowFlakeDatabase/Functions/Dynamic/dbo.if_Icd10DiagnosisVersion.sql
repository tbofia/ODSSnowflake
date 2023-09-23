CREATE OR REPLACE FUNCTION dbo.if_Icd10DiagnosisVersion(
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
		,StartDate DATETIME
		,EndDate DATETIME
		,NonSpecific BOOLEAN
		,Traumatic BOOLEAN
		,Duration NUMBER(5,0)
		,Description VARCHAR
		,DiagnosisFamilyId NUMBER(3,0)
		,TotalCharactersRequired NUMBER(3,0)
		,PlaceholderRequired BOOLEAN )
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
		,t.StartDate
		,t.EndDate
		,t.NonSpecific
		,t.Traumatic
		,t.Duration
		,t.Description
		,t.DiagnosisFamilyId
		,t.TotalCharactersRequired
		,t.PlaceholderRequired
FROM src.Icd10DiagnosisVersion t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		DiagnosisCode,
		StartDate,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.Icd10DiagnosisVersion
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		DiagnosisCode,
		StartDate) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.DiagnosisCode = s.DiagnosisCode
	AND t.StartDate = s.StartDate
WHERE t.DmlOperation <> 'D'

$$;


