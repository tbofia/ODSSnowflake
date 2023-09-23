CREATE TABLE IF NOT EXISTS src.VPNBillableFlags (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , SOJ VARCHAR(2) NOT NULL
	 , NetworkID NUMBER(10, 0) NOT NULL
	 , ActivityFlag VARCHAR(2) NOT NULL
	 , Billable VARCHAR(1) NULL
	 , CompanyCode VARCHAR(10) NOT NULL
	 , CompanyName VARCHAR(100) NULL
);

