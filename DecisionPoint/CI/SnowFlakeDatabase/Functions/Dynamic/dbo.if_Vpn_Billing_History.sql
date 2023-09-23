CREATE OR REPLACE FUNCTION dbo.if_Vpn_Billing_History(
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
		,Customer VARCHAR(50)
		,TransactionID NUMBER(19,0)
		,Period DATETIME
		,ActivityFlag VARCHAR(1)
		,BillableFlag VARCHAR(1)
		,Void VARCHAR(4)
		,CreditType VARCHAR(10)
		,Network VARCHAR(50)
		,BillIdNo NUMBER(10,0)
		,Line_No NUMBER(5,0)
		,TransactionDate DATETIME
		,RepriceDate DATETIME
		,ClaimNo VARCHAR(50)
		,ProviderCharges NUMBER(19,4)
		,DPAllowed NUMBER(19,4)
		,VPNAllowed NUMBER(19,4)
		,Savings NUMBER(19,4)
		,Credits NUMBER(19,4)
		,NetSavings NUMBER(19,4)
		,SOJ VARCHAR(2)
		,seqno NUMBER(10,0)
		,CompanyCode VARCHAR(10)
		,VpnId NUMBER(5,0)
		,ProcessFlag NUMBER(5,0)
		,SK NUMBER(10,0)
		,DATABASE_NAME VARCHAR(100)
		,SubmittedToFinance BOOLEAN
		,IsInitialLoad BOOLEAN
		,VpnBillingCategoryCode VARCHAR(1) )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.Customer
		,t.TransactionID
		,t.Period
		,t.ActivityFlag
		,t.BillableFlag
		,t.Void
		,t.CreditType
		,t.Network
		,t.BillIdNo
		,t.Line_No
		,t.TransactionDate
		,t.RepriceDate
		,t.ClaimNo
		,t.ProviderCharges
		,t.DPAllowed
		,t.VPNAllowed
		,t.Savings
		,t.Credits
		,t.NetSavings
		,t.SOJ
		,t.seqno
		,t.CompanyCode
		,t.VpnId
		,t.ProcessFlag
		,t.SK
		,t.DATABASE_NAME
		,t.SubmittedToFinance
		,t.IsInitialLoad
		,t.VpnBillingCategoryCode
FROM src.Vpn_Billing_History t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		TransactionID,
		Period,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.Vpn_Billing_History
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		TransactionID,
		Period) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.TransactionID = s.TransactionID
	AND t.Period = s.Period
WHERE t.DmlOperation <> 'D'

$$;


