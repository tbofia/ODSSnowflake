CREATE OR REPLACE TABLE stg.BIReportAdjustmentCategory (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , BIReportAdjustmentCategoryId NUMBER(10, 0) NOT NULL
	 , Name VARCHAR(50) NULL
	 , Description VARCHAR(500) NULL
	 , DisplayPriority NUMBER(10, 0) NULL
);

