CREATE OR REPLACE FUNCTION dbo.if_UDF_Sentry_Criteria(
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
		,UdfIdNo NUMBER(10,0)
		,CriteriaID NUMBER(10,0)
		,ParentName VARCHAR(50)
		,Name VARCHAR(50)
		,Description VARCHAR(1000)
		,Operators VARCHAR(50)
		,PredefinedValues VARCHAR
		,ValueDataType VARCHAR(50)
		,ValueFormat VARCHAR(50) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.UdfIdNo
		,t.CriteriaID
		,t.ParentName
		,t.Name
		,t.Description
		,t.Operators
		,t.PredefinedValues
		,t.ValueDataType
		,t.ValueFormat
FROM src.UDF_Sentry_Criteria t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		CriteriaID,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.UDF_Sentry_Criteria
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		CriteriaID) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.CriteriaID = s.CriteriaID
WHERE t.DmlOperation <> 'D'

$$;


