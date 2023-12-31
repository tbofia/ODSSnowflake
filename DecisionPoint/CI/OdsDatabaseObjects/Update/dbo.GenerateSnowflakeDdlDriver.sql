
IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'dbo.GenerateSnowflakeDdlDriver') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE dbo.GenerateSnowflakeDdlDriver
GO 


CREATE PROCEDURE dbo.GenerateSnowflakeDdlDriver (
@SourceDatabaseName VARCHAR(100),
@SnapshotServer VARCHAR(255) = null,
@OutputPath VARCHAR(MAX)='\\user01nas\usrtmp\VLPA\Snowflake\ddl',
@Debug INT = 0
)
AS
BEGIN
SET NOCOUNT ON
DECLARE @dynSQl VARCHAR(max) = ''

--DECLARE @SourceDatabaseName varchar(100) ='Acsods_Snowflake',
-- @SnapshotServer varchar(255) = 'QSQL104NTV',
-- @OutputPath varchar(MAX) ='\\user01nas\usrtmp\VLPA\Snowflake\ddl',
-- @Debug INT = 0

 

DECLARE @numberOfRecords INT
IF OBJECT_ID('tempdb..#procId') IS NOT NULL
DROP TABLE #procId
CREATE TABLE #procId(id INT IDENTITY,processId INT)
DECLARE @SqlQuery VARCHAR(MAX)

SET @SqlQuery='
INSERT INTO #procId (processId)
SELECT ProcessId FROM '+@SourceDatabaseName+'.adm.Process where TargetSchemaName <> ''rpt''
'

EXEC(@SqlQuery)

SET @numberOfRecords = (SELECT COUNT(*) from #procId)

DECLARE @counter INT= 1,@ProcessId INT
WHILE @counter<=@numberOfRecords
BEGIN
SELECT @ProcessId=ProcessId FROM #procId WHERE id=@counter
BEGIN TRY
	EXEC GenerateSnowflakeDdlStgSrcTable @SourceDatabaseName,@ProcessId,@SnapshotServer,@OutputPath,1,@Debug
	EXEC GenerateSnowflakeDdlStgSrcTable @SourceDatabaseName,@ProcessId,@SnapshotServer,@OutputPath,0,@Debug
END TRY
BEGIN CATCH
	PRINT 'Could not create table...Make sure table exists.'
	PRINT 'ERROR at ProcessID'+CAST(@ProcessId AS VARCHAR)
END CATCH


SET @counter= @counter + 1
END 

PRINT('No of tables generated : ')
PRINT((@counter-1)*2)





SET NOCOUNT OFF
 END


 GO

