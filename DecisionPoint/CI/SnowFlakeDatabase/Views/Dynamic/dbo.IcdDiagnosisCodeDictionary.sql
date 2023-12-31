CREATE OR REPLACE VIEW dbo.IcdDiagnosisCodeDictionary
AS
SELECT 
		ODSPOSTINGGROUPAUDITID
		,ODSCUSTOMERID
		,ODSCREATEDATE
		,ODSSNAPSHOTDATE
		,ODSROWISCURRENT
		,ODSHASHBYTESVALUE
		,DMLOPERATION
		,DIAGNOSISCODE
		,ICDVERSION
		,STARTDATE
		,ENDDATE
		,NONSPECIFIC
		,TRAUMATIC
		,DURATION
		,DESCRIPTION
		,DIAGNOSISFAMILYID
		,DIAGNOSISSEVERITYID
		,LATERALITYID
		,TOTALCHARACTERSREQUIRED
		,PLACEHOLDERREQUIRED
		,FLAGS
		,ADDITIONALDIGITS
		,COLOSSUS
		,INJURYNATUREID
		,ENCOUNTERSUBCATEGORYID
FROM src.IcdDiagnosisCodeDictionary
WHERE   ODSROWISCURRENT = 1
	AND DMLOPERATION <> 'D';


