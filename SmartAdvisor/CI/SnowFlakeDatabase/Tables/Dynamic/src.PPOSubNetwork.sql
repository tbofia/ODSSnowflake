CREATE TABLE IF NOT EXISTS src.PPOSubNetwork (
	  ODSPOSTINGGROUPAUDITID NUMBER(10, 0) NOT NULL
	 , ODSCUSTOMERID NUMBER(10, 0) NOT NULL
	 , ODSCREATEDATE DATETIME NOT NULL
	 , ODSSNAPSHOTDATE DATETIME NOT NULL
	 , ODSROWISCURRENT INT NOT NULL
	 , ODSHASHBYTESVALUE BINARY(8000) NULL
	 , DMLOPERATION VARCHAR(1) NOT NULL
	 , PPONETWORKID VARCHAR(2) NOT NULL
	 , GROUPCODE VARCHAR(3) NOT NULL
	 , GROUPNAME VARCHAR(40) NULL
	 , EXTERNALID VARCHAR(30) NULL
	 , SITECODE VARCHAR(3) NULL
	 , CREATEDATE DATETIME NULL
	 , CREATEUSERID VARCHAR(2) NULL
	 , MODDATE DATETIME NULL
	 , MODUSERID VARCHAR(2) NULL
	 , STREET1 VARCHAR(30) NULL
	 , STREET2 VARCHAR(30) NULL
	 , CITY VARCHAR(15) NULL
	 , STATE VARCHAR(2) NULL
	 , ZIP VARCHAR(10) NULL
	 , PHONENUM VARCHAR(20) NULL
	 , EMAILADDRESS VARCHAR(255) NULL
	 , WEBSITE VARCHAR(255) NULL
	 , TIN VARCHAR(9) NULL
	 , COMMENT VARCHAR(4000) NULL
);
