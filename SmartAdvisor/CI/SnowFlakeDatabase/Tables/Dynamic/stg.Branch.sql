CREATE OR REPLACE TABLE stg.Branch (
	  ODSPOSTINGGROUPAUDITID NUMBER(10, 0) NOT NULL
	 , ODSCUSTOMERID NUMBER(10, 0) NOT NULL
	 , ODSCREATEDATE DATETIME NOT NULL
	 , ODSSNAPSHOTDATE DATETIME NOT NULL
	 , ODSROWISCURRENT INT NOT NULL
	 , ODSHASHBYTESVALUE BINARY(8000) NULL
	 , DMLOPERATION VARCHAR(1) NOT NULL
	 , CLAIMSYSSUBSET VARCHAR(4) NOT NULL
	 , BRANCHSEQ NUMBER(10, 0) NOT NULL
	 , NAME VARCHAR(60) NULL
	 , EXTERNALID VARCHAR(20) NULL
	 , BRANCHID VARCHAR(20) NULL
	 , LOCATIONCODE VARCHAR(10) NULL
	 , ADMINKEY VARCHAR(40) NULL
	 , ADDRESS1 VARCHAR(30) NULL
	 , ADDRESS2 VARCHAR(30) NULL
	 , CITY VARCHAR(20) NULL
	 , STATE VARCHAR(2) NULL
	 , ZIP VARCHAR(9) NULL
	 , PHONENUM VARCHAR(20) NULL
	 , FAXNUM VARCHAR(20) NULL
	 , CONTACTNAME VARCHAR(30) NULL
	 , TIN VARCHAR(9) NULL
	 , STATETAXID VARCHAR(30) NULL
	 , DIRNUM VARCHAR(20) NULL
	 , MODUSERID VARCHAR(2) NULL
	 , MODDATE DATETIME NULL
	 , RULEFIRE VARCHAR(4) NULL
	 , FEERATECNTRLEX VARCHAR(4) NULL
	 , FEERATECNTRLIN VARCHAR(4) NULL
	 , SALESTAXEXEMPT VARCHAR(1) NULL
	 , EFFECTIVEDATE DATETIME NULL
	 , TERMINATIONDATE DATETIME NULL
);

