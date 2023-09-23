CREATE OR REPLACE FUNCTION dbo.if_Provider_ClientRef(
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
		,PvdIdNo NUMBER(10,0)
		,ClientRefId VARCHAR(50)
		,ClientRefId2 VARCHAR(100) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.PvdIdNo
		,t.ClientRefId
		,t.ClientRefId2
FROM src.Provider_ClientRef t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		PvdIdNo,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.Provider_ClientRef
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		PvdIdNo) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.PvdIdNo = s.PvdIdNo
WHERE t.DmlOperation <> 'D'

$$;


