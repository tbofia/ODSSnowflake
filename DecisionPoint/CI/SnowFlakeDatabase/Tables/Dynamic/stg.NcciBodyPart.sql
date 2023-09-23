CREATE OR REPLACE TABLE stg.NcciBodyPart (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , NcciBodyPartId NUMBER(3, 0) NOT NULL
	 , Description VARCHAR(100) NULL
	 , NarrativeInformation VARCHAR NULL
);

