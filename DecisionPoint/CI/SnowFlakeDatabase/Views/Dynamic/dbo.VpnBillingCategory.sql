CREATE OR REPLACE VIEW dbo.VpnBillingCategory
AS
SELECT 
		ODSPOSTINGGROUPAUDITID
		,ODSCUSTOMERID
		,ODSCREATEDATE
		,ODSSNAPSHOTDATE
		,ODSROWISCURRENT
		,ODSHASHBYTESVALUE
		,DMLOPERATION
		,VPNBILLINGCATEGORYCODE
		,VPNBILLINGCATEGORYDESCRIPTION
FROM src.VpnBillingCategory
WHERE   ODSROWISCURRENT = 1
	AND DMLOPERATION <> 'D';

