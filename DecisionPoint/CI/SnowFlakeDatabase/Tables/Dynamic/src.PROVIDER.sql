CREATE TABLE IF NOT EXISTS src.PROVIDER (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , PvdIDNo NUMBER(10, 0) NOT NULL
	 , PvdMID NUMBER(10, 0) NULL
	 , PvdSource NUMBER(5, 0) NULL
	 , PvdTIN VARCHAR(15) NULL
	 , PvdLicNo VARCHAR(30) NULL
	 , PvdCertNo VARCHAR(30) NULL
	 , PvdLastName VARCHAR(60) NULL
	 , PvdFirstName VARCHAR(35) NULL
	 , PvdMI VARCHAR(1) NULL
	 , PvdTitle VARCHAR(5) NULL
	 , PvdGroup VARCHAR(60) NULL
	 , PvdAddr1 VARCHAR(55) NULL
	 , PvdAddr2 VARCHAR(55) NULL
	 , PvdCity VARCHAR(30) NULL
	 , PvdState VARCHAR(2) NULL
	 , PvdZip VARCHAR(12) NULL
	 , PvdZipPerf VARCHAR(12) NULL
	 , PvdPhone VARCHAR(25) NULL
	 , PvdFAX VARCHAR(13) NULL
	 , PvdSPC_List VARCHAR NULL
	 , PvdAuthNo VARCHAR(30) NULL
	 , PvdSPC_ACD VARCHAR(2) NULL
	 , PvdUpdateCounter NUMBER(5, 0) NULL
	 , PvdPPO_Provider NUMBER(5, 0) NULL
	 , PvdFlags NUMBER(10, 0) NULL
	 , PvdERRate NUMBER(19, 4) NULL
	 , PvdSubNet VARCHAR(4) NULL
	 , InUse VARCHAR(100) NULL
	 , PvdStatus NUMBER(10, 0) NULL
	 , PvdElectroStartDate DATETIME NULL
	 , PvdElectroEndDate DATETIME NULL
	 , PvdAccredStartDate DATETIME NULL
	 , PvdAccredEndDate DATETIME NULL
	 , PvdRehabStartDate DATETIME NULL
	 , PvdRehabEndDate DATETIME NULL
	 , PvdTraumaStartDate DATETIME NULL
	 , PvdTraumaEndDate DATETIME NULL
	 , OPCERT VARCHAR(7) NULL
	 , PvdDentalStartDate DATETIME NULL
	 , PvdDentalEndDate DATETIME NULL
	 , PvdNPINo VARCHAR(10) NULL
	 , PvdCMSId VARCHAR(6) NULL
	 , CreateDate DATETIME NULL
	 , LastChangedOn DATETIME NULL
);

