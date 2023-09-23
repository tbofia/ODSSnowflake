CREATE OR REPLACE TABLE stg.Client (
	  ODSPOSTINGGROUPAUDITID NUMBER(10, 0) NOT NULL
	 , ODSCUSTOMERID NUMBER(10, 0) NOT NULL
	 , ODSCREATEDATE DATETIME NOT NULL
	 , ODSSNAPSHOTDATE DATETIME NOT NULL
	 , ODSROWISCURRENT INT NOT NULL
	 , ODSHASHBYTESVALUE BINARY(8000) NULL
	 , DMLOPERATION VARCHAR(1) NOT NULL
	 , CLIENTCODE VARCHAR(4) NOT NULL
	 , NAME VARCHAR(30) NULL
	 , JURISDICTION VARCHAR(2) NULL
	 , CONTROLNUM VARCHAR(20) NULL
	 , POLICYTIMELIMIT NUMBER(5, 0) NULL
	 , POLICYLIMITWARNINGPCT NUMBER(5, 0) NULL
	 , POLICYLIMIT NUMBER(19, 4) NULL
	 , POLICYDEDUCTIBLE NUMBER(19, 4) NULL
	 , POLICYCOPAYPCT NUMBER(5, 0) NULL
	 , POLICYCOPAYAMOUNT NUMBER(19, 4) NULL
	 , BEDIAGNOSIS VARCHAR(1) NULL
	 , INVOICEBRCYCLE VARCHAR(1) NULL
	 , STATUS VARCHAR(1) NULL
	 , INVOICEGROUPBY VARCHAR(1) NULL
	 , BEDOI VARCHAR(1) NULL
	 , DRUGMARKUPBRAND NUMBER(5, 0) NULL
	 , SUPPLYLIMIT NUMBER(5, 0) NULL
	 , INVOICEPPOCYCLE VARCHAR(1) NULL
	 , INVOICEPPOTAX NUMBER(5, 0) NULL
	 , DRUGMARKUPGEN NUMBER(5, 0) NULL
	 , DRUGDISPGEN NUMBER(5, 0) NULL
	 , DRUGDISPBRAND NUMBER(5, 0) NULL
	 , BEADJUSTER VARCHAR(1) NULL
	 , INVOICETAX NUMBER(5, 0) NULL
	 , COMPANYSEQ NUMBER(5, 0) NULL
	 , BEMEDALERT VARCHAR(1) NULL
	 , UCRPERCENTILE NUMBER(5, 0) NULL
	 , CLIENTCOMMENT VARCHAR(6000) NULL
	 , REMITATTENTION VARCHAR(30) NULL
	 , REMITADDRESS1 VARCHAR(30) NULL
	 , REMITADDRESS2 VARCHAR(30) NULL
	 , REMITCITYSTATEZIP VARCHAR(30) NULL
	 , REMITPHONE VARCHAR(12) NULL
	 , EXTERNALID VARCHAR(10) NULL
	 , BEOTHER VARCHAR(1) NULL
	 , MEDALERTDAYS NUMBER(5, 0) NULL
	 , MEDALERTVISITS NUMBER(5, 0) NULL
	 , MEDALERTMAXCHARGE NUMBER(19, 4) NULL
	 , MEDALERTWARNVISITS NUMBER(5, 0) NULL
	 , PROVIDERSUBSET VARCHAR(4) NULL
	 , ALLOWREREVIEW VARCHAR(1) NULL
	 , ACCTREP VARCHAR(2) NULL
	 , CLIENTTYPE VARCHAR(1) NULL
	 , UCRMARKUP NUMBER(5, 0) NULL
	 , INVOICECOMBINED VARCHAR(1) NULL
	 , BESUBMITDT VARCHAR(1) NULL
	 , BERCVDCARRIERDATE VARCHAR(1) NULL
	 , BERCVDBILLREVIEWDATE VARCHAR(1) NULL
	 , BEDUEDATE VARCHAR(1) NULL
	 , PRODUCTCODE VARCHAR(1) NULL
	 , BEPROVINVOICE VARCHAR(1) NULL
	 , CLAIMSYSSUBSET VARCHAR(4) NULL
	 , DEFAULTBRTOUCR VARCHAR(1) NULL
	 , BASEPPOFEESOFFFS VARCHAR(1) NULL
	 , BECLIENTTOBTABLECODE VARCHAR(2) NULL
	 , BEFORCEPAY VARCHAR(1) NULL
	 , BEPAYAUTHORIZATION VARCHAR(1) NULL
	 , BECARRIERSEQFLAG VARCHAR(1) NULL
	 , BEPROVTYPETABLECODE VARCHAR(2) NULL
	 , BEPROVSPCL1TABLECODE VARCHAR(2) NULL
	 , BEPROVLICENSE VARCHAR(1) NULL
	 , BEPAYAUTHTABLECODE VARCHAR(2) NULL
	 , PENDREASONTABLECODE VARCHAR(2) NULL
	 , VOCREHAB VARCHAR(1) NULL
	 , EDIACKREQUIRED VARCHAR(1) NULL
	 , STATERPTIND VARCHAR(1) NULL
	 , BEPATIENTACCTNUM VARCHAR(1) NULL
	 , AUTODUP VARCHAR(1) NULL
	 , USEALLOWONDUP VARCHAR(1) NULL
	 , URIMPORTUSED VARCHAR(1) NULL
	 , URPROGSTARTDATE VARCHAR(1) NULL
	 , URIMPORTCTRLNUM VARCHAR(4) NULL
	 , URIMPORTCTRLGROUP VARCHAR(4) NULL
	 , UCRSOURCE VARCHAR(1) NULL
	 , UCRMARKUP2 NUMBER(5, 0) NULL
	 , NGDTABLECODE VARCHAR(2) NULL
	 , BESUBPRODUCTTABLECODE VARCHAR(2) NULL
	 , COUNTRYTABLECODE VARCHAR(2) NULL
	 , BEREFPHYS VARCHAR(1) NULL
	 , BEPMTWARNDAYS NUMBER(5, 0) NULL
	 , GEOSTATE VARCHAR(2) NULL
	 , BEDISABLEDOICHECK VARCHAR(1) NULL
	 , DELAYDAYS NUMBER(5, 0) NULL
	 , BEVALIDATETOTAL VARCHAR(1) NULL
	 , BEFASTMATCH VARCHAR(1) NULL
	 , BEPRIORBILLDEFAULT VARCHAR(1) NULL
	 , BECLIENTDUEDAYS NUMBER(5, 0) NULL
	 , BEAUTOCALCDUEDATE VARCHAR(1) NULL
	 , UCRSOURCE2 VARCHAR(1) NULL
	 , UCRPERCENTILE2 NUMBER(5, 0) NULL
	 , BEPROVSPCL2TABLECODE VARCHAR(2) NULL
	 , FEERATECNTRLEX VARCHAR(4) NULL
	 , FEERATECNTRLIN VARCHAR(4) NULL
	 , BECOLLISIONPROVBILLS VARCHAR(1) NULL
	 , BECOLLISIONBILLS VARCHAR(1) NULL
	 , SUPPLYMARKUP NUMBER(5, 0) NULL
	 , BECOLLISIONPROVIDERS VARCHAR(1) NULL
	 , DEFAULTCOPAYDEDUCT VARCHAR(1) NULL
	 , AUTOBUNDLING VARCHAR(1) NULL
	 , BEVALIDATEBILLCLAIMICD9 VARCHAR(1) NULL
	 , ENABLEGENERICREPRICE VARCHAR(1) NULL
	 , BESUBPRODFEEINFO VARCHAR(1) NULL
	 , DENYNONINJDRUGS VARCHAR(1) NULL
	 , BECOLLISIONDOSLINES VARCHAR(1) NULL
	 , PPOPROFILESITECODE VARCHAR(3) NULL
	 , PPOPROFILEID NUMBER(10, 0) NULL
	 , BESHOWDEAWARNING VARCHAR(1) NULL
	 , BEHIDEADJUSTERCOLUMN VARCHAR(1) NULL
	 , BEHIDECOPAYCOLUMN VARCHAR(1) NULL
	 , BEHIDEDEDUCTCOLUMN VARCHAR(1) NULL
	 , BEPAIDDATE VARCHAR(1) NULL
	 , BEPROCCROSSWALK VARCHAR(1) NULL
	 , CREATEUSERID VARCHAR(2) NULL
	 , CREATEDATE DATETIME NULL
	 , MODUSERID VARCHAR(2) NULL
	 , MODDATE DATETIME NULL
	 , BECONSULTDATE VARCHAR(1) NULL
	 , BESHOWPHARMACYCOLUMNS VARCHAR(1) NULL
	 , BEADJVERIFDATES VARCHAR(1) NULL
	 , FUTUREDOSMONTHLIMIT NUMBER(5, 0) NULL
	 , BESTOPATLINEUNITS VARCHAR(1) NULL
	 , BENYNF10FIELDS VARCHAR(1) NULL
	 , ENABLEDRGGROUPER VARCHAR(1) NULL
	 , APPLYCPTAMAUCRRULES VARCHAR(1) NULL
	 , BEPROVSIGONFILE VARCHAR(1) NULL
	 , BETIMEENTRY VARCHAR(1) NULL
	 , SALESTAXEXEMPT VARCHAR(1) NULL
	 , INVOICERETAILPROFILE VARCHAR(4) NULL
	 , INVOICEWHOLESALEPROFILE VARCHAR(4) NULL
	 , BEDEFAULTTAXZIP VARCHAR(1) NULL
	 , RECEIPTHANDLINGCODE VARCHAR(1) NULL
	 , PAYMENTHANDLINGCODE VARCHAR(1) NULL
	 , DEFAULTRETAILSALESTAXZIP VARCHAR(9) NULL
	 , DEFAULTWHOLESALESALESTAXZIP VARCHAR(9) NULL
	 , TXNONSUBSCRIB VARCHAR(1) NULL
	 , ROOTCLAIMLENGTH NUMBER(5, 0) NULL
	 , BEDAWTABLECODE VARCHAR(4) NULL
	 , EORPROFILESEQ NUMBER(10, 0) NULL
	 , BEOTHERBILLINGPROVIDER VARCHAR(1) NULL
	 , BEDOCCTRLID VARCHAR(1) NULL
	 , REPORTINGETL VARCHAR(1) NULL
	 , CLAIMVERIFICATION VARCHAR(1) NULL
	 , PROVVERIFICATION VARCHAR(1) NULL
	 , BEPERMITALLOWOVER VARCHAR(1) NULL
	 , BESTOPATLINEDXREF VARCHAR(1) NULL
	 , BEQUICKINFOCODE VARCHAR(12) NULL
	 , EXCLUDEDSMARTCLIENTSELECT VARCHAR(1) NULL
	 , COLLISIONSSEARCHBY VARCHAR(1) NULL
	 , AUTODUPINCLUDEPROV VARCHAR(1) NULL
	 , URPROFILEID VARCHAR(8) NULL
	 , EXCLUDEURDM VARCHAR(1) NULL
	 , BECOLLISIONURCASES VARCHAR(1) NULL
	 , MUEEDITS VARCHAR(1) NULL
	 , CPTRARITY NUMBER(5, 2) NULL
	 , ICDRARITY NUMBER(5, 2) NULL
	 , ICDTOCPTRARITY NUMBER(5, 2) NULL
	 , BEDISABLEPPOSEARCH VARCHAR(1) NULL
	 , BESHOWLINEEXTERNALIDCOLUMN VARCHAR(1) NULL
	 , BESHOWLINEPRIORAUTHCOLUMN VARCHAR(1) NULL
	 , SMARTGUIDELINESFLAG VARCHAR(1) NULL
	 , BEPROVBILLINGLICENSE VARCHAR(1) NULL
	 , BEPROVFACILITYLICENSE VARCHAR(1) NULL
	 , VENDORPROVIDERSUBSET VARCHAR(4) NULL
	 , DEFAULTJURISCLIENTCODE VARCHAR(1) NULL
	 , CLIENTGROUPID NUMBER(10, 0) NULL
	 , DRUGDISPFEEAPPLYTO VARCHAR(1) NULL
);

