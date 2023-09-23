CREATE TABLE IF NOT EXISTS src.CLAIMS (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , ClaimIDNo NUMBER(10, 0) NOT NULL
	 , ClaimNo VARCHAR NULL
	 , DateLoss DATETIME NULL
	 , CV_Code VARCHAR(2) NULL
	 , DiaryIndex NUMBER(10, 0) NULL
	 , LastSaved DATETIME NULL
	 , PolicyNumber VARCHAR(50) NULL
	 , PolicyHoldersName VARCHAR(30) NULL
	 , PaidDeductible NUMBER(19, 4) NULL
	 , Status VARCHAR(1) NULL
	 , InUse VARCHAR(100) NULL
	 , CompanyID NUMBER(10, 0) NULL
	 , OfficeIndex NUMBER(10, 0) NULL
	 , AdjIdNo NUMBER(10, 0) NULL
	 , PaidCoPay NUMBER(19, 4) NULL
	 , AssignedUser VARCHAR(15) NULL
	 , Privatized NUMBER(5, 0) NULL
	 , PolicyEffDate DATETIME NULL
	 , Deductible NUMBER(19, 4) NULL
	 , LossState VARCHAR(2) NULL
	 , AssignedGroup NUMBER(10, 0) NULL
	 , CreateDate DATETIME NULL
	 , LastChangedOn DATETIME NULL
	 , AllowMultiCoverage BOOLEAN NULL
);

