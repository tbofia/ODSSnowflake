CREATE TABLE IF NOT EXISTS src.UDFLibrary (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , UDFIdNo NUMBER(10, 0) NOT NULL
	 , UDFName VARCHAR(50) NULL
	 , ScreenType NUMBER(5, 0) NULL
	 , UDFDescription VARCHAR(1000) NULL
	 , DataFormat NUMBER(5, 0) NULL
	 , RequiredField NUMBER(5, 0) NULL
	 , ReadOnly NUMBER(5, 0) NULL
	 , Invisible NUMBER(5, 0) NULL
	 , TextMaxLength NUMBER(5, 0) NULL
	 , TextMask VARCHAR(50) NULL
	 , TextEnforceLength NUMBER(5, 0) NULL
	 , RestrictRange NUMBER(5, 0) NULL
	 , MinValDecimal FLOAT(24) NULL
	 , MaxValDecimal FLOAT(24) NULL
	 , MinValDate DATETIME NULL
	 , MaxValDate DATETIME NULL
	 , ListAllowMultiple NUMBER(5, 0) NULL
	 , DefaultValueText VARCHAR(100) NULL
	 , DefaultValueDecimal FLOAT(24) NULL
	 , DefaultValueDate DATETIME NULL
	 , UseDefault NUMBER(5, 0) NULL
	 , ReqOnSubmit NUMBER(5, 0) NULL
	 , IncludeDateButton BOOLEAN NULL
);

