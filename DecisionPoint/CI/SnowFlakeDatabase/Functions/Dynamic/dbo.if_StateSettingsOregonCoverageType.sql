CREATE OR REPLACE FUNCTION dbo.if_StateSettingsOregonCoverageType(
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
		,StateSettingsOregonId NUMBER(3,0)
		,CoverageType VARCHAR(2) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.StateSettingsOregonId
		,t.CoverageType
FROM src.StateSettingsOregonCoverageType t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		StateSettingsOregonId,
		CoverageType,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.StateSettingsOregonCoverageType
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		StateSettingsOregonId,
		CoverageType) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.StateSettingsOregonId = s.StateSettingsOregonId
	AND t.CoverageType = s.CoverageType
WHERE t.DmlOperation <> 'D'

$$;


