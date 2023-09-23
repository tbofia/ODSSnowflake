CREATE OR REPLACE FUNCTION dbo.if_ApportionmentEndnote(
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
		,ApportionmentEndnote NUMBER(10,0)
		,ShortDescription VARCHAR(50)
		,LongDescription VARCHAR(500) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.ApportionmentEndnote
		,t.ShortDescription
		,t.LongDescription
FROM src.ApportionmentEndnote t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ApportionmentEndnote,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.ApportionmentEndnote
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ApportionmentEndnote) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ApportionmentEndnote = s.ApportionmentEndnote
WHERE t.DmlOperation <> 'D'

$$;


