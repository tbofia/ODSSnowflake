CREATE OR REPLACE FUNCTION dbo.if_lkp_SPC(
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
		,lkp_SpcId NUMBER(10,0)
		,LongName VARCHAR(50)
		,ShortName VARCHAR(4)
		,Mult NUMBER(19,4)
		,NCD92 NUMBER(5,0)
		,NCD93 NUMBER(5,0)
		,PlusFour NUMBER(5,0)
		,CbreSpecialtyCode VARCHAR(12) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.lkp_SpcId
		,t.LongName
		,t.ShortName
		,t.Mult
		,t.NCD92
		,t.NCD93
		,t.PlusFour
		,t.CbreSpecialtyCode
FROM src.lkp_SPC t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		lkp_SpcId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.lkp_SPC
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		lkp_SpcId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.lkp_SpcId = s.lkp_SpcId
WHERE t.DmlOperation <> 'D'

$$;


