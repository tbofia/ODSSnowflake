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

