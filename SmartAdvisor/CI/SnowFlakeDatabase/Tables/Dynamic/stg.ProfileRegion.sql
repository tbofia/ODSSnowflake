CREATE OR REPLACE TABLE stg.ProfileRegion (
	  ODSPOSTINGGROUPAUDITID NUMBER(10, 0) NOT NULL
	 , ODSCUSTOMERID NUMBER(10, 0) NOT NULL
	 , ODSCREATEDATE DATETIME NOT NULL
	 , ODSSNAPSHOTDATE DATETIME NOT NULL
	 , ODSROWISCURRENT INT NOT NULL
	 , ODSHASHBYTESVALUE BINARY(8000) NULL
	 , DMLOPERATION VARCHAR(1) NOT NULL
	 , SITECODE VARCHAR(3) NOT NULL
	 , PROFILEREGIONID NUMBER(10, 0) NOT NULL
	 , REGIONTYPECODE VARCHAR(2) NULL
	 , REGIONNAME VARCHAR(50) NULL
);
