
IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'dbo.GenerateSnowflakeDDLDynFunction') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE dbo.GenerateSnowflakeDDLDynFunction
GO 

CREATE PROCEDURE dbo.GenerateSnowflakeDDLDynFunction
	(
		 @SourceDatabaseName VARCHAR(255) 
		,@OutputPath VARCHAR(MAX)
		,@ProcessId INT = 0
		,@Debug BIT = 0
	)
AS
BEGIN
SET NOCOUNT ON;

/*Declare @SourceDatabaseName VARCHAR(255) = 'WcsOds_SnowFlake'
		,@OutputPath VARCHAR(MAX) = '\\qa14nas\CSG-Analytics\OdsFileExtracts\SmartAdvisor\Snowflake_Replication\Snowflake_Admin\functions'
		,@ProcessId INT = 0
		,@Debug BIT = 0   --1 print the result 
	*/

DECLARE  @SQLScript VARCHAR(MAX) = ''
		,@srcColumnList VARCHAR(MAX)
		,@GroupByColumnList VARCHAR(MAX)
		,@TargetSchemaName VARCHAR(3) --= (SELECT TargetSchemaName FROM AcsOds_SnowFlake.adm.Process WHERE ProcessId = @ProcessId)
		,@ProductSchemaName VARCHAR(3)
		,@JoinClause VARCHAR(MAX)
		,@TargetTableName VARCHAR(255) --= (SELECT TargetTableName FROM AcsOds_SnowFlake.adm.Process WHERE ProcessId = @ProcessId);

		CREATE TABLE  #KeyColumnsList (TargetColumnName VARCHAR(255),TargetColumnPosition INT);


CREATE TABLE #procId(Id INT IDENTITY(1,1),processId INT)
DECLARE @Query NVARCHAR(MAX),
@TableText VARCHAR(MAX) = ''

SET @Query='INSERT INTO #procId (processId) '+
CASE
	 WHEN @ProcessId = 0 THEN 'SELECT ProcessId FROM '+@SourceDatabaseName+'.adm.Process  WHERE TargetSchemaName <> ''rpt'';'
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
SET @Query =' SELECT @TargetSchemaName = TargetSchemaName FROM '+@SourceDatabaseName+'.adm.Process WHERE ProcessId = ' + CAST(@ProcessId AS VARCHAR(10))
EXEC sp_executeSQL @Query,N'@TargetSchemaName VARCHAR(255) OUTPUT',@TargetSchemaName OUTPUT

----Get the target table Name 
SET @Query =' SELECT @TargetTableName = TargetTableName FROM '+@SourceDatabaseName+'.adm.Process WHERE ProcessId = ' + CAST(@ProcessId AS VARCHAR(10))
EXEC sp_executeSQL @Query,N'@TargetTableName VARCHAR(255) OUTPUT',@TargetTableName OUTPUT

-- Get list of columns.
SET @srcColumnList = Null
SET @Query =' SELECT @srcColumnList =  COALESCE(@srcColumnList+CHAR(13)+CHAR(10)+CHAR(9)+ ''	,'','''')+
			CASE 
				WHEN COLUMN_NAME LIKE ''%[^a-Z0-9_]%'' THEN ''"''+UPPER(COLUMN_NAME)+''"''
				ELSE UPPER(COLUMN_NAME) END  
			FROM '+@SourceDatabaseName+'.INFORMATION_SCHEMA.COLUMNS
			WHERE TABLE_SCHEMA = '''+@TargetSchemaName+''' 
				AND TABLE_NAME = '''+@TargetTableName+''' 
				ORDER BY ORDINAL_POSITION;'
EXEC sp_executeSQL @Query,N'@srcColumnList VARCHAR(MAX) OUTPUT',@srcColumnList OUTPUT

-- 1.0 Get Join Clause for the given process to Join staging and Target	
TRUNCATE TABLE #KeyColumnsList
SET @Query =  ' INSERT INTO #KeyColumnsList(TargetColumnName,TargetColumnPosition)	
SELECT DISTINCT
			CASE 
				WHEN COLUMN_NAME LIKE ''%[^a-Z0-9_]%'' THEN ''T."''+UPPER(COLUMN_NAME)+''"''
				ELSE ''T.''+UPPER(COLUMN_NAME) END ,I.ORDINAL_POSITION 
FROM '+@SourceDatabaseName+'.INFORMATION_SCHEMA.TABLE_CONSTRAINTS T  
INNER JOIN  '+@SourceDatabaseName+'.INFORMATION_SCHEMA.KEY_COLUMN_USAGE I
				ON CONSTRAINT_TYPE = ''PRIMARY KEY''
				AND I.TABLE_NAME = T.TABLE_NAME
				AND I.CONSTRAINT_NAME = T.CONSTRAINT_NAME
INNER JOIN '+@SourceDatabaseName+'.adm.Process P 
	ON I.TABLE_NAME = P.TargetTableName
	AND I.TABLE_SCHEMA = '''+@TargetSchemaName+''' 
WHERE P.TargetTableName = '''+@TargetTableName+''' 
AND I.COLUMN_NAME NOT IN (''OdsCustomerId'',''OdsPostingGroupAuditId'')
ORDER BY ORDINAL_POSITION;
'
EXEC(@Query)

-- Build Join Clause with key columns
SET @JoinClause = NULL
SELECT @JoinClause =  COALESCE(@JoinClause+CHAR(13)+CHAR(10)+CHAR(9)+'AND ','')+'T.'+TargetColumnName+' = S.'+TargetColumnName
FROM #KeyColumnsList
ORDER BY TargetColumnPosition;

-- Build Key Columns comma seperated
SET @GroupByColumnList = NULL
SELECT @GroupByColumnList =  COALESCE(@GroupByColumnList+','+CHAR(13)+CHAR(10)+CHAR(9)+CHAR(9),'')+TargetColumnName
FROM #KeyColumnsList
ORDER BY TargetColumnPosition;

-----Generate Return table column list

SET @Query = '
SET @TableText =''''

SELECT @TableText=@TableText+
		CASE WHEN ordinal_position = 1 THEN '' (''   + + CHAR(13) + CHAR(10)  + + CHAR(9)+ CHAR(9)+
			'' ''
		ELSE    + CHAR(13) + CHAR(10)  + CHAR(9)+ CHAR(9)+ '','' END  +
	UPPER(COLUMN_NAME) + '' ''+CASE WHEN ic.column_name = ''OdsRowIsCurrent'' THEN ''INT'' ELSE m.SnowflakeDataType END
      +
	CASE	WHEN ic.column_name = ''OdsRowIsCurrent'' THEN ''''
		WHEN ic.data_type=''DATETIME'' THEN ''''
		WHEN ic.data_type=''DATETIME2'' THEN ''''
		WHEN ic.data_type in (''XML'',''UNIQUEIDENTIFIER'') THEN ''''
		WHEN character_maximum_length = -1 THEN ''''
		WHEN character_maximum_length is not null THEN ''('' + cast(character_maximum_length as VARCHAR) + '')''
		WHEN datetime_precision is not null AND DATA_TYPE<>''DATE'' THEN ''('' + cast(datetime_precision as VARCHAR) + '')''
		WHEN numeric_precision is not null THEN ''('' + cast(numeric_precision as VARCHAR) +
		CASE WHEN numeric_scale is not null THEN '','' + cast(numeric_scale as VARCHAR) 
		ELSE '''' 
		END +
         '')'' 
	ELSE '''' 
	END 
	
FROM '+@SourceDatabaseName+'.INFORMATION_SCHEMA.COLUMNS ic
	INNER JOIN SnowFlake_Admin.adm.DataTypeMapping m
			ON ic.Data_type=m.SqlServerDataType
	
WHERE
		 ic.table_schema  = '''+@TargetSchemaName +'''
	AND  ic.TABLE_NAME  = '''+@TargetTableName+'''

ORDER BY ic.table_name, ORDINAL_POSITION;'

EXEC sp_executesql @Query,N'@TableText VARCHAR(MAX) OUT',@TableText OUT

		
-- Build Index Scripts
SET @SQLScript = ''
SET @SQLScript = Convert(Varchar(max),@SQLScript)+
'CREATE OR REPLACE FUNCTION '+@ProductSchemaName+'.if_'+@TargetTableName+'(
		IF_ODSPOSTINGGROUPAUDITID INT
)
RETURNS TABLE '+@TableText+' )
AS
$$
SELECT '+@srcColumnList+'
FROM '+@TargetSchemaName+'.'+@TargetTableName+' T
INNER JOIN (
	SELECT 
		ODSCUSTOMERID,
		'+@GroupByColumnList+',
		MAX(ODSPOSTINGGROUPAUDITID) AS ODSPOSTINGGROUPAUDITID
	FROM '+@TargetSchemaName+'.'+@TargetTableName+'
	WHERE ODSPOSTINGGROUPAUDITID <= IF_ODSPOSTINGGROUPAUDITID
	GROUP BY ODSCUSTOMERID,
		'+@GroupByColumnList+') S
ON T.ODSPOSTINGGROUPAUDITID = S.ODSPOSTINGGROUPAUDITID
	AND T.ODSCUSTOMERID = S.ODSCUSTOMERID
	AND '+@JoinClause+'
WHERE T.DMLOPERATION <> ''D''

$$;

'


IF OBJECT_ID('tempdb..##SnFunctionddl') IS NOT NULL  
		DROP TABLE ##SnFunctionddl
	CREATE TABLE ##SnFunctionddl (Ddl TEXT)
----Store to global temp table because variable can export max 8000 chars so 
----if table creation has more than 8000 chars we are using global temp table.
INSERT INTO ##SnFunctionddl VALUES(@SQLScript)

-- Run VIEW Creation scripts
BEGIN TRY
--PRINT (@SQLScript)
DECLARE @Sql VARCHAR(8000)
	   ,@SnapshotServer VARCHAR(255) = @@Servername
SELECT @sql = 'bcp "SELECT * FROM ##SnFunctionddl" queryout '+ @OutputPath +'\'+@ProductSchemaName+'.if_'+@TargetTableName+'.sql -q -c -t, -T -S '+@SnapshotServer

--Execute on cmd
EXEC master..xp_cmdshell @sql,no_output

END TRY
BEGIN CATCH
PRINT 'Function Could Not be built...Make sure table exists and no function have been created on it.'
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

