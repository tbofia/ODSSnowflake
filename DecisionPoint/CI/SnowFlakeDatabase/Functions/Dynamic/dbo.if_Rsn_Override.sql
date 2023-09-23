CREATE OR REPLACE FUNCTION dbo.if_Rsn_Override(
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
		,ReasonNumber NUMBER(10,0)
		,ShortDesc VARCHAR(50)
		,LongDesc VARCHAR
		,CategoryIdNo NUMBER(5,0)
		,ClientSpec NUMBER(5,0)
		,COAIndex NUMBER(5,0)
		,NJPenaltyPct NUMBER(9,6)
		,NetworkID NUMBER(10,0)
		,SpecialProcessing BOOLEAN )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.ReasonNumber
		,t.ShortDesc
		,t.LongDesc
		,t.CategoryIdNo
		,t.ClientSpec
		,t.COAIndex
		,t.NJPenaltyPct
		,t.NetworkID
		,t.SpecialProcessing
FROM src.Rsn_Override t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ReasonNumber,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.Rsn_Override
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ReasonNumber) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ReasonNumber = s.ReasonNumber
WHERE t.DmlOperation <> 'D'

$$;


