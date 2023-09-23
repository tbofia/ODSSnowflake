IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'adm.Etl_GenerateProcessHashbytes') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION adm.Etl_GenerateProcessHashbytes
GO

CREATE FUNCTION adm.Etl_GenerateProcessHashbytes (
@ProcessId INT)
RETURNS VARCHAR(MAX)
AS
BEGIN

-- DECLARE @ProcessId INT = 153;
DECLARE	 @StgColumnList VARCHAR(MAX)
		,@TargetTableName VARCHAR(255) = (SELECT TargetTableName FROM adm.Process WHERE ProcessId = @ProcessId)
		,@StagingSchemaName CHAR(3) = N'stg'
		,@HashbyteFunction VARCHAR(MAX)
		,@Hashbytecolumns VARCHAR(MAX)
		,@HashbyteFunctionType INT;

-- Get Process Hashbytefunction type
SET @HashbyteFunctionType = (SELECT HashFunctionType FROM adm.Process WHERE ProcessId = @ProcessId)

-- 2.0 Get Column list for Staging tables	
SELECT @stgColumnList =  COALESCE(@stgColumnList+CHAR(13)+CHAR(10)+CHAR(9)+',','')+'['+COLUMN_NAME+']' 
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = @StagingSchemaName
AND TABLE_NAME = @TargetTableName
AND COLUMN_NAME <> 'DmlOperation'
ORDER BY ORDINAL_POSITION;

-- Build Hash value with columns, function to use depends on the process.
-- 3.0 Get Hash column list for staging table

IF @HashbyteFunctionType = 1
	SET @HashbyteFunction = ',HASHBYTES(''SHA1'', (SELECT '+@stgColumnList+' FOR XML RAW)) OdsHashbytesValue';

ELSE IF @HashbyteFunctionType = 2
BEGIN
	-- Get Hash column list for staging table
	SELECT @Hashbytecolumns =  COALESCE(@Hashbytecolumns+CHAR(13)+CHAR(10)+CHAR(9)+'+','')+'CAST(ISNULL(['+COLUMN_NAME+'], '''') AS VARBINARY(MAX))' 
	FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_SCHEMA = @StagingSchemaName
	AND TABLE_NAME = @TargetTableName
	AND COLUMN_NAME <> 'DmlOperation'
	ORDER BY ORDINAL_POSITION;	
	
	SET @HashbyteFunction = ',CAST(master.sys.fn_repl_hash_binary('+@Hashbytecolumns+') AS VARBINARY(8000)) OdsHashbytesValue';
END

ELSE IF @HashbyteFunctionType = 3
	SET @HashbyteFunction = ',HASHBYTES(''SHA1'', (SELECT '+@stgColumnList+' FOR XML RAW, BINARY BASE64)) OdsHashbytesValue';
 
RETURN @HashbyteFunction

END

GO
