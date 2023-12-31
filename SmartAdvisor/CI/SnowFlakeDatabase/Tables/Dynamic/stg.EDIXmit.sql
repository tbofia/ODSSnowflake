CREATE OR REPLACE TABLE stg.EDIXmit (
	  ODSPOSTINGGROUPAUDITID NUMBER(10, 0) NOT NULL
	 , ODSCUSTOMERID NUMBER(10, 0) NOT NULL
	 , ODSCREATEDATE DATETIME NOT NULL
	 , ODSSNAPSHOTDATE DATETIME NOT NULL
	 , ODSROWISCURRENT INT NOT NULL
	 , ODSHASHBYTESVALUE BINARY(8000) NULL
	 , DMLOPERATION VARCHAR(1) NOT NULL
	 , EDIXMITSEQ NUMBER(10, 0) NOT NULL
	 , FILESPEC VARCHAR(8000) NULL
	 , FILELOCATION VARCHAR(255) NULL
	 , RECOMMENDEDPAYMENT NUMBER(19, 4) NULL
	 , USERID VARCHAR(2) NULL
	 , XMITDATE DATETIME NULL
	 , DATEFROM DATETIME NULL
	 , DATETO DATETIME NULL
	 , EDITYPE VARCHAR(1) NULL
	 , EDIPARTNERID VARCHAR(3) NULL
	 , DBVERSION VARCHAR(20) NULL
	 , EDIMAPTOOLSITECODE VARCHAR(3) NULL
	 , EDIPORTTYPE VARCHAR(1) NULL
	 , EDIMAPTOOLID NUMBER(10, 0) NULL
	 , TRANSMISSIONSTATUS VARCHAR(1) NULL
	 , BATCHNUMBER NUMBER(10, 0) NULL
	 , SENDERID VARCHAR(20) NULL
	 , RECEIVERID VARCHAR(20) NULL
	 , EXTERNALBATCHID VARCHAR(50) NULL
	 , SARELATEDBATCHID NUMBER(19, 0) NULL
	 , ACKNOTECODE VARCHAR(3) NULL
	 , ACKNOTE VARCHAR(50) NULL
	 , EXTERNALBATCHDATE DATETIME NULL
	 , USERNOTES VARCHAR(1000) NULL
	 , RESUBMITDATE DATETIME NULL
	 , RESUBMITUSERID VARCHAR(2) NULL
	 , MODDATE DATETIME NULL
	 , MODUSERID VARCHAR(2) NULL
);

