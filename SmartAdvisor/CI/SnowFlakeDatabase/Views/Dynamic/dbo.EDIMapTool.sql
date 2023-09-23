CREATE OR REPLACE VIEW dbo.EDIMapTool
AS

SELECT 
		ODSPOSTINGGROUPAUDITID
		,ODSCUSTOMERID
		,ODSCREATEDATE
		,ODSSNAPSHOTDATE
		,ODSROWISCURRENT
		,ODSHASHBYTESVALUE
		,DMLOPERATION
		,SITECODE
		,EDIPORTTYPE
		,EDIMAPTOOLID
		,EDISOURCEID
		,EDIMAPTOOLNAME
		,EDIMAPTOOLTYPE
		,EDIMAPTOOLDESC
		,EDIOBJECTID
		,MENUTITLE
		,SECURITYLEVEL
		,EDIINPUTFILENAME
		,EDIOUTPUTFILENAME
		,EDIMULTIFILES
		,EDIREPORTTYPE
		,FORMPROPERTIES
		,JURISDICTION
		,EDITYPE
		,EDIPARTNERID
		,BILLCONTROLTABLECODE
		,EDICONTROLFLAG
		,BILLCONTROLSEQ
		,EDIOBJECTSITECODE
		,PERMITUNDEFINEDRECIDS
		,SELECTIONQUERY
		,REPORTSELECTIONQUERY
		,CLASS
		,LINESELECTIONQUERY
		,PORTPROPERTIES
		,EDIFILECONFIGSITECODE
		,EDIFILECONFIGSEQ
		,LZCONTROLTABLECODE
		,LZCONTROLSEQ
FROM src.EDIMapTool
WHERE   ODSROWISCURRENT = 1
	AND DMLOPERATION <> 'D';


