CREATE OR REPLACE FUNCTION dbo.if_ProviderSpecialtyToProvType(
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
		,ProviderType VARCHAR(20)
		,ProviderType_Desc VARCHAR(80)
		,Specialty VARCHAR(20)
		,Specialty_Desc VARCHAR(80)
		,CreateDate DATETIME
		,ModifyDate DATETIME
		,LogicalDelete VARCHAR(1) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.ProviderType
		,t.ProviderType_Desc
		,t.Specialty
		,t.Specialty_Desc
		,t.CreateDate
		,t.ModifyDate
		,t.LogicalDelete
FROM src.ProviderSpecialtyToProvType t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ProviderType,
		Specialty,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.ProviderSpecialtyToProvType
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ProviderType,
		Specialty) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ProviderType = s.ProviderType
	AND t.Specialty = s.Specialty
WHERE t.DmlOperation <> 'D'

$$;


