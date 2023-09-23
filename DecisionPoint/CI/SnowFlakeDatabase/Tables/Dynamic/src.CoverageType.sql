-- rename table to coveragetype
CALL ADM.DDL_TABLE('RENAME', 'SRC', 'LKP_CVTYPE', 'COVERAGETYPE');

CREATE TABLE IF NOT EXISTS src.CoverageType (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , LongName VARCHAR(30) NULL
	 , ShortName VARCHAR(2) NOT NULL
	 , CbreCoverageTypeCode VARCHAR(2) NULL
	 , CoverageTypeCategoryCode VARCHAR(4) NULL
	 , PricingMethodId NUMBER(3, 0) NULL
);

-- Drop all obsolete objects after renaming
CALL ADM.DROP_OBJECT('DROP','TABLE','SRC','LKP_CVTYPE');
CALL ADM.DROP_OBJECT('DROP','VIEW','DBO','LKP_CVTYPE');
CALL ADM.DROP_OBJECT('DROP','FUNCTION','DBO','IF_LKP_CVTYPE (NUMBER)');
