CREATE OR REPLACE VIEW dbo.PPOSubNetwork
AS

SELECT 
		ODSPOSTINGGROUPAUDITID
		,ODSCUSTOMERID
		,ODSCREATEDATE
		,ODSSNAPSHOTDATE
		,ODSROWISCURRENT
		,ODSHASHBYTESVALUE
		,DMLOPERATION
		,PPONETWORKID
		,GROUPCODE
		,GROUPNAME
		,EXTERNALID
		,SITECODE
		,CREATEDATE
		,CREATEUSERID
		,MODDATE
		,MODUSERID
		,STREET1
		,STREET2
		,CITY
		,STATE
		,ZIP
		,PHONENUM
		,EMAILADDRESS
		,WEBSITE
		,TIN
		,COMMENT
FROM src.PPOSubNetwork
WHERE   ODSROWISCURRENT = 1
	AND DMLOPERATION <> 'D';

