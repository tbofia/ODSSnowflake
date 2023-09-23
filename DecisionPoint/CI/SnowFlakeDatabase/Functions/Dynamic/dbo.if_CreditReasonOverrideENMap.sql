CREATE OR REPLACE FUNCTION dbo.if_CreditReasonOverrideENMap(
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
		,CreditReasonOverrideENMapId NUMBER(10,0)
		,CreditReasonId NUMBER(10,0)
		,OverrideEndnoteId NUMBER(5,0) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.CreditReasonOverrideENMapId
		,t.CreditReasonId
		,t.OverrideEndnoteId
FROM src.CreditReasonOverrideENMap t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		CreditReasonOverrideENMapId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.CreditReasonOverrideENMap
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		CreditReasonOverrideENMapId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.CreditReasonOverrideENMapId = s.CreditReasonOverrideENMapId
WHERE t.DmlOperation <> 'D'

$$;


