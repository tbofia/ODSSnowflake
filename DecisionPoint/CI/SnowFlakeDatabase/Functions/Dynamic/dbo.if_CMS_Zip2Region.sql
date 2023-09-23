CREATE OR REPLACE FUNCTION dbo.if_CMS_Zip2Region(
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
		,StartDate DATETIME
		,EndDate DATETIME
		,ZIP_Code VARCHAR(5)
		,State VARCHAR(2)
		,Region VARCHAR(2)
		,AmbRegion VARCHAR(2)
		,RuralFlag NUMBER(5,0)
		,ASCRegion NUMBER(5,0)
		,PlusFour NUMBER(5,0)
		,CarrierId NUMBER(10,0) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.StartDate
		,t.EndDate
		,t.ZIP_Code
		,t.State
		,t.Region
		,t.AmbRegion
		,t.RuralFlag
		,t.ASCRegion
		,t.PlusFour
		,t.CarrierId
FROM src.CMS_Zip2Region t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		StartDate,
		ZIP_Code,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.CMS_Zip2Region
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		StartDate,
		ZIP_Code) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.StartDate = s.StartDate
	AND t.ZIP_Code = s.ZIP_Code
WHERE t.DmlOperation <> 'D'

$$;


