CREATE OR REPLACE TABLE stg.Vpn_Billing_History (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , Customer VARCHAR(50) NULL
	 , TransactionID NUMBER(19, 0) NOT NULL
	 , Period DATETIME NOT NULL
	 , ActivityFlag VARCHAR(1) NULL
	 , BillableFlag VARCHAR(1) NULL
	 , Void VARCHAR(4) NULL
	 , CreditType VARCHAR(10) NULL
	 , Network VARCHAR(50) NULL
	 , BillIdNo NUMBER(10, 0) NULL
	 , Line_No NUMBER(5, 0) NULL
	 , TransactionDate DATETIME NULL
	 , RepriceDate DATETIME NULL
	 , ClaimNo VARCHAR(50) NULL
	 , ProviderCharges NUMBER(19, 4) NULL
	 , DPAllowed NUMBER(19, 4) NULL
	 , VPNAllowed NUMBER(19, 4) NULL
	 , Savings NUMBER(19, 4) NULL
	 , Credits NUMBER(19, 4) NULL
	 , NetSavings NUMBER(19, 4) NULL
	 , SOJ VARCHAR(2) NULL
	 , seqno NUMBER(10, 0) NULL
	 , CompanyCode VARCHAR(10) NULL
	 , VpnId NUMBER(5, 0) NULL
	 , ProcessFlag NUMBER(5, 0) NULL
	 , SK NUMBER(10, 0) NULL
	 , DATABASE_NAME VARCHAR(100) NULL
	 , SubmittedToFinance BOOLEAN NULL
	 , IsInitialLoad BOOLEAN NULL
	 , VpnBillingCategoryCode VARCHAR(1) NULL
);

