CREATE OR REPLACE VIEW dbo.VpnLedger
AS
SELECT 
		ODSPOSTINGGROUPAUDITID
		,ODSCUSTOMERID
		,ODSCREATEDATE
		,ODSSNAPSHOTDATE
		,ODSROWISCURRENT
		,ODSHASHBYTESVALUE
		,DMLOPERATION
		,TRANSACTIONID
		,TRANSACTIONTYPEID
		,BILLIDNO
		,LINE_NO
		,CHARGED
		,DPALLOWED
		,VPNALLOWED
		,SAVINGS
		,CREDITS
		,HASOVERRIDE
		,ENDNOTES
		,NETWORKIDNO
		,PROCESSFLAG
		,LINETYPE
		,DATETIMESTAMP
		,SEQNO
		,VPN_REF_LINE_NO
		,SPECIALPROCESSING
		,CREATEDATE
		,LASTCHANGEDON
		,ADJUSTEDCHARGED
FROM src.VpnLedger
WHERE   ODSROWISCURRENT = 1
	AND DMLOPERATION <> 'D';

