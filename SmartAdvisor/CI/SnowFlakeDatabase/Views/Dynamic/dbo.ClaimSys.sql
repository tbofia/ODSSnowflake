CREATE OR REPLACE VIEW dbo.ClaimSys
AS

SELECT 
		ODSPOSTINGGROUPAUDITID
		,ODSCUSTOMERID
		,ODSCREATEDATE
		,ODSSNAPSHOTDATE
		,ODSROWISCURRENT
		,ODSHASHBYTESVALUE
		,DMLOPERATION
		,CLAIMSYSSUBSET
		,CLAIMIDMASK
		,CLAIMACCESS
		,CLAIMSYSDESC
		,POLICYHOLDERREQ
		,VALIDATEBRANCH
		,VALIDATEPOLICY
		,LGLCODE1TABLECODE
		,LGLCODE2TABLECODE
		,LGLCODE3TABLECODE
		,UROCCTABLECODE
		,POLICY5DAYSTABLECODE
		,POLICY90DAYSTABLECODE
		,JOB5DAYSTABLECODE
		,JOB90DAYSTABLECODE
		,HCOTRANSINDTABLECODE
		,QUALIFIEDINJWORKTABLECODE
		,PERMSTATIONARYTABLECODE
		,VALIDATEADJUSTER
		,MCOPROGRAM
		,ADJUSTERREQUIRED
		,HOSPITALADMITTABLECODE
		,ATTORNEYTAXADDRREQUIRED
		,BODYPARTTABLECODE
		,POLICYDEFAULTS
		,POLICYCOPAYAMOUNT
		,POLICYCOPAYPCT
		,POLICYDEDUCTIBLE
		,POLICYLIMIT
		,POLICYTIMELIMIT
		,POLICYLIMITWARNINGPCT
		,RESTRICTUSERACCESS
		,BEOVERRIDEPERMISSIONFLAG
		,ROOTCLAIMLENGTH
		,RELATECLAIMSTOTALPOLICYDETAIL
		,POLICYLIMITRESULT
		,ENABLECLAIMCLIENTCODEDEFAULT
		,REEVALCOPYDOCCTRLID
		,ENABLECEPHEADERFIELDEDITS
		,ENABLESMARTCLIENTSELECTION
		,SCSCLIENTSELECTIONCODE
		,SCSPROVIDERSUBSET
		,SCSCLIENTCODEMASK
		,SCSDEFAULTCLIENT
		,CLAIMEXTERNALIDASCARRIERCLAIMID
		,POLICYEXTERNALIDASCARRIERPOLICYID
		,URPROFILEID
		,BEUROVERRIDESREQUIREREVIEWREF
		,URENTRYVALIDATIONS
		,PENDPPOEDICONTROL
		,BEREEVALLINEADDDELETE
		,CPTGROUPTOINDIVIDUAL
		,CLAIMEXTERNALIDASCLAIMADMINCLAIMNUM
		,CREATEUSERID
		,CREATEDATE
		,MODUSERID
		,MODDATE
		,FINANCIALAGGREGATION
FROM src.ClaimSys
WHERE   ODSROWISCURRENT = 1
	AND DMLOPERATION <> 'D';


