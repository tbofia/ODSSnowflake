CREATE OR REPLACE FUNCTION dbo.if_RPT_RsnCategories(
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
		,CategoryIdNo NUMBER(5,0)
		,CatDesc VARCHAR(50)
		,Priority NUMBER(5,0) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.CategoryIdNo
		,t.CatDesc
		,t.Priority
FROM src.RPT_RsnCategories t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		CategoryIdNo,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.RPT_RsnCategories
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		CategoryIdNo) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.CategoryIdNo = s.CategoryIdNo
WHERE t.DmlOperation <> 'D'

$$;


