CREATE OR REPLACE FUNCTION dbo.if_UDFClaimant(
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
		,CmtIdNo NUMBER(10,0)
		,UDFIdNo NUMBER(10,0)
		,UDFValueText VARCHAR(255)
		,UDFValueDecimal NUMBER(19,4)
		,UDFValueDate DATETIME )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.CmtIdNo
		,t.UDFIdNo
		,t.UDFValueText
		,t.UDFValueDecimal
		,t.UDFValueDate
FROM src.UDFClaimant t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		CmtIdNo,
		UDFIdNo,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.UDFClaimant
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		CmtIdNo,
		UDFIdNo) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.CmtIdNo = s.CmtIdNo
	AND t.UDFIdNo = s.UDFIdNo
WHERE t.DmlOperation <> 'D'

$$;


