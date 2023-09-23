CREATE TABLE IF NOT EXISTS src.BillProvider (
	  ODSPOSTINGGROUPAUDITID NUMBER(10, 0) NOT NULL
	 , ODSCUSTOMERID NUMBER(10, 0) NOT NULL
	 , ODSCREATEDATE DATETIME NOT NULL
	 , ODSSNAPSHOTDATE DATETIME NOT NULL
	 , ODSROWISCURRENT INT NOT NULL
	 , ODSHASHBYTESVALUE BINARY(8000) NULL
	 , DMLOPERATION VARCHAR(1) NOT NULL
	 , CLIENTCODE VARCHAR(4) NOT NULL
	 , BILLSEQ NUMBER(10, 0) NOT NULL
	 , BILLPROVIDERSEQ NUMBER(10, 0) NOT NULL
	 , QUALIFIER VARCHAR(2) NULL
	 , LASTNAME VARCHAR(40) NULL
	 , FIRSTNAME VARCHAR(30) NULL
	 , MIDDLENAME VARCHAR(25) NULL
	 , SUFFIX VARCHAR(10) NULL
	 , NPI VARCHAR(10) NULL
	 , LICENSENUM VARCHAR(30) NULL
	 , DEANUM VARCHAR(9) NULL
);

