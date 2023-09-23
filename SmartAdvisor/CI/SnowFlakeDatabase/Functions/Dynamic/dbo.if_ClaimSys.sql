CREATE OR REPLACE FUNCTION dbo.if_ClaimSys(
		IF_ODSPOSTINGGROUPAUDITID INT
)
RETURNS TABLE  (
		 ODSPOSTINGGROUPAUDITID NUMBER(10,0)
		,ODSCUSTOMERID NUMBER(10,0)
		,ODSCREATEDATE DATETIME
		,ODSSNAPSHOTDATE DATETIME
		,ODSROWISCURRENT INT
		,ODSHASHBYTESVALUE BINARY(8000)
		,DMLOPERATION VARCHAR(1)
		,CLAIMSYSSUBSET VARCHAR(4)
		,CLAIMIDMASK VARCHAR(35)
		,CLAIMACCESS VARCHAR(1)
		,CLAIMSYSDESC VARCHAR(30)
		,POLICYHOLDERREQ VARCHAR(1)
		,VALIDATEBRANCH VARCHAR(1)
		,VALIDATEPOLICY VARCHAR(1)
		,LGLCODE1TABLECODE VARCHAR(2)
		,LGLCODE2TABLECODE VARCHAR(2)
		,LGLCODE3TABLECODE VARCHAR(2)
		,UROCCTABLECODE VARCHAR(2)
		,POLICY5DAYSTABLECODE VARCHAR(2)
		,POLICY90DAYSTABLECODE VARCHAR(2)
		,JOB5DAYSTABLECODE VARCHAR(2)
		,JOB90DAYSTABLECODE VARCHAR(2)
		,HCOTRANSINDTABLECODE VARCHAR(2)
		,QUALIFIEDINJWORKTABLECODE VARCHAR(2)
		,PERMSTATIONARYTABLECODE VARCHAR(2)
		,VALIDATEADJUSTER VARCHAR(1)
		,MCOPROGRAM VARCHAR(1)
		,ADJUSTERREQUIRED VARCHAR(1)
		,HOSPITALADMITTABLECODE VARCHAR(2)
		,ATTORNEYTAXADDRREQUIRED VARCHAR(1)
		,BODYPARTTABLECODE VARCHAR(2)
		,POLICYDEFAULTS VARCHAR(1)
		,POLICYCOPAYAMOUNT NUMBER(19,4)
		,POLICYCOPAYPCT NUMBER(5,0)
		,POLICYDEDUCTIBLE NUMBER(19,4)
		,POLICYLIMIT NUMBER(19,4)
		,POLICYTIMELIMIT NUMBER(5,0)
		,POLICYLIMITWARNINGPCT NUMBER(5,0)
		,RESTRICTUSERACCESS VARCHAR(1)
		,BEOVERRIDEPERMISSIONFLAG VARCHAR(1)
		,ROOTCLAIMLENGTH NUMBER(5,0)
		,RELATECLAIMSTOTALPOLICYDETAIL VARCHAR(1)
		,POLICYLIMITRESULT VARCHAR(1)
		,ENABLECLAIMCLIENTCODEDEFAULT VARCHAR(1)
		,REEVALCOPYDOCCTRLID VARCHAR(1)
		,ENABLECEPHEADERFIELDEDITS VARCHAR(1)
		,ENABLESMARTCLIENTSELECTION VARCHAR(1)
		,SCSCLIENTSELECTIONCODE VARCHAR(12)
		,SCSPROVIDERSUBSET VARCHAR(4)
		,SCSCLIENTCODEMASK VARCHAR(4)
		,SCSDEFAULTCLIENT VARCHAR(4)
		,CLAIMEXTERNALIDASCARRIERCLAIMID VARCHAR(1)
		,POLICYEXTERNALIDASCARRIERPOLICYID VARCHAR(1)
		,URPROFILEID VARCHAR(8)
		,BEUROVERRIDESREQUIREREVIEWREF VARCHAR(1)
		,URENTRYVALIDATIONS VARCHAR(1)
		,PENDPPOEDICONTROL VARCHAR(1)
		,BEREEVALLINEADDDELETE VARCHAR(1)
		,CPTGROUPTOINDIVIDUAL VARCHAR(1)
		,CLAIMEXTERNALIDASCLAIMADMINCLAIMNUM VARCHAR(1)
		,CREATEUSERID VARCHAR(2)
		,CREATEDATE DATETIME
		,MODUSERID VARCHAR(2)
		,MODDATE DATETIME
		,FINANCIALAGGREGATION VARCHAR )
AS
$$
SELECT T.ODSPOSTINGGROUPAUDITID
		,T.ODSCUSTOMERID
		,T.ODSCREATEDATE
		,T.ODSSNAPSHOTDATE
		,T.ODSROWISCURRENT
		,T.ODSHASHBYTESVALUE
		,T.DMLOPERATION
		,T.CLAIMSYSSUBSET
		,T.CLAIMIDMASK
		,T.CLAIMACCESS
		,T.CLAIMSYSDESC
		,T.POLICYHOLDERREQ
		,T.VALIDATEBRANCH
		,T.VALIDATEPOLICY
		,T.LGLCODE1TABLECODE
		,T.LGLCODE2TABLECODE
		,T.LGLCODE3TABLECODE
		,T.UROCCTABLECODE
		,T.POLICY5DAYSTABLECODE
		,T.POLICY90DAYSTABLECODE
		,T.JOB5DAYSTABLECODE
		,T.JOB90DAYSTABLECODE
		,T.HCOTRANSINDTABLECODE
		,T.QUALIFIEDINJWORKTABLECODE
		,T.PERMSTATIONARYTABLECODE
		,T.VALIDATEADJUSTER
		,T.MCOPROGRAM
		,T.ADJUSTERREQUIRED
		,T.HOSPITALADMITTABLECODE
		,T.ATTORNEYTAXADDRREQUIRED
		,T.BODYPARTTABLECODE
		,T.POLICYDEFAULTS
		,T.POLICYCOPAYAMOUNT
		,T.POLICYCOPAYPCT
		,T.POLICYDEDUCTIBLE
		,T.POLICYLIMIT
		,T.POLICYTIMELIMIT
		,T.POLICYLIMITWARNINGPCT
		,T.RESTRICTUSERACCESS
		,T.BEOVERRIDEPERMISSIONFLAG
		,T.ROOTCLAIMLENGTH
		,T.RELATECLAIMSTOTALPOLICYDETAIL
		,T.POLICYLIMITRESULT
		,T.ENABLECLAIMCLIENTCODEDEFAULT
		,T.REEVALCOPYDOCCTRLID
		,T.ENABLECEPHEADERFIELDEDITS
		,T.ENABLESMARTCLIENTSELECTION
		,T.SCSCLIENTSELECTIONCODE
		,T.SCSPROVIDERSUBSET
		,T.SCSCLIENTCODEMASK
		,T.SCSDEFAULTCLIENT
		,T.CLAIMEXTERNALIDASCARRIERCLAIMID
		,T.POLICYEXTERNALIDASCARRIERPOLICYID
		,T.URPROFILEID
		,T.BEUROVERRIDESREQUIREREVIEWREF
		,T.URENTRYVALIDATIONS
		,T.PENDPPOEDICONTROL
		,T.BEREEVALLINEADDDELETE
		,T.CPTGROUPTOINDIVIDUAL
		,T.CLAIMEXTERNALIDASCLAIMADMINCLAIMNUM
		,T.CREATEUSERID
		,T.CREATEDATE
		,T.MODUSERID
		,T.MODDATE
		,T.FINANCIALAGGREGATION
FROM src.ClaimSys T
INNER JOIN (
	SELECT 
		ODSCUSTOMERID,
		CLAIMSYSSUBSET,
		MAX(ODSPOSTINGGROUPAUDITID) AS ODSPOSTINGGROUPAUDITID
	FROM src.ClaimSys
	WHERE ODSPOSTINGGROUPAUDITID <= IF_ODSPOSTINGGROUPAUDITID
	GROUP BY ODSCUSTOMERID,
		CLAIMSYSSUBSET) S
ON T.ODSPOSTINGGROUPAUDITID = S.ODSPOSTINGGROUPAUDITID
	AND T.ODSCUSTOMERID = S.ODSCUSTOMERID
	AND T.CLAIMSYSSUBSET = S.CLAIMSYSSUBSET
WHERE T.DMLOPERATION <> 'D'

$$;

