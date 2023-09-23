
IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'dbo.GenerateSnowflakeDdlStgSrcTable') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE dbo.GenerateSnowflakeDdlStgSrcTable
GO 

CREATE PROCEDURE dbo.GenerateSnowflakeDdlStgSrcTable (
@SourceDatabaseName VARCHAR(255),
@ProcessId INT,
@SnapshotServer VARCHAR(512) = null,
@OutputPath VARCHAR(MAX),
@IsStage INT,
@Debug INT = 0
)
AS
BEGIN

IF @SnapshotServer is null
BEGIN
 SET @SnapshotServer = @@Servername
END

--DECLARE
--@SourceDatabaseName VARCHAR(100) ='acsods_pilot',
--@SchemaName VARCHAR(100) = 'all',
--@TableName VARCHAR(100) = 'all',
--@Debug INT = 1;


IF OBJECT_ID('tempdb..##snddl') is not null  DROP TABLE ##snddl
	CREATE TABLE ##snddl (ddl text)


DECLARE @SQLQuery NVARCHAR(MAX),
@SchemaName VARCHAR(100),
@TableName VARCHAR(MAX) ,
@TableText VARCHAR(MAX) = '',
@GetQuery NVARCHAR(MAX)


IF(@IsStage=1)
BEGIN
SET @SchemaName = 'stg'
END
ELSE
BEGIN
	SET @GetQuery ='SELECT @SchemaName=TargetSchemaName FROM '+@SourceDatabaseName+'.adm.process where ProcessId=' + CAST(@ProcessId AS VARCHAR)
	EXEC sp_executeSQL @GetQuery,N'@SchemaName VARCHAR(16) OUTPUT',@SchemaName OUTPUT
END


SET @GetQuery ='SELECT @TableName=TargetTableName FROM '+@SourceDatabaseName+'.adm.process where ProcessId=' + CAST(@ProcessId AS VARCHAR)
EXEC sp_executeSQL @GetQuery,N'@TableName VARCHAR(255) OUTPUT',@TableName OUTPUT
	


SET @SQLQuery = '
SET @TableText =''''

SELECT @TableText=@TableText+
		CASE WHEN ordinal_position = 1 THEN  +
			''CREATE ''+
			CASE WHEN '''+@SchemaName+''' =''stg'' THEN ''OR REPLACE TABLE ''
				ELSE ''TABLE IF NOT EXISTS ''
			END
  
			+'''+@SchemaName+'''+''.''+ic.TABLE_NAME+'' (''   + + CHAR(13) + CHAR(10)  + CHAR(9) + CHAR(32) +
			'' ''
		ELSE    + CHAR(13) + CHAR(10) + CHAR(9)  +   '' , '' END  +
	column_name + '' '' + CASE WHEN ic.column_name = ''OdsRowIsCurrent'' THEN ''INT'' ELSE m.SnowflakeDataType END
      +
	CASE	WHEN ic.column_name = ''OdsRowIsCurrent'' THEN ''''
		WHEN ic.data_type=''DATETIME'' THEN ''''
		WHEN ic.data_type=''DATETIME2'' THEN ''''
		WHEN character_maximum_length = -1 THEN ''''
		WHEN ic.data_type in (''XML'',''UNIQUEIDENTIFIER'') THEN ''''
		WHEN character_maximum_length is not null THEN ''('' + cast(character_maximum_length as VARCHAR) + '')''
		WHEN datetime_precision is not null AND DATA_TYPE<>''DATE'' THEN ''('' + cast(datetime_precision as VARCHAR) + '')''
		WHEN numeric_precision is not null THEN ''('' + cast(numeric_precision as VARCHAR) +
		CASE WHEN numeric_scale is not null THEN '', '' + cast(numeric_scale as VARCHAR) 
		ELSE '''' 
		END +
         '')''
	ELSE '''' 
	END +
	CASE WHEN is_nullable=''YES'' THEN '' NULL''
	ELSE '' NOT NULL''
	END
--SELECT *
FROM '+@SourceDatabaseName+'.information_schema.columns ic
	INNER JOIN adm.datatypeMapping m
			on ic.Data_type=m.SqlServerDataType
	
where ic.table_schema  = ''src''
	AND  ic.TABLE_NAME  = '''+@TableName+'''

ORDER BY ic.table_name, ordinal_position;'


EXEC sp_executesql @SQLQuery,N'@TableText VARCHAR(MAX) OUT',@TableText OUT

--comlete table body
SET @TableText=@TableText+'
);' +  CHAR(13) + CHAR(10)

--ADD Primary key constraint

--IF @SchemaName='src'
--BEGIN
--DECLARE @primaryConstraint VARCHAR(MAX),
--		@PKSQLQuery NVARCHAR(MAX)

--SET @TableText+= CHAR(13) + CHAR(10)  + CHAR(13) + CHAR(10)  +
--'ALTER TABLE ' + @SchemaName + '.' + @TableName + ' ADD PRIMARY KEY ('


--SET @PKSQLQuery = '
--SET @primaryConstraint=''''
--select @primaryConstraint += case when ORDINAL_POSITION=1 then COLUMN_NAME
--else '',''+COLUMN_NAME
--end
--FROM '+@SourceDatabaseName+'.INFORMATION_SCHEMA.TABLE_CONSTRAINTS T  
--INNER JOIN '+@SourceDatabaseName+'.INFORMATION_SCHEMA.KEY_COLUMN_USAGE I
--				ON CONSTRAINT_TYPE = ''PRIMARY KEY''
--				AND I.TABLE_NAME = T.TABLE_NAME
--				AND I.CONSTRAINT_NAME = T.CONSTRAINT_NAME	
--WHERE I.TABLE_SCHEMA ='''+@SchemaName+''' and I.TABLE_NAME = '''+@TableName+'''
--ORDER BY ORDINAL_POSITION'

--EXEC sp_executesql @PKSQLQuery,N'@primaryConstraint VARCHAR(MAX) OUT',@primaryConstraint OUT
--SET @TableText+=@primaryConstraint+');'
--END




--Store to global temp table because variable can export max 8000 chars so if table creation has more than 8000 chars we are using global temp table
INSERT INTO ##snddl VALUES(@TableText)


DECLARE @sql VARCHAR(8000)
SELECT @sql = 'bcp "SELECT * FROM ##snddl" queryout '+@OutputPath+'\'+@SchemaName+'.'+@TableName+'.sql -q -c -t, -T -S '+@SnapshotServer
--SELECT @sql
--Execute on cmd
EXEC master..xp_cmdshell @sql,no_output


IF (@Debug = 1)
BEGIN
	PRINT(@sql);
	PRINT(@SQLQuery)
END

END






GO

