CREATE OR REPLACE FUNCTION dbo.if_CMT_HDR(
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
		,CMT_HDR_IDNo NUMBER(10,0)
		,CmtIDNo NUMBER(10,0)
		,PvdIDNo NUMBER(10,0)
		,LastChangedOn DATETIME )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.CMT_HDR_IDNo
		,t.CmtIDNo
		,t.PvdIDNo
		,t.LastChangedOn
FROM src.CMT_HDR t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		CMT_HDR_IDNo,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.CMT_HDR
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		CMT_HDR_IDNo) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.CMT_HDR_IDNo = s.CMT_HDR_IDNo
WHERE t.DmlOperation <> 'D'

$$;


