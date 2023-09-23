CREATE OR REPLACE FUNCTION aw.if_AcceptedTreatmentDate(
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
		,AcceptedTreatmentDateId NUMBER(10,0)
		,DemandClaimantId NUMBER(10,0)
		,TreatmentDate TIMESTAMP_LTZ(7)
		,Comments VARCHAR(255)
		,TreatmentCategoryId NUMBER(3,0)
		,LastUpdatedBy VARCHAR(15)
		,LastUpdatedDate TIMESTAMP_LTZ(7) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.AcceptedTreatmentDateId
		,t.DemandClaimantId
		,t.TreatmentDate
		,t.Comments
		,t.TreatmentCategoryId
		,t.LastUpdatedBy
		,t.LastUpdatedDate
FROM src.AcceptedTreatmentDate t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		AcceptedTreatmentDateId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.AcceptedTreatmentDate
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		AcceptedTreatmentDateId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.AcceptedTreatmentDateId = s.AcceptedTreatmentDateId
WHERE t.DmlOperation <> 'D'

$$;


