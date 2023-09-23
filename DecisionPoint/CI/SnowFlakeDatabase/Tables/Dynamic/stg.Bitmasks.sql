CREATE OR REPLACE TABLE stg.Bitmasks (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , TableProgramUsed VARCHAR(50) NOT NULL
	 , AttributeUsed VARCHAR(50) NOT NULL
	 , Decimal NUMBER(19, 0) NOT NULL
	 , ConstantName VARCHAR(50) NULL
	 , Bit VARCHAR(50) NULL
	 , Hex VARCHAR(20) NULL
	 , Description VARCHAR(250) NULL
);

