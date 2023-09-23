CREATE TABLE IF NOT EXISTS rpt.LoadStatus (
		   JobRunId Number(10, 0) NOT NULL
		 , JobName varchar(8000) NOT NULL
		 , Status varchar(5) NOT NULL
		 , NoOfCustomers Number(10, 0) NULL
		 , StartDate timestamp_Ntz(3) NOT NULL
		 , EndDate timestamp_Ntz(3) NULL
);
