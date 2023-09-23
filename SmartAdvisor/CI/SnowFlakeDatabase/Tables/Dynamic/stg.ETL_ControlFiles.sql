
CREATE OR REPLACE TABLE stg.ETL_ControlFiles
(
	Control_File_Name VARCHAR(255) NOT NULL,		
	Product  VARCHAR(25)NOT NULL,				
	Load_Type VARCHAR(25)NOT NULL,				
	Ods_Cutoff_Posting_Group_Audit_Id INT NOT NULL,	
	Snapshot_Date Datetime NOT NULL,				
	Target_Table_Name VARCHAR(100) NOT NULL,		
	Total_Files  INT NULL,						
	File_Number INT NULL,							
	File_Name VARCHAR(255)NOT NULL,				
	Total_Row_Count INT NULL,						
	Total_Records_In_Source INT NULL,				
	Current_Replication_ID  INT NULL,				
	Previous_Replication_ID  INT NULL,				
	Ods_Version VARCHAR(20) NOT NULL,
	File_Size NUMBER(10,3) NULL
);

COMMENT ON COLUMN stg.ETL_ControlFiles.Control_File_Name IS 'Control File Name.';
COMMENT ON COLUMN stg.ETL_ControlFiles.Product  IS'Data Source Name. Sample Values: ACS, WCS etc.';
COMMENT ON COLUMN stg.ETL_ControlFiles.Load_Type IS'The type of load. 0 is for full load, 1 is for incremental load.';
COMMENT ON COLUMN stg.ETL_ControlFiles.Ods_Cutoff_Posting_Group_Audit_Id IS'Last ods posting group coming from ods.';
COMMENT ON COLUMN stg.ETL_ControlFiles.Snapshot_Date    IS'Snapshot Date of load (Create date of control file).';
COMMENT ON COLUMN stg.ETL_ControlFiles.Target_Table_Name IS'Target Table Name (without schema).';
COMMENT ON COLUMN stg.ETL_ControlFiles.Total_Files IS'Total number of files for the target table.';
COMMENT ON COLUMN stg.ETL_ControlFiles.File_Number IS'The sequence of the file.';
COMMENT ON COLUMN stg.ETL_ControlFiles.File_Name   IS'The file name.';
COMMENT ON COLUMN stg.ETL_ControlFiles.Total_Row_Count IS'Total number of rows in the file.';
COMMENT ON COLUMN stg.ETL_ControlFiles.Total_Records_In_Source IS'Total number of rows extracted from the source on ODS side.';
COMMENT ON COLUMN stg.ETL_ControlFiles.Current_Replication_ID IS'Identity value generated per extraction on ODS side to detect gaps between consecutive posting groups.';
COMMENT ON COLUMN stg.ETL_ControlFiles.Previous_Replication_ID IS'Identity value of the previous extraction on ODS side.';
COMMENT ON COLUMN stg.ETL_ControlFiles.Ods_Version   IS'Current Ods Version';
COMMENT ON COLUMN stg.ETL_ControlFiles.File_Size   IS'The file size in MB';

