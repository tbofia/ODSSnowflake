
IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'adm.Rep_DropDatabaseSnapshot') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE adm.Rep_DropDatabaseSnapshot
GO 


CREATE PROCEDURE adm.Rep_DropDatabaseSnapshot (
@DBSnapshotName VARCHAR(100)  )
AS
BEGIN
-- DECLARE  @DBSnapshotName VARCHAR(100) = ''
    SET NOCOUNT ON

	IF EXISTS(SELECT  1
                    FROM    sys.databases
                    WHERE   name = @DBSnapshotName)
    EXEC ('DROP DATABASE ' + @DBSnapshotName + ';');

END

GO


