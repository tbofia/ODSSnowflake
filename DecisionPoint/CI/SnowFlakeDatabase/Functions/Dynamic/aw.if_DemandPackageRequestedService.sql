CREATE OR REPLACE FUNCTION aw.if_DemandPackageRequestedService(
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
		,DemandPackageRequestedServiceId NUMBER(10,0)
		,DemandPackageId NUMBER(10,0)
		,ReviewRequestOptions VARCHAR )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.DemandPackageRequestedServiceId
		,t.DemandPackageId
		,t.ReviewRequestOptions
FROM src.DemandPackageRequestedService t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		DemandPackageRequestedServiceId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.DemandPackageRequestedService
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		DemandPackageRequestedServiceId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.DemandPackageRequestedServiceId = s.DemandPackageRequestedServiceId
WHERE t.DmlOperation <> 'D'

$$;


