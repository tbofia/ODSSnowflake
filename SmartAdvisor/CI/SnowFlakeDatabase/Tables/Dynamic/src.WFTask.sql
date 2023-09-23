CREATE TABLE IF NOT EXISTS src.WFTask (
	  ODSPOSTINGGROUPAUDITID NUMBER(10, 0) NOT NULL
	 , ODSCUSTOMERID NUMBER(10, 0) NOT NULL
	 , ODSCREATEDATE DATETIME NOT NULL
	 , ODSSNAPSHOTDATE DATETIME NOT NULL
	 , ODSROWISCURRENT INT NOT NULL
	 , ODSHASHBYTESVALUE BINARY(8000) NULL
	 , DMLOPERATION VARCHAR(1) NOT NULL
	 , WFTASKSEQ NUMBER(10, 0) NOT NULL
	 , WFLOWSEQ NUMBER(10, 0) NULL
	 , WFTASKREGISTRYSEQ NUMBER(10, 0) NULL
	 , NAME VARCHAR(35) NULL
	 , PARAMETER1 VARCHAR(35) NULL
	 , RECORDSTATUS VARCHAR(1) NULL
	 , NODELEFT NUMBER(8, 2) NULL
	 , NODETOP NUMBER(8, 2) NULL
	 , CREATEUSERID VARCHAR(2) NULL
	 , CREATEDATE DATETIME NULL
	 , MODUSERID VARCHAR(2) NULL
	 , MODDATE DATETIME NULL
	 , NOPRIOR VARCHAR(1) NULL
	 , NORESTART VARCHAR(1) NULL
	 , PARAMETERX VARCHAR(2000) NULL
	 , DEFAULTPENDGROUP VARCHAR(12) NULL
	 , CONFIGURATION VARCHAR(2000) NULL
);

