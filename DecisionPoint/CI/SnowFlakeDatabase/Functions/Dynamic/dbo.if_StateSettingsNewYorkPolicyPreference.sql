CREATE OR REPLACE FUNCTION dbo.if_StateSettingsNewYorkPolicyPreference(
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
		,PolicyPreferenceId NUMBER(10,0)
		,ShareCoPayMaximum BOOLEAN )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.PolicyPreferenceId
		,t.ShareCoPayMaximum
FROM src.StateSettingsNewYorkPolicyPreference t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		PolicyPreferenceId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.StateSettingsNewYorkPolicyPreference
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		PolicyPreferenceId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.PolicyPreferenceId = s.PolicyPreferenceId
WHERE t.DmlOperation <> 'D'

$$;


