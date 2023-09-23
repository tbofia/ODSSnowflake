CREATE OR REPLACE FUNCTION dbo.if_prf_Office(
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
		,CompanyId NUMBER(10,0)
		,OfficeId NUMBER(10,0)
		,OfcNo VARCHAR(4)
		,OfcName VARCHAR(40)
		,OfcAddr1 VARCHAR(30)
		,OfcAddr2 VARCHAR(30)
		,OfcCity VARCHAR(30)
		,OfcState VARCHAR(2)
		,OfcZip VARCHAR(12)
		,OfcPhone VARCHAR(20)
		,OfcDefault NUMBER(5,0)
		,OfcClaimMask VARCHAR(50)
		,OfcTinMask VARCHAR(50)
		,Version NUMBER(5,0)
		,OfcEdits NUMBER(10,0)
		,OfcCOAEnabled NUMBER(5,0)
		,CTGEnabled NUMBER(5,0)
		,LastChangedOn DATETIME
		,AllowMultiCoverage BOOLEAN )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.CompanyId
		,t.OfficeId
		,t.OfcNo
		,t.OfcName
		,t.OfcAddr1
		,t.OfcAddr2
		,t.OfcCity
		,t.OfcState
		,t.OfcZip
		,t.OfcPhone
		,t.OfcDefault
		,t.OfcClaimMask
		,t.OfcTinMask
		,t.Version
		,t.OfcEdits
		,t.OfcCOAEnabled
		,t.CTGEnabled
		,t.LastChangedOn
		,t.AllowMultiCoverage
FROM src.prf_Office t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		OfficeId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.prf_Office
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		OfficeId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.OfficeId = s.OfficeId
WHERE t.DmlOperation <> 'D'

$$;


