CREATE OR REPLACE VIEW dbo.PPOProfileHistory
AS

SELECT 
		ODSPOSTINGGROUPAUDITID
		,ODSCUSTOMERID
		,ODSCREATEDATE
		,ODSSNAPSHOTDATE
		,ODSROWISCURRENT
		,ODSHASHBYTESVALUE
		,DMLOPERATION
		,PPOPROFILEHISTORYSEQ
		,RECORDDELETED
		,LOGDATETIME
		,LOGINAME
		,SITECODE
		,PPOPROFILEID
		,PROFILEDESC
		,CREATEDATE
		,CREATEUSERID
		,MODDATE
		,MODUSERID
		,SMARTSEARCHPAGEMAX
		,JURISDICTIONSTACKEXCLUSIVE
		,REEVALFULLSTACKWHENORIGALLOWNOHIT
FROM src.PPOProfileHistory
WHERE   ODSROWISCURRENT = 1
	AND DMLOPERATION <> 'D';

