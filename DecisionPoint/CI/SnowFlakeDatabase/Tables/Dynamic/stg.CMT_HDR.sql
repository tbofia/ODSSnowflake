CREATE OR REPLACE TABLE stg.CMT_HDR (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , CMT_HDR_IDNo NUMBER(10, 0) NOT NULL
	 , CmtIDNo NUMBER(10, 0) NULL
	 , PvdIDNo NUMBER(10, 0) NULL
	 , LastChangedOn DATETIME NULL
);

