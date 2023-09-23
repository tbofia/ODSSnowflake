CREATE TABLE IF NOT EXISTS src.WFlow (
	  ODSPOSTINGGROUPAUDITID NUMBER(10, 0) NOT NULL
	 , ODSCUSTOMERID NUMBER(10, 0) NOT NULL
	 , ODSCREATEDATE DATETIME NOT NULL
	 , ODSSNAPSHOTDATE DATETIME NOT NULL
	 , ODSROWISCURRENT INT NOT NULL
	 , ODSHASHBYTESVALUE BINARY(8000) NULL
	 , DMLOPERATION VARCHAR(1) NOT NULL
	 , WFLOWSEQ NUMBER(10, 0) NOT NULL
	 , DESCRIPTION VARCHAR(50) NULL
	 , RECORDSTATUS VARCHAR(1) NULL
	 , ENTITYTYPECODE VARCHAR(2) NULL
	 , CREATEUSERID VARCHAR(2) NULL
	 , CREATEDATE DATETIME NULL
	 , MODUSERID VARCHAR(2) NULL
	 , MODDATE DATETIME NULL
	 , INITIALTASKSEQ NUMBER(10, 0) NULL
	 , PAUSETASKSEQ NUMBER(10, 0) NULL
);

