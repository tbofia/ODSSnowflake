CREATE OR REPLACE FUNCTION dbo.if_Claims_ClientRef(
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
		,ClaimIdNo NUMBER(10,0)
		,ClientRefId VARCHAR(50) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.ClaimIdNo
		,t.ClientRefId
FROM src.Claims_ClientRef t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ClaimIdNo,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.Claims_ClientRef
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ClaimIdNo) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ClaimIdNo = s.ClaimIdNo
WHERE t.DmlOperation <> 'D'

$$;


