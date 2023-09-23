CREATE OR REPLACE TABLE adm.Customer (
	  Customer_Id NUMBER(10, 0) NOT NULL
	, Customer_Name VARCHAR(100) NOT NULL
	, Customer_Database VARCHAR(255) NOT NULL
	, Ebt_CompCode VARCHAR(2) NULL
	, Is_Active BOOLEAN NOT NULL
	, Is_Self_Hosted NUMBER(10, 0) NOT NULL
	, Is_From_Decision_Point NUMBER(10, 0) NOT NULL
	, Is_Loaded_Daily NUMBER(10, 0) NOT NULL
	, Use_For_Reporting NUMBER(10, 0) NOT NULL
	, Include_In_Industry NUMBER(10, 0) NOT NULL
);

