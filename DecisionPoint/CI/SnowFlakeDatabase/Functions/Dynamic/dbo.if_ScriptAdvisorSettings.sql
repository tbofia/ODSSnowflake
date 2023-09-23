CREATE OR REPLACE FUNCTION dbo.if_ScriptAdvisorSettings(
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
		,ScriptAdvisorSettingsId NUMBER(3,0)
		,IsPharmacyEligible BOOLEAN
		,EnableSendCardToClaimant BOOLEAN
		,EnableBillSource BOOLEAN )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.ScriptAdvisorSettingsId
		,t.IsPharmacyEligible
		,t.EnableSendCardToClaimant
		,t.EnableBillSource
FROM src.ScriptAdvisorSettings t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ScriptAdvisorSettingsId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.ScriptAdvisorSettings
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ScriptAdvisorSettingsId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ScriptAdvisorSettingsId = s.ScriptAdvisorSettingsId
WHERE t.DmlOperation <> 'D'

$$;


