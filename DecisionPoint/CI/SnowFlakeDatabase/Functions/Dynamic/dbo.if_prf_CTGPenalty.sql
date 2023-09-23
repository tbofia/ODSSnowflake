CREATE OR REPLACE FUNCTION dbo.if_prf_CTGPenalty(
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
		,CTGPenID NUMBER(10,0)
		,ProfileId NUMBER(10,0)
		,ApplyPreCerts NUMBER(5,0)
		,NoPrecertLogged NUMBER(5,0)
		,MaxTotalPenalty NUMBER(5,0)
		,TurnTimeForAppeals NUMBER(5,0)
		,ApplyEndnoteForPercert NUMBER(5,0)
		,ApplyEndnoteForCarePath NUMBER(5,0)
		,ExemptPrecertPenalty NUMBER(5,0)
		,ApplyNetworkPenalty BOOLEAN )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.CTGPenID
		,t.ProfileId
		,t.ApplyPreCerts
		,t.NoPrecertLogged
		,t.MaxTotalPenalty
		,t.TurnTimeForAppeals
		,t.ApplyEndnoteForPercert
		,t.ApplyEndnoteForCarePath
		,t.ExemptPrecertPenalty
		,t.ApplyNetworkPenalty
FROM src.prf_CTGPenalty t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		CTGPenID,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.prf_CTGPenalty
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		CTGPenID) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.CTGPenID = s.CTGPenID
WHERE t.DmlOperation <> 'D'

$$;


