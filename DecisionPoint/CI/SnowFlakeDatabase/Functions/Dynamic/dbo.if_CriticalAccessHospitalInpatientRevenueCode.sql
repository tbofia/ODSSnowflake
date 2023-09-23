CREATE OR REPLACE FUNCTION dbo.if_CriticalAccessHospitalInpatientRevenueCode(
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
		,RevenueCode VARCHAR(4) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.RevenueCode
FROM src.CriticalAccessHospitalInpatientRevenueCode t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		RevenueCode,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.CriticalAccessHospitalInpatientRevenueCode
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		RevenueCode) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.RevenueCode = s.RevenueCode
WHERE t.DmlOperation <> 'D'

$$;

