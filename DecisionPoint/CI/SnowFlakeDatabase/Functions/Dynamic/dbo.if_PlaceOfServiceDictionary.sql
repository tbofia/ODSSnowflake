CREATE OR REPLACE FUNCTION dbo.if_PlaceOfServiceDictionary(
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
		,PlaceOfServiceCode NUMBER(5,0)
		,Description VARCHAR(255)
		,Facility NUMBER(5,0)
		,MHL NUMBER(5,0)
		,PlusFour NUMBER(5,0)
		,Institution NUMBER(10,0)
		,StartDate DATETIME
		,EndDate DATETIME )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.PlaceOfServiceCode
		,t.Description
		,t.Facility
		,t.MHL
		,t.PlusFour
		,t.Institution
		,t.StartDate
		,t.EndDate
FROM src.PlaceOfServiceDictionary t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		PlaceOfServiceCode,
		StartDate,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.PlaceOfServiceDictionary
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		PlaceOfServiceCode,
		StartDate) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.PlaceOfServiceCode = s.PlaceOfServiceCode
	AND t.StartDate = s.StartDate
WHERE t.DmlOperation <> 'D'

$$;


