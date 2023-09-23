CREATE OR REPLACE FUNCTION aw.if_PROVIDEDLINK(
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
		,PROVIDEDLINKID NUMBER(10,0)
		,TITLE VARCHAR(100)
		,URL VARCHAR(150)
		,ORDERINDEX	NUMBER(3,0))
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.PROVIDEDLINKID
		,t.TITLE
		,t.URL
		,t.ORDERINDEX

FROM src.PROVIDEDLINK t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		PROVIDEDLINKID,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.PROVIDEDLINK
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		PROVIDEDLINKID) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.PROVIDEDLINKID = s.PROVIDEDLINKID
WHERE t.DmlOperation <> 'D'

$$;
