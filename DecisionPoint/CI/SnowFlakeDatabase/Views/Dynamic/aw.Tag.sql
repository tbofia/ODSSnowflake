CREATE OR REPLACE VIEW aw.Tag
AS
SELECT 
		ODSPOSTINGGROUPAUDITID
		,ODSCUSTOMERID
		,ODSCREATEDATE
		,ODSSNAPSHOTDATE
		,ODSROWISCURRENT
		,ODSHASHBYTESVALUE
		,DMLOPERATION
		,TAGID
		,NAME
		,DATECREATED
		,DATEMODIFIED
		,CREATEDBY
		,MODIFIEDBY
FROM src.Tag
WHERE   ODSROWISCURRENT = 1
	AND DMLOPERATION <> 'D';


