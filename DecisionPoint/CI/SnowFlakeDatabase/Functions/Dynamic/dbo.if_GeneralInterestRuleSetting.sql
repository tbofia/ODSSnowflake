CREATE OR REPLACE FUNCTION dbo.if_GeneralInterestRuleSetting(
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
		,GeneralInterestRuleBaseTypeId NUMBER(3,0) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.GeneralInterestRuleBaseTypeId
FROM src.GeneralInterestRuleSetting t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		GeneralInterestRuleBaseTypeId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.GeneralInterestRuleSetting
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		GeneralInterestRuleBaseTypeId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.GeneralInterestRuleBaseTypeId = s.GeneralInterestRuleBaseTypeId
WHERE t.DmlOperation <> 'D'

$$;


