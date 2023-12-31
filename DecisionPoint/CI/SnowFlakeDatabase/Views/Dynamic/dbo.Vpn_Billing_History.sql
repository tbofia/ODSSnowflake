CREATE OR REPLACE VIEW dbo.Vpn_Billing_History
AS
SELECT 
		ODSPOSTINGGROUPAUDITID
		,ODSCUSTOMERID
		,ODSCREATEDATE
		,ODSSNAPSHOTDATE
		,ODSROWISCURRENT
		,ODSHASHBYTESVALUE
		,DMLOPERATION
		,CUSTOMER
		,TRANSACTIONID
		,PERIOD
		,ACTIVITYFLAG
		,BILLABLEFLAG
		,VOID
		,CREDITTYPE
		,NETWORK
		,BILLIDNO
		,LINE_NO
		,TRANSACTIONDATE
		,REPRICEDATE
		,CLAIMNO
		,PROVIDERCHARGES
		,DPALLOWED
		,VPNALLOWED
		,SAVINGS
		,CREDITS
		,NETSAVINGS
		,SOJ
		,SEQNO
		,COMPANYCODE
		,VPNID
		,PROCESSFLAG
		,SK
		,DATABASE_NAME
		,SUBMITTEDTOFINANCE
		,ISINITIALLOAD
		,VPNBILLINGCATEGORYCODE
FROM src.Vpn_Billing_History
WHERE   ODSROWISCURRENT = 1
	AND DMLOPERATION <> 'D';


