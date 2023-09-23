CREATE OR REPLACE TABLE stg.WFTaskRegistry (
	  ODSPOSTINGGROUPAUDITID NUMBER(10, 0) NOT NULL
	 , ODSCUSTOMERID NUMBER(10, 0) NOT NULL
	 , ODSCREATEDATE DATETIME NOT NULL
	 , ODSSNAPSHOTDATE DATETIME NOT NULL
	 , ODSROWISCURRENT INT NOT NULL
	 , ODSHASHBYTESVALUE BINARY(8000) NULL
	 , DMLOPERATION VARCHAR(1) NOT NULL
	 , WFTASKREGISTRYSEQ NUMBER(10, 0) NOT NULL
	 , ENTITYTYPECODE VARCHAR(2) NULL
	 , DESCRIPTION VARCHAR(50) NULL
	 , ACTION VARCHAR(50) NULL
	 , SMALLIMAGERESID NUMBER(10, 0) NULL
	 , LARGEIMAGERESID NUMBER(10, 0) NULL
	 , PERSISTBEFORE VARCHAR(1) NULL
	 , NACTION VARCHAR(512) NULL
);

