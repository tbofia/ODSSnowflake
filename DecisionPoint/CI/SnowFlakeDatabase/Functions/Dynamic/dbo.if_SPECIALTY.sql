CREATE OR REPLACE FUNCTION dbo.if_SPECIALTY(
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
		,SpcIdNo NUMBER(10,0)
		,Code VARCHAR(50)
		,Description VARCHAR(70)
		,PayeeSubTypeID NUMBER(10,0)
		,TieredTypeID NUMBER(5,0) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.SpcIdNo
		,t.Code
		,t.Description
		,t.PayeeSubTypeID
		,t.TieredTypeID
FROM src.SPECIALTY t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		Code,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.SPECIALTY
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		Code) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.Code = s.Code
WHERE t.DmlOperation <> 'D'

$$;


