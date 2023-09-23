CREATE TABLE IF NOT EXISTS src.VPNActivityFlag (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , Activity_Flag VARCHAR(1) NOT NULL
	 , AF_Description VARCHAR(50) NULL
	 , AF_ShortDesc VARCHAR(50) NULL
	 , Data_Source VARCHAR(5) NULL
	 , Default_Billable BOOLEAN NULL
	 , Credit BOOLEAN NULL
);

