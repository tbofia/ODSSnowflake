SET NOCOUNT ON;
DECLARE	 @ProcessId INT = '$(processid_)'

DECLARE  @SQLScript NVARCHAR(MAX) = ''
		,@srcColumnList VARCHAR(MAX)
		,@TargetSchemaName CHAR(3) = N'src'
		,@ProductSchemaName VARCHAR(3)
		,@TargetTableName VARCHAR(255) = (SELECT TargetTableName FROM adm.Process WHERE ProcessId = @ProcessId);
DECLARE  @KeyColumnsList TABLE (TargetColumnName VARCHAR(255));

-- Get Product Schema
SELECT @ProductSchemaName = Pdct.SchemaName
FROM adm.Product Pdct
INNER JOIN adm.Process P ON P.ProductKey = Pdct.ProductKey AND P.ProcessId = @ProcessId;

-- Get list of columns.
SELECT @srcColumnList =  COALESCE(@srcColumnList+CHAR(13)+CHAR(10)+CHAR(9)+',','')+CASE WHEN COLUMN_NAME LIKE '%[^a-Z0-9_]%' THEN '['+COLUMN_NAME+']' ELSE COLUMN_NAME END 
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = @TargetSchemaName
AND TABLE_NAME = @TargetTableName
ORDER BY ORDINAL_POSITION;

-- Build Index Scripts
SET @SQLScript =
'IF OBJECT_ID('''+@ProductSchemaName+'.'+@TargetTableName+''', ''V'') IS NOT NULL
    DROP VIEW '+@ProductSchemaName+'.'+@TargetTableName+';
GO

CREATE VIEW '+@ProductSchemaName+'.'+@TargetTableName+'
AS

SELECT 
	 '+@srcColumnList+'
FROM '+@TargetSchemaName+'.'+@TargetTableName+'
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> ''D'';
GO

'

-- Run Index Creation scripts
BEGIN TRY
PRINT (@SQLScript)
END TRY
BEGIN CATCH
PRINT 'Indexes Could Not be built...Make sure table exists and no indexes have been created on it.'
END CATCH
