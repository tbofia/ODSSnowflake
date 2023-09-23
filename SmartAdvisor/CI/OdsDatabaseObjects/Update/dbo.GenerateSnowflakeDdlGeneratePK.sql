IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'dbo.GenerateSnowflakeDdlGeneratePK') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE dbo.GenerateSnowflakeDdlGeneratePK
GO 

CREATE PROCEDURE dbo.GenerateSnowflakeDdlGeneratePK (
@SourceDatabaseName VARCHAR(255),
@SnapshotServer VARCHAR(512) = null,
@OutputPath VARCHAR(MAX),
@Debug INT = 0
)
AS
BEGIN


--DECLARE
--@SourceDatabaseName VARCHAR(100) ='acsods_snowflake',
--@Debug INT = 0,
--@SnapshotServer varchar(100),
--@OutputPath VARCHAR(MAX) = '\\user01nas\usrtmp\VLPA\Snowflake\PK\PK.sql';



DECLARE @numberOfRecords INT
DECLARE  @SQLQuery NVARCHAR(MAX),@TableText VARCHAR(MAX) = ''

IF OBJECT_ID('tempdb..#procId') IS NOT NULL
DROP TABLE #procId
CREATE TABLE #procId(id INT IDENTITY,processId INT)


SET @SqlQuery='
INSERT INTO #procId (processId)
SELECT ProcessId FROM '+@SourceDatabaseName+'.adm.Process
'

exec(@SqlQuery)

 
SET @numberOfRecords = (select count(*) from #procId)

DECLARE @counter INT= 1,@ProcessId INT
WHILE @counter<=@numberOfRecords
BEGIN
SELECT @ProcessId=ProcessId FROM #procId WHERE id=@counter
BEGIN TRY





IF @SnapshotServer is null
BEGIN
 SET @SnapshotServer = @@Servername
END


IF OBJECT_ID('tempdb..##snddl') is not null  DROP TABLE ##snddl
	CREATE TABLE ##snddl (ddl text)


DECLARE
@SchemaName VARCHAR(100),
@TableName VARCHAR(MAX) ,
@GetQuery NVARCHAR(MAX)



SET @GetQuery ='SELECT @SchemaName=TargetSchemaName FROM '+@SourceDatabaseName+'.adm.process where ProcessId=' + CAST(@ProcessId AS VARCHAR)
EXEC sp_executeSQL @GetQuery,N'@SchemaName VARCHAR(16) OUTPUT',@SchemaName OUTPUT



SET @GetQuery ='SELECT @TableName=TargetTableName FROM '+@SourceDatabaseName+'.adm.process where ProcessId=' + CAST(@ProcessId AS VARCHAR)
EXEC sp_executeSQL @GetQuery,N'@TableName VARCHAR(255) OUTPUT',@TableName OUTPUT




--ADD Primary key constraint


DECLARE @primaryConstraint VARCHAR(MAX),
		@PKSQLQuery NVARCHAR(MAX)

SET @TableText+= 
'ALTER TABLE ' + @SchemaName + '.' + @TableName + ' ADD PRIMARY KEY ('


SET @PKSQLQuery = '
SET @primaryConstraint=''''
select @primaryConstraint += case when ORDINAL_POSITION=1 then UPPER(COLUMN_NAME)
else '',''+UPPER(COLUMN_NAME)
end
FROM '+@SourceDatabaseName+'.INFORMATION_SCHEMA.TABLE_CONSTRAINTS T  
INNER JOIN '+@SourceDatabaseName+'.INFORMATION_SCHEMA.KEY_COLUMN_USAGE I
				ON CONSTRAINT_TYPE = ''PRIMARY KEY''
				AND I.TABLE_NAME = T.TABLE_NAME
				AND I.CONSTRAINT_NAME = T.CONSTRAINT_NAME	
WHERE I.TABLE_SCHEMA ='''+@SchemaName+''' and I.TABLE_NAME = '''+@TableName+'''
ORDER BY ORDINAL_POSITION'

EXEC sp_executesql @PKSQLQuery,N'@primaryConstraint VARCHAR(MAX) OUT',@primaryConstraint OUT
SET @TableText+=@primaryConstraint+');'+char(13)+CHAR(10)



--Store to global temp table because variable can export max 8000 chars so if table creation has more than 8000 chars we are using global temp table

END TRY
BEGIN CATCH
	PRINT 'Could not create PK...Make sure table exists.'
	PRINT 'ERROR at ProcessID'+CAST(@ProcessId AS VARCHAR)
END CATCH


SET @counter= @counter + 1
END 

INSERT INTO ##snddl VALUES(@TableText)


DECLARE @sql VARCHAR(8000)
SELECT @sql = 'bcp "SELECT * FROM ##snddl" queryout '+@OutputPath+' -q -c -t, -T -S '+@SnapshotServer
--SELECT @sql
--Execute on cmd
EXEC master..xp_cmdshell @sql,no_output


IF (@Debug = 1)
BEGIN
	PRINT(@TableText);
	PRINT(@SQLQuery);
END


END


GO

