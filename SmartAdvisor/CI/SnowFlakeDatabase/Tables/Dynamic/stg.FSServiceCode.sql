CREATE OR REPLACE TABLE stg.FSServiceCode (
	  ODSPOSTINGGROUPAUDITID NUMBER(10, 0) NOT NULL
	 , ODSCUSTOMERID NUMBER(10, 0) NOT NULL
	 , ODSCREATEDATE DATETIME NOT NULL
	 , ODSSNAPSHOTDATE DATETIME NOT NULL
	 , ODSROWISCURRENT INT NOT NULL
	 , ODSHASHBYTESVALUE BINARY(8000) NULL
	 , DMLOPERATION VARCHAR(1) NOT NULL
	 , JURISDICTION VARCHAR(2) NOT NULL
	 , SERVICECODE VARCHAR(30) NOT NULL
	 , GEOAREACODE VARCHAR(12) NOT NULL
	 , EFFECTIVEDATE DATETIME NOT NULL
	 , DESCRIPTION VARCHAR(255) NULL
	 , TERMDATE DATETIME NULL
	 , CODESOURCE VARCHAR(6) NULL
	 , CODEGROUP VARCHAR(12) NULL
);
