CREATE OR REPLACE FUNCTION aw.if_DemandPackage(
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
		,DemandPackageId NUMBER(10,0)
		,DemandClaimantId NUMBER(10,0)
		,RequestedByUserName VARCHAR(15)
		,DateTimeReceived TIMESTAMP_LTZ(7)
		,CorrelationId VARCHAR(36)
		,PageCount NUMBER(5,0) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.DemandPackageId
		,t.DemandClaimantId
		,t.RequestedByUserName
		,t.DateTimeReceived
		,t.CorrelationId
		,t.PageCount
FROM src.DemandPackage t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		DemandPackageId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.DemandPackage
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		DemandPackageId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.DemandPackageId = s.DemandPackageId
WHERE t.DmlOperation <> 'D'

$$;


