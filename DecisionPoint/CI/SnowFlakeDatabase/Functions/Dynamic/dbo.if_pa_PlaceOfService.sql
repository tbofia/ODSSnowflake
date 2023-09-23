CREATE OR REPLACE FUNCTION dbo.if_pa_PlaceOfService(
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
		,POS NUMBER(5,0)
		,Description VARCHAR(255)
		,Facility NUMBER(5,0)
		,MHL NUMBER(5,0)
		,PlusFour NUMBER(5,0)
		,Institution NUMBER(10,0) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.POS
		,t.Description
		,t.Facility
		,t.MHL
		,t.PlusFour
		,t.Institution
FROM src.pa_PlaceOfService t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		POS,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.pa_PlaceOfService
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		POS) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.POS = s.POS
WHERE t.DmlOperation <> 'D'

$$;


