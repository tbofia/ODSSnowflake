CREATE TABLE IF NOT EXISTS src.Esp_Ppo_Billing_Data_Self_Bill (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , COMPANYCODE VARCHAR(10) NULL
	 , TRANSACTIONTYPE VARCHAR(10) NULL
	 , BILL_HDR_AMTALLOWED NUMBER(15, 2) NULL
	 , BILL_HDR_AMTCHARGED NUMBER(15, 2) NULL
	 , BILL_HDR_BILLIDNO NUMBER(10, 0) NULL
	 , BILL_HDR_CMT_HDR_IDNO NUMBER(10, 0) NULL
	 , BILL_HDR_CREATEDATE DATETIME NULL
	 , BILL_HDR_CV_TYPE VARCHAR(5) NULL
	 , BILL_HDR_FORM_TYPE VARCHAR(8) NULL
	 , BILL_HDR_NOLINES NUMBER(10, 0) NULL
	 , BILLS_ALLOWED NUMBER(15, 2) NULL
	 , BILLS_ANALYZED NUMBER(15, 2) NULL
	 , BILLS_CHARGED NUMBER(15, 2) NULL
	 , BILLS_DT_SVC DATETIME NULL
	 , BILLS_LINE_NO NUMBER(10, 0) NULL
	 , CLAIMANT_CLIENTREF_CMTSUFFIX VARCHAR(50) NULL
	 , CLAIMANT_CMTFIRST_NAME VARCHAR(50) NULL
	 , CLAIMANT_CMTIDNO VARCHAR(20) NULL
	 , CLAIMANT_CMTLASTNAME VARCHAR(60) NULL
	 , CMTSTATEOFJURISDICTION VARCHAR(2) NULL
	 , CLAIMS_COMPANYID NUMBER(10, 0) NULL
	 , CLAIMS_CLAIMNO VARCHAR(50) NULL
	 , CLAIMS_DATELOSS DATETIME NULL
	 , CLAIMS_OFFICEINDEX NUMBER(10, 0) NULL
	 , CLAIMS_POLICYHOLDERSNAME VARCHAR(100) NULL
	 , CLAIMS_POLICYNUMBER VARCHAR(50) NULL
	 , PNETWKEVENTLOG_EVENTID NUMBER(10, 0) NULL
	 , PNETWKEVENTLOG_LOGDATE DATETIME NULL
	 , PNETWKEVENTLOG_NETWORKID NUMBER(10, 0) NULL
	 , ACTIVITY_FLAG VARCHAR(1) NULL
	 , PPO_AMTALLOWED NUMBER(15, 2) NULL
	 , PREPPO_AMTALLOWED NUMBER(15, 2) NULL
	 , PREPPO_ALLOWED_FS VARCHAR(1) NULL
	 , PRF_COMPANY_COMPANYNAME VARCHAR(50) NULL
	 , PRF_OFFICE_OFCNAME VARCHAR(50) NULL
	 , PRF_OFFICE_OFCNO VARCHAR(25) NULL
	 , PROVIDER_PVDFIRSTNAME VARCHAR(60) NULL
	 , PROVIDER_PVDGROUP VARCHAR(60) NULL
	 , PROVIDER_PVDLASTNAME VARCHAR(60) NULL
	 , PROVIDER_PVDTIN VARCHAR(15) NULL
	 , PROVIDER_STATE VARCHAR(5) NULL
	 , UDFCLAIM_UDFVALUETEXT VARCHAR(255) NULL
	 , ENTRY_DATE DATETIME NULL
	 , UDFCLAIMANT_UDFVALUETEXT VARCHAR(255) NULL
	 , SOURCE_DB VARCHAR(20) NULL
	 , CLAIMS_CV_CODE VARCHAR(5) NULL
	 , VPN_TRANSACTIONID NUMBER(19, 0) NOT NULL
	 , VPN_TRANSACTIONTYPEID NUMBER(10, 0) NULL
	 , VPN_BILLIDNO NUMBER(10, 0) NULL
	 , VPN_LINE_NO NUMBER(5, 0) NULL
	 , VPN_CHARGED NUMBER(19, 4) NULL
	 , VPN_DPALLOWED NUMBER(19, 4) NULL
	 , VPN_VPNALLOWED NUMBER(19, 4) NULL
	 , VPN_SAVINGS NUMBER(19, 4) NULL
	 , VPN_CREDITS NUMBER(19, 4) NULL
	 , VPN_HASOVERRIDE BOOLEAN NULL
	 , VPN_ENDNOTES VARCHAR(200) NULL
	 , VPN_NETWORKIDNO NUMBER(10, 0) NULL
	 , VPN_PROCESSFLAG NUMBER(5, 0) NULL
	 , VPN_LINETYPE NUMBER(10, 0) NULL
	 , VPN_DATETIMESTAMP DATETIME NULL
	 , VPN_SEQNO NUMBER(10, 0) NULL
	 , VPN_VPN_REF_LINE_NO NUMBER(5, 0) NULL
	 , VPN_NETWORKNAME VARCHAR(50) NULL
	 , VPN_SOJ VARCHAR(2) NULL
	 , VPN_CAT3 NUMBER(10, 0) NULL
	 , VPN_PPODATESTAMP DATETIME NULL
	 , VPN_NINTEYDAYS NUMBER(10, 0) NULL
	 , VPN_BILL_TYPE VARCHAR(1) NULL
	 , VPN_NET_SAVINGS NUMBER(19, 4) NULL
	 , CREDIT BOOLEAN NULL
	 , RECON BOOLEAN NULL
	 , DELETED BOOLEAN NULL
	 , STATUS_FLAG VARCHAR(2) NULL
	 , DATE_SAVED DATETIME NULL
	 , SUB_NETWORK VARCHAR(50) NULL
	 , INVALID_CREDIT BOOLEAN NULL
	 , PROVIDER_SPECIALTY VARCHAR(50) NULL
	 , ADJUSTOR_IDNUMBER VARCHAR(25) NULL
	 , ACP_FLAG VARCHAR(1) NULL
	 , OVERRIDE_ENDNOTES VARCHAR NULL
	 , OVERRIDE_ENDNOTES_DESC VARCHAR NULL
);
