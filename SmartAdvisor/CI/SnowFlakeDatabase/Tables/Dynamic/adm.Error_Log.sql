CREATE TABLE IF NOT EXISTS adm.Error_Log
(
	Object_Audit_Key INT NOT NULL COMMENT 'Key of object that generated error Ex. ProcessAuditId, will be -1 if error is at Master procedure level',
	Event_Id  INT NOT NULL COMMENT 'Event Id from Event table',
	Error_Message STRING NULL COMMENT 'Error message associated with event Ex. if primary key violation then this will be the keys in violation',
	Log_Date  DATETIME NOT NULL COMMENT 'When the error occured'

);

