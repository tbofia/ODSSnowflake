CREATE OR REPLACE FUNCTION dbo.if_Bitmasks(
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
		,TableProgramUsed VARCHAR(50)
		,AttributeUsed VARCHAR(50)
		,Decimal NUMBER(19,0)
		,ConstantName VARCHAR(50)
		,Bit VARCHAR(50)
		,Hex VARCHAR(20)
		,Description VARCHAR(250) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.TableProgramUsed
		,t.AttributeUsed
		,t.Decimal
		,t.ConstantName
		,t.Bit
		,t.Hex
		,t.Description
FROM src.Bitmasks t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		TableProgramUsed,
		AttributeUsed,
		Decimal,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.Bitmasks
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		TableProgramUsed,
		AttributeUsed,
		Decimal) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.TableProgramUsed = s.TableProgramUsed
	AND t.AttributeUsed = s.AttributeUsed
	AND t.Decimal = s.Decimal
WHERE t.DmlOperation <> 'D'

$$;


