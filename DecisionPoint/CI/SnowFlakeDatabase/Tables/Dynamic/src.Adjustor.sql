CREATE TABLE IF NOT EXISTS src.Adjustor (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , lAdjIdNo NUMBER(10, 0) NOT NULL
	 , IDNumber VARCHAR(15) NULL
	 , Lastname VARCHAR(30) NULL
	 , FirstName VARCHAR(30) NULL
	 , Address1 VARCHAR(30) NULL
	 , Address2 VARCHAR(30) NULL
	 , City VARCHAR(30) NULL
	 , State VARCHAR(2) NULL
	 , ZipCode VARCHAR(12) NULL
	 , Phone VARCHAR(25) NULL
	 , Fax VARCHAR(25) NULL
	 , Office VARCHAR(120) NULL
	 , EMail VARCHAR(60) NULL
	 , InUse VARCHAR(100) NULL
	 , OfficeIdNo NUMBER(10, 0) NULL
	 , UserId NUMBER(10, 0) NULL
	 , CreateDate DATETIME NULL
	 , LastChangedOn DATETIME NULL
);

