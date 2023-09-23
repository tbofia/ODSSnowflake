CREATE OR REPLACE TABLE stg.Icd10DiagnosisVersion (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , DiagnosisCode VARCHAR(8) NOT NULL
	 , StartDate DATETIME NOT NULL
	 , EndDate DATETIME NULL
	 , NonSpecific BOOLEAN NULL
	 , Traumatic BOOLEAN NULL
	 , Duration NUMBER(5, 0) NULL
	 , Description VARCHAR NULL
	 , DiagnosisFamilyId NUMBER(3, 0) NULL
	 , TotalCharactersRequired NUMBER(3, 0) NULL
	 , PlaceholderRequired BOOLEAN NULL
);

