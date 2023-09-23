--Create integer partition function for 100 partition boundaries.
IF( EXISTS( SELECT * FROM sys.partition_functions WHERE name = 'DP_Ods_PartitionFunction' ) )
BEGIN TRY 
DROP PARTITION FUNCTION DP_Ods_PartitionFunction;
END TRY
BEGIN CATCH
PRINT 'Partition function is being used by a Partition Scheme'
GOTO ENDFUNCTION
END CATCH

DECLARE @IntegerPartitionFunction nvarchar(max) = N'CREATE PARTITION FUNCTION DP_Ods_PartitionFunction (int) AS RANGE LEFT FOR VALUES (';
DECLARE @i int = 1;
WHILE @i < 100
BEGIN
SET @IntegerPartitionFunction += CAST(@i as nvarchar(10)) + N', ';
SET @i += 1;
END
SET @IntegerPartitionFunction += CAST(@i as nvarchar(10)) + N');';
BEGIN TRY
EXEC sp_executesql @IntegerPartitionFunction;
END TRY
BEGIN CATCH
PRINT 'Cannot Recreate Partition. Check that it has been dropped...'
END CATCH

ENDFUNCTION:
GO

/*
SELECT 
	 f.name AS FunctionName
	,f.fanout
	,r.boundary_id
	,r.value
FROM sys.partition_functions F 
INNER JOIN sys.partition_range_values r
	ON f.function_id = r.function_id
WHERE f.name = 'DP_Ods_PartitionFunction'
*/

-- Partition Scheme 
IF( EXISTS( SELECT * FROM sys.partition_schemes WHERE name = 'DP_Ods_PartitionScheme' ) )
BEGIN TRY
 DROP PARTITION SCHEME DP_Ods_PartitionScheme;
END TRY
BEGIN CATCH
PRINT 'Partition scheme is being used to partition existing tables'
GOTO ENDSCHEME
END CATCH

BEGIN TRY
CREATE PARTITION SCHEME DP_Ods_PartitionScheme
    AS PARTITION DP_Ods_PartitionFunction
    ALL TO ('PRIMARY');
END TRY
BEGIN CATCH
PRINT 'Cannot create partition scheme...Check that does not already exist'
END CATCH

ENDSCHEME:
GO
/*
SELECT 
	 ps.name AS PartitionSchemeName
	,ds.destination_id
	,fg.name AS FileGroupName
	,fg.is_default
	,f.physical_name
FROM sys.partition_schemes ps
INNER JOIN sys.destination_data_spaces ds
	ON ps.data_space_id = ds.partition_scheme_id
INNER JOIN sys.filegroups fg
	ON ds.data_space_id = fg.data_space_id
INNER JOIN sys.database_files f
	ON f.data_space_id = fg.data_space_id
WHERE ps.name = 'DP_Ods_PartitionScheme'

*/

-- Use This Part when need to split partitions e.g. when adding a new customer
/*
ALTER PARTITION SCHEME DP_Ods_PartitionScheme 
NEXT USED 'PRIMARY';

ALTER PARTITION FUNCTION DP_Ods_PartitionFunction ()
SPLIT RANGE (<PartitionFunctionBoundary>); -- The Partition function boundary will be the CustomerId
*/

