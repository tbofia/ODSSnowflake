CREATE OR REPLACE FUNCTION dbo.if_IcdDiagnosisCodeDictionaryBodyPart(
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
		,NcciBodyPartId NUMBER(3,0) )
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
		,t.NcciBodyPartId
FROM src.IcdDiagnosisCodeDictionaryBodyPart t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		DiagnosisCode,
		IcdVersion,
		StartDate,
		NcciBodyPartId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.IcdDiagnosisCodeDictionaryBodyPart
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		DiagnosisCode,
		IcdVersion,
		StartDate,
		NcciBodyPartId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.DiagnosisCode = s.DiagnosisCode
	AND t.IcdVersion = s.IcdVersion
	AND t.StartDate = s.StartDate
	AND t.NcciBodyPartId = s.NcciBodyPartId
WHERE t.DmlOperation <> 'D'

$$;


