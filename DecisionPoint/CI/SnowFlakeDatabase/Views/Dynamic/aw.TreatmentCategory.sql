CREATE OR REPLACE VIEW aw.TreatmentCategory
AS
SELECT 
		ODSPOSTINGGROUPAUDITID
		,ODSCUSTOMERID
		,ODSCREATEDATE
		,ODSSNAPSHOTDATE
		,ODSROWISCURRENT
		,ODSHASHBYTESVALUE
		,DMLOPERATION
		,TREATMENTCATEGORYID
		,CATEGORY
		,METADATA
FROM src.TreatmentCategory
WHERE   ODSROWISCURRENT = 1
	AND DMLOPERATION <> 'D';


