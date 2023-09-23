CREATE OR REPLACE FUNCTION dbo.if_lkp_TS(
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
		,ShortName VARCHAR(2)
		,StartDate DATETIME
		,EndDate DATETIME
		,LongName VARCHAR(100)
		,Global NUMBER(5,0)
		,AnesMedDirect NUMBER(5,0)
		,AffectsPricing NUMBER(5,0)
		,IsAssistantSurgery BOOLEAN
		,IsCoSurgeon BOOLEAN )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.ShortName
		,t.StartDate
		,t.EndDate
		,t.LongName
		,t.Global
		,t.AnesMedDirect
		,t.AffectsPricing
		,t.IsAssistantSurgery
		,t.IsCoSurgeon
FROM src.lkp_TS t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ShortName,
		StartDate,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.lkp_TS
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ShortName,
		StartDate) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ShortName = s.ShortName
	AND t.StartDate = s.StartDate
WHERE t.DmlOperation <> 'D'

$$;


