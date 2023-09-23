CREATE OR REPLACE VIEW dbo.PPOContract
AS

SELECT 
		ODSPOSTINGGROUPAUDITID
		,ODSCUSTOMERID
		,ODSCREATEDATE
		,ODSSNAPSHOTDATE
		,ODSROWISCURRENT
		,ODSHASHBYTESVALUE
		,DMLOPERATION
		,PPONETWORKID
		,PPOCONTRACTID
		,SITECODE
		,TIN
		,ALTERNATETIN
		,STARTDATE
		,ENDDATE
		,OPLINEITEMDEFAULTDISCOUNT
		,COMPANYNAME
		,FIRST
		,GROUPCODE
		,GROUPNAME
		,OPDISCOUNTBASEVALUE
		,OPOFFFS
		,OPOFFUCR
		,OPOFFCHARGE
		,OPEFFECTIVEDATE
		,OPADDITIONALDISCOUNTOFFLINK
		,OPTERMINATIONDATE
		,OPUCRPERCENTILE
		,OPCONDITION
		,IPDISCOUNTBASEVALUE
		,IPOFFFS
		,IPOFFUCR
		,IPOFFCHARGE
		,IPEFFECTIVEDATE
		,IPTERMINATIONDATE
		,IPCONDITION
		,IPSTOPCAPAMOUNT
		,IPSTOPCAPRATE
		,MINDISC
		,MAXDISC
		,MEDICALPERDIEM
		,SURGICALPERDIEM
		,ICUPERDIEM
		,PSYCHIATRICPERDIEM
		,MISCPARM
		,SPCCODE
		,PPOTYPE
		,BILLINGADDRESS1
		,BILLINGADDRESS2
		,BILLINGCITY
		,BILLINGSTATE
		,BILLINGZIP
		,PRACTICEADDRESS1
		,PRACTICEADDRESS2
		,PRACTICECITY
		,PRACTICESTATE
		,PRACTICEZIP
		,PHONENUM
		,OUTFILE
		,INPATFILE
		,URCOORDINATORFLAG
		,EXCLUSIVEPPOORGFLAG
		,STOPLOSSTYPECODE
		,BR_RNEDISCOUNT
		,MODDATE
		,EXPORTFLAG
		,OPMANUALINDICATOR
		,OPSTOPCAPAMOUNT
		,OPSTOPCAPRATE
		,SPECIALTY1
		,SPECIALTY2
		,LESSOROFTHRESHOLD
		,BILATERALDISCOUNT
		,SURGERYDISCOUNT2
		,SURGERYDISCOUNT3
		,SURGERYDISCOUNT4
		,SURGERYDISCOUNT5
		,MATRIX
		,PROVTYPE
		,ALLINCLUSIVE
		,REGION
		,PAYMENTADDRESSFLAG
		,MEDICALGROUP
		,MEDICALGROUPCODE
		,RATEMODE
		,PRACTICECOUNTY
		,FIPSCOUNTYCODE
		,PRIMARYCAREFLAG
		,PPOCONTRACTIDOLD
		,MULTISURG
		,BILEVEL
		,DRGRATE
		,DRGGREATERTHANBC
		,DRGMINPERCENTBC
		,CARVEOUT
		,PPOTOFSSEQ
		,LICENSENUM
		,MEDICARENUM
		,NPI
FROM src.PPOContract
WHERE   ODSROWISCURRENT = 1
	AND DMLOPERATION <> 'D';

