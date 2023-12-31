CREATE OR REPLACE VIEW dbo.Modifier
AS

SELECT 
		ODSPOSTINGGROUPAUDITID
		,ODSCUSTOMERID
		,ODSCREATEDATE
		,ODSSNAPSHOTDATE
		,ODSROWISCURRENT
		,ODSHASHBYTESVALUE
		,DMLOPERATION
		,JURISDICTION
		,CODE
		,SITECODE
		,FUNC
		,VAL
		,MODTYPE
		,GROUPCODE
		,MODDESCRIPTION
		,MODCOMMENT1
		,MODCOMMENT2
		,CREATEDATE
		,CREATEUSERID
		,MODDATE
		,MODUSERID
		,STATUTE
		,REMARK1
		,REMARKQUALIFIER1
		,REMARK2
		,REMARKQUALIFIER2
		,REMARK3
		,REMARKQUALIFIER3
		,REMARK4
		,REMARKQUALIFIER4
		,CBREREASONID
FROM src.Modifier
WHERE   ODSROWISCURRENT = 1
	AND DMLOPERATION <> 'D';


