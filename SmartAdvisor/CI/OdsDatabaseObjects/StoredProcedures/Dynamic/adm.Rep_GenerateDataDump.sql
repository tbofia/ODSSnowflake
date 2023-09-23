IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'adm.Rep_GenerateDataDump') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE adm.Rep_GenerateDataDump
GO 

CREATE PROCEDURE adm.Rep_GenerateDataDump (
 @IsIncremental INT 
,@SnapshotDatabase VARCHAR(100)
,@SnapshotCreateDate DATETIME
,@SnapshotServer VARCHAR(255)
,@SourceServer VARCHAR(255)
,@SourceDatabase VARCHAR(100)
,@OdsCutoffPostingGroupAuditId INT
,@OdsMaxPostingGroupAuditId INT
,@ReplicationAuditId INT
,@OutputPath VARCHAR(500)
,@FileExtension VARCHAR(8) 
,@FileSize INT
,@DropSnapshot INT
)
AS	
BEGIN
SET NOCOUNT ON
-- Local Variables
DECLARE @ProcessList VARCHAR(3000)
	   ,@TotalRecordsInSource BIGINT
	   ,@CreateDate DATETIME
	   ,@ProcessId INT
	   ,@TableName VARCHAR(255)
	   ,@SchemaName VARCHAR(10)
	   ,@Status VARCHAR(5)
	   ,@MinId INT
	   ,@MaxId INT
	   ,@ChangeDate DATETIME
	   ,@LastChangeDate DATETIME
	   ,@UpdateProcessReplicationAuditQuery NVARCHAR(MAX)
	   ,@FileDelimiterQuery NVARCHAR(MAX)
	   ,@FileDelimiter VARCHAR(4) 
-- Audit Variables
DECLARE @PreviousRecordsInSource BIGINT
-- Audit Logging variables
		,@cmd VARCHAR(500)
		,@unameparam_ VARCHAR(50) = '/E'
		,@pwdparam_ VARCHAR(50) = ''
		,@SqlQuery VARCHAR(8000) = '';
-- Batch variables
DECLARE  @ReplicationDatabase VARCHAR(200) = DB_NAME()
		,@SQLSelect VARCHAR(MAX)
		,@NumberOfBatches INT
-- xp cmdshell variables
DECLARE @FileName VARCHAR(500)
-- Restart-ability Variables
DECLARE	@Res_IsRestart INT = 0

-- Errror handling variables 
DECLARE @ErrMsg VARCHAR(MAX),
		@ErrSeverity VARCHAR(MAX)

-- Validating input values    

IF (@IsIncremental IS NULL)
BEGIN
        RAISERROR ('NULL is passed. Invalid @IsIncremental Value.  Aborting.', 16, 1) WITH LOG
END
ELSE
BEGIN 
IF NOT EXISTS ( SELECT  DataExtractTypeId 
                    FROM    (values(0),(1)) DataExtractType(DataExtractTypeId)
                    WHERE   DataExtractTypeId = @IsIncremental)
        RAISERROR ('Invalid @IsIncremental Value.  Aborting.', 16, 1) WITH LOG


IF NOT EXISTS ( SELECT  1
                    FROM    sys.databases
                    WHERE   name = @SnapshotDatabase )
        RAISERROR ('@SnapshotDatabase does not exist on this server.  Aborting.', 16, 1) WITH LOG

IF OBJECT_ID('tempdb..#FilePathCheck') IS NOT NULL DROP TABLE #FilePathCheck
CREATE TABLE #FilePathCheck
(
[FILE_EXISTS]			INT NOT NULL,
[FILE_IS_DIRECTORY]		INT NOT NULL,
[PARENT_DIRECTORY_EXISTS]	INT NOT NULL,
)

INSERT INTO #FilePathCheck
EXEC master.dbo.xp_fileexist @OutputPath

IF EXISTS (SELECT 1 FROM #FilePathCheck
	WHERE [PARENT_DIRECTORY_EXISTS] = 0
	OR [FILE_IS_DIRECTORY] = 0)
	RAISERROR ('@OutputPath is not valid.  Aborting.', 16, 1) WITH LOG


BEGIN
-- Creating Temp tables for Error Handling
IF OBJECT_ID('tempdb..#CommandPromptOutput') IS NOT NULL DROP TABLE #CommandPromptOutput
    CREATE TABLE #CommandPromptOutput(
          CommandPromptOutputId INT IDENTITY(1, 1) PRIMARY KEY CLUSTERED ,
          ResultText VARCHAR(MAX));
	
IF OBJECT_ID('tempdb..#ErrorWhiteList') IS NOT NULL DROP TABLE #ErrorWhiteList
    CREATE TABLE #ErrorWhiteList(
          CommandPromptOutputId INT);

-- Creating temp table for Process List
IF OBJECT_ID('tempdb..#ProcessList') IS NOT NULL DROP TABLE #ProcessList
	CREATE TABLE #ProcessList
	(
	Id INT IDENTITY(1,1),
	ProcessId INT,
	TableName VARCHAR(255),
	SchemaName VARCHAR(10),
	Status VARCHAR(5)
	);

IF SUBSTRING(REVERSE(@OutputPath), 1, 1) <> '\'
	SET @OutputPath = @OutputPath + '\'; 


-- 1.0 Check For incompleted OdsCutoffPostingGroupAuditId in adm.PostingGroupReplicationAudit 
IF EXISTS (SELECT TOP 1 * FROM adm.PostingGroupReplicationAudit WHERE Status = 'S')
SET @Res_IsRestart = 1


IF @Res_IsRestart = 1
BEGIN
SELECT @SnapshotDatabase = SnapshotName, 
	@SnapshotCreateDate = SnapshotDate, 
	@IsIncremental = DataExtractTypeId, 
	@ReplicationAuditId = ReplicationAuditId,
	@OdsCutoffPostingGroupAuditId = CASE 
										WHEN @IsIncremental  = 0 THEN 0 
									ELSE (
										SELECT TOP 1 OdsCutoffPostingGroupAuditId 
										FROM adm.PostingGroupReplicationAudit 
										WHERE [Status] ='FI' 
										ORDER BY ReplicationAuditId DESC) 
									END,
	@OdsMaxPostingGroupAuditId = OdsCutoffPostingGroupAuditId 

	FROM adm.PostingGroupReplicationAudit 
	WHERE Status = 'S'
END


SET @LastChangeDate = FORMAT(GETDATE(),'yyyy-MM-dd hh:mm:ss')


IF EXISTS (SELECT 1 FROM adm.PostingGroupReplicationAudit 
			WHERE OdsCutoffPostingGroupAuditId = @OdsMaxPostingGroupAuditId 
				AND Status = 'FI')
BEGIN
RAISERROR ('OdsCutoffPostingGroupAuditId exists.  Aborting.', 16, 1) WITH LOG
END
ELSE
BEGIN


-- Get the Process list to generate the data extracts
SET @ProcessList = 
	'WITH CTE_LatestProcessReplication AS(
		SELECT ProcessId
			,MAX(ProcessReplicationAuditId) ProcessReplicationAuditId
		FROM '+@ReplicationDatabase+'.adm.ProcessReplicationAudit
		WHERE ReplicationAuditId = '+CAST(@ReplicationAuditId AS VARCHAR(10))+'
		GROUP BY ProcessId)
	 SELECT DISTINCT P.ProcessId
		, P.TargetTableName
		, P.TargetSchemaName 
		, CASE WHEN PR.Status IS NULL THEN ''N'' ELSE PR.Status END Status
	 FROM '+@SourceDatabase+'.adm.Process P
	 LEFT OUTER JOIN CTE_LatestProcessReplication LR
	 ON P.ProcessId = LR.ProcessId
	 LEFT OUTER JOIN '+@ReplicationDatabase+'.adm.ProcessReplicationAudit PR
	 ON LR.ProcessId = PR.ProcessId
	 AND LR.ProcessReplicationAuditId = PR.ProcessReplicationAuditId
	 WHERE P.IsActive = 1
	 AND (PR.ProcessId IS NULL OR PR.Status = ''S'')
	 ORDER BY P.ProcessId'

INSERT INTO #ProcessList
EXEC (@ProcessList)	
UPDATE #ProcessList SET SchemaName = 'adm' WHERE SchemaName = 'rpt'

-- Looping through each Process Id to generate data extracts
SELECT @MinId = MIN(Id) FROM #ProcessList
SELECT @MaxId = MAX(Id) FROM #ProcessList

WHILE @MinId <= @MaxId
BEGIN
	SET @CreateDate = FORMAT(GETDATE(), 'yyyy-MM-dd hh:mm:ss')
	SET @LastChangeDate = FORMAT(GETDATE(), 'yyyy-MM-dd hh:mm:ss')

	SELECT   @ProcessId = ProcessId
			,@TableName = TableName
			,@SchemaName = SchemaName 
			,@Status = [Status]
	FROM #ProcessList 
	WHERE Id = @MinId	

	SET @TotalRecordsInSource = 0	
	-- Get FileDelimiter for process from adm.Process
	SET @FileDelimiterQuery = 'SET @FileDelimiter = (SELECT FileColumnDelimiter 
													 FROM '+@SnapshotDatabase+'.adm.Process 
													 WHERE ProcessId = '+CAST(@ProcessId AS VARCHAR(10))+')'
	EXEC sys.sp_executesql @FileDelimiterQuery,N'@SnapshotDatabase VARCHAR(255), @ProcessId INT, @FileDelimiter VARCHAR(5) OUTPUT', @SnapshotDatabase = @SnapshotDatabase, @ProcessId = @ProcessId, @FileDelimiter = @FileDelimiter OUTPUT

	-- 2.3 Removing PII data using adm.ProcessColumn table

	EXEC adm.Rep_RemovePIIData 0,@IsIncremental,@ProcessId, @SnapshotDatabase, @OdsCutoffPostingGroupAuditId,@OdsMaxPostingGroupAuditId, @FileSize, @SQLSelect OUTPUT, @NumberOfBatches OUTPUT

	SELECT TOP 1 @PreviousRecordsInSource = TotalRecordsInSource 
	FROM adm.ProcessReplicationAudit PA
	INNER JOIN adm.PostingGroupReplicationAudit PR
	ON PA.ReplicationAuditId  = PR.ReplicationAuditId 
	AND PR.Status = 'FI'
	WHERE ProcessId = @ProcessId
	ORDER BY PR.ReplicationAuditId DESC

	-- 2.5 Updating TotalRecordsInSource in ProcessReplicationAudit
	SET @UpdateProcessReplicationAuditQuery = 
	CASE 
		WHEN @IsIncremental = 0 THEN 
					'SELECT @TotalRecordsInSource = CAST(COUNT_BIG(1) AS BIGINT) FROM '+@SnapshotDatabase+'.'+@SchemaName+'.'+@TableName

		WHEN @IsIncremental = 1 THEN
			CASE WHEN @SchemaName = 'adm' THEN 
					'SELECT @TotalRecordsInSource = '+CAST(ISNULL(@PreviousRecordsInSource,0) AS VARCHAR(25))+'+COUNT_BIG(1) 
					 FROM '+@SnapshotDatabase+'.'+@SchemaName+'.'+@TableName+' 
					 WHERE PostingGroupAuditId > '+CAST(@OdsCutoffPostingGroupAuditId AS VARCHAR(10))
					
				 ELSE 
					'SELECT @TotalRecordsInSource = '+CAST(ISNULL(@PreviousRecordsInSource,0) AS VARCHAR(25))+'+SUM(LoadRowCount) 
					 FROM '+@SnapshotDatabase+'.adm.ProcessAudit 
					 WHERE ProcessId = '+CAST(@ProcessId AS VARCHAR(10))+' 
					 AND PostingGroupAuditId > '+CAST(@OdsCutoffPostingGroupAuditId AS VARCHAR(10))
			END
	END
													 
	EXEC sys.sp_executesql @UpdateProcessReplicationAuditQuery,N'@TotalRecordsInSource BIGINT OUTPUT', @TotalRecordsInSource = @TotalRecordsInSource OUTPUT

	-- 2.2 Inserting details of data extracts in adm.ProcessReplicationAudit table	
	SET @SqlQuery = 'INSERT INTO adm.ProcessReplicationAudit
	SELECT '+CAST(@ReplicationAuditId AS VARCHAR(10))+','+CAST(@ProcessId AS VARCHAR(10))+','''+@TableName+''',''S'','+CAST(CASE WHEN @NumberOfBatches =0 THEN 1 ELSE @NumberOfBatches END AS VARCHAR(10))+','+CAST(ISNULL(@TotalRecordsInSource,@PreviousRecordsInSource) AS VARCHAR(10))+','''+CONVERT(VARCHAR(23),@CreateDate,21)+''','''+CONVERT(VARCHAR(23),@LastChangeDate,21)+'''';

	SET @cmd = 'sqlcmd -S '+@SourceServer+' '+@unameparam_+' '+@pwdparam_+' -d '+@ReplicationDatabase+' -Q"'+REPLACE(@SqlQuery,CHAR(13)+CHAR(10),' ')+'"'

	IF @Status <> 'S'
		EXEC MASTER..xp_cmdshell @cmd
	
-- 2.6 Creating File name for both Control file and Data file
	SELECT @FileName = SnapshotName + '_' 
					+	RIGHT('0000000000' + CAST(OdsCutoffPostingGroupAuditId AS VARCHAR(10)), 10) + '_' 
					+	CASE WHEN DataExtractTypeId = 0 THEN 'FULL' WHEN DataExtractTypeId = 1 THEN 'INCR' END		
    FROM    adm.PostingGroupReplicationAudit WHERE   ReplicationAuditId = @ReplicationAuditId;


-- 3.0 Insert details of data extracts in adm.ProcessFileReplication table
-- Generating Data files for each process in the NAS folder
    BEGIN TRY

	WAITFOR DELAY '00:00:05'

	EXEC adm.Rep_GenerateDataFiles  @NumberOfBatches,@ProcessId,@SQLSelect,@TableName,@FileName,@FileDelimiter,@SnapshotCreateDate,@SnapshotServer,@SourceServer,@ReplicationAuditId,@OutputPath,@FileExtension; 

	END TRY
	BEGIN CATCH
		IF XACT_STATE() <> 0
			ROLLBACK TRANSACTION	

		
		SELECT  @ErrMsg = ERROR_MESSAGE() ,
				@ErrSeverity = ERROR_SEVERITY()		

		RAISERROR (@ErrMsg, @ErrSeverity, 1) WITH LOG
		RETURN
	END CATCH	

	SET @ChangeDate = FORMAT(GETDATE(), 'yyyy-MM-dd hh:mm:ss')

	SET @SqlQuery = 'IF '+CAST(CASE WHEN @NumberOfBatches =0 THEN 1 ELSE @NumberOfBatches END AS VARCHAR(10))+' = 
	(SELECT COUNT(1)
	FROM adm.ProcessReplicationAudit P
	INNER JOIN adm.ProcessFileReplicationAudit F
	ON P.ProcessReplicationAuditId = F.ProcessReplicationAuditId
	AND F.Status = ''FI''
	WHERE ProcessId = '+CAST(@ProcessId AS VARCHAR(10))+'
	AND P.ReplicationAuditId = '+CAST(@ReplicationAuditId AS VARCHAR(10))+')
	
	UPDATE adm.ProcessReplicationAudit 
	SET [Status] = ''FI'' ,
		LastChangeDate = '''+CONVERT(VARCHAR(23),@ChangeDate,21)+'''
	WHERE ProcessId = '+CAST(@ProcessId AS VARCHAR(10))+'
	AND ReplicationAuditId = '+CAST(@ReplicationAuditId AS VARCHAR(10));

	SET @cmd = 'sqlcmd -S '+@SourceServer+' '+@unameparam_+' '+@pwdparam_+' -d '+@ReplicationDatabase+' -Q"'+REPLACE(@SqlQuery,CHAR(13)+CHAR(10),' ')+'"'

	EXEC MASTER..xp_cmdshell @cmd

	SET @MinId = @MinId + 1
END


SET @ChangeDate = FORMAT(GETDATE(), 'yyyy-MM-dd hh:mm:ss')

SET @SqlQuery = '
IF (
SELECT CASE WHEN COUNT(P.ProcessId) = COUNT(PA.ProcessId) THEN 1 ELSE 0 END
FROM '+@SourceDatabase+'.adm.Process P
LEFT OUTER JOIN adm.ProcessReplicationAudit PA
ON P.ProcessId = PA.ProcessId
AND PA.ReplicationAuditId = '+CAST(@ReplicationAuditId AS VARCHAR(10))+'
AND PA.Status = ''FI''
WHERE P.IsActive = 1) = 1

UPDATE adm.PostingGroupReplicationAudit 
SET [Status] = ''FI'', 
	LastChangeDate = '''+CONVERT(VARCHAR(23),@ChangeDate,21)+'''
WHERE ReplicationAuditId = '+CAST(@ReplicationAuditId AS VARCHAR(10));

SET @cmd = 'sqlcmd -S '+@SourceServer+' '+@unameparam_+' '+@pwdparam_+' -d '+@ReplicationDatabase+' -Q"'+REPLACE(@SqlQuery,CHAR(13)+CHAR(10),' ')+'"'

EXEC MASTER..xp_cmdshell @cmd

WAITFOR DELAY '00:00:05'

END
END

IF @DropSnapshot = 1
BEGIN
	EXEC adm.Rep_DropDatabaseSnapshot @SnapshotDatabase
END
END
END


GO


