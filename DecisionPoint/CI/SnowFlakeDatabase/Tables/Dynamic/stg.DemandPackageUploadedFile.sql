CREATE OR REPLACE TABLE stg.DemandPackageUploadedFile (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , DemandPackageUploadedFileId NUMBER(10, 0) NOT NULL
	 , DemandPackageId NUMBER(10, 0) NULL
	 , FileName VARCHAR(255) NULL
	 , Size NUMBER(10, 0) NULL
	 , DocStoreId VARCHAR(50) NULL
);

