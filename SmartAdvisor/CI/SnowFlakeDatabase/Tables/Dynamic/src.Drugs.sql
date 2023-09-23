CREATE TABLE IF NOT EXISTS src.Drugs (
	  ODSPOSTINGGROUPAUDITID NUMBER(10, 0) NOT NULL
	 , ODSCUSTOMERID NUMBER(10, 0) NOT NULL
	 , ODSCREATEDATE DATETIME NOT NULL
	 , ODSSNAPSHOTDATE DATETIME NOT NULL
	 , ODSROWISCURRENT INT NOT NULL
	 , ODSHASHBYTESVALUE BINARY(8000) NULL
	 , DMLOPERATION VARCHAR(1) NOT NULL
	 , DRUGCODE VARCHAR(4) NOT NULL
	 , DRUGSDESCRIPTION VARCHAR(20) NULL
	 , DISP VARCHAR(20) NULL
	 , DRUGTYPE VARCHAR(1) NULL
	 , CAT VARCHAR(1) NULL
	 , UPDATEFLAG VARCHAR(1) NULL
	 , UV NUMBER(10, 0) NULL
	 , CREATEDATE DATETIME NULL
	 , CREATEUSERID VARCHAR(2) NULL
	 , MODDATE DATETIME NULL
	 , MODUSERID VARCHAR(2) NULL
);
