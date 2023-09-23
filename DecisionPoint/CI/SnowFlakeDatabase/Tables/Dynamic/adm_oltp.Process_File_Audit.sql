CREATE TABLE IF NOT EXISTS ADM_OLTP.PROCESS_FILE_AUDIT 
(
	Process_File_Audit_Id INT NOT NULL IDENTITY(1,1) COMMENT 'Identity key',
	Process_Audit_Id  INT NOT NULL COMMENT 'Foreign key which is used to refer to ADM.PROCESS_INJEST_AUDIT',							
	File_Number  INT NOT NULL COMMENT 'From Control file',					
	Status  CHAR(2) NOT NULL COMMENT 'Load Status (S=Start,FI=Finished,Er=Error)',							
	Total_Records_In_File INT NULL COMMENT 'Total number of records in the file',				
	Total_Records_Extracted INT NULL COMMENT 'Total number of records extracted to the table',					
	Total_Records_With_Errors INT NULL COMMENT 'Total number of records with errors',		
	Load_Date DATETIME NULL COMMENT 'When file load starts',						
	Create_Date DATETIME NOT NULL COMMENT 'When file load starts',				
	Last_Change_Date DATETIME NOT NULL COMMENT 'last status update',
	PRIMARY KEY(Process_File_Audit_Id)
);