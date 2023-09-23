CREATE TABLE IF NOT EXISTS src.ClaimDiag (
	  ODSPOSTINGGROUPAUDITID NUMBER(10, 0) NOT NULL
	 , ODSCUSTOMERID NUMBER(10, 0) NOT NULL
	 , ODSCREATEDATE DATETIME NOT NULL
	 , ODSSNAPSHOTDATE DATETIME NOT NULL
	 , ODSROWISCURRENT INT NOT NULL
	 , ODSHASHBYTESVALUE BINARY(8000) NULL
	 , DMLOPERATION VARCHAR(1) NOT NULL
	 , CLAIMSYSSUBSET VARCHAR(4) NOT NULL
	 , CLAIMSEQ NUMBER(10, 0) NOT NULL
	 , CLAIMDIAGSEQ NUMBER(5, 0) NOT NULL
	 , DIAGCODE VARCHAR(8) NULL
);

