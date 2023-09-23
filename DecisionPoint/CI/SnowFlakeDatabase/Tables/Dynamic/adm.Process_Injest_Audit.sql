CREATE TABLE IF NOT EXISTS ADM.PROCESS_INJEST_AUDIT 
(
	Process_Audit_Id INT NOT NULL IDENTITY(1,1) COMMENT 'Identity key generated when process starts',
	Posting_Group_Audit_Id INT NOT NULL COMMENT 'Foreign key which is used to refer to ADM.POSTING_GROUP_INJEST_AUDIT',						              
	Process_Id INT NOT NULL COMMENT 'The identity value in adm.process for the table we are loading',							                  
	Status CHAR(2) NOT NULL COMMENT 'Load Status (S=Start,FI=Finished,Er=Error)',	
	Total_Records_In_Source BIGINT NULL COMMENT 'Total Number of records reported by source system in countrol file',
	Total_Number_Of_Files INT NULL COMMENT 'Total number of files',					 
	Total_Records_Extracted INT NULL COMMENT 'Total number of records extracted. Sum from all files.',				
	Total_Records_Loaded INT NULL COMMENT 'Total number of records loaded to the target',					
	Total_Records_Updated INT NULL COMMENT 'Total number of records updated. Sum from all files.',				
	Load_Date  DATETIME NULL COMMENT 'When Last file was loaded',						
	Update_Date DATETIME NULL COMMENT 'When records updated',					
	Create_Date DATETIME NOT NULL COMMENT 'When First File is started',					
	Last_Change_Date DATETIME NOT NULL COMMENT 'Last Change of status ( last milesstone)',
	PRIMARY KEY(Process_Audit_Id)
);

-- ADD NEW COLUMN Total_Records_In_Source
CALL ADM.ALTER_COLUMN(
    'ADD', 
    'ADM', 
    'PROCESS_INJEST_AUDIT', 
    'Total_Records_In_Source',
    'BIGINT', 
    'NULL',
    'Total Number of records reported by source system in countrol file'
);
