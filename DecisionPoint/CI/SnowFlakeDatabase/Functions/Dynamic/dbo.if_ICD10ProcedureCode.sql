CREATE OR REPLACE FUNCTION dbo.if_ICD10ProcedureCode(
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
		,ICDProcedureCode VARCHAR(7)
		,StartDate DATETIME
		,EndDate DATETIME
		,Description VARCHAR(300)
		,PASGrpNo NUMBER(5,0) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.ICDProcedureCode
		,t.StartDate
		,t.EndDate
		,t.Description
		,t.PASGrpNo
FROM src.ICD10ProcedureCode t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ICDProcedureCode,
		StartDate,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.ICD10ProcedureCode
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ICDProcedureCode,
		StartDate) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ICDProcedureCode = s.ICDProcedureCode
	AND t.StartDate = s.StartDate
WHERE t.DmlOperation <> 'D'

$$;


