CREATE OR REPLACE FUNCTION dbo.if_MedicareStatusIndicatorRule(
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
		,MedicareStatusIndicatorRuleId NUMBER(10,0)
		,MedicareStatusIndicatorRuleName VARCHAR(50)
		,StatusIndicator VARCHAR(500)
		,StartDate DATETIME
		,EndDate DATETIME
		,Endnote NUMBER(10,0)
		,EditActionId NUMBER(3,0)
		,Comments VARCHAR(1000) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.MedicareStatusIndicatorRuleId
		,t.MedicareStatusIndicatorRuleName
		,t.StatusIndicator
		,t.StartDate
		,t.EndDate
		,t.Endnote
		,t.EditActionId
		,t.Comments
FROM src.MedicareStatusIndicatorRule t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		MedicareStatusIndicatorRuleId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.MedicareStatusIndicatorRule
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		MedicareStatusIndicatorRuleId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.MedicareStatusIndicatorRuleId = s.MedicareStatusIndicatorRuleId
WHERE t.DmlOperation <> 'D'

$$;


