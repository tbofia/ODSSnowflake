CREATE OR REPLACE FUNCTION dbo.if_ny_pharmacy(
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
		,NDCCode VARCHAR(13)
		,StartDate DATETIME
		,EndDate DATETIME
		,Description VARCHAR(125)
		,Fee NUMBER(19,4)
		,TypeOfDrug NUMBER(5,0) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.NDCCode
		,t.StartDate
		,t.EndDate
		,t.Description
		,t.Fee
		,t.TypeOfDrug
FROM src.ny_pharmacy t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		NDCCode,
		StartDate,
		TypeOfDrug,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.ny_pharmacy
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		NDCCode,
		StartDate,
		TypeOfDrug) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.NDCCode = s.NDCCode
	AND t.StartDate = s.StartDate
	AND t.TypeOfDrug = s.TypeOfDrug
WHERE t.DmlOperation <> 'D'

$$;


