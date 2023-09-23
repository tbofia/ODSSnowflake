CREATE TABLE IF NOT EXISTS src.prf_Office (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , CompanyId NUMBER(10, 0) NULL
	 , OfficeId NUMBER(10, 0) NOT NULL
	 , OfcNo VARCHAR(4) NULL
	 , OfcName VARCHAR(40) NULL
	 , OfcAddr1 VARCHAR(30) NULL
	 , OfcAddr2 VARCHAR(30) NULL
	 , OfcCity VARCHAR(30) NULL
	 , OfcState VARCHAR(2) NULL
	 , OfcZip VARCHAR(12) NULL
	 , OfcPhone VARCHAR(20) NULL
	 , OfcDefault NUMBER(5, 0) NULL
	 , OfcClaimMask VARCHAR(50) NULL
	 , OfcTinMask VARCHAR(50) NULL
	 , Version NUMBER(5, 0) NULL
	 , OfcEdits NUMBER(10, 0) NULL
	 , OfcCOAEnabled NUMBER(5, 0) NULL
	 , CTGEnabled NUMBER(5, 0) NULL
	 , LastChangedOn DATETIME NULL
	 , AllowMultiCoverage BOOLEAN NULL
);

