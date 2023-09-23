CREATE OR REPLACE FUNCTION dbo.if_SENTRY_ACTION(
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
		,ActionID NUMBER(10,0)
		,Name VARCHAR(50)
		,Description VARCHAR(100)
		,CompatibilityKey VARCHAR(50)
		,PredefinedValues VARCHAR
		,ValueDataType VARCHAR(50)
		,ValueFormat VARCHAR(250)
		,BillLineAction NUMBER(10,0)
		,AnalyzeFlag NUMBER(5,0)
		,ActionCategoryIDNo NUMBER(10,0) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.ActionID
		,t.Name
		,t.Description
		,t.CompatibilityKey
		,t.PredefinedValues
		,t.ValueDataType
		,t.ValueFormat
		,t.BillLineAction
		,t.AnalyzeFlag
		,t.ActionCategoryIDNo
FROM src.SENTRY_ACTION t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ActionID,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.SENTRY_ACTION
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ActionID) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ActionID = s.ActionID
WHERE t.DmlOperation <> 'D'

$$;


