CREATE OR REPLACE FUNCTION dbo.if_UDFListValues(
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
		,ListValueIdNo NUMBER(10,0)
		,UDFIdNo NUMBER(10,0)
		,SeqNo NUMBER(5,0)
		,ListValue VARCHAR(50)
		,DefaultValue NUMBER(5,0) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.ListValueIdNo
		,t.UDFIdNo
		,t.SeqNo
		,t.ListValue
		,t.DefaultValue
FROM src.UDFListValues t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ListValueIdNo,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.UDFListValues
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ListValueIdNo) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ListValueIdNo = s.ListValueIdNo
WHERE t.DmlOperation <> 'D'

$$;


