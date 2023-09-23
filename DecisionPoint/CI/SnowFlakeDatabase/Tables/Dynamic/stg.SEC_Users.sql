CREATE OR REPLACE TABLE stg.SEC_Users (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , UserId NUMBER(10, 0) NOT NULL
	 , LoginName VARCHAR(15) NULL
	 , Password VARCHAR(30) NULL
	 , CreatedBy VARCHAR(50) NULL
	 , CreatedDate DATETIME NULL
	 , UserStatus NUMBER(10, 0) NULL
	 , FirstName VARCHAR(20) NULL
	 , LastName VARCHAR(20) NULL
	 , AccountLocked NUMBER(5, 0) NULL
	 , LockedCounter NUMBER(5, 0) NULL
	 , PasswordCreateDate DATETIME NULL
	 , PasswordCaseFlag NUMBER(5, 0) NULL
	 , ePassword VARCHAR(30) NULL
	 , CurrentSettings VARCHAR NULL
);

