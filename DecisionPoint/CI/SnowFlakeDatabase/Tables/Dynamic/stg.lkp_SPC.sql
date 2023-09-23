CREATE OR REPLACE TABLE stg.lkp_SPC (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , lkp_SpcId NUMBER(10, 0) NOT NULL
	 , LongName VARCHAR(50) NULL
	 , ShortName VARCHAR(4) NULL
	 , Mult NUMBER(19, 4) NULL
	 , NCD92 NUMBER(5, 0) NULL
	 , NCD93 NUMBER(5, 0) NULL
	 , PlusFour NUMBER(5, 0) NULL
	 , CbreSpecialtyCode VARCHAR(12) NULL
);

