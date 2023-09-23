CREATE OR REPLACE FUNCTION aw.if_DemandClaimant(
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
		,DemandClaimantId NUMBER(10,0)
		,ExternalClaimantId NUMBER(10,0)
		,OrganizationId VARCHAR(100)
		,HeightInInches NUMBER(5,0)
		,Weight NUMBER(5,0)
		,Occupation VARCHAR(50)
		,BiReportStatus NUMBER(5,0)
		,HasDemandPackage NUMBER(10,0)
		,FactsOfLoss VARCHAR(250)
		,PreExistingConditions VARCHAR(100)
		,Archived BOOLEAN )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.DemandClaimantId
		,t.ExternalClaimantId
		,t.OrganizationId
		,t.HeightInInches
		,t.Weight
		,t.Occupation
		,t.BiReportStatus
		,t.HasDemandPackage
		,t.FactsOfLoss
		,t.PreExistingConditions
		,t.Archived
FROM src.DemandClaimant t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		DemandClaimantId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.DemandClaimant
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		DemandClaimantId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.DemandClaimantId = s.DemandClaimantId
WHERE t.DmlOperation <> 'D'

$$;


