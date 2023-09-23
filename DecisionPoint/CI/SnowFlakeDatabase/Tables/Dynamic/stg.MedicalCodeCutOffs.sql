CREATE OR REPLACE TABLE stg.MedicalCodeCutOffs (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , CodeTypeID NUMBER(10, 0) NOT NULL
	 , CodeType VARCHAR(50) NULL
	 , Code VARCHAR(50) NOT NULL
	 , FormType VARCHAR(10) NOT NULL
	 , MaxChargedPerUnit FLOAT(53) NULL
	 , MaxUnitsPerEncounter FLOAT(53) NULL
);

