CREATE OR REPLACE TABLE stg.PPONetwork (
	  ODSPOSTINGGROUPAUDITID NUMBER(10, 0) NOT NULL
	 , ODSCUSTOMERID NUMBER(10, 0) NOT NULL
	 , ODSCREATEDATE DATETIME NOT NULL
	 , ODSSNAPSHOTDATE DATETIME NOT NULL
	 , ODSROWISCURRENT INT NOT NULL
	 , ODSHASHBYTESVALUE BINARY(8000) NULL
	 , DMLOPERATION VARCHAR(1) NOT NULL
	 , PPONETWORKID VARCHAR(2) NOT NULL
	 , NAME VARCHAR(30) NULL
	 , TIN VARCHAR(10) NULL
	 , ZIP VARCHAR(10) NULL
	 , STATE VARCHAR(2) NULL
	 , CITY VARCHAR(15) NULL
	 , STREET VARCHAR(30) NULL
	 , PHONENUM VARCHAR(20) NULL
	 , PPONETWORKCOMMENT VARCHAR(6000) NULL
	 , ALLOWMAINT VARCHAR(1) NULL
	 , REQEXTPPO VARCHAR(1) NULL
	 , DEMORATES VARCHAR(1) NULL
	 , PRINTASPROVIDER VARCHAR(1) NULL
	 , PPOTYPE VARCHAR(3) NULL
	 , PPOVERSION VARCHAR(1) NULL
	 , PPOBRIDGEEXISTS VARCHAR(1) NULL
	 , USESDRG VARCHAR(1) NULL
	 , PPOTOOTHER VARCHAR(1) NULL
	 , SUBNETWORKINDICATOR VARCHAR(1) NULL
	 , EMAILADDRESS VARCHAR(255) NULL
	 , WEBSITE VARCHAR(255) NULL
	 , BILLCONTROLSEQ NUMBER(5, 0) NULL
);

