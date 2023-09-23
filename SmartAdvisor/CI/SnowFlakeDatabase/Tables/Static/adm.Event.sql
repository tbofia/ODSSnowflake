CREATE OR REPLACE TABLE  adm.Event
(
	Event_Id INT NOT NULL COMMENT 'Event Id 1-9 related to Process Error Logs, 10-19 related to Errors from Tasks, 20-29 related to any Errors from the Master Stored Procedure.',
	Event_Type VARCHAR(100),
	Event_Description  VARCHAR(250)

);



