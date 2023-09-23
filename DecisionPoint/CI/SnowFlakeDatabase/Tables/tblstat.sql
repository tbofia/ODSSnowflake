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


