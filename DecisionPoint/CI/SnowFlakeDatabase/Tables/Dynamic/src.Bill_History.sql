CREATE TABLE IF NOT EXISTS src.Bill_History (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , BillIdNo NUMBER(10, 0) NOT NULL
	 , SeqNo NUMBER(10, 0) NOT NULL
	 , DateCommitted DATETIME NULL
	 , AmtCommitted NUMBER(19, 4) NULL
	 , UserId VARCHAR(15) NULL
	 , AmtCoPay NUMBER(19, 4) NULL
	 , AmtDeductible NUMBER(19, 4) NULL
	 , Flags NUMBER(10, 0) NULL
	 , AmtSalesTax NUMBER(19, 4) NULL
	 , AmtOtherTax NUMBER(19, 4) NULL
	 , DeductibleOverride BOOLEAN NULL
	 , PricingState VARCHAR(2) NULL
	 , ApportionmentPercentage NUMBER(5, 2) NULL
	 , FloridaDeductibleRuleEligible BOOLEAN NULL
);

