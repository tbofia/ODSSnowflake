CREATE OR REPLACE VIEW dbo.ProviderAddress
AS

SELECT 
		ODSPOSTINGGROUPAUDITID
		,ODSCUSTOMERID
		,ODSCREATEDATE
		,ODSSNAPSHOTDATE
		,ODSROWISCURRENT
		,ODSHASHBYTESVALUE
		,DMLOPERATION
		,PROVIDERSUBSET
		,PROVIDERADDRESSSEQ
		,RECTYPE
		,ADDRESS1
		,ADDRESS2
		,CITY
		,STATE
		,ZIP
		,PHONENUM
		,FAXNUM
		,CONTACTFIRSTNAME
		,CONTACTLASTNAME
		,CONTACTMIDDLEINITIAL
		,URFIRSTNAME
		,URLASTNAME
		,URMIDDLEINITIAL
		,FACILITYNAME
		,COUNTRYCODE
		,MAILCODE
FROM src.ProviderAddress
WHERE   ODSROWISCURRENT = 1
	AND DMLOPERATION <> 'D';


