CREATE OR REPLACE FUNCTION dbo.if_UB_RevenueCodes(
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
		,RevenueCode VARCHAR(4)
		,StartDate DATETIME
		,EndDate DATETIME
		,PRC_DESC VARCHAR
		,Flags NUMBER(10,0)
		,Vague VARCHAR(1)
		,PerVisit NUMBER(5,0)
		,PerClaimant NUMBER(5,0)
		,PerProvider NUMBER(5,0)
		,BodyFlags NUMBER(10,0)
		,DrugFlag NUMBER(5,0)
		,CurativeFlag NUMBER(5,0)
		,RevenueCodeSubCategoryId NUMBER(3,0) )
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
		,t.StartDate
		,t.EndDate
		,t.PRC_DESC
		,t.Flags
		,t.Vague
		,t.PerVisit
		,t.PerClaimant
		,t.PerProvider
		,t.BodyFlags
		,t.DrugFlag
		,t.CurativeFlag
		,t.RevenueCodeSubCategoryId
FROM src.UB_RevenueCodes t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		RevenueCode,
		StartDate,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.UB_RevenueCodes
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		RevenueCode,
		StartDate) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.RevenueCode = s.RevenueCode
	AND t.StartDate = s.StartDate
WHERE t.DmlOperation <> 'D'

$$;


