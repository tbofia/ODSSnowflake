CREATE OR REPLACE FUNCTION dbo.if_prf_CTGPenaltyLines(
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
		,CTGPenLineID NUMBER(10,0)
		,ProfileId NUMBER(10,0)
		,PenaltyType NUMBER(5,0)
		,FeeSchedulePercent NUMBER(5,0)
		,StartDate DATETIME
		,EndDate DATETIME
		,TurnAroundTime NUMBER(5,0) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.CTGPenLineID
		,t.ProfileId
		,t.PenaltyType
		,t.FeeSchedulePercent
		,t.StartDate
		,t.EndDate
		,t.TurnAroundTime
FROM src.prf_CTGPenaltyLines t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		CTGPenLineID,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.prf_CTGPenaltyLines
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		CTGPenLineID) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.CTGPenLineID = s.CTGPenLineID
WHERE t.DmlOperation <> 'D'

$$;


