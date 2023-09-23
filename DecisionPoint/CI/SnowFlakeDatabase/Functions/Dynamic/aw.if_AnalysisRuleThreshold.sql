CREATE OR REPLACE FUNCTION aw.if_AnalysisRuleThreshold(
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
		,AnalysisRuleThresholdId NUMBER(10,0)
		,AnalysisRuleId NUMBER(10,0)
		,ThresholdKey VARCHAR(50)
		,ThresholdValue VARCHAR(100)
		,CreateDate TIMESTAMP_LTZ(7)
		,LastChangedOn TIMESTAMP_LTZ(7) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.AnalysisRuleThresholdId
		,t.AnalysisRuleId
		,t.ThresholdKey
		,t.ThresholdValue
		,t.CreateDate
		,t.LastChangedOn
FROM src.AnalysisRuleThreshold t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		AnalysisRuleThresholdId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.AnalysisRuleThreshold
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		AnalysisRuleThresholdId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.AnalysisRuleThresholdId = s.AnalysisRuleThresholdId
WHERE t.DmlOperation <> 'D'

$$;


