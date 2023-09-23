CREATE OR REPLACE FUNCTION dbo.if_prf_CTGPenaltyHdr(
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
		,CTGPenHdrID NUMBER(10,0)
		,ProfileId NUMBER(10,0)
		,PenaltyType NUMBER(5,0)
		,PayNegRate NUMBER(5,0)
		,PayPPORate NUMBER(5,0)
		,DatesBasedOn NUMBER(5,0)
		,ApplyPenaltyToPharmacy BOOLEAN
		,ApplyPenaltyCondition BOOLEAN )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.CTGPenHdrID
		,t.ProfileId
		,t.PenaltyType
		,t.PayNegRate
		,t.PayPPORate
		,t.DatesBasedOn
		,t.ApplyPenaltyToPharmacy
		,t.ApplyPenaltyCondition
FROM src.prf_CTGPenaltyHdr t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		CTGPenHdrID,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.prf_CTGPenaltyHdr
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		CTGPenHdrID) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.CTGPenHdrID = s.CTGPenHdrID
WHERE t.DmlOperation <> 'D'

$$;


