CREATE OR REPLACE FUNCTION dbo.if_prf_PPO(
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
		,PPOSysId NUMBER(10,0)
		,ProfileId NUMBER(10,0)
		,PPOId NUMBER(10,0)
		,bStatus NUMBER(5,0)
		,StartDate DATETIME
		,EndDate DATETIME
		,AutoSend NUMBER(5,0)
		,AutoResend NUMBER(5,0)
		,BypassMatching NUMBER(5,0)
		,UseProviderNetworkEnrollment NUMBER(5,0)
		,TieredTypeId NUMBER(5,0)
		,Priority NUMBER(5,0)
		,PolicyEffectiveDate DATETIME
		,BillFormType NUMBER(10,0) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.PPOSysId
		,t.ProfileId
		,t.PPOId
		,t.bStatus
		,t.StartDate
		,t.EndDate
		,t.AutoSend
		,t.AutoResend
		,t.BypassMatching
		,t.UseProviderNetworkEnrollment
		,t.TieredTypeId
		,t.Priority
		,t.PolicyEffectiveDate
		,t.BillFormType
FROM src.prf_PPO t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		PPOSysId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.prf_PPO
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		PPOSysId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.PPOSysId = s.PPOSysId
WHERE t.DmlOperation <> 'D'

$$;


