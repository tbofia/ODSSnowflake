CREATE TABLE IF NOT EXISTS src.BillControlHistory (
	  ODSPOSTINGGROUPAUDITID NUMBER(10, 0) NOT NULL
	 , ODSCUSTOMERID NUMBER(10, 0) NOT NULL
	 , ODSCREATEDATE DATETIME NOT NULL
	 , ODSSNAPSHOTDATE DATETIME NOT NULL
	 , ODSROWISCURRENT INT NOT NULL
	 , ODSHASHBYTESVALUE BINARY(8000) NULL
	 , DMLOPERATION VARCHAR(1) NOT NULL
	 , BILLCONTROLHISTORYSEQ NUMBER(19, 0) NOT NULL
	 , CLIENTCODE VARCHAR(4) NOT NULL
	 , BILLSEQ NUMBER(10, 0) NOT NULL
	 , BILLCONTROLSEQ NUMBER(5, 0) NOT NULL
	 , CREATEDATE DATETIME NULL
	 , CONTROL VARCHAR(1) NULL
	 , EXTERNALID VARCHAR(50) NULL
	 , EDIBATCHLOGSEQ NUMBER(19, 0) NULL
	 , DELETED BOOLEAN NULL
	 , MODUSERID VARCHAR(2) NULL
	 , EXTERNALID2 VARCHAR(50) NULL
	 , MESSAGE VARCHAR(500) NULL
);

