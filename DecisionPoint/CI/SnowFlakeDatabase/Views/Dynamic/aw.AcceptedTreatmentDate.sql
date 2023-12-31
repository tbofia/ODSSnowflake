CREATE OR REPLACE VIEW aw.AcceptedTreatmentDate
AS
SELECT 
		ODSPOSTINGGROUPAUDITID
		,ODSCUSTOMERID
		,ODSCREATEDATE
		,ODSSNAPSHOTDATE
		,ODSROWISCURRENT
		,ODSHASHBYTESVALUE
		,DMLOPERATION
		,ACCEPTEDTREATMENTDATEID
		,DEMANDCLAIMANTID
		,TREATMENTDATE
		,COMMENTS
		,TREATMENTCATEGORYID
		,LASTUPDATEDBY
		,LASTUPDATEDDATE
FROM src.AcceptedTreatmentDate
WHERE   ODSROWISCURRENT = 1
	AND DMLOPERATION <> 'D';


