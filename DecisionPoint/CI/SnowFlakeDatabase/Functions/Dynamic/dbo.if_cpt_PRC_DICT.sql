CREATE OR REPLACE FUNCTION dbo.if_cpt_PRC_DICT(
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
		,PRC_CD VARCHAR(7)
		,StartDate DATETIME
		,EndDate DATETIME
		,PRC_DESC VARCHAR
		,Flags NUMBER(10,0)
		,Vague VARCHAR(1)
		,PerVisit NUMBER(5,0)
		,PerClaimant NUMBER(5,0)
		,PerProvider NUMBER(5,0)
		,BodyFlags NUMBER(10,0)
		,Colossus NUMBER(5,0)
		,CMS_Status VARCHAR(1)
		,DrugFlag NUMBER(5,0)
		,CurativeFlag NUMBER(5,0)
		,ExclPolicyLimit NUMBER(5,0)
		,SpecNetFlag NUMBER(5,0) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.PRC_CD
		,t.StartDate
		,t.EndDate
		,t.PRC_DESC
		,t.Flags
		,t.Vague
		,t.PerVisit
		,t.PerClaimant
		,t.PerProvider
		,t.BodyFlags
		,t.Colossus
		,t.CMS_Status
		,t.DrugFlag
		,t.CurativeFlag
		,t.ExclPolicyLimit
		,t.SpecNetFlag
FROM src.cpt_PRC_DICT t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		PRC_CD,
		StartDate,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.cpt_PRC_DICT
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		PRC_CD,
		StartDate) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.PRC_CD = s.PRC_CD
	AND t.StartDate = s.StartDate
WHERE t.DmlOperation <> 'D'

$$;


