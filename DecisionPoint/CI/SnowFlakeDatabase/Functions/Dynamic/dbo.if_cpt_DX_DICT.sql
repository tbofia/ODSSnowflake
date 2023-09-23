CREATE OR REPLACE FUNCTION dbo.if_cpt_DX_DICT(
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
		,ICD9 VARCHAR(6)
		,StartDate DATETIME
		,EndDate DATETIME
		,Flags NUMBER(5,0)
		,NonSpecific VARCHAR(1)
		,AdditionalDigits VARCHAR(1)
		,Traumatic VARCHAR(1)
		,DX_DESC VARCHAR
		,Duration NUMBER(5,0)
		,Colossus NUMBER(5,0)
		,DiagnosisFamilyId NUMBER(3,0) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.ICD9
		,t.StartDate
		,t.EndDate
		,t.Flags
		,t.NonSpecific
		,t.AdditionalDigits
		,t.Traumatic
		,t.DX_DESC
		,t.Duration
		,t.Colossus
		,t.DiagnosisFamilyId
FROM src.cpt_DX_DICT t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ICD9,
		StartDate,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.cpt_DX_DICT
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ICD9,
		StartDate) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ICD9 = s.ICD9
	AND t.StartDate = s.StartDate
WHERE t.DmlOperation <> 'D'

$$;


