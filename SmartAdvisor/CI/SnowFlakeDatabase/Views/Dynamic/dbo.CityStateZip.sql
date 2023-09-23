CREATE OR REPLACE VIEW dbo.CityStateZip
AS

SELECT 
		ODSPOSTINGGROUPAUDITID
		,ODSCUSTOMERID
		,ODSCREATEDATE
		,ODSSNAPSHOTDATE
		,ODSROWISCURRENT
		,ODSHASHBYTESVALUE
		,DMLOPERATION
		,ZIPCODE
		,CTYSTKEY
		,CPYDTLCODE
		,ZIPCLSCODE
		,CTYSTNAME
		,CTYSTNAMEABV
		,CTYSTFACCODE
		,CTYSTMAILIND
		,PRELSTCTYKEY
		,PRELSTCTYNME
		,CTYDLVIND
		,AUTZONEIND
		,UNQZIPIND
		,FINANCENUM
		,STATEABBRV
		,COUNTYNUM
		,COUNTYNAME
FROM src.CityStateZip
WHERE   ODSROWISCURRENT = 1
	AND DMLOPERATION <> 'D';

