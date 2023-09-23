CREATE TABLE IF NOT EXISTS src.ClaimInsurer (
	  ODSPOSTINGGROUPAUDITID NUMBER(10, 0) NOT NULL
	 , ODSCUSTOMERID NUMBER(10, 0) NOT NULL
	 , ODSCREATEDATE DATETIME NOT NULL
	 , ODSSNAPSHOTDATE DATETIME NOT NULL
	 , ODSROWISCURRENT INT NOT NULL
	 , ODSHASHBYTESVALUE BINARY(8000) NULL
	 , DMLOPERATION VARCHAR(1) NOT NULL
	 , CLAIMSYSSUBSET VARCHAR(4) NOT NULL
	 , CLAIMSEQ NUMBER(10, 0) NOT NULL
	 , INSURERTYPE VARCHAR(1) NOT NULL
	 , EFFECTIVEDATE DATETIME NOT NULL
	 , INSURERSEQ NUMBER(10, 0) NULL
	 , TERMINATIONDATE DATETIME NULL
	 , EXTERNALPOLICYNUMBER VARCHAR(30) NULL
	 , UNITSTATCLAIMID VARCHAR(35) NULL
	 , UNITSTATPOLICYID VARCHAR(30) NULL
	 , POLICYEFFECTIVEDATE DATETIME NULL
	 , SELFINSURED VARCHAR(1) NULL
	 , CLAIMADMINCLAIMNUM VARCHAR(35) NULL
);

