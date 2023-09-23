SET NOCOUNT ON;
DECLARE	 @ProcessId INT = '$(processid_)'

DECLARE  @SQLScript NVARCHAR(MAX) = ''
		,@srcColumnList VARCHAR(MAX)
		,@GroupByColumnList VARCHAR(MAX)
		,@TargetSchemaName VARCHAR(3) = (SELECT TargetSchemaName FROM adm.Process WHERE ProcessId = @ProcessId)
		,@ProductSchemaName VARCHAR(3)
		,@JoinClause VARCHAR(MAX)
		,@TargetTableName VARCHAR(255) = (SELECT TargetTableName FROM adm.Process WHERE ProcessId = @ProcessId);
DECLARE  @KeyColumnsList TABLE (TargetColumnName VARCHAR(255),TargetColumnPosition INT);

-- Get Product Schema
SELECT @ProductSchemaName = Pdct.SchemaName
FROM adm.Product Pdct
INNER JOIN adm.Process P ON P.ProductKey = Pdct.ProductKey AND P.ProcessId = @ProcessId;

-- Get list of columns.
SELECT @srcColumnList =  COALESCE(@srcColumnList+','+CHAR(13)+CHAR(10)+CHAR(9),'')+'t.'+ CASE WHEN COLUMN_NAME LIKE '%[^a-Z0-9_]%' THEN '['+COLUMN_NAME+']' ELSE COLUMN_NAME END
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = @TargetSchemaName
AND TABLE_NAME = @TargetTableName
ORDER BY ORDINAL_POSITION;

-- 1.0 Get Join Clause for the given process to Join staging and Target	
INSERT INTO @KeyColumnsList	
SELECT DISTINCT I.COLUMN_NAME AS TargetColumnName, ORDINAL_POSITION AS TargetColumnPosition
FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE I
INNER JOIN adm.Process P
	ON I.TABLE_NAME = P.TargetTableName
	AND OBJECTPROPERTY(OBJECT_ID(I.CONSTRAINT_SCHEMA + '.' + I.CONSTRAINT_NAME), 'IsPrimaryKey') = 1
	AND I.TABLE_SCHEMA = @TargetSchemaName
WHERE P.TargetTableName = @TargetTableName
AND I.COLUMN_NAME NOT IN ('OdsCustomerId','OdsPostingGroupAuditId')
ORDER BY ORDINAL_POSITION;

-- Build Join Clause with key columns
SELECT @JoinClause =  COALESCE(@JoinClause+CHAR(13)+CHAR(10)+CHAR(9)+'AND ','')+'t.'+TargetColumnName+' = s.'+TargetColumnName
FROM @KeyColumnsList
ORDER BY TargetColumnPosition;

-- Build Key Columns comma seperated
SELECT @GroupByColumnList =  COALESCE(@GroupByColumnList+','+CHAR(13)+CHAR(10)+CHAR(9)+CHAR(9),'')+TargetColumnName
FROM @KeyColumnsList
ORDER BY TargetColumnPosition;
		
-- Build Index Scripts
SET @SQLScript =
'IF OBJECT_ID('''+@ProductSchemaName+'.if_'+@TargetTableName+''', ''IF'') IS NOT NULL
    DROP FUNCTION '+@ProductSchemaName+'.if_'+@TargetTableName+';
GO

CREATE FUNCTION '+@ProductSchemaName+'.if_'+@TargetTableName+'(
	@OdsPostingGroupAuditId INT
)
RETURNS TABLE
AS
RETURN
SELECT 
	 '+@srcColumnList+'
FROM '+@TargetSchemaName+'.'+@TargetTableName+' t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		'+@GroupByColumnList+',
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM '+@TargetSchemaName+'.'+@TargetTableName+'
	WHERE OdsPostingGroupAuditId <= @OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		'+@GroupByColumnList+') s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND '+@JoinClause+'
WHERE t.DmlOperation <> ''D'';

GO

'

-- Run Index Creation scripts
BEGIN TRY
PRINT (@SQLScript)
END TRY
BEGIN CATCH
PRINT 'Indexes Could Not be built...Make sure table exists and no indexes have been created on it.'
END CATCH
