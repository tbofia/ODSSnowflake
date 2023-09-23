CREATE TABLE IF NOT EXISTS src.FSProcedure (
	  ODSPOSTINGGROUPAUDITID NUMBER(10, 0) NOT NULL
	 , ODSCUSTOMERID NUMBER(10, 0) NOT NULL
	 , ODSCREATEDATE DATETIME NOT NULL
	 , ODSSNAPSHOTDATE DATETIME NOT NULL
	 , ODSROWISCURRENT INT NOT NULL
	 , ODSHASHBYTESVALUE BINARY(8000) NULL
	 , DMLOPERATION VARCHAR(1) NOT NULL
	 , JURISDICTION VARCHAR(2) NOT NULL
	 , EXTENSION VARCHAR(3) NOT NULL
	 , PROCEDURECODE VARCHAR(6) NOT NULL
	 , FSPROCDESCRIPTION VARCHAR(24) NULL
	 , SV VARCHAR(1) NULL
	 , STAR VARCHAR(1) NULL
	 , PANEL VARCHAR(1) NULL
	 , IP VARCHAR(1) NULL
	 , MULT VARCHAR(1) NULL
	 , ASSTSURGEON VARCHAR(1) NULL
	 , SECTIONFLAG VARCHAR(1) NULL
	 , FUP VARCHAR(3) NULL
	 , BAV NUMBER(5, 0) NULL
	 , PROCGROUP VARCHAR(4) NULL
	 , VIEWTYPE NUMBER(5, 0) NULL
	 , UNITVALUE1 NUMBER(19, 4) NULL
	 , UNITVALUE2 NUMBER(19, 4) NULL
	 , UNITVALUE3 NUMBER(19, 4) NULL
	 , UNITVALUE4 NUMBER(19, 4) NULL
	 , UNITVALUE5 NUMBER(19, 4) NULL
	 , UNITVALUE6 NUMBER(19, 4) NULL
	 , UNITVALUE7 NUMBER(19, 4) NULL
	 , UNITVALUE8 NUMBER(19, 4) NULL
	 , UNITVALUE9 NUMBER(19, 4) NULL
	 , UNITVALUE10 NUMBER(19, 4) NULL
	 , UNITVALUE11 NUMBER(19, 4) NULL
	 , UNITVALUE12 NUMBER(19, 4) NULL
	 , PROUNITVALUE1 NUMBER(19, 4) NULL
	 , PROUNITVALUE2 NUMBER(19, 4) NULL
	 , PROUNITVALUE3 NUMBER(19, 4) NULL
	 , PROUNITVALUE4 NUMBER(19, 4) NULL
	 , PROUNITVALUE5 NUMBER(19, 4) NULL
	 , PROUNITVALUE6 NUMBER(19, 4) NULL
	 , PROUNITVALUE7 NUMBER(19, 4) NULL
	 , PROUNITVALUE8 NUMBER(19, 4) NULL
	 , PROUNITVALUE9 NUMBER(19, 4) NULL
	 , PROUNITVALUE10 NUMBER(19, 4) NULL
	 , PROUNITVALUE11 NUMBER(19, 4) NULL
	 , PROUNITVALUE12 NUMBER(19, 4) NULL
	 , TECHUNITVALUE1 NUMBER(19, 4) NULL
	 , TECHUNITVALUE2 NUMBER(19, 4) NULL
	 , TECHUNITVALUE3 NUMBER(19, 4) NULL
	 , TECHUNITVALUE4 NUMBER(19, 4) NULL
	 , TECHUNITVALUE5 NUMBER(19, 4) NULL
	 , TECHUNITVALUE6 NUMBER(19, 4) NULL
	 , TECHUNITVALUE7 NUMBER(19, 4) NULL
	 , TECHUNITVALUE8 NUMBER(19, 4) NULL
	 , TECHUNITVALUE9 NUMBER(19, 4) NULL
	 , TECHUNITVALUE10 NUMBER(19, 4) NULL
	 , TECHUNITVALUE11 NUMBER(19, 4) NULL
	 , TECHUNITVALUE12 NUMBER(19, 4) NULL
	 , SITECODE VARCHAR(3) NULL
);

