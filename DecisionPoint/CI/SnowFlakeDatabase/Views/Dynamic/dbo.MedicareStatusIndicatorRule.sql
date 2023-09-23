CREATE OR REPLACE VIEW dbo.MedicareStatusIndicatorRule
AS
SELECT 
		ODSPOSTINGGROUPAUDITID
		,ODSCUSTOMERID
		,ODSCREATEDATE
		,ODSSNAPSHOTDATE
		,ODSROWISCURRENT
		,ODSHASHBYTESVALUE
		,DMLOPERATION
		,MEDICARESTATUSINDICATORRULEID
		,MEDICARESTATUSINDICATORRULENAME
		,STATUSINDICATOR
		,STARTDATE
		,ENDDATE
		,ENDNOTE
		,EDITACTIONID
		,COMMENTS
FROM src.MedicareStatusIndicatorRule
WHERE   ODSROWISCURRENT = 1
	AND DMLOPERATION <> 'D';


