CREATE OR REPLACE FUNCTION adm.Mnt_GetPostingGroupAuditIdAsOfSnapshotDate (
OdsCustomerId INT,
SnapshotDate DATETIME)
RETURNS INT
AS
$$

SELECT MAX(PostingGroupAuditId)
FROM rpt.PostingGroupAudit pga
WHERE pga.CustomerId = CASE WHEN IFNULL(OdsCustomerId,0) = 0 THEN pga.CustomerId ELSE OdsCustomerId END
AND pga.SnapshotCreateDate <= IFNULL(SnapshotDate,Current_timestamp()::timestampNTZ) 
AND Status = 'FI'
$$;


