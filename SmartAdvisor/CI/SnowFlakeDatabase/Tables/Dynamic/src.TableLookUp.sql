CREATE TABLE IF NOT EXISTS src.TableLookUp (
	  ODSPOSTINGGROUPAUDITID NUMBER(10, 0) NOT NULL
	 , ODSCUSTOMERID NUMBER(10, 0) NOT NULL
	 , ODSCREATEDATE DATETIME NOT NULL
	 , ODSSNAPSHOTDATE DATETIME NOT NULL
	 , ODSROWISCURRENT INT NOT NULL
	 , ODSHASHBYTESVALUE BINARY(8000) NULL
	 , DMLOPERATION VARCHAR(1) NOT NULL
	 , TABLECODE VARCHAR(4) NOT NULL
	 , TYPECODE VARCHAR(4) NOT NULL
	 , CODE VARCHAR(12) NOT NULL
	 , SITECODE VARCHAR(3) NOT NULL
	 , OLDCODE VARCHAR(12) NULL
	 , SHORTDESC VARCHAR(40) NULL
	 , SOURCE VARCHAR(1) NULL
	 , PRIORITY NUMBER(5, 0) NULL
	 , LONGDESC VARCHAR(6000) NULL
	 , OWNERAPP VARCHAR(1) NULL
	 , RECORDSTATUS VARCHAR(1) NULL
	 , CREATEDATE DATETIME NULL
	 , CREATEUSERID VARCHAR(2) NULL
	 , MODDATE DATETIME NULL
	 , MODUSERID VARCHAR(2) NULL
);

