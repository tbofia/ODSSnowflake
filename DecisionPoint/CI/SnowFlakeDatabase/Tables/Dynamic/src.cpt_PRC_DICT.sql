CREATE TABLE IF NOT EXISTS src.cpt_PRC_DICT (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , PRC_CD VARCHAR(7) NOT NULL
	 , StartDate DATETIME NOT NULL
	 , EndDate DATETIME NULL
	 , PRC_DESC VARCHAR NULL
	 , Flags NUMBER(10, 0) NULL
	 , Vague VARCHAR(1) NULL
	 , PerVisit NUMBER(5, 0) NULL
	 , PerClaimant NUMBER(5, 0) NULL
	 , PerProvider NUMBER(5, 0) NULL
	 , BodyFlags NUMBER(10, 0) NULL
	 , Colossus NUMBER(5, 0) NULL
	 , CMS_Status VARCHAR(1) NULL
	 , DrugFlag NUMBER(5, 0) NULL
	 , CurativeFlag NUMBER(5, 0) NULL
	 , ExclPolicyLimit NUMBER(5, 0) NULL
	 , SpecNetFlag NUMBER(5, 0) NULL
);

