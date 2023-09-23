CREATE OR REPLACE FUNCTION dbo.if_MedicalCodeCutOffs(
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
		,CodeTypeID NUMBER(10,0)
		,CodeType VARCHAR(50)
		,Code VARCHAR(50)
		,FormType VARCHAR(10)
		,MaxChargedPerUnit FLOAT(53)
		,MaxUnitsPerEncounter FLOAT(53) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.CodeTypeID
		,t.CodeType
		,t.Code
		,t.FormType
		,t.MaxChargedPerUnit
		,t.MaxUnitsPerEncounter
FROM src.MedicalCodeCutOffs t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		CodeTypeID,
		Code,
		FormType,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.MedicalCodeCutOffs
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		CodeTypeID,
		Code,
		FormType) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.CodeTypeID = s.CodeTypeID
	AND t.Code = s.Code
	AND t.FormType = s.FormType
WHERE t.DmlOperation <> 'D'

$$;


