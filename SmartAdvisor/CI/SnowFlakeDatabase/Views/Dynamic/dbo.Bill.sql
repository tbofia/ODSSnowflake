CREATE OR REPLACE VIEW dbo.Bill
AS

SELECT 
		ODSPOSTINGGROUPAUDITID
		,ODSCUSTOMERID
		,ODSCREATEDATE
		,ODSSNAPSHOTDATE
		,ODSROWISCURRENT
		,ODSHASHBYTESVALUE
		,DMLOPERATION
		,CLIENTCODE
		,BILLSEQ
		,CLAIMSEQ
		,CLAIMSYSSUBSET
		,PROVIDERSEQ
		,PROVIDERSUBSET
		,POSTDATE
		,DOSFIRST
		,INVOICED
		,INVOICEDPPO
		,CREATEUSERID
		,CARRIERSEQNEW
		,DOCCTRLTYPE
		,DOSLAST
		,PPONETWORKID
		,POS
		,PROVTYPE
		,PROVSPECIALTY1
		,PROVZIP
		,PROVSTATE
		,SUBMITDATE
		,PROVINVOICE
		,REGION
		,HOSPITALSEQ
		,MODUSERID
		,STATUS
		,STATUSPRIOR
		,BILLABLELINES
		,TOTALCHARGE
		,BRREDUCTION
		,BRFEE
		,TOTALALLOW
		,TOTALFEE
		,DUPCLIENTCODE
		,DUPBILLSEQ
		,FUPSTARTDATE
		,FUPENDDATE
		,SENDBACKMSG1SITECODE
		,SENDBACKMSG1
		,SENDBACKMSG2SITECODE
		,SENDBACKMSG2
		,PPOREDUCTION
		,PPOPRC
		,PPOCONTRACTID
		,PPOSTATUS
		,PPOFEE
		,NGDREDUCTION
		,NGDFEE
		,URFEE
		,OTHERDATA
		,EXTERNALSTATUS
		,URFLAG
		,VISITS
		,TOS
		,TOB
		,SUBPRODUCTCODE
		,FORCEPAY
		,PMTAUTH
		,FLOWSTATUS
		,CONSULTDATE
		,RCVDDATE
		,ADMISSIONTYPE
		,PAIDDATE
		,ADMITDATE
		,DISCHARGEDATE
		,TXBILLTYPE
		,RCVDBRDATE
		,DUEDATE
		,ADJUSTER
		,DOI
		,RETCTRLFLG
		,RETCTRLNUM
		,SITECODE
		,SOURCEID
		,CASETYPE
		,SUBPRODUCTID
		,SUBPRODUCTPRICE
		,URREDUCTION
		,PROVLICENSENUM
		,PROVMEDICARENUM
		,PROVSPECIALTY2
		,PMTEXPORTDATE
		,PMTACCEPTDATE
		,CLIENTTOB
		,BRFEENET
		,PPOFEENET
		,NGDFEENET
		,URFEENET
		,SUBPRODUCTPRICENET
		,BILLSEQNEWREV
		,BILLSEQORGREV
		,VOCPLANSEQ
		,REVIEWDATE
		,AUDITDATE
		,REEVALALLOW
		,CHECKNUM
		,NEGOTYPE
		,DISCHARGEHOUR
		,UB92TOB
		,MCO
		,DRG
		,PATIENTACCOUNT
		,EXAMINERREVFLAG
		,REFPROVNAME
		,PAIDAMOUNT
		,ADMISSIONSOURCE
		,ADMITHOUR
		,PATIENTSTATUS
		,DRGVALUE
		,COMPANYSEQ
		,TOTALCOPAY
		,UB92PROCMETHOD
		,TOTALDEDUCTIBLE
		,POLICYCOPAYAMOUNT
		,POLICYCOPAYPCT
		,DOCCTRLID
		,RESOURCEUTILGROUP
		,POLICYDEDUCTIBLE
		,POLICYLIMIT
		,POLICYTIMELIMIT
		,POLICYWARNINGPCT
		,APPBENEFITS
		,APPASSIGNEE
		,CREATEDATE
		,MODDATE
		,INCREMENTVALUE
		,ADJVERIFREQUESTDATE
		,ADJVERIFRCVDDATE
		,RENDERINGPROVLASTNAME
		,RENDERINGPROVFIRSTNAME
		,RENDERINGPROVMIDDLENAME
		,RENDERINGPROVSUFFIX
		,REREVIEWCOUNT
		,DRGBILLED
		,DRGCALCULATED
		,PROVRXLICENSENUM
		,PROVSIGONFILE
		,REFPROVFIRSTNAME
		,REFPROVMIDDLENAME
		,REFPROVSUFFIX
		,REFPROVDEANUM
		,SENDBACKMSG1SUBSET
		,SENDBACKMSG2SUBSET
		,PPONETWORKJURISDICTIONIND
		,MANUALREDUCTIONMODE
		,WHOLESALESALESTAXZIP
		,RETAILSALESTAXZIP
		,PPONETWORKJURISDICTIONINSURERSEQ
		,INVOICEDWHOLESALE
		,INVOICEDPPOWHOLESALE
		,ADMITTINGDXREF
		,ADMITTINGDXCODE
		,PROVFACILITYNPI
		,PROVBILLINGNPI
		,PROVRENDERINGNPI
		,PROVOPERATINGNPI
		,PROVREFERRINGNPI
		,PROVOTHER1NPI
		,PROVOTHER2NPI
		,PROVOPERATINGLICENSENUM
		,EHUBID
		,OTHERBILLINGPROVIDERSUBSET
		,OTHERBILLINGPROVIDERSEQ
		,RESUBMISSIONREASONCODE
		,CONTRACTTYPE
		,CONTRACTAMOUNT
		,PRIORAUTHREFERRALNUM1
		,PRIORAUTHREFERRALNUM2
		,DRGCOMPOSITEFACTOR
		,DRGDISCHARGEFRACTION
		,DRGINPATIENTMULTIPLIER
		,DRGWEIGHT
		,EFTPMTMETHODCODE
		,EFTPMTFORMATCODE
		,EFTSENDERDFIID
		,EFTSENDERACCTNUM
		,EFTORIGCOSUPPLCODE
		,EFTRECEIVERDFIID
		,EFTRECEIVERACCTQUAL
		,EFTRECEIVERACCTNUM
		,POLICYLIMITRESULT
		,HISTORYBATCHNUMBER
		,PROVBILLINGTAXONOMY
		,PROVFACILITYTAXONOMY
		,PROVRENDERINGTAXONOMY
		,PPOSTACKLIST
		,ICDVERSION
		,ODGFLAG
		,PROVBILLLICENSENUM
		,PROVFACILITYLICENSENUM
		,PROVVENDOREXTERNALID
		,BRACTUALCLIENTCODE
		,BROVERRIDECLIENTCODE
		,BILLREEVALREASONCODE
		,PAYMENTCLEAREDDATE
		,ESTIMATEDBRCLIENTCODE
		,ESTIMATEDBRJURIS
		,OVERRIDEFEECONTROLRETAIL
		,OVERRIDEFEECONTROLWHOLESALE
		,STATEMENTFROMDATE
		,STATEMENTTHROUGHDATE
FROM src.Bill
WHERE   ODSROWISCURRENT = 1
	AND DMLOPERATION <> 'D';

