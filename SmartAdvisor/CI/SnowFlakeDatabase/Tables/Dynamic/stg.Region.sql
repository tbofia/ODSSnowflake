CREATE OR REPLACE TABLE stg.Region (
	  ODSPOSTINGGROUPAUDITID NUMBER(10, 0) NOT NULL
	 , ODSCUSTOMERID NUMBER(10, 0) NOT NULL
	 , ODSCREATEDATE DATETIME NOT NULL
	 , ODSSNAPSHOTDATE DATETIME NOT NULL
	 , ODSROWISCURRENT INT NOT NULL
	 , ODSHASHBYTESVALUE BINARY(8000) NULL
	 , DMLOPERATION VARCHAR(1) NOT NULL
	 , JURISDICTION VARCHAR(2) NOT NULL
	 , EXTENSION VARCHAR(3) NOT NULL
	 , ENDZIP VARCHAR(5) NOT NULL
	 , BEG VARCHAR(5) NULL
	 , REGION NUMBER(5, 0) NULL
	 , REGIONDESCRIPTION VARCHAR(4) NULL
);

