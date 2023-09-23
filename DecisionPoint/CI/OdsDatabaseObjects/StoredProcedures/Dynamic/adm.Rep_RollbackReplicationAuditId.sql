
IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'adm.Rep_RollbackReplicationAuditId') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE adm.Rep_RollbackReplicationAuditId
GO 

CREATE PROCEDURE adm.Rep_RollbackReplicationAuditId
(
@ReplicationAuditId INT
)
AS
BEGIN
DECLARE @ProcessReplicationAuditId INT

IF NOT EXISTS (SELECT 1 FROM adm.PostingGroupReplicationAudit WHERE ReplicationAuditId = @ReplicationAuditId)
RAISERROR ('ReplicationAudiId does not exists. Aborting.', 16, 1) WITH LOG
	ELSE
	BEGIN
	-- Get the associated ProcessReplicationAuditId for the provided ReplicationAuditId
	SELECT @ProcessReplicationAuditId = MIN(ProcessReplicationAuditId) FROM adm.ProcessReplicationAudit WHERE ReplicationAuditId = @ReplicationAuditId
	-- Deleting rows from ProcessFileReplicationAudit
	DELETE FROM adm.ProcessFileReplicationAudit WHERE ProcessReplicationAuditId >= @ProcessReplicationAuditId
	-- Deleting rows from ProcessReplicationAudit
	DELETE FROM adm.ProcessReplicationAudit WHERE ReplicationAuditId >= @ReplicationAuditId
	-- Deleting rows from PostingGroupReplicationAudit
	DELETE FROM adm.PostingGroupReplicationAudit WHERE ReplicationAuditId >= @ReplicationAuditId
	END
END

GO