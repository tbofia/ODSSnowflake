CREATE OR REPLACE FUNCTION dbo.if_SENTRY_CRITERIA(
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
		,CriteriaID NUMBER(10,0)
		,ParentName VARCHAR(50)
		,Name VARCHAR(50)
		,Description VARCHAR(150)
		,Operators VARCHAR(50)
		,PredefinedValues VARCHAR
		,ValueDataType VARCHAR(50)
		,ValueFormat VARCHAR(250)
		,NullAllowed NUMBER(5,0) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.CriteriaID
		,t.ParentName
		,t.Name
		,t.Description
		,t.Operators
		,t.PredefinedValues
		,t.ValueDataType
		,t.ValueFormat
		,t.NullAllowed
FROM src.SENTRY_CRITERIA t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		CriteriaID,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.SENTRY_CRITERIA
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		CriteriaID) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.CriteriaID = s.CriteriaID
WHERE t.DmlOperation <> 'D'

$$;


