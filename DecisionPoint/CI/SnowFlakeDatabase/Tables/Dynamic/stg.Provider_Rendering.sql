CREATE OR REPLACE TABLE stg.Provider_Rendering (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , PvdIDNo NUMBER(10, 0) NOT NULL
	 , RenderingAddr1 VARCHAR(55) NULL
	 , RenderingAddr2 VARCHAR(55) NULL
	 , RenderingCity VARCHAR(30) NULL
	 , RenderingState VARCHAR(2) NULL
	 , RenderingZip VARCHAR(12) NULL
);

