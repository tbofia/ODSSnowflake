CREATE TABLE IF NOT EXISTS ADM_OLTP.PROCESS_AUDIT 
(
	Process_Audit_Id INT NOT NULL IDENTITY(1,1) COMMENT 'Primary key.Identity.',
	Posting_Group_Audit_Id INT NOT NULL COMMENT 'FK to Posting_Group_Audit',						              
	Process_Id INT NOT NULL COMMENT 'FK to Process',							                  
	Status CHAR(2)  NOT NULL COMMENT 'Status of load.  When FI, load is complete.',	
	Total_Records_In_Source BIGINT NULL COMMENT 'Total Number of records reported by source system in control file',
	Total_Records_In_Target INT NULL COMMENT 'Total Number of records in the Ods',				
	Total_Deleted_Records INT NULL COMMENT 'Total Number of records delete from the source',				
	Control_Row_Count INT NULL COMMENT 'Total Number of records reported by source for each Posting group',
	Extract_Row_Count INT NULL COMMENT 'Number of records loaded into stg table (staging)',
    Update_Row_Count INT NULL COMMENT 'Number of records updated in stg table (staging)',
    Load_Row_Count INT  NULL  COMMENT 'Number of records loaaded into src table',		
	Extract_Date  DATETIME NULL COMMENT 'Date and time data was loaded into stg table',						
	Last_Update_Date DATETIME NULL COMMENT 'Data and time record was last inserted or updated',
	Load_Date	DATETIME NULL COMMENT 'Date and time data was loaded into src table',
	Create_Date DATETIME NOT NULL COMMENT 'Date and time record was created',				
	Last_Change_Date DATETIME NOT NULL COMMENT 'Data and time record was last inserted or updated',
	PRIMARY KEY(Process_Audit_Id)
);
