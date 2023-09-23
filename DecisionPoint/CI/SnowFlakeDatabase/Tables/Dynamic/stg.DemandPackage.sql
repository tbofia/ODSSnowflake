CREATE OR REPLACE TABLE stg.DemandPackage (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , DemandPackageId NUMBER(10, 0) NOT NULL
	 , DemandClaimantId NUMBER(10, 0) NULL
	 , RequestedByUserName VARCHAR(15) NULL
	 , DateTimeReceived TIMESTAMP_LTZ(7) NULL
	 , CorrelationId VARCHAR(36) NULL
	 , PageCount NUMBER(5, 0) NULL
);

