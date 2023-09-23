CREATE OR REPLACE FUNCTION dbo.if_StateSettingsFlorida(
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
		,StateSettingsFloridaId NUMBER(10,0)
		,ClaimantInitialServiceOption NUMBER(5,0)
		,ClaimantInitialServiceDays NUMBER(5,0) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.StateSettingsFloridaId
		,t.ClaimantInitialServiceOption
		,t.ClaimantInitialServiceDays
FROM src.StateSettingsFlorida t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		StateSettingsFloridaId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.StateSettingsFlorida
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		StateSettingsFloridaId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.StateSettingsFloridaId = s.StateSettingsFloridaId
WHERE t.DmlOperation <> 'D'

$$;


