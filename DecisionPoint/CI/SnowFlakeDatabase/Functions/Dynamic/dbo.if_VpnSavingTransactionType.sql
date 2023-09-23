CREATE OR REPLACE FUNCTION dbo.if_VpnSavingTransactionType(
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
		,VpnSavingTransactionTypeId NUMBER(10,0)
		,VpnSavingTransactionType VARCHAR(50) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.VpnSavingTransactionTypeId
		,t.VpnSavingTransactionType
FROM src.VpnSavingTransactionType t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		VpnSavingTransactionTypeId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.VpnSavingTransactionType
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		VpnSavingTransactionTypeId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.VpnSavingTransactionTypeId = s.VpnSavingTransactionTypeId
WHERE t.DmlOperation <> 'D'

$$;


