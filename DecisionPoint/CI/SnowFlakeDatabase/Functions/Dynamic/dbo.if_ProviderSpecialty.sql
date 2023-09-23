CREATE OR REPLACE FUNCTION dbo.if_ProviderSpecialty(
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
		,ProviderId NUMBER(10,0)
		,SpecialtyCode VARCHAR(50) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.ProviderId
		,t.SpecialtyCode
FROM src.ProviderSpecialty t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ProviderId,
		SpecialtyCode,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.ProviderSpecialty
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ProviderId,
		SpecialtyCode) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ProviderId = s.ProviderId
	AND t.SpecialtyCode = s.SpecialtyCode
WHERE t.DmlOperation <> 'D'

$$;


