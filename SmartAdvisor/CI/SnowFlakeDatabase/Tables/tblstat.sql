CREATE OR REPLACE TABLE adm.Customer (
	  CUSTOMER_ID NUMBER(10, 0) NOT NULL
	, CUSTOMER_NAME VARCHAR(100) NOT NULL
	, SITE_CODE VARCHAR(25) NOT NULL
	, CUSTOMER_DATABASE VARCHAR(255) NOT NULL
	, SERVER_NAME VARCHAR(255) NULL
	, IS_ACTIVE BOOLEAN NOT NULL
	, IS_SELF_HOSTED NUMBER(10, 0) NOT NULL
	, IS_FROM_SMART_ADVISOR NUMBER(10, 0) NOT NULL
	, IS_LOADED_DAILY NUMBER(10, 0) NOT NULL
	, USE_FOR_REPORTING NUMBER(10, 0) NOT NULL
	, INCLUDE_IN_INDUSTRY NUMBER(10, 0) NOT NULL
);

CREATE OR REPLACE TABLE adm.Data_Extract_Type (
	  Data_Extract_Type_Id NUMBER(3, 0) NOT NULL
	, Data_Extract_Type_Name VARCHAR(50) NOT NULL
	, Data_Extract_Type_Code VARCHAR(4) NOT NULL
	, Is_Full_Extract BOOLEAN NOT NULL
);


CREATE OR REPLACE TABLE  adm.Event
(
	Event_Id INT NOT NULL COMMENT 'Event Id 1-9 related to Process Error Logs, 10-19 related to Errors from Tasks, 20-29 related to any Errors from the Master Stored Procedure.',
	Event_Type VARCHAR(100),
	Event_Description  VARCHAR(250)

);



CREATE OR REPLACE TABLE adm.Posting_Group (
	  Posting_Group_Id NUMBER(3, 0) NOT NULL
	, Posting_Group_Name VARCHAR(50) NOT NULL
);


CREATE OR REPLACE TABLE adm.Process (
	   Process_Id NUMBER(5, 0) NOT NULL
	 , Process_Description VARCHAR(100) NOT NULL
	 , Target_Schema_Name VARCHAR(10) NOT NULL
	 , Target_Table_Name VARCHAR(100) NOT NULL
	 , Product_Key VARCHAR(100) NOT NULL
	 , Target_Platform VARCHAR(50) NOT NULL
	 , File_Column_Delimiter VARCHAR(2) NOT NULL
	 , Posting_Group_Id NUMBER(10, 0) NOT NULL
	 , Load_Group NUMBER(10, 0) NOT NULL
	 , Hash_Function_Type NUMBER(10, 0) NOT NULL
	 , Is_Active BOOLEAN NOT NULL
	 , Is_Snapshot BOOLEAN NOT NULL
);

CREATE OR REPLACE TABLE adm.Process_Format_Files(
	 Process_Id INT NOT NULL
	,Format_File_Name VARCHAR(100) NOT NULL
	,Create_Date DATETIME NOT NULL
);

CREATE OR REPLACE TABLE adm.Process_Primary_Key(
	 Process_Id INT NOT NULL
	,Primary_Key_Column VARCHAR(128) NOT NULL
	,Create_Date DATETIME NOT NULL
);

CREATE OR REPLACE TABLE adm.Product (
	   Product_Key VARCHAR(100) NOT NULL
	 , Name VARCHAR(100) NOT NULL
	 , Schema_Name VARCHAR(10) NOT NULL
);


CREATE OR REPLACE TABLE adm.Status_Code (
	   Status VARCHAR(2) NOT NULL
	 , Short_Description VARCHAR(100) NOT NULL
	 , Long_Description VARCHAR(8000) NOT NULL
);


