CREATE TABLE IF NOT EXISTS rpt.ProcessAudit (
	  ProcessAuditId NUMBER(10, 0) NOT NULL
	, PostingGroupAuditId NUMBER(10, 0) NOT NULL
	, ProcessId NUMBER(5, 0) NOT NULL
	, Status VARCHAR(2) NOT NULL
	, TotalRecordsInSource NUMBER(19, 0) NULL
	, TotalRecordsInTarget NUMBER(19, 0) NULL
	, TotalDeletedRecords NUMBER(10, 0) NULL
	, ControlRowCount NUMBER(10, 0) NULL
	, ExtractRowCount NUMBER(10, 0) NULL
	, UpdateRowCount NUMBER(10, 0) NULL
	, LoadRowCount NUMBER(10, 0) NULL
	, ExtractDate DATETIME NULL
	, LastUpdateDate DATETIME NULL
	, LoadDate DATETIME NULL
	, CreateDate DATETIME NOT NULL
	, LastChangeDate DATETIME NOT NULL
);

