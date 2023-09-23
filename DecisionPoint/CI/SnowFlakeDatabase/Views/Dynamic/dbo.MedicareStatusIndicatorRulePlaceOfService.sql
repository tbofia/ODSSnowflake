CREATE OR REPLACE VIEW dbo.MedicareStatusIndicatorRulePlaceOfService
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
		,PLACEOFSERVICE
FROM src.MedicareStatusIndicatorRulePlaceOfService
WHERE   ODSROWISCURRENT = 1
	AND DMLOPERATION <> 'D';


