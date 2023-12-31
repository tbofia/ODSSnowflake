CREATE OR REPLACE VIEW aw.TreatmentCategoryRange
AS
SELECT 
		ODSPOSTINGGROUPAUDITID
		,ODSCUSTOMERID
		,ODSCREATEDATE
		,ODSSNAPSHOTDATE
		,ODSROWISCURRENT
		,ODSHASHBYTESVALUE
		,DMLOPERATION
		,TREATMENTCATEGORYRANGEID
		,TREATMENTCATEGORYID
		,STARTRANGE
		,ENDRANGE
FROM src.TreatmentCategoryRange
WHERE   ODSROWISCURRENT = 1
	AND DMLOPERATION <> 'D';


