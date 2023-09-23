CREATE OR REPLACE TABLE stg.BillReevalReason (
	  ODSPOSTINGGROUPAUDITID NUMBER(10, 0) NOT NULL
	 , ODSCUSTOMERID NUMBER(10, 0) NOT NULL
	 , ODSCREATEDATE DATETIME NOT NULL
	 , ODSSNAPSHOTDATE DATETIME NOT NULL
	 , ODSROWISCURRENT INT NOT NULL
	 , ODSHASHBYTESVALUE BINARY(8000) NULL
	 , DMLOPERATION VARCHAR(1) NOT NULL
	 , BILLREEVALREASONCODE VARCHAR(30) NOT NULL
	 , SITECODE VARCHAR(3) NOT NULL
	 , BILLREEVALREASONCATEGORYSEQ NUMBER(10, 0) NULL
	 , SHORTDESCRIPTION VARCHAR(40) NULL
	 , LONGDESCRIPTION VARCHAR(255) NULL
	 , ACTIVE BOOLEAN NULL
	 , CREATEDATE DATETIME NULL
	 , CREATEUSERID VARCHAR(2) NULL
	 , MODDATE DATETIME NULL
	 , MODUSERID VARCHAR(2) NULL
);

