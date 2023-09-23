-- Drops all foreign keys
DECLARE @sql nvarchar(512), 
	@fk_name nvarchar(128),
	@schema_name nvarchar(64),
	@table_name nvarchar(64)

DECLARE cr_drop_fks CURSOR FOR 
SELECT o.name, s.name, OBJECT_NAME(o.parent_object_id)
FROM sys.objects o
INNER JOIN sys.schemas s ON o.schema_id=s.schema_id
WHERE o.type='F'
ORDER BY o.name

OPEN cr_drop_fks

FETCH NEXT FROM cr_drop_fks
INTO @fk_name, @schema_name, @table_name

WHILE @@FETCH_STATUS = 0
BEGIN
	SET @sql='ALTER TABLE '+@schema_name+'.'+@table_name+' DROP CONSTRAINT '+@fk_name
	EXEC sp_executesql @sql
	FETCH NEXT FROM cr_drop_fks
	INTO @fk_name, @schema_name, @table_name
END

CLOSE cr_drop_fks
DEALLOCATE cr_drop_fks
GO
