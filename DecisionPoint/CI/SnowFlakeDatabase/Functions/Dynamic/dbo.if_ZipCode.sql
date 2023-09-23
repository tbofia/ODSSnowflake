CREATE OR REPLACE FUNCTION dbo.if_ZipCode(
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
		,ZipCode VARCHAR(5)
		,PrimaryRecord BOOLEAN
		,STATE VARCHAR(2)
		,City VARCHAR(30)
		,CityAlias VARCHAR(30)
		,County VARCHAR(30)
		,Cbsa VARCHAR(5)
		,CbsaType VARCHAR(5)
		,ZipCodeRegionId NUMBER(3,0) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.ZipCode
		,t.PrimaryRecord
		,t.STATE
		,t.City
		,t.CityAlias
		,t.County
		,t.Cbsa
		,t.CbsaType
		,t.ZipCodeRegionId
FROM src.ZipCode t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ZipCode,
		CityAlias,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.ZipCode
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ZipCode,
		CityAlias) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ZipCode = s.ZipCode
	AND t.CityAlias = s.CityAlias
WHERE t.DmlOperation <> 'D'

$$;


