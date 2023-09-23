CREATE OR REPLACE FUNCTION dbo.if_StateSettingsHawaii(
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
		,StateSettingsHawaiiId NUMBER(10,0)
		,PhysicalMedicineLimitOption NUMBER(5,0) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.StateSettingsHawaiiId
		,t.PhysicalMedicineLimitOption
FROM src.StateSettingsHawaii t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		StateSettingsHawaiiId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.StateSettingsHawaii
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		StateSettingsHawaiiId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.StateSettingsHawaiiId = s.StateSettingsHawaiiId
WHERE t.DmlOperation <> 'D'

$$;


