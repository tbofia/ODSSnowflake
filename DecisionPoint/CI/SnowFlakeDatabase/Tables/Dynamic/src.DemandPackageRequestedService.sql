CREATE TABLE IF NOT EXISTS src.DemandPackageRequestedService (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , DemandPackageRequestedServiceId NUMBER(10, 0) NOT NULL
	 , DemandPackageId NUMBER(10, 0) NULL
	 , ReviewRequestOptions VARCHAR NULL
);

