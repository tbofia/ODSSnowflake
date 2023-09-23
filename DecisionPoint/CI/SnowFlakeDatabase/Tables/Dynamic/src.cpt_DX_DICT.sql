CREATE TABLE IF NOT EXISTS src.cpt_DX_DICT (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , ICD9 VARCHAR(6) NOT NULL
	 , StartDate DATETIME NOT NULL
	 , EndDate DATETIME NULL
	 , Flags NUMBER(5, 0) NULL
	 , NonSpecific VARCHAR(1) NULL
	 , AdditionalDigits VARCHAR(1) NULL
	 , Traumatic VARCHAR(1) NULL
	 , DX_DESC VARCHAR NULL
	 , Duration NUMBER(5, 0) NULL
	 , Colossus NUMBER(5, 0) NULL
	 , DiagnosisFamilyId NUMBER(3, 0) NULL
);

