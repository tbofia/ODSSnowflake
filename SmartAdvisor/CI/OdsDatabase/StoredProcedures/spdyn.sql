IF OBJECT_ID('adm.Etl_CreateUnpartitionedTableIndexes', 'P') IS NOT NULL
    DROP PROCEDURE adm.Etl_CreateUnpartitionedTableIndexes
GO

CREATE PROCEDURE adm.Etl_CreateUnpartitionedTableIndexes (
@CustomerId INT,
@ProcessId INT,
@returnstatus INT OUTPUT)
AS
BEGIN
-- DECLARE @ProcessId INT = 11,@CustomerId INT = 9,@returnstatus INT;
DECLARE  @SQLScript VARCHAR(MAX)
		,@StagingSchemaName CHAR(3) = 'stg'
		,@TargetSchemaName CHAR(3) = (SELECT TargetSchemaName FROM adm.Process WHERE ProcessId = @ProcessId)	
		,@TargetTableName VARCHAR(255) = (SELECT TargetTableName FROM adm.Process WHERE ProcessId = @ProcessId);
		
-- Get Index Key Columns
;WITH Ods_IndexColumns AS(
SELECT IC2.object_id,
      IC2.index_id,
      STUFF(( SELECT ',' + C.name + CASE WHEN MAX(CONVERT(INT, IC1.is_descending_key)) = 1 THEN ' DESC' ELSE ' ASC' END
              FROM   sys.index_columns IC1
              INNER  JOIN sys.columns C
                  ON  C.object_id = IC1.object_id
                  AND C.column_id = IC1.column_id
                  AND IC1.is_included_column = 0
              WHERE  IC1.object_id = IC2.object_id  AND IC1.index_id = IC2.index_id
              GROUP BY IC1.object_id,C.name, index_id
              ORDER BY  MAX(IC1.key_ordinal) 
              FOR XML PATH('')),1,1,'') KeyColumns,
      STUFF(( SELECT ',' + C.name
			  FROM   sys.index_columns IC1
			  INNER  JOIN sys.columns C
				  ON  C.object_id = IC1.object_id
				  AND C.column_id = IC1.column_id
				  AND IC1.is_included_column = 1
			  WHERE  IC1.object_id = IC2.object_id  AND IC1.index_id = IC2.index_id
			  GROUP BY IC1.object_id,C.name,index_id 
			  FOR XML PATH('')),1,1,'') IncludedColumns
FROM   sys.index_columns IC2 
GROUP BY IC2.object_id,IC2.index_id)
-- Build Index script or Primary key constraint.
SELECT @SQLScript =  COALESCE(@SQLScript+CHAR(13)+CHAR(10)+'','')+
	 CASE WHEN I.is_primary_key = 1 
		  THEN 'ALTER TABLE '+@StagingSchemaName + '.' + @TargetTableName+'_Unpartitioned'+' ADD CONSTRAINT '+I.name
		  ELSE 'CREATE ' END+
	 CASE WHEN I.is_primary_key <> 1 AND I.is_unique = 1 THEN ' UNIQUE '   ELSE ''  END +
	 CASE WHEN I.is_primary_key = 1 THEN ' PRIMARY KEY ' ELSE '' END+
	 I.type_desc COLLATE DATABASE_DEFAULT + CASE WHEN I.is_primary_key <> 1 THEN ' INDEX ' ELSE '' END +
	 CASE WHEN I.is_primary_key <> 1 THEN  I.name + ' ON ' ELSE '' END+
	 CASE WHEN I.is_primary_key <> 1 THEN  @StagingSchemaName + '.' + @TargetTableName+'_Unpartitioned'  ELSE '' END+ 
	   ' ('+IC.KeyColumns+')  ' +
	   ISNULL(' INCLUDE(' + IC.IncludedColumns + ') ', '')+
	   'WITH (DATA_COMPRESSION = PAGE);'+CHAR(13)+CHAR(10)

FROM   sys.indexes I
INNER JOIN sys.tables T
ON  T.object_id = I.object_id
INNER JOIN Ods_IndexColumns IC
	ON I.object_id = IC.object_id
	AND I.index_id = IC.index_id

WHERE T.name = @TargetTableName
	AND SCHEMA_NAME(T.schema_id) = @TargetSchemaName
	AND I.type <> 0
ORDER BY I.Index_id

-- Execute Script to build indexes aligned with target table
BEGIN TRY
EXEC(@SQLScript)
SET @returnstatus = 0
END TRY
BEGIN CATCH
PRINT 'Indexes Could Not be built...Make sure table exists and no indexes have been created on it.'
SET @returnstatus = 1
END CATCH

END
GO
IF OBJECT_ID('adm.Etl_CreateUnpartitionedTableSchema', 'P') IS NOT NULL
    DROP PROCEDURE adm.Etl_CreateUnpartitionedTableSchema
GO

CREATE PROCEDURE adm.Etl_CreateUnpartitionedTableSchema (
@CustomerId INT,
@ProcessId INT,
@SwitchOut INT = 0,
@returnstatus INT OUTPUT)
AS
BEGIN
-- DECLARE @ProcessId INT = 26,@CustomerId INT = 19,@SwitchOut INT = 0,@returnstatus INT;
DECLARE  @SQLScript VARCHAR(MAX) = 'CREATE TABLE '
		,@DatabaseCollation VARCHAR(255)
		,@SrcColumnList VARCHAR(MAX)
		,@StagingSchemaName CHAR(3) = 'stg'
		,@TargetSchemaName CHAR(3) = (SELECT TargetSchemaName FROM adm.Process WHERE ProcessId = @ProcessId)
		,@TargetTableName VARCHAR(255) = (SELECT TargetTableName FROM adm.Process WHERE ProcessId = @ProcessId);

--Get Database Collation ** Use in Case Column Collation is Different
SET @DatabaseCollation = (SELECT CONVERT (varchar, DATABASEPROPERTYEX(DB_NAME(),'collation')));  

-- Build Column definitions for the table.
SELECT @SrcColumnList =  COALESCE(@srcColumnList+CHAR(13)+CHAR(10)+CHAR(9)+',','')
+'['+ COLUMN_NAME +']' +' '
+ DATA_TYPE 
+ CASE WHEN DATA_TYPE in ('decimal','numeric') THEN '('+CAST(NUMERIC_PRECISION AS VARCHAR(5))+','+CAST(NUMERIC_SCALE AS VARCHAR(5))+')' ELSE '' END
+ CASE WHEN CHARACTER_MAXIMUM_LENGTH = -1 AND DATA_TYPE <> 'xml' THEN ' (MAX)' WHEN  CHARACTER_MAXIMUM_LENGTH IS NOT NULL AND DATA_TYPE not in ('text','xml') THEN ' ('+CAST(CHARACTER_MAXIMUM_LENGTH AS VARCHAR(10))+')' ELSE '' END
+ CASE WHEN COLLATION_NAME <> @DatabaseCollation THEN ISNULL(' COLLATE '+COLLATION_NAME,'') ELSE '' END
+ CASE WHEN IS_NULLABLE = 'YES' THEN ' NULL' ELSE ' NOT NULL' END 

FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = @TargetSchemaName
AND TABLE_NAME = @TargetTableName
ORDER BY ORDINAL_POSITION;

-- Put it together and add check constraint for customer use only.
SET @SQLScript = @SQLScript + @StagingSchemaName +'.'+@TargetTableName+'_Unpartitioned'+' ('+CHAR(13)+CHAR(10)+CHAR(9)
+@SrcColumnList+')WITH (DATA_COMPRESSION = PAGE);'+CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10)+

-- Only Add check constraint if table will be used for switching into main table.
CASE WHEN @SwitchOut = 0 THEN
'ALTER TABLE '+ @StagingSchemaName +'.'+@TargetTableName+'_Unpartitioned'+CHAR(13)+CHAR(10)+
'ADD CONSTRAINT CK_'+@TargetTableName+'_CustomerPartitionCheck CHECK (OdsCustomerId = '+CAST(@CustomerId AS VARCHAR(5))+');'
ELSE '' END;

BEGIN TRY
EXEC(@SQLScript)
SET @returnstatus = 0
END TRY
BEGIN CATCH
PRINT 'Could not create table...Make sure table doesn''t exists.'
SET @returnstatus = 1
END CATCH

END
GO

IF OBJECT_ID('adm.Etl_GetPostingGroupAuditId', 'P') IS NOT NULL
    DROP PROCEDURE adm.Etl_GetPostingGroupAuditId
GO

CREATE PROCEDURE adm.Etl_GetPostingGroupAuditId (
@OltpPostingGroupAuditId INT,
@PostingGroupId INT,
@CustomerId INT,
@OdsVersion VARCHAR(20),
@CoreDBVersionId INT,
@SnapshotCreateDate VARCHAR(100),
@DataExtractTypeId INT)
AS
BEGIN
-- DECLARE @OltpPostingGroupAuditId INT = 1,@PostingGroupId INT = 1,@CustomerId INT = 1,@OdsVersion VARCHAR(20) = '1.0.0.0',@CoreDBVersionId INT = 0,@SnapshotCreateDate VARCHAR(100) = '1900-01-01',@DataExtractTypeId INT = 1 

DECLARE  @PostingGroupAuditId INT
		,@LastLoadStatus VARCHAR(2)
		,@SourceServer VARCHAR(255) = (SELECT ServerName FROM adm.Customer WHERE CustomerId = @CustomerId)
		,@FullLoadProcess VARCHAR(255)
		,@LatestCoreDBVersionId INT;

-- Get Latest CoreDBVersion for the Customers Server
SELECT @LatestCoreDBVersionId = MAX(PGA.CoreDBVersionId)
FROM adm.Customer C
INNER JOIN adm.PostingGroupAudit PGA
ON C.CustomerId = PGA.CustomerId
WHERE PGA.Status = 'FI'
	AND C.ServerName = @SourceServer;

-- Check for new tables in case of full load
WITH cte_FullLoadProcesses AS(
-- Processes that have completed the full load
SELECT PA.ProcessId, P.TargetTableName
FROM adm.Process P
INNER JOIN adm.ProcessAudit PA ON P.ProcessId = PA.ProcessId
INNER JOIN adm.PostingGroupAudit PGA 
	ON PA.PostingGroupAuditId = PGA.PostingGroupAuditId
	AND PGA.CustomerId = @CustomerId 
	AND PGA.DataExtractTypeId = 0
WHERE PA.Status = 'FI')
-- Check is any new tables are in this Full Load
SELECT TOP 1 @FullLoadProcess = C.ControlFileName
FROM stg.ETL_ControlFiles C
LEFT OUTER JOIN cte_FullLoadProcesses F ON C.TargetTableName = F.TargetTableName
WHERE C.OltpPostingGroupAuditId = @OltpPostingGroupAuditId AND C.SnapshotDate = @SnapshotCreateDate AND F.ProcessId IS NULL

-- Get Status of last posting group, only move forward if completed.
SELECT TOP 1 @LastLoadStatus = Status
FROM adm.PostingGroupAudit 
WHERE CustomerId = @CustomerId
ORDER BY PostingGroupAuditId DESC

-- If the Version at the Source is higher that the Ods Version then do not create any PostingGroupAuditId
IF (CAST('/' + REPLACE(@OdsVersion,'.','.1') + '/' AS HIERARCHYID) > (SELECT MAX(CAST('/' + REPLACE(AppVersion,'.','.1') + '/' AS HIERARCHYID)) FROM adm.AppVersion))
	SET @PostingGroupAuditId = 0
ELSE
	BEGIN 
	-- Check if PostingGroup Audit id has already been created.
	SELECT TOP 1 @PostingGroupAuditId  = PostingGroupAuditId 
	FROM adm.PostingGroupAudit 
	WHERE SnapshotCreateDate = @SnapshotCreateDate 
	AND CustomerId = @CustomerId

	-- Generate Postinggroupauditid if does not already exist.
	IF (@PostingGroupAuditId IS NULL 
	AND ((@DataExtractTypeId = 0 AND (@LastLoadStatus IS NULL OR (@FullLoadProcess IS NOT NULL AND @LastLoadStatus = 'FI')))
	  OR (@DataExtractTypeId IN (1,2) AND @LastLoadStatus = 'FI')))
		INSERT INTO adm.PostingGroupAudit( 
		   OltpPostingGroupAuditId
		  ,PostingGroupId
		  ,CustomerId
		  ,Status
		  ,DataExtractTypeId
		  ,OdsVersion
		  ,CoreDBVersionId
		  ,SnapshotCreateDate
		  ,CreateDate
		  ,LastChangeDate
		)
		VALUES (@OltpPostingGroupAuditId,@PostingGroupId,@CustomerId,'S',@DataExtractTypeId,@OdsVersion,@CoreDBVersionId,@SnapshotCreateDate,GETDATE(),GETDATE())

	SELECT TOP 1 @PostingGroupAuditId  = PostingGroupAuditId 
	FROM adm.PostingGroupAudit 
	WHERE SnapshotCreateDate = @SnapshotCreateDate 
	AND CustomerId = @CustomerId
	END
-- If ever get a zero, means previous posting group was not completed or is second full load.
SELECT ISNULL(@PostingGroupAuditId,0),ISNULL(@LatestCoreDBVersionId,0);

END

GO
IF OBJECT_ID('adm.Etl_GetProcessAuditId', 'P') IS NOT NULL
    DROP PROCEDURE adm.Etl_GetProcessAuditId
GO

CREATE PROCEDURE adm.Etl_GetProcessAuditId (
@ProcessId INT,
@ControlRowCount INT,
@TotalRecordsInSource BIGINT,
@CustomerId INT,
@IsSnapshot BIT,
@PostingGroupAuditId INT,
@DataExtractTypeId INT)
AS
BEGIN
--DECLARE @ProcessId INT=26,@ControlRowCount INT = 0,@CustomerId INT=1,@IsSnapshot BIT=1,@PostingGroupAuditId INT=6,@DataExtractTypeId INT=0
DECLARE  @FullLoadStatus INT 
		,@ProcessAuditId INT;
DECLARE @InsertedRecord TABLE(ProcessAuditId INT);

DECLARE @SourceServer VARCHAR(255) = (SELECT ServerName FROm adm.Customer WHERE CustomerId = @CustomerId)

-- Set Process FullLoadStatus
IF EXISTS(SELECT TOP 1 PA.ProcessId
FROM adm.ProcessAudit PA
INNER JOIN adm.PostingGroupAudit PGA
	ON PA.PostingGroupAuditId = PGA.PostingGroupAuditId 
INNER JOIN adm.Customer C
	ON PGA.CustomerId = C.CustomerId 
WHERE PA.ProcessId = @ProcessId
-- For snapshot Tables check that the table has not been loaded for the server in Question.
	AND CASE WHEN @IsSnapshot = 1 THEN C.ServerName ELSE CAST(C.CustomerId AS VARCHAR(5)) END = CASE WHEN @IsSnapshot = 1 THEN @SourceServer ELSE CAST(@CustomerId AS VARCHAR(5)) END 
	AND PGA.DataExtractTypeId = 0
	AND PA.Status = 'FI')

SET @FullLoadStatus = 1
ELSE SET @FullLoadStatus = 0

-- Get ProcessAuditId
SELECT TOP 1 @ProcessAuditId = ProcessAuditId 
FROM adm.ProcessAudit
WHERE ProcessId = @ProcessId
AND PostingGroupAuditId = @PostingGroupAuditId
AND Status = 'I';

IF @ProcessAuditId IS NULL
INSERT INTO adm.ProcessAudit WITH (TABLOCKX)(
       PostingGroupAuditId
      ,ProcessId
      ,Status
	  ,ControlRowCount
	  ,TotalRecordsInSource
      ,CreateDate
      ,LastChangeDate)
OUTPUT INSERTED.ProcessAuditId
INTO @InsertedRecord
VALUES (@PostingGroupAuditId,@ProcessId,'S',@ControlRowCount,@TotalRecordsInSource,GETDATE(),GETDATE())

SELECT COALESCE(ProcessAuditId,@ProcessAuditId,-1),@FullLoadStatus
FROM @InsertedRecord;

END
GO

IF OBJECT_ID('adm.Etl_InsertIntoTargetFromStaging', 'P') IS NOT NULL
    DROP PROCEDURE adm.Etl_InsertIntoTargetFromStaging
GO

CREATE PROCEDURE adm.Etl_InsertIntoTargetFromStaging (
@CustomerId INT, 
@ProcessId INT,
@OdsPostingGroupAuditId INT, 
@SnapshotDate VARCHAR(50),
@DataExtractTypeId INT,
@RowsAffected INT OUTPUT,
@returnstatus INT OUTPUT)
AS
BEGIN
-- DECLARE @CustomerId INT = 9, @ProcessId INT = 26, @OdsPostingGroupAuditId INT = 0, @SnapshotDate VARCHAR(50) = '2016-02-26 16:24:37.190',@DataExtractTypeId INT = 1;
DECLARE	 @InsertSQL VARCHAR(MAX) = 'INSERT INTO '
		,@StgColumnList VARCHAR(MAX)
		,@SrcColumnList VARCHAR(MAX)
		,@TargetSchemaName CHAR(3) = (SELECT TargetSchemaName FROM adm.Process WHERE ProcessId = @ProcessId)
		,@TargetTableName VARCHAR(255) = (SELECT TargetTableName FROM adm.Process WHERE ProcessId = @ProcessId)
		,@StagingSchemaName CHAR(3) = N'stg'
		,@HashbyteFunction VARCHAR(MAX)
		,@Hashbytecolumns VARCHAR(MAX);

-- 1.0 Get column list for staging table
SELECT @stgColumnList =  COALESCE(@stgColumnList+CHAR(13)+CHAR(10)+CHAR(9)+',','')+'['+ COLUMN_NAME +']'
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = @StagingSchemaName
AND TABLE_NAME = @TargetTableName
AND COLUMN_NAME <> 'DmlOperation'
ORDER BY ORDINAL_POSITION;

-- 2.0 Get Colimn list for target table
SELECT @srcColumnList =  COALESCE(@srcColumnList+CHAR(13)+CHAR(10)+CHAR(9)+',','')+'['+ COLUMN_NAME +']'
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = @TargetSchemaName
AND TABLE_NAME = @TargetTableName
ORDER BY ORDINAL_POSITION;
	
-- 3.0 Generate Hashbyte column list and Decide function to use
IF ((SELECT HashFunctionType FROM adm.Process WHERE ProcessId = @ProcessId) = 2)
BEGIN
	-- Get Hash column list for staging table
	SELECT @Hashbytecolumns =  COALESCE(@Hashbytecolumns+CHAR(13)+CHAR(10)+CHAR(9)+'+','')+'CAST(ISNULL('+'['+ COLUMN_NAME +']'+', '''') AS VARBINARY(MAX))' 
	FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_SCHEMA = @StagingSchemaName
	AND TABLE_NAME = @TargetTableName
	AND COLUMN_NAME <> 'DmlOperation'
	ORDER BY ORDINAL_POSITION;	
	
	SET @HashbyteFunction = ',CAST(master.sys.fn_repl_hash_binary('+@Hashbytecolumns+') AS VARBINARY(8000)) OdsHashbytesValue';
END
ELSE 
	SET @HashbyteFunction = ',HASHBYTES(''SHA1'', (SELECT '+@stgColumnList+' FOR XML RAW)) OdsHashbytesValue';

-- 4.0 Insert staging data to target
SET @InsertSQL = @InsertSQL + 
CASE WHEN @DataExtractTypeId = 0 THEN @StagingSchemaName ELSE @TargetSchemaName END+'.'+@TargetTableName+
CASE WHEN @DataExtractTypeId = 0 THEN '_Unpartitioned' ELSE '' END+
' ('+@srcColumnList+') 
 SELECT	 ' +CAST(@OdsPostingGroupAuditId AS VARCHAR(10))+CHAR(13)+CHAR(10)+CHAR(9)+
		','+CAST(@CustomerId AS VARCHAR(3))+CHAR(13)+CHAR(10)+CHAR(9)+
		','''+CONVERT(VARCHAR(50),GETDATE(),121)+''''+CHAR(13)+CHAR(10)+CHAR(9)+
		','''+@SnapshotDate+''''+CHAR(13)+CHAR(10)+CHAR(9)+
		','+CASE WHEN @DataExtractTypeId IN (1,2) THEN '0' ELSE '1' END+CHAR(13)+CHAR(10)+CHAR(9)+ -- Set incr and snaps to 'isnotcurrent' until gets flipped on update.
		@HashbyteFunction+CHAR(13)+CHAR(10)+CHAR(9)+
		',DmlOperation'+CHAR(13)+CHAR(10)+CHAR(9)+
		','+@stgColumnList+CHAR(13)+CHAR(10)+CHAR(9)+
'FROM '+@StagingSchemaName+'.'+@TargetTableName+';';

BEGIN TRANSACTION InsertTrans
BEGIN TRY 
	EXEC(@InsertSQL); 
	SELECT @RowsAffected = @@ROWCOUNT,@returnstatus = 0;
COMMIT TRANSACTION InsertTrans
END TRY
BEGIN CATCH
	SELECT @RowsAffected = -1,@returnstatus = 1;
	PRINT 'Failed to load data into target table...!'
	ROLLBACK TRANSACTION InsertTrans
END CATCH

END


GO
IF OBJECT_ID('adm.Etl_ProcessLoadGroupBalancing', 'P') IS NOT NULL
    DROP PROCEDURE adm.Etl_ProcessLoadGroupBalancing
GO

CREATE PROCEDURE adm.Etl_ProcessLoadGroupBalancing
AS
BEGIN
DECLARE  @SQLScript NVARCHAR(MAX)
		,@NextLoadGroup INT;

-- Initialize Load Groups
UPDATE P
SET LoadGroup = S.LoadGroup
FROM adm.Process P
INNER JOIN (
	SELECT ProcessId
		 ,ROW_NUMBER()OVER (ORDER BY SUM(CAST(LoadRowCount AS BIGINT)) DESC) AS LoadGroup
	FROM adm.ProcessAudit
	WHERE Status = 'FI'
	GROUP BY  ProcessId) AS S
ON P.ProcessId = S.ProcessId;

-- Get Next Load Group to Assign
SET @SQLScript = '
;WITH CTE_NextLoadGroup AS(
SELECT P.LoadGroup
	  ,SUM(CAST(PA.LoadRowCount AS BIGINT)) LoadGroupSize
FROM adm.ProcessAudit PA
INNER JOIN adm.Process P
ON PA.ProcessId = P.ProcessId
WHERE PA.Status = ''FI''
	AND LoadGroup BETWEEN 1 AND 3
GROUP BY  P.LoadGroup)
SELECT TOP 1 @NextLoadGroup = LoadGroup
FROM CTE_NextLoadGroup C
INNER JOIN (
	SELECT MIN(LoadGroupSize) MinLoadGroupSize
	FROM CTE_NextLoadGroup) M ON C.LoadGroupSize = M.MinLoadGroupSize;'


DECLARE @ProcessId INT
DECLARE db_cursor_nextloadgroup  CURSOR FOR  
SELECT ProcessId
FROM adm.Process
WHERE LoadGroup > 3

OPEN db_cursor_nextloadgroup   
FETCH NEXT FROM db_cursor_nextloadgroup INTO @ProcessId

WHILE @@FETCH_STATUS = 0   
BEGIN 

EXEC sp_executesql @SQLScript,N'@NextLoadGroup INT OUTPUT',@NextLoadGroup = @NextLoadGroup OUTPUT;

UPDATE adm.Process
SET LoadGroup = @NextLoadGroup
WHERE ProcessId = @ProcessId

FETCH NEXT FROM db_cursor_nextloadgroup INTO @ProcessId

END

CLOSE db_cursor_nextloadgroup   
DEALLOCATE db_cursor_nextloadgroup

END
GO
IF OBJECT_ID('adm.Etl_QueuePostingGroupForArchive', 'P') IS NOT NULL
    DROP PROCEDURE adm.Etl_QueuePostingGroupForArchive
GO

CREATE PROCEDURE adm.Etl_QueuePostingGroupForArchive (
@CustomerId INT,
@SnapshotDate VARCHAR(50),
@DataExtractTypeId INT)
AS
BEGIN
-- DECLARE @CustomerId INT = 45,@SnapshotDate VARCHAR(50) = '2019-01-17 02:30:04.000',@DataExtractTypeId INT = 1

WITH cte_FullLoadProcesses AS(
-- Processes that have completed the full load
SELECT DISTINCT PA.ProcessId, P.TargetTableName
FROM adm.Process P
INNER JOIN adm.ProcessAudit PA ON P.ProcessId = PA.ProcessId
INNER JOIN adm.PostingGroupAudit PGA 
	ON PA.PostingGroupAuditId = PGA.PostingGroupAuditId
	AND PGA.CustomerId = @CustomerId
	AND PGA.DataExtractTypeId = 0
WHERE PA.Status = 'FI')

-- Update the Posting Group As Ready for archiving if all the processes are done.
UPDATE PGA 
SET  PGA.Status = 'A'
 ,PGA.LastChangeDate = GETDATE()
 
FROM adm.PostingGroupAudit PGA
INNER JOIN (
	-- Incrementals and Snapshots
	SELECT  PGA.PostingGroupAuditId
	FROM stg.ETL_ControlFiles F 
	INNER JOIN adm.Process P ON P.TargetTableName = F.TargetTableName
		AND P.IsActive = 1
	INNER JOIN adm.PostingGroupAudit PGA 
	ON PGA.SnapshotCreateDate = F.SnapshotDate
	AND PGA.CustomerId = @CustomerId
	LEFT OUTER JOIN adm.ProcessAudit PA
	ON PA.ProcessId = P.ProcessId
	AND PA.PostingGroupAuditId = PGA.PostingGroupAuditId
	AND PA.Status = 'FI'
	WHERE F.SnapshotDate = @SnapshotDate 
		AND @DataExtractTypeId IN (1,2)
	GROUP BY PGA.PostingGroupAuditId
	HAVING COUNT(P.ProcessId) = SUM(CASE WHEN PA.ProcessId IS NOT NULL THEN 1 ELSE 0 END)
	
	UNION 
	-- FullLoads (Also applies when new tables are added.)
	SELECT PGA.PostingGroupAuditId
	FROM stg.ETL_ControlFiles C
	INNER JOIN adm.Process P ON P.TargetTableName = C.TargetTableName
		AND P.IsActive = 1
	INNER JOIN adm.PostingGroupAudit PGA 
		ON PGA.SnapshotCreateDate = C.SnapshotDate
		AND PGA.CustomerId = @CustomerId 
	LEFT OUTER JOIN cte_FullLoadProcesses F ON C.TargetTableName = F.TargetTableName
	WHERE C.SnapshotDate = @SnapshotDate
		AND @DataExtractTypeId = 0
	GROUP BY PGA.PostingGroupAuditId
	HAVING COUNT(P.ProcessId) = SUM(CASE WHEN F.ProcessId IS NOT NULL THEN 1 ELSE 0 END)) F 

ON PGA.PostingGroupAuditId = F.PostingGroupAuditId
WHERE PGA.Status <> 'FI';
END
GO
IF OBJECT_ID('adm.Etl_ReduceStagingDataWithHashbytes', 'P') IS NOT NULL
    DROP PROCEDURE adm.Etl_ReduceStagingDataWithHashbytes
GO

CREATE PROCEDURE adm.Etl_ReduceStagingDataWithHashbytes (
@CustomerId INT,
@ProcessId INT,
@OdsPostingGroupAuditId INT,
@DataExtractTypeId INT,
@returnstatus INT OUTPUT)
AS
BEGIN
-- DECLARE @CustomerId INT = 1, @ProcessId INT = 28, @OdsPostingGroupAuditId INT = 1, @DataExtractTypeId INT = 1,@returnstatus INT;
DECLARE	 @SQLScript VARCHAR(MAX) = CAST('' AS VARCHAR(MAX))
		,@JoinClause VARCHAR(MAX)
		,@StgColumnList VARCHAR(MAX)
		,@TargetSchemaName CHAR(3) = (SELECT TargetSchemaName FROM adm.Process WHERE ProcessId = @ProcessId)
		,@TargetTableName VARCHAR(255) = (SELECT TargetTableName FROM adm.Process WHERE ProcessId = @ProcessId)
		,@IsSnapshot INT = (SELECT IsSnapshot FROM adm.Process WHERE ProcessId = @ProcessId)
		,@SourceServer VARCHAR(255) = (SELECT ServerName FROM adm.Customer WHERE CustomerId = @CustomerId)
		,@StagingSchemaName CHAR(3) = N'stg'
		,@HashbyteFunction VARCHAR(MAX)
		,@Hashbytecolumns VARCHAR(MAX)
		,@RowCount INT=0
		,@KeyColumns VARCHAR(255)
		,@KeyColumnSingle VARCHAR(255)
		,@KeyColumnCommaSeparated VARCHAR(255);
DECLARE  @KeyColumnsList TABLE (TargetColumnName VARCHAR(255));
DECLARE  @SQLScriptSP NVARCHAR(MAX) = '';

-- 1.0 Get Join Clause for the given process to Join staging and Target	
INSERT INTO @KeyColumnsList	
SELECT DISTINCT '['+I.COLUMN_NAME+']' AS TargetColumnName
FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE I
INNER JOIN adm.Process P
	ON I.TABLE_NAME = P.TargetTableName
	AND OBJECTPROPERTY(OBJECT_ID(I.CONSTRAINT_SCHEMA + '.' + I.CONSTRAINT_NAME), 'IsPrimaryKey') = 1
	AND I.TABLE_SCHEMA = @TargetSchemaName
WHERE P.TargetTableName = @TargetTableName
	AND I.COLUMN_NAME NOT IN ('OdsCustomerId','OdsPostingGroupAuditId')

-- Get one of columns that is part of the primary key	
SET @KeyColumnSingle = (SELECT TOP 1 TargetColumnName FROM @KeyColumnsList);

-- Create Join Clause	
SELECT @JoinClause =  COALESCE(@JoinClause+' AND ','')+'T.'+TargetColumnName+' = S.'+TargetColumnName
FROM @KeyColumnsList;

-- Get Key columns comma seperated
SELECT @KeyColumnCommaSeparated =  COALESCE(@KeyColumnCommaSeparated+CHAR(13)+CHAR(10)+' ,','')+TargetColumnName
FROM @KeyColumnsList;

-- Get Key columns comma seperated and aliased		
SELECT @KeyColumns =  COALESCE(@KeyColumns+CHAR(13)+CHAR(10)+CHAR(9)+',','')+'T.'+TargetColumnName
FROM @KeyColumnsList;

-- 2.0 Get Column list for Staging tables	
SELECT @stgColumnList =  COALESCE(@stgColumnList+CHAR(13)+CHAR(10)+CHAR(9)+',','')+'S.'+'['+COLUMN_NAME+']' 
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = @StagingSchemaName
AND TABLE_NAME = @TargetTableName
AND COLUMN_NAME <> 'DmlOperation'
ORDER BY ORDINAL_POSITION;

-- Build Hash value with columns, function to use depends on the process.
-- 3.0 Get Hash column list for staging table
IF ((SELECT HashFunctionType FROM adm.Process WHERE ProcessId = @ProcessId) = 2)
BEGIN
	-- Get Hash column list for staging table
	SELECT @Hashbytecolumns =  COALESCE(@Hashbytecolumns+CHAR(13)+CHAR(10)+CHAR(9)+'+','')+'CAST(ISNULL('+'['+COLUMN_NAME+']' +', '''') AS VARBINARY(MAX))' 
	FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_SCHEMA = @StagingSchemaName
	AND TABLE_NAME = @TargetTableName
	AND COLUMN_NAME <> 'DmlOperation'
	ORDER BY ORDINAL_POSITION;	
	
	SET @HashbyteFunction = ',CAST(master.sys.fn_repl_hash_binary('+@Hashbytecolumns+') AS VARBINARY(8000)) OdsHashbytesValue';
END
ELSE 
	SET @HashbyteFunction = ',HASHBYTES(''SHA1'', (SELECT '+@stgColumnList+' FOR XML RAW)) OdsHashbytesValue';

-- 4.0 Update Snapshot Data that has been deleted.
IF (@IsSnapshot = 1 OR @DataExtractTypeId = 2) 
BEGIN
	 -- Count Records In staging
	SET @SQLScriptSP = 'SELECT @RowCount = COUNT(1) FROM '+@StagingSchemaName+'.'+@TargetTableName;
	EXEC sp_executesql @SQLScriptSP,N'@RowCount INT out',@RowCount out;

	-- Only Delete records if there is data in staging to compare to. (Note If All Data is deleted at source, Target will not delete)
	IF (@RowCount > 0) 
	BEGIN
	-- This is to mark records deleted from the source to IsNotCurrent.
		SET @SQLScript =@SQLScript+
						'INSERT INTO '+@StagingSchemaName+'.'+@TargetTableName+'('+CHAR(13)+CHAR(10)+'  '+@KeyColumnCommaSeparated+CHAR(13)+CHAR(10)+' ,DmlOperation)'+CHAR(13)+CHAR(10)+
						'SELECT '+@KeyColumns+CHAR(13)+CHAR(10)+' ,''D'''+CHAR(13)+CHAR(10)+
						'FROM '+@TargetSchemaName+'.'+@TargetTableName+' T'+CHAR(13)+CHAR(10)+
						 CASE WHEN @IsSnapshot = 1 THEN -- Do this Join For Core Tables so we can filter by Server
													'INNER JOIN adm.PostingGroupAudit PGA'+CHAR(13)+CHAR(10)+CHAR(9)+
													'ON T.OdsPostingGroupAuditId = PGA.PostingGroupAuditId'+CHAR(13)+CHAR(10)+
													'INNER JOIN adm.Customer C'+CHAR(13)+CHAR(10)+CHAR(9)+
													'ON PGA.CustomerId = C.CustomerId'+CHAR(13)+CHAR(10)
						 ELSE '' END+
						'LEFT OUTER JOIN '+@StagingSchemaName+'.'+@TargetTableName+' S'+CHAR(13)+CHAR(10)+CHAR(9)+
						'ON '+@JoinClause+''+CHAR(13)+CHAR(10)+
						'WHERE '+CASE WHEN @IsSnapshot = 1 THEN 'C.ServerName = '''+@SourceServer+'''' ELSE 'T.OdsCustomerId = '+CAST(@CustomerId AS VARCHAR(3))+'' END+CHAR(13)+CHAR(10)+CHAR(9)+
						'AND T.OdsRowIsCurrent = 1'+CHAR(13)+CHAR(10)+CHAR(9)+
						'AND T.DmlOPeration <> ''D'''+CHAR(13)+CHAR(10)+CHAR(9)+
						'AND S.'+@KeyColumnSingle+' IS NULL'+';'
						
		EXEC(@SQLScript);	
	END
END

-- 5.0 Reduce Staging Data using Generated Hashbytes
SET @SQLScript = 'SELECT '+ @stgColumnList+CHAR(13)+CHAR(10)+CHAR(9)+
	',S.DmlOperation'+CHAR(13)+CHAR(10)+CHAR(9)+
	@HashbyteFunction+CHAR(13)+CHAR(10)+
'INTO '+'#'+@TargetTableName+'
FROM '+@StagingSchemaName+'.'+@TargetTableName+' S;'+CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10)+

'-- Truncate Staging Table	
TRUNCATE TABLE '+@StagingSchemaName+'.'+@TargetTableName+';'+CHAR(9)+CHAR(9)+'

;WITH cte_'+@TargetTableName+' AS ('+CHAR(13)+CHAR(10)+
 -- Do this Join For Core Tables so we can filter by Server
'SELECT '+@KeyColumns+CHAR(13)+CHAR(10)+CHAR(9)+
',T.OdsCustomerId'+CHAR(13)+CHAR(10)+CHAR(9)+
',T.OdsRowIsCurrent'+CHAR(13)+CHAR(10)+CHAR(9)+
',T.OdsHashbytesValue'+CHAR(13)+CHAR(10)+CHAR(9)+
',T.DmlOperation'+CHAR(13)+CHAR(10)+CHAR(9)+
',C.ServerName'+CHAR(13)+CHAR(10)+
'FROM '+@TargetSchemaName+'.'+@TargetTableName+' T'+CHAR(13)+CHAR(10)+
'INNER JOIN adm.PostingGroupAudit PGA'+CHAR(13)+CHAR(10)+
'ON T.OdsPostingGroupAuditId = PGA.PostingGroupAuditId'+CHAR(13)+CHAR(10)+
'INNER JOIN adm.Customer C'+CHAR(13)+CHAR(10)+
'ON PGA.CustomerId = C.CustomerId
WHERE T.OdsRowIsCurrent = 1
AND '+CASE WHEN @IsSnapshot = 1 THEN 'C.ServerName = '''+@SourceServer+'''' ELSE 'T.OdsCustomerId = '+CAST(@CustomerId AS VARCHAR(3)) END+' )

-- Reinsert Data into staging table
INSERT INTO '+@StagingSchemaName+'.'+@TargetTableName+'('+CHAR(9)+@stgColumnList+CHAR(13)+CHAR(10)+CHAR(9)+',DmlOperation)'+CHAR(9)+'
SELECT '+@stgColumnList+CHAR(13)+CHAR(10)+CHAR(9)+',S.DmlOperation
FROM '+'#'+@TargetTableName+' S
LEFT OUTER JOIN cte_'+@TargetTableName+' T
ON '+@JoinClause+CHAR(13)+CHAR(10)+
'WHERE T.OdsHashbytesValue <> S.OdsHashbytesValue'+CHAR(13)+CHAR(10)+CHAR(9)+
'OR (S.DmlOperation = ''D'' AND T.DmlOperation <>''D'')'+CHAR(13)+CHAR(10)+CHAR(9)+
'OR (S.DmlOperation <>''D'' AND T.DmlOperation = ''D'')'+CHAR(13)+CHAR(10)+CHAR(9)+
'OR T.'+@KeyColumnSingle +' IS NULL;'

BEGIN TRY
EXEC(@SQLScript);
SET @returnstatus = 0
END TRY
BEGIN CATCH
PRINT 'Data Reduction Query failed...'
SET @returnstatus = 1
END CATCH
END

GO
IF OBJECT_ID('adm.Etl_SwitchUnpartitionedTable', 'P') IS NOT NULL
    DROP PROCEDURE adm.Etl_SwitchUnpartitionedTable
GO

CREATE PROCEDURE adm.Etl_SwitchUnpartitionedTable (
@CustomerId INT,
@ProcessId INT,
@TargetNameExtension VARCHAR(100) = '',
@SwitchOut INT = 0,
@returnstatus INT OUTPUT)
AS
BEGIN

-- DECLARE @ProcessId INT = 19,@CustomerId INT = 69,@TargetNameExtension VARCHAR(100) = '_',@returnstatus INT,@SwitchOut INT = 0;
DECLARE  @SQLScript VARCHAR(MAX) = ''
		,@StagingSchemaName CHAR(3) = 'stg'
		,@TargetSchemaName CHAR(3) = (SELECT TargetSchemaName FROM adm.Process WHERE ProcessId = @ProcessId)	
		,@TargetTableName VARCHAR(255) = (SELECT TargetTableName FROM adm.Process WHERE ProcessId = @ProcessId);
-- Check switch direction and switch accordingly
IF @SwitchOut = 0
	BEGIN
	-- Make sure check constraint exists before you switch in.
	SET @SQLScript = @SQLScript +
	'IF NOT EXISTS (SELECT CONSTRAINT_NAME FROM INFORMATION_SCHEMA.CHECK_CONSTRAINTS'+CHAR(13)+CHAR(10)+
	'WHERE CONSTRAINT_NAME = ''CK_'+@TargetTableName+'_CustomerPartitionCheck'''+CHAR(13)+CHAR(10)+
	'AND CONSTRAINT_SCHEMA = '''+@StagingSchemaName+''')'+CHAR(13)+CHAR(10)+
	'ALTER TABLE '+ @StagingSchemaName +'.'+@TargetTableName+'_Unpartitioned'+CHAR(13)+CHAR(10)+
	'ADD CONSTRAINT CK_'+@TargetTableName+'_CustomerPartitionCheck CHECK (OdsCustomerId = '+CAST(@CustomerId AS VARCHAR(5))+');'+CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10)
					  
	SET @SQLScript = @SQLScript+
	'ALTER TABLE '+@StagingSchemaName+'.'+@TargetTableName+'_Unpartitioned'+ 
	' SWITCH TO '+@TargetSchemaName+'.'+@TargetTableName+@TargetNameExtension+' PARTITION '+CAST(@CustomerId AS VARCHAR(5))+';'+CHAR(13)+CHAR(10)+
	'DROP TABLE '+@StagingSchemaName+'.'+@TargetTableName+'_Unpartitioned'+'';
	END
ELSE 
	SET @SQLScript = 'ALTER TABLE '+@TargetSchemaName+'.'+@TargetTableName+@TargetNameExtension+ 
	' SWITCH PARTITION '+CAST(@CustomerId AS VARCHAR(5))+' TO '+@StagingSchemaName+'.'+@TargetTableName+'_Unpartitioned'+';'+CHAR(13)+CHAR(10)
	
-- If Indexes were successfully built, switch Partitions

BEGIN TRY
EXEC(@SQLScript)
SET @returnstatus = 0
END TRY
BEGIN CATCH
PRINT 'Could Not Switch Partitions...'
SET @returnstatus = 1
END CATCH

END

GO
IF OBJECT_ID('adm.Etl_UpdateTargetColumnsWithStaging', 'P') IS NOT NULL
    DROP PROCEDURE adm.Etl_UpdateTargetColumnsWithStaging
GO

CREATE PROCEDURE adm.Etl_UpdateTargetColumnsWithStaging (
@CustomerId INT,
@OdsPostingGroupAuditId INT,
@SnapshotDate VARCHAR(50))
AS
BEGIN
-- DECLARE @CustomerId INT = 1, @SnapshotDate VARCHAR(50) = '2018-12-14 17:32:19.000', @PostingGroupId INT = 1, @OdsPostingGroupAuditId INT = 5;

DECLARE  @ProcessId INT
		,@ProcessAuditId INT
		,@Status VARCHAR(2)
		,@IsSnapshot INT
		,@SQLQuery NVARCHAR(MAX)
		,@UpdateSQL NVARCHAR(MAX)=''
		,@JoinClause VARCHAR(MAX)
		,@DisableIdx VARCHAR(MAX)
		,@RebuildIdx VARCHAR(MAX)
		,@TargetSchemaName CHAR(3)
		,@TargetTableName VARCHAR(255)
		,@TotalUpdatedRecords INT
		,@TotalRecordsInTarget BIGINT
		,@SourceServer VARCHAR(255) = (SELECT ServerName FROM adm.Customer WHERE CustomerId = @CustomerId);

-- Check if all processes have been loaded	   
IF EXISTS (
SELECT 1
FROM stg.ETL_ControlFiles C
INNER JOIN adm.Process P ON C.TargetTableName = P.TargetTableName
	AND P.IsActive = 1
LEFT OUTER JOIN adm.ProcessAudit PA ON P.ProcessId = PA.ProcessId
	AND PA.Status IN ('I','U','FI')
	AND PA.PostingGroupAuditId = @OdsPostingGroupAuditId
WHERE C.SnapshotDate = @SnapshotDate
HAVING COUNT(DISTINCT P.ProcessId) = COUNT(DISTINCT PA.ProcessId))

BEGIN

	BEGIN TRANSACTION UpdateTrans
	BEGIN TRY 

	IF CURSOR_STATUS('global','process_cursor')>=-1
		DEALLOCATE process_cursor

	-- Get all Loaded Processes and their ProcessAuditids for update.
	DECLARE process_cursor CURSOR FOR  
	SELECT P.ProcessId, PA.ProcessAuditId,PA.Status
	FROM stg.ETL_ControlFiles C
	INNER JOIN adm.Process P ON C.TargetTableName = P.TargetTableName
	INNER JOIN adm.ProcessAudit PA ON P.ProcessId = PA.ProcessId
		AND PA.Status IN('I','U')
		AND PA.PostingGroupAuditId = @OdsPostingGroupAuditId
	WHERE C.SnapshotDate = @SnapshotDate;
	
	OPEN process_cursor ;  
	FETCH NEXT FROM process_cursor INTO @ProcessId,@ProcessAuditId,@Status;

	WHILE @@FETCH_STATUS = 0   
	BEGIN
	
	SET @TargetSchemaName= (SELECT TargetSchemaName FROM adm.Process WHERE ProcessId = @ProcessId)
	SET @TargetTableName = (SELECT TargetTableName FROM adm.Process WHERE ProcessId = @ProcessId)
	SET @IsSnapshot = (SELECT IsSnapshot FROM adm.Process WHERE ProcessId = @ProcessId)
	SET @JoinClause = NULL;
	SET @DisableIdx  = NULL;
	SET @RebuildIdx = NULL;
	 		
	SELECT @JoinClause =  COALESCE(@JoinClause+' AND ','')+'T.'+TargetColumnName+' = S.'+TargetColumnName
	FROM(
	SELECT DISTINCT I.COLUMN_NAME AS TargetColumnName
	FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE I
	INNER JOIN adm.Process P
		ON I.TABLE_NAME = P.TargetTableName
		AND OBJECTPROPERTY(OBJECT_ID(I.CONSTRAINT_SCHEMA + '.' + I.CONSTRAINT_NAME), 'IsPrimaryKey') = 1
		AND I.TABLE_SCHEMA = 'src'
	WHERE P.TargetTableName = @TargetTableName
		AND I.COLUMN_NAME NOT IN ('OdsPostingGroupAuditId','OdsCustomerId')) AS T

	-- Disable all Non Clustered Indexes
	SELECT @DisableIdx = COALESCE(@DisableIdx,'')+'ALTER INDEX '+I.name+' ON '+@TargetSchemaName+'.'+@TargetTableName+' DISABLE;'+CHAR(13)+CHAR(10)
	FROM   sys.indexes I
	INNER JOIN sys.tables T
	ON  T.object_id = I.object_id
	WHERE T.name = @TargetTableName
		AND SCHEMA_NAME(T.schema_id) = @TargetSchemaName
		AND I.type = 2

	-- Rebuild all Non Clustered Indexes
	SELECT @RebuildIdx = COALESCE(@RebuildIdx,'')+'ALTER INDEX '+I.name+' ON '+@TargetSchemaName+'.'+@TargetTableName+' REBUILD;'+CHAR(13)+CHAR(10)
	FROM   sys.indexes I
	INNER JOIN sys.tables T
	ON  T.object_id = I.object_id
	WHERE T.name = @TargetTableName
		AND SCHEMA_NAME(T.schema_id) = @TargetSchemaName
		AND I.type = 2

	-- Build Update Script for Incremental
	IF @Status = 'I'
		SET @UpdateSQL = 
		'UPDATE T'+CHAR(13)+CHAR(10)+
		'SET  T.OdsRowIsCurrent = CASE WHEN T.OdsPostingGroupAuditId = '+CAST(@OdsPostingGroupAuditId AS VARCHAR(20))+ ' THEN 1 ELSE 0 END'+CHAR(13)+CHAR(10)+
		 CASE WHEN @IsSnapshot = 1 THEN CHAR(9)+',T.OdsCustomerId = 0'+CHAR(13)+CHAR(10) ELSE '' END+
		'FROM '+@TargetSchemaName+'.'+@TargetTableName+' T'+CHAR(13)+CHAR(10)+
		CASE WHEN @IsSnapshot = 1 THEN -- Do this Join For Core Tables so we can filter by Server
								'INNER JOIN adm.PostingGroupAudit PGA'+CHAR(13)+CHAR(10)+CHAR(9)+
								'ON T.OdsPostingGroupAuditId = PGA.PostingGroupAuditId'+CHAR(13)+CHAR(10)+
								'INNER JOIN adm.Customer C'+CHAR(13)+CHAR(10)+CHAR(9)+
								'ON PGA.CustomerId = C.CustomerId'+CHAR(13)+CHAR(10)
								ELSE '' END+
		'INNER JOIN '+@TargetSchemaName+'.'+@TargetTableName+' S'+CHAR(13)+CHAR(10)+
		'	ON '+@JoinClause+CHAR(13)+CHAR(10)+
		'	AND S.OdsPostingGroupAuditId = '+CAST(@OdsPostingGroupAuditId AS VARCHAR(20))+CHAR(13)+CHAR(10)+
		'WHERE '+CASE WHEN @IsSnapshot = 1 THEN 'C.ServerName = '''+@SourceServer+'''' ELSE 'T.OdsCustomerId = '+CAST(@CustomerId AS VARCHAR(3))+'' END+CHAR(13)+CHAR(10)+CHAR(9)+
		'AND ((T.OdsRowIsCurrent = 1) OR (T.OdsRowIsCurrent = 0 AND T.OdsPostingGroupAuditId = '+CAST(@OdsPostingGroupAuditId AS VARCHAR(20))+'));'+CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10)	
	-- Build update script for fullload. 
	IF (@Status = 'U' AND @IsSnapshot = 1)
		SET @UpdateSQL = --@DisableIdx+CHAR(13)+CHAR(10)+
		'UPDATE T'+CHAR(13)+CHAR(10)+
		'SET OdsCustomerId = 0'+CHAR(13)+CHAR(10)+
		'FROM '+@TargetSchemaName+'.'+@TargetTableName+' T'+CHAR(13)+CHAR(10)+
		'WHERE T.OdsPostingGroupAuditId = '+CAST(@OdsPostingGroupAuditId AS VARCHAR(20))+CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10)--+
		--@RebuildIdx+CHAR(13)+CHAR(10)

	-- Execute Update Statement for current process
	SET @UpdateSQL = @UpdateSQL + CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10) + 'SELECT @TotalUpdatedRecords = @@ROWCOUNT'
	EXEC sp_executesql @UpdateSQL,N'@TotalUpdatedRecords INT OUT',@TotalUpdatedRecords OUT;

	-- Get Number of records in the target table based on last load
	SELECT TOP 1 @TotalRecordsInTarget = PA.TotalRecordsInTarget
	FROM adm.ProcessAudit PA WITH (NOLOCK)
	INNER JOIN adm.PostingGroupAudit PGA WITH (NOLOCK)
	ON PA.PostingGroupAuditId = PGA.PostingGroupAuditId
		AND PGA.Status = 'FI'
	INNER JOIN adm.Customer C
	ON PGA.CustomerId = C.CustomerId
	WHERE PA.Status = 'FI'
		AND CASE WHEN @IsSnapshot = 1 THEN C.ServerName ELSE CAST(C.CustomerId AS VARCHAR(5)) END  = CASE WHEN @IsSnapshot = 1 THEN @SourceServer ELSE CAST(@CustomerId AS VARCHAR(5)) END		
		AND PA.ProcessId = @ProcessId

	ORDER BY ProcessAuditId DESC

	-- Update adm.ProcessAudit Table with number of updated records
	UPDATE adm.ProcessAudit
	SET  Status = 'FI'
	 ,TotalRecordsInTarget = @TotalRecordsInTarget + (2*LoadRowCount - @TotalUpdatedRecords) - TotalDeletedRecords
	 ,LastUpdateDate = GETDATE()
	 ,UpdateRowCount = CASE WHEN @Status = 'I' THEN @TotalUpdatedRecords END
	 ,LastChangeDate = GETDATE()
	WHERE ProcessAuditId = @ProcessAuditId

	-- Check if total records in source is equal to records in target and confirm by counting records in table
	IF EXISTS(SELECT PA.ProcessAuditId FROM adm.ProcessAudit PA INNER JOIN adm.Process P ON P.ProcessId = PA.ProcessId WHERE PA.ProcessAuditId = @ProcessAuditId AND P.IsSnapshot = 0 AND ISNULL(PA.TotalRecordsInTarget,0) <> PA.TotalRecordsInSource)
	BEGIN
		-- Count Number of records in the target table
		SET @SQLQuery = '
			 SELECT @TotalRecordsInTarget = COUNT(1)'+CHAR(13)+CHAR(10)+ 
			'FROM '+@TargetSchemaName+'.'+@TargetTableName+' T WITH (NOLOCK)'+CHAR(13)+CHAR(10)+ -- Use with Nolock because we want to include records in current transaction
			'INNER JOIN adm.PostingGroupAudit PGA'+CHAR(13)+CHAR(10)+CHAR(9)+
			'ON T.OdsPostingGroupAuditId = PGA.PostingGroupAuditId'+CHAR(13)+CHAR(10)+
			'INNER JOIN adm.Customer C'+CHAR(13)+CHAR(10)+CHAR(9)+
			'ON PGA.CustomerId = C.CustomerId'+CHAR(13)+CHAR(10)+
			'WHERE T.OdsRowIsCurrent = 1'+CHAR(13)+CHAR(10)+
			'AND T.DmlOperation <> ''D'''+CHAR(13)+CHAR(10)+
			'AND '+CASE WHEN @IsSnapshot = 1 THEN 'C.ServerName = '''+@SourceServer+'''' ELSE 'T.OdsCustomerId = '+CAST(@CustomerId AS VARCHAR(3))+'' END+';'

		EXEC sp_executesql @SQLQuery ,N'@TotalRecordsInTarget BIGINT OUT',@TotalRecordsInTarget OUT;

		UPDATE adm.ProcessAudit
		SET  Status = 'FI'
		 ,TotalRecordsInTarget = @TotalRecordsInTarget
		 ,LastChangeDate = GETDATE()
		WHERE ProcessAuditId = @ProcessAuditId
	END
	  
	FETCH NEXT FROM process_cursor INTO @ProcessId,@ProcessAuditId,@Status;
	END
	
	CLOSE process_cursor;   
	DEALLOCATE process_cursor;
		
	COMMIT TRANSACTION UpdateTrans
	END TRY
	BEGIN CATCH

	IF CURSOR_STATUS('global','process_cursor')>=-1
		DEALLOCATE process_cursor

	ROLLBACK TRANSACTION UpdateTrans
	END CATCH

END

END

GO
