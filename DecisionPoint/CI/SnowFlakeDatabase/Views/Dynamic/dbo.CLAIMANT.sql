CREATE OR REPLACE VIEW dbo.CLAIMANT
AS
SELECT 
		ODSPOSTINGGROUPAUDITID
		,ODSCUSTOMERID
		,ODSCREATEDATE
		,ODSSNAPSHOTDATE
		,ODSROWISCURRENT
		,ODSHASHBYTESVALUE
		,DMLOPERATION
		,CMTIDNO
		,CLAIMIDNO
		,CMTSSN
		,CMTLASTNAME
		,CMTFIRSTNAME
		,CMTMI
		,CMTDOB
		,CMTSEX
		,CMTADDR1
		,CMTADDR2
		,CMTCITY
		,CMTSTATE
		,CMTZIP
		,CMTPHONE
		,CMTOCCNO
		,CMTATTORNEYNO
		,CMTPOLICYLIMIT
		,CMTSTATEOFJURISDICTION
		,CMTDEDUCTIBLE
		,CMTCOPAYMENTPERCENTAGE
		,CMTCOPAYMENTMAX
		,CMTPPO_ELIGIBLE
		,CMTCOORDBENEFITS
		,CMTFLCOPAY
		,CMTCOAEXPORT
		,CMTPGFIRSTNAME
		,CMTPGLASTNAME
		,CMTDEDTYPE
		,EXPORTTOCLAIMIQ
		,CMTINACTIVE
		,CMTPRECERTOPTION
		,CMTPRECERTSTATE
		,CREATEDATE
		,LASTCHANGEDON
		,ODSPARTICIPANT
		,COVERAGETYPE
		,DONOTDISPLAYCOVERAGETYPEONEOB
		,SHOWALLOCATIONSONEOB
		,SETPREALLOCATION
		,PHARMACYELIGIBLE
		,SENDCARDTOCLAIMANT
		,SHARECOPAYMAXIMUM
FROM src.CLAIMANT
WHERE   ODSROWISCURRENT = 1
	AND DMLOPERATION <> 'D';


