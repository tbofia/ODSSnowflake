CREATE OR REPLACE FUNCTION dbo.if_UB_APC_DICT(
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
		,StartDate DATETIME
		,EndDate DATETIME
		,APC VARCHAR(5)
		,Description VARCHAR(255) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.StartDate
		,t.EndDate
		,t.APC
		,t.Description
FROM src.UB_APC_DICT t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		APC,
		StartDate,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.UB_APC_DICT
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		APC,
		StartDate) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.APC = s.APC
	AND t.StartDate = s.StartDate
WHERE t.DmlOperation <> 'D'

$$;


