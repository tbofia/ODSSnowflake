CREATE OR REPLACE VIEW dbo.EndnoteSubCategory
AS
SELECT 
		ODSPOSTINGGROUPAUDITID
		,ODSCUSTOMERID
		,ODSCREATEDATE
		,ODSSNAPSHOTDATE
		,ODSROWISCURRENT
		,ODSHASHBYTESVALUE
		,DMLOPERATION
		,ENDNOTESUBCATEGORYID
		,DESCRIPTION
FROM src.EndnoteSubCategory
WHERE   ODSROWISCURRENT = 1
	AND DMLOPERATION <> 'D';


