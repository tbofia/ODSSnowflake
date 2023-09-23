CREATE OR REPLACE FUNCTION dbo.if_UserInfo(
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
		,USERID VARCHAR(2)
		,USERPASSWORD VARCHAR(35)
		,NAME VARCHAR(30)
		,SECURITYLEVEL VARCHAR(1)
		,ENABLEADJUSTERMENU VARCHAR(1)
		,ENABLEPROVADDS VARCHAR(1)
		,ALLOWPOSTING VARCHAR(1)
		,ENABLECLAIMADDS VARCHAR(1)
		,ENABLEPOLICYADDS VARCHAR(1)
		,ENABLEINVOICECREDITVOID VARCHAR(1)
		,ENABLEREEVALUATIONS VARCHAR(1)
		,ENABLEPPOACCESS VARCHAR(1)
		,ENABLEURCOMMENTVIEW VARCHAR(1)
		,ENABLEPENDRELEASE VARCHAR(1)
		,ENABLEXTABLEUPDATE VARCHAR(1)
		,CREATEUSERID VARCHAR(2)
		,CREATEDATE DATETIME
		,MODUSERID VARCHAR(2)
		,MODDATE DATETIME
		,ENABLEPPOFASTMATCHADDS VARCHAR(1)
		,EXTERNALID VARCHAR(30)
		,EMAILADDRESS VARCHAR(255)
		,EMAILNOTIFY VARCHAR(1)
		,ACTIVESTATUS VARCHAR(1)
		,COMPANYSEQ NUMBER(5,0)
		,NETWORKLOGIN VARCHAR(50)
		,AUTOMATICNETWORKLOGIN VARCHAR(1)
		,LASTLOGGEDINDATE DATETIME
		,PROMPTTOCREATEMCC VARCHAR(1)
		,ACCESSALLWORKQUEUES VARCHAR(1)
		,LANDINGZONEACCESS VARCHAR(1)
		,REVIEWLEVEL NUMBER(3,0)
		,ENABLEUSERMAINTENANCE VARCHAR(1)
		,ENABLEHISTORYMAINTENANCE VARCHAR(1)
		,ENABLECLIENTMAINTENANCE VARCHAR(1)
		,FEEACCESS VARCHAR(1)
		,ENABLESALESTAXMAINTENANCE VARCHAR(1)
		,BESALESTAXZIPCODEACCESS VARCHAR(1)
		,INVOICEGENACCESS VARCHAR(1)
		,BEPERMITALLOWOVER VARCHAR(1)
		,PERMITREREVIEWS VARCHAR(1)
		,EDITBILLCONTROL VARCHAR(1)
		,RESTRICTEORNOTES VARCHAR(1)
		,UWQAUTONEXTBILL VARCHAR(1)
		,UWQDISABLEOPTIONS VARCHAR(1)
		,UWQDISABLERULES VARCHAR(1)
		,PERMITCHECKREISSUE VARCHAR(1)
		,ENABLEEDIAUTOMATIONMAINTENANCE VARCHAR(1)
		,RESTRICTDIARYNOTES VARCHAR(1)
		,RESTRICTEXTERNALDIARYNOTES VARCHAR(1)
		,BEDEFERMANUALMODEMSG VARCHAR(1)
		,USERROLEID NUMBER(10,0)
		,ERASEBILLTEMPHISTORY VARCHAR(1)
		,EDITPPOPROFILE VARCHAR(1)
		,ENABLEURACCESS VARCHAR(1)
		,CAPSTONECONFIGURATIONACCESS VARCHAR(1)
		,PERMITUDFDEFINITION VARCHAR(1)
		,ENABLEPPOPROFILEEDIT VARCHAR(1)
		,ENABLESUPERVISORROLE VARCHAR(1) )
AS
$$
SELECT T.ODSPOSTINGGROUPAUDITID
		,T.ODSCUSTOMERID
		,T.ODSCREATEDATE
		,T.ODSSNAPSHOTDATE
		,T.ODSROWISCURRENT
		,T.ODSHASHBYTESVALUE
		,T.DMLOPERATION
		,T.USERID
		,T.USERPASSWORD
		,T.NAME
		,T.SECURITYLEVEL
		,T.ENABLEADJUSTERMENU
		,T.ENABLEPROVADDS
		,T.ALLOWPOSTING
		,T.ENABLECLAIMADDS
		,T.ENABLEPOLICYADDS
		,T.ENABLEINVOICECREDITVOID
		,T.ENABLEREEVALUATIONS
		,T.ENABLEPPOACCESS
		,T.ENABLEURCOMMENTVIEW
		,T.ENABLEPENDRELEASE
		,T.ENABLEXTABLEUPDATE
		,T.CREATEUSERID
		,T.CREATEDATE
		,T.MODUSERID
		,T.MODDATE
		,T.ENABLEPPOFASTMATCHADDS
		,T.EXTERNALID
		,T.EMAILADDRESS
		,T.EMAILNOTIFY
		,T.ACTIVESTATUS
		,T.COMPANYSEQ
		,T.NETWORKLOGIN
		,T.AUTOMATICNETWORKLOGIN
		,T.LASTLOGGEDINDATE
		,T.PROMPTTOCREATEMCC
		,T.ACCESSALLWORKQUEUES
		,T.LANDINGZONEACCESS
		,T.REVIEWLEVEL
		,T.ENABLEUSERMAINTENANCE
		,T.ENABLEHISTORYMAINTENANCE
		,T.ENABLECLIENTMAINTENANCE
		,T.FEEACCESS
		,T.ENABLESALESTAXMAINTENANCE
		,T.BESALESTAXZIPCODEACCESS
		,T.INVOICEGENACCESS
		,T.BEPERMITALLOWOVER
		,T.PERMITREREVIEWS
		,T.EDITBILLCONTROL
		,T.RESTRICTEORNOTES
		,T.UWQAUTONEXTBILL
		,T.UWQDISABLEOPTIONS
		,T.UWQDISABLERULES
		,T.PERMITCHECKREISSUE
		,T.ENABLEEDIAUTOMATIONMAINTENANCE
		,T.RESTRICTDIARYNOTES
		,T.RESTRICTEXTERNALDIARYNOTES
		,T.BEDEFERMANUALMODEMSG
		,T.USERROLEID
		,T.ERASEBILLTEMPHISTORY
		,T.EDITPPOPROFILE
		,T.ENABLEURACCESS
		,T.CAPSTONECONFIGURATIONACCESS
		,T.PERMITUDFDEFINITION
		,T.ENABLEPPOPROFILEEDIT
		,T.ENABLESUPERVISORROLE
FROM src.UserInfo T
INNER JOIN (
	SELECT 
		ODSCUSTOMERID,
		USERID,
		MAX(ODSPOSTINGGROUPAUDITID) AS ODSPOSTINGGROUPAUDITID
	FROM src.UserInfo
	WHERE ODSPOSTINGGROUPAUDITID <= IF_ODSPOSTINGGROUPAUDITID
	GROUP BY ODSCUSTOMERID,
		USERID) S
ON T.ODSPOSTINGGROUPAUDITID = S.ODSPOSTINGGROUPAUDITID
	AND T.ODSCUSTOMERID = S.ODSCUSTOMERID
	AND T.USERID = S.USERID
WHERE T.DMLOPERATION <> 'D'

$$;


