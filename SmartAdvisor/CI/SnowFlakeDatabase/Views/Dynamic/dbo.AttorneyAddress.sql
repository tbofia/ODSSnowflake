CREATE OR REPLACE VIEW dbo.AttorneyAddress
AS

SELECT 
		ODSPOSTINGGROUPAUDITID
		,ODSCUSTOMERID
		,ODSCREATEDATE
		,ODSSNAPSHOTDATE
		,ODSROWISCURRENT
		,ODSHASHBYTESVALUE
		,DMLOPERATION
		,CLAIMSYSSUBSET
		,ATTORNEYADDRESSSEQ
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
FROM src.AttorneyAddress
WHERE   ODSROWISCURRENT = 1
	AND DMLOPERATION <> 'D';


