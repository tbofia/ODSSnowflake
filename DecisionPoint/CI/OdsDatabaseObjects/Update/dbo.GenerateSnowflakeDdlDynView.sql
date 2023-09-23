

IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'dbo.GenerateSnowflakeDdlDynView') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE dbo.GenerateSnowflakeDdlDynView
GO 

CREATE PROCEDURE dbo.GenerateSnowflakeDdlDynView
	(
		@SourceDatabaseName VARCHAR(255)
		,@OutputPath VARCHAR(MAX)
		,@ProcessId INT = 0
		,@Debug BIT = 0 
	)
AS
BEGIN
SET NOCOUNT ON;

	DECLARE  @SQLScript NVARCHAR(MAX) = ''		
		,@srcColumnList VARCHAR(MAX)=''
		,@TargetSchemaName CHAR(3) = N'src'
		,@ProductSchemaName VARCHAR(3)
		,@TargetTableName VARCHAR(255) 

if OBJECT_ID('tempDB..#ProcId') is not null
DROP TABLE #ProcId

CREATE TABLE #procId(Id INT IDENTITY,processId INT)
DECLARE @Query NVARCHAR(MAX)

SET @Query='INSERT INTO #procId (processId) '+
CASE
	 WHEN @ProcessId = 0 THEN 'SELECT ProcessId FROM '+@SourceDatabaseName+'.adm.Process WHERE TargetSchemaName <> ''rpt'''
	 ELSE + '  SELECT '+CONVERT(VARCHAR(10), @ProcessID) END

EXEC(@Query)

DECLARE @Cnt INT = 1
WHILE @Cnt <= (SELECT COUNT(*) FROM #ProcId)
BEGIN
SELECT @ProcessId = ProcessId FROM #ProcId WHERE Id = @Cnt

-- Get Product Schema
SET @Query =' SELECT @ProductSchemaName = Pdct.SchemaName
			  FROM '+@SourceDatabaseName+'.adm.Product Pdct
			  INNER JOIN '+@SourceDatabaseName+'.adm.Process P ON P.ProductKey = Pdct.ProductKey 
			  AND P.ProcessId =' + CAST(@ProcessId AS VARCHAR(10))
EXEC sp_executeSQL @Query,N'@ProductSchemaName VARCHAR(3) OUTPUT',@ProductSchemaName OUTPUT


----Get the target table Name 
SET @Query =' SELECT @TargetTableName = TargetTableName FROM '+@SourceDatabaseName+'.adm.Process WHERE ProcessId = ' + CAST(@ProcessId AS VARCHAR(10))
EXEC sp_executeSQL @Query,N'@TargetTableName VARCHAR(255) OUTPUT',@TargetTableName OUTPUT

-- Get list of columns.
SET @srcColumnList = NULL
SET @Query =' SELECT @srcColumnList =  COALESCE(@srcColumnList+CHAR(13) + CHAR(10)+char(9)+''	,'',char(9)+'''')+
			CASE 
				WHEN COLUMN_NAME LIKE ''%[^a-Z0-9_]%'' THEN ''"''+UPPER(COLUMN_NAME)+''"'' 
				ELSE UPPER(COLUMN_NAME) END  
			FROM '+@SourceDatabaseName+'.INFORMATION_SCHEMA.COLUMNS
			WHERE TABLE_SCHEMA = '''+@TargetSchemaName+''' 
				AND TABLE_NAME = '''+@TargetTableName+''' 
				ORDER BY ORDINAL_POSITION;'

EXEC sp_executeSQL @Query,N'@srcColumnList VARCHAR(MAX) OUTPUT',@srcColumnList OUTPUT

-- Build Index Scripts
SET @SQLScript =
'CREATE OR REPLACE VIEW '+@ProductSchemaName+'.'+@TargetTableName+'
AS
SELECT 
	'+@srcColumnList+'
FROM '+@TargetSchemaName+'.'+@TargetTableName+'
WHERE   ODSROWISCURRENT = 1
	AND DMLOPERATION <> ''D'';

'

IF OBJECT_ID('tempdb..##SnViewddl') is not null  DROP TABLE ##SnViewddl
	CREATE TABLE ##SnViewddl (Ddl TEXT)
----Store to global temp table because variable can export max 8000 chars so 
----if view creation has more than 8000 chars we are using global temp table.
INSERT INTO ##SnViewddl VALUES(@SQLScript)

-- Run VIEW Creation scripts
BEGIN TRY
--PRINT (@SQLScript)
DECLARE @Sql VARCHAR(8000)
	   ,@SnapshotServer VARCHAR(255) = @@Servername
SELECT @sql = 'bcp "SELECT * FROM ##SnViewddl" queryout '+ @OutputPath +'\'+@ProductSchemaName+'.'+@TargetTableName+'.sql -q -c -t, -T -S '+@SnapshotServer

--Execute on cmd
EXEC master..xp_cmdshell @sql,no_output

END TRY
BEGIN CATCH
PRINT 'View Could Not be built...Make sure view exists and no Views have been created on it.'
END CATCH


IF (@Debug = 1)
BEGIN
	PRINT(@sql);
	PRINT(@SQLScript);
END





SET @Cnt = @Cnt + 1
END 

END
GO

