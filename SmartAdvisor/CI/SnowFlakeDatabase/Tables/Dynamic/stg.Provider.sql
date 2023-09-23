CREATE OR REPLACE TABLE stg.Provider (
	  ODSPOSTINGGROUPAUDITID NUMBER(10, 0) NOT NULL
	 , ODSCUSTOMERID NUMBER(10, 0) NOT NULL
	 , ODSCREATEDATE DATETIME NOT NULL
	 , ODSSNAPSHOTDATE DATETIME NOT NULL
	 , ODSROWISCURRENT INT NOT NULL
	 , ODSHASHBYTESVALUE BINARY(8000) NULL
	 , DMLOPERATION VARCHAR(1) NOT NULL
	 , PROVIDERSUBSET VARCHAR(4) NOT NULL
	 , PROVIDERSEQ NUMBER(19, 0) NOT NULL
	 , TIN VARCHAR(9) NULL
	 , TINSUFFIX VARCHAR(6) NULL
	 , EXTERNALID VARCHAR(30) NULL
	 , NAME VARCHAR(50) NULL
	 , GROUPCODE VARCHAR(5) NULL
	 , LICENSENUM VARCHAR(30) NULL
	 , MEDICARENUM VARCHAR(20) NULL
	 , PRACTICEADDRESSSEQ NUMBER(10, 0) NULL
	 , BILLINGADDRESSSEQ NUMBER(10, 0) NULL
	 , HOSPITALSEQ NUMBER(10, 0) NULL
	 , PROVTYPE VARCHAR(3) NULL
	 , SPECIALTY1 VARCHAR(8) NULL
	 , SPECIALTY2 VARCHAR(8) NULL
	 , CREATEUSERID VARCHAR(2) NULL
	 , CREATEDATE DATETIME NULL
	 , MODUSERID VARCHAR(2) NULL
	 , MODDATE DATETIME NULL
	 , STATUS VARCHAR(1) NULL
	 , EXTERNALSTATUS VARCHAR(1) NULL
	 , EXPORTDATE DATETIME NULL
	 , SSNTININDICATOR VARCHAR(1) NULL
	 , PMTDAYS NUMBER(5, 0) NULL
	 , AUTHBEGINDATE DATETIME NULL
	 , AUTHENDDATE DATETIME NULL
	 , TAXADDRESSSEQ NUMBER(10, 0) NULL
	 , CTRLNUM1099 VARCHAR(4) NULL
	 , SURCHARGECODE VARCHAR(1) NULL
	 , WORKCOMPNUM VARCHAR(18) NULL
	 , WORKCOMPSTATE VARCHAR(2) NULL
	 , NCPDPID VARCHAR(10) NULL
	 , ENTITYTYPE VARCHAR(1) NULL
	 , LASTNAME VARCHAR(35) NULL
	 , FIRSTNAME VARCHAR(25) NULL
	 , MIDDLENAME VARCHAR(25) NULL
	 , SUFFIX VARCHAR(10) NULL
	 , NPI VARCHAR(10) NULL
	 , FACILITYNPI VARCHAR(10) NULL
	 , VERIFICATIONGROUPID VARCHAR(30) NULL
);

