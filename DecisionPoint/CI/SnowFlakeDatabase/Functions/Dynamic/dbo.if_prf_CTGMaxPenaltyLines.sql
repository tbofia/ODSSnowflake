CREATE OR REPLACE FUNCTION dbo.if_prf_CTGMaxPenaltyLines(
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
		,CTGMaxPenLineID NUMBER(10,0)
		,ProfileId NUMBER(10,0)
		,DatesBasedOn NUMBER(5,0)
		,MaxPenaltyPercent NUMBER(5,0)
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
		,t.CTGMaxPenLineID
		,t.ProfileId
		,t.DatesBasedOn
		,t.MaxPenaltyPercent
		,t.StartDate
		,t.EndDate
FROM src.prf_CTGMaxPenaltyLines t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		CTGMaxPenLineID,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.prf_CTGMaxPenaltyLines
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		CTGMaxPenLineID) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.CTGMaxPenLineID = s.CTGMaxPenLineID
WHERE t.DmlOperation <> 'D'

$$;


