CREATE OR REPLACE TABLE stg.AdjusterPendGroup (
	  ODSPOSTINGGROUPAUDITID NUMBER(10, 0) NOT NULL
	 , ODSCUSTOMERID NUMBER(10, 0) NOT NULL
	 , ODSCREATEDATE DATETIME NOT NULL
	 , ODSSNAPSHOTDATE DATETIME NOT NULL
	 , ODSROWISCURRENT INT NOT NULL
	 , ODSHASHBYTESVALUE BINARY(8000) NULL
	 , DMLOPERATION VARCHAR(1) NOT NULL
	 , CLAIMSYSSUBSET VARCHAR(4) NOT NULL
	 , ADJUSTER VARCHAR(25) NOT NULL
	 , PENDGROUPCODE VARCHAR(12) NOT NULL
);

