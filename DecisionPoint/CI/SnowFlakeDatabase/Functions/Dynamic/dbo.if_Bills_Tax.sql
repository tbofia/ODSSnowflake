CREATE OR REPLACE FUNCTION dbo.if_Bills_Tax(
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
		,BillsTaxId NUMBER(10,0)
		,TableType NUMBER(5,0)
		,BillIdNo NUMBER(10,0)
		,Line_No NUMBER(5,0)
		,SeqNo NUMBER(5,0)
		,TaxTypeId NUMBER(5,0)
		,ImportTaxRate NUMBER(5,5)
		,Tax NUMBER(19,4)
		,OverridenTax NUMBER(19,4)
		,ImportTaxAmount NUMBER(19,4) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.BillsTaxId
		,t.TableType
		,t.BillIdNo
		,t.Line_No
		,t.SeqNo
		,t.TaxTypeId
		,t.ImportTaxRate
		,t.Tax
		,t.OverridenTax
		,t.ImportTaxAmount
FROM src.Bills_Tax t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		BillsTaxId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.Bills_Tax
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		BillsTaxId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.BillsTaxId = s.BillsTaxId
WHERE t.DmlOperation <> 'D'

$$;


