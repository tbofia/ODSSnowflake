CREATE OR REPLACE TABLE stg.BIReportAdjustmentCategoryMapping (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , BIReportAdjustmentCategoryId NUMBER(10, 0) NOT NULL
	 , Adjustment360SubCategoryId NUMBER(10, 0) NOT NULL
);

