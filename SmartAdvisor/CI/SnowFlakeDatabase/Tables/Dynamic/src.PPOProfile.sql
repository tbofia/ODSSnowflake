CREATE TABLE IF NOT EXISTS src.PPOProfile (
	  ODSPOSTINGGROUPAUDITID NUMBER(10, 0) NOT NULL
	 , ODSCUSTOMERID NUMBER(10, 0) NOT NULL
	 , ODSCREATEDATE DATETIME NOT NULL
	 , ODSSNAPSHOTDATE DATETIME NOT NULL
	 , ODSROWISCURRENT INT NOT NULL
	 , ODSHASHBYTESVALUE BINARY(8000) NULL
	 , DMLOPERATION VARCHAR(1) NOT NULL
	 , SITECODE VARCHAR(3) NOT NULL
	 , PPOPROFILEID NUMBER(10, 0) NOT NULL
	 , PROFILEDESC VARCHAR(50) NULL
	 , CREATEDATE DATETIME NULL
	 , CREATEUSERID VARCHAR(2) NULL
	 , MODDATE DATETIME NULL
	 , MODUSERID VARCHAR(2) NULL
	 , SMARTSEARCHPAGEMAX NUMBER(5, 0) NULL
	 , JURISDICTIONSTACKEXCLUSIVE VARCHAR(1) NULL
	 , REEVALFULLSTACKWHENORIGALLOWNOHIT VARCHAR(1) NULL
);

