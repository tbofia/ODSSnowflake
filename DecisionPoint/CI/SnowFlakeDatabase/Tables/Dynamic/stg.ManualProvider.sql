CREATE OR REPLACE TABLE stg.ManualProvider (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , ManualProviderId NUMBER(10, 0) NOT NULL
	 , TIN VARCHAR(15) NULL
	 , LastName VARCHAR(60) NULL
	 , FirstName VARCHAR(35) NULL
	 , GroupName VARCHAR(60) NULL
	 , Address1 VARCHAR(55) NULL
	 , Address2 VARCHAR(55) NULL
	 , City VARCHAR(30) NULL
	 , State VARCHAR(2) NULL
	 , Zip VARCHAR(12) NULL
);

