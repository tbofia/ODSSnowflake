
IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'adm.Rep_CreateDatabaseSnapshot') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE adm.Rep_CreateDatabaseSnapshot
GO 

CREATE PROCEDURE adm.Rep_CreateDatabaseSnapshot(
@DatabaseName VARCHAR(255),
@DBSnapshotName VARCHAR(255) OUTPUT,
@SnapshotServer VARCHAR(255) OUTPUT,
@SnapshotCreateDate DATETIME2 OUTPUT)
AS
BEGIN

DECLARE  
		@Timestamp VARCHAR(14)		
        ,@Sql NVARCHAR(MAX)
        ,@ErrMsg NVARCHAR(4000)
        ,@ErrSeverity INT
        ,@CRLF NCHAR(2)	= CHAR(13) + CHAR(10) 	-- Carriage Return + Line Feed
        ,@TB NCHAR(1)	= CHAR(9) 		-- Tab character
        ,@SQ NCHAR(1)	= CHAR(39)		-- Single quote character

    --SET @DatabaseName = ISNULL(@DatabaseName, DB_NAME());

    IF NOT EXISTS ( SELECT  1
                    FROM    sys.databases
                    WHERE   name = @DatabaseName )
        RAISERROR ('@DatabaseName does not exist on this server.  Aborting.', 16, 1) WITH LOG

-- Now, let's create the SQL to create our snapshot
    SET @SnapshotCreateDate = ISNULL(@SnapshotCreateDate,GETDATE());
    SET @SnapshotCreateDate = DATEADD(ms, -DATEPART(ms, @SnapshotCreateDate), @SnapshotCreateDate); -- Remove milliseconds from date
    SET @Timestamp = CONVERT(VARCHAR(8), @SnapshotCreateDate, 112) + RIGHT('0' + CAST(DATEPART(hh, @SnapshotCreateDate) AS VARCHAR(2)), 2) + RIGHT('0' + CAST(DATEPART(mi, @SnapshotCreateDate) AS VARCHAR(2)), 2) + RIGHT('0' + CAST(DATEPART(ss, @SnapshotCreateDate) AS VARCHAR(2)), 2);
    SET @DBSnapshotName = @DatabaseName + '_' + @Timestamp;

	SET @Sql = 'CREATE DATABASE ' + @DBSnapshotName + '' + @CRLF + 'ON' 
		  
	;WITH cte_SnapshotInfo AS(
	SELECT	REVERSE(SUBSTRING(REVERSE(mf.physical_name), CHARINDEX('\', REVERSE(mf.physical_name)), 520)) + mf.name + '_' + @Timestamp + '.ss' AS SnapshotFileName ,
		mf.name AS LogicalFileName ,
		RANK() OVER (ORDER BY mf.name) AS FileSequence
	FROM	sys.master_files mf
	INNER JOIN sys.databases d ON mf.database_id = d.database_id
	WHERE     d.NAME = @DatabaseName
	AND	mf.type = 0)

	SELECT  @Sql += +CASE WHEN y.FileSequence = 1
				THEN @TB
				ELSE ' ,' + @TB
				END
		  +	'(' + 'NAME = ' + y.LogicalFileName + '' 
		  +	'  ,  FILENAME = ' + @SQ + y.SnapshotFileName + @SQ 
		  +	')' + @CRLF
	FROM cte_SnapshotInfo y

	SET @Sql = @Sql + 'AS SNAPSHOT OF ' + @DatabaseName + ';' + @CRLF

-- Now let's create the snapshot
    BEGIN TRY
        EXEC (@Sql);

        SET @SnapshotServer= @@SERVERNAME

    END TRY

    BEGIN CATCH
			IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION

        SELECT  @ErrMsg = ERROR_MESSAGE() ,
                @ErrSeverity = ERROR_SEVERITY()

		-- Drop the snapshot (it won't rollback with the transaction); if something failed at this step, 
		-- we don't want it hanging around since we'll have to recreate the snapshot anyway.
        EXEC adm.Rep_DropDatabaseSnapshot @DBSnapshotName;

        RAISERROR (@ErrMsg, @ErrSeverity, 1) WITH LOG

    END CATCH

END
GO



IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'adm.Rep_CreateDataFiles') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE adm.Rep_CreateDataFiles
GO 


CREATE PROCEDURE adm.Rep_CreateDataFiles (
 @BcpCommand VARCHAR(8000)
,@TotalRowsAffected BIGINT OUTPUT
)
AS
BEGIN
-- Creating Temp tables for Error Handling
IF OBJECT_ID('tempdb..#CommandPromptOutput') IS NOT NULL DROP TABLE #CommandPromptOutput
    CREATE TABLE #CommandPromptOutput(
          CommandPromptOutputId INT IDENTITY(1, 1) PRIMARY KEY CLUSTERED ,
          ResultText VARCHAR(MAX));
	
IF OBJECT_ID('tempdb..#ErrorWhiteList') IS NOT NULL DROP TABLE #ErrorWhiteList
    CREATE TABLE #ErrorWhiteList(
          CommandPromptOutputId INT);

INSERT INTO #CommandPromptOutput
EXEC master.sys.xp_cmdshell @BcpCommand;		

INSERT INTO #ErrorWhiteList
        ( CommandPromptOutputId
        )
        SELECT  CommandPromptOutputId
        FROM    #CommandPromptOutput
        WHERE   ResultText LIKE 'Error%Warning: BCP import with a format file will convert empty strings in delimited columns to NULL%'
		
DELETE FROM a
FROM    #CommandPromptOutput a
        INNER JOIN ( SELECT CommandPromptOutputId - 1 AS CommandPromptOutputId -- Previous line (containing error number)
                        FROM   #ErrorWhiteList
                        UNION ALL
                        SELECT CommandPromptOutputId -- Error description
                        FROM   #ErrorWhiteList ) b ON a.CommandPromptOutputId = b.CommandPromptOutputId;
IF EXISTS ( SELECT  1
            FROM    #CommandPromptOutput
            WHERE   ResultText LIKE '%Error%' )
    BEGIN
        RAISERROR ('There is a problem with our bcp command!', 16, 1)
    END

SELECT  @TotalRowsAffected = CAST(ISNULL(SUBSTRING(ResultText, 1, PATINDEX('%rows copied.%', ResultText) - 1), '0') AS INT)
FROM    #CommandPromptOutput
WHERE   ResultText LIKE '%rows copied.%';
END


GO



IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'adm.Rep_DropDatabaseSnapshot') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE adm.Rep_DropDatabaseSnapshot
GO 


CREATE PROCEDURE adm.Rep_DropDatabaseSnapshot (
@DBSnapshotName VARCHAR(100)  )
AS
BEGIN
-- DECLARE  @DBSnapshotName VARCHAR(100) = ''
    SET NOCOUNT ON

	IF EXISTS(SELECT  1
                    FROM    sys.databases
                    WHERE   name = @DBSnapshotName)
    EXEC ('DROP DATABASE ' + @DBSnapshotName + ';');

END

GO



IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'adm.Rep_GenerateControlFile') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE adm.Rep_GenerateControlFile
GO 


CREATE PROCEDURE adm.Rep_GenerateControlFile
(
@ReplicationAuditId INT,
@OutputPath VARCHAR(255),
@FileExtension VARCHAR(5),
@SourceDatabase VARCHAR(100)
)
AS
BEGIN
    SET NOCOUNT ON
DECLARE @FileName VARCHAR(100)  
	,@CFileExtension VARCHAR(4) = 'ctl' 
	,@FileColumnDelimiter VARCHAR(2) = ',' 
	,@AcsOdsVersion VARCHAR(10) 
	,@DatabaseName VARCHAR(100) = DB_NAME()
	,@SnapshotServer VARCHAR(100) = @@SERVERNAME
	,@BcpCommand VARCHAR(8000)
	,@SourceQuery VARCHAR(MAX)
	,@PreviousReplicationAuditId INT		
		
	IF OBJECT_ID('tempdb..#CPromptOutput') IS NOT NULL DROP TABLE #CPromptOutput
	CREATE TABLE #CPromptOutput
		(
        CommandPromptOutputId INT IDENTITY(1, 1) PRIMARY KEY CLUSTERED ,
        ResultText VARCHAR(MAX)
		);
	 -- Creating control file name
	SELECT @FileName = SnapshotName + '_' 
					+ RIGHT('0000000000' + CAST(OdsCutoffPostingGroupAuditId AS VARCHAR(10)), 10) + '_' 
					+  CASE WHEN DataExtractTypeId = 0 THEN 'FULL' 
							WHEN DataExtractTypeId = 1 THEN 'INCR' 
						END		
    FROM    adm.PostingGroupReplicationAudit 
	WHERE   ReplicationAuditId = @ReplicationAuditId;
	
	SELECT @PreviousReplicationAuditId = ISNULL(MAX(ReplicationAuditId),-1) 
	FROM adm.PostingGroupReplicationAudit 
	WHERE Status = 'FI' 
		AND ReplicationAuditId < @ReplicationAuditId

		-- Let's get all details that need in control file
	SET @SourceQuery = 
	'SELECT  ''' +@FileName+'.ctl'+ ''' 
			, pr.ProductName
			,CASE WHEN pr.DataExtractTypeId = 0 THEN ''FULL'' 
				  WHEN pr.DataExtractTypeId = 1 THEN ''INCR'' 
				END
	,pr.OdsCutoffPostingGroupAuditId
	, pr.SnapshotDate
	, pa.SourceTableName
	, pa.TotalNumberOfFiles
	,pf.FileNumber
	, '''+@FileName+'_'+'''+pa.SourceTableName+'''+'_''
		+CAST(pf.FileNumber AS VARCHAR(10))+'+'''.'+@FileExtension+'''
	, pf.TotalRecordsInFile
	, pa.TotalRecordsInSource
	, pr.ReplicationAuditId
	, CASE WHEN pr.DataExtractTypeId = 0 THEN -1 ELSE '+CAST(@PreviousReplicationAuditId AS VARCHAR(15))+' END
	,pr.OdsVersion
	,FileSize 	
	FROM '+@DatabaseName+'.adm.PostingGroupReplicationAudit pr 
	INNER JOIN '+@DatabaseName+'.adm.ProcessReplicationAudit pa
								ON pr.ReplicationAuditId = pa.ReplicationAuditId
	INNER JOIN '+@SourceDatabase+'.adm.Process p ON p.ProcessId = pa.ProcessId AND p.IsActive = 1
	INNER JOIN '+@DatabaseName+'.adm.ProcessFileReplicationAudit pf 
								ON pa.ProcessReplicationAuditId = pf.ProcessReplicationAuditId
	WHERE pr.ReplicationAuditId = '+CAST(@ReplicationAuditId AS VARCHAR(10))+' 
		AND pa.Status <> ''S'' 
		AND pf.Status <> ''S'''
			
	-- BCP command to export control file data
	SET @BcpCommand = 'bcp "' +REPLACE(REPLACE(@SourceQuery, CHAR(13), ' '), CHAR(10), ' ') + -- newlines are causing issues for bcp
			'" queryout ' + @OutputPath + @FileName+ '.' + @CFileExtension + ' -c -t "' + @FileColumnDelimiter + '" -S ' + @SnapshotServer + ' -T';


	INSERT  INTO #CPromptOutput
	EXEC master.sys.xp_cmdshell @BcpCommand;
END


GO


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


IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'adm.Rep_GenerateDataFiles') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE adm.Rep_GenerateDataFiles
GO 

CREATE PROCEDURE adm.Rep_GenerateDataFiles (
 @NumberOfBatches INT
,@ProcessId INT
,@SQLSelect VARCHAR(MAX)
,@TableName VARCHAR(255)
,@FileName VARCHAR(500)
,@FileDelimiter VARCHAR(4) 
,@SnapshotCreateDate DATETIME
,@SnapshotServer VARCHAR(255)
,@PrimaryServer VARCHAR(255)
,@ReplicationAuditId INT
,@OutputPath VARCHAR(500)
,@FileExtension VARCHAR(8) 

)
AS
BEGIN
DECLARE  @BatchCounter INT = 0
		,@TotalRowsAffected INT
		,@OutputSQLSelect VARCHAR(MAX)
		,@BcpCommand VARCHAR(8000)
		,@DataFileName VARCHAR(255)
		,@Size FLOAT
		,@SizeSQL VARCHAR(8000)
		-- Audit Logging variables
		,@cmd VARCHAR(500)
		,@unameparam_ VARCHAR(50) = '/E'
		,@pwdparam_ VARCHAR(50) = ''
		,@ReplicationDatabase VARCHAR(200) = DB_NAME()
		,@CreateDate DATETIME = GETDATE()
		,@ChangeDate DATETIME
		,@SqlQuery VARCHAR(8000) = '';

	-- Loop for generating multiple split files
	WHILE @BatchCounter < @NumberOfBatches OR @BatchCounter = 0
	BEGIN
		SET @OutputSQLSelect = CASE WHEN @NumberOfBatches<>0 THEN REPLACE(REPLACE(@SQLSelect,CHAR(13)+CHAR(10),' '),'<BatchId>',@BatchCounter)
									ELSE REPLACE(@SQLSelect,CHAR(13)+CHAR(10),' ')
								END
		SET @TotalRowsAffected = 0

		SET @SqlQuery = 'IF NOT EXISTS(SELECT 1 FROM adm.ProcessFileReplicationAudit WHERE ProcessReplicationAuditId = '+CAST((SELECT MAX(ProcessReplicationAuditId) FROM adm.ProcessReplicationAudit WHERE ReplicationAuditId = @ReplicationAuditId AND ProcessId = @ProcessId) AS VARCHAR(10))+' AND FileNumber = '+CAST(@BatchCounter AS VARCHAR(10))+' )
		INSERT INTO adm.ProcessFileReplicationAudit
		SELECT '+CAST((SELECT MAX(ProcessReplicationAuditId) FROM adm.ProcessReplicationAudit WHERE ReplicationAuditId = @ReplicationAuditId AND ProcessId = @ProcessId) AS VARCHAR(10))+', '+CAST(@BatchCounter AS VARCHAR(10))+', ''S'', NULL, '''+CONVERT(VARCHAR(23),@SnapshotCreateDate,21)+''', '''+CONVERT(VARCHAR(23),@CreateDate,21)+''', NULL,NULL';

		SET @cmd = 'sqlcmd -S '+@PrimaryServer+' '+@unameparam_+' '+@pwdparam_+' -d '+@ReplicationDatabase+' -Q"'+REPLACE(@SqlQuery,CHAR(13)+CHAR(10),' ')+'"'

		EXEC MASTER..xp_cmdshell @cmd
		-- Let's build our bcp command
		
		SET @BcpCommand = 'bcp "' +REPLACE(REPLACE(@OutputSQLSelect, CHAR(13), ' '), CHAR(10), ' ') + -- newlines are causing issues for bcp
			'" queryout ' + @OutputPath + @FileName+'_'+@TableName+ '_'+CAST(@BatchCounter AS VARCHAR(5))  + '.' + @FileExtension + ' -c -t "' + @FileDelimiter + '" -S ' + @SnapshotServer + ' -T';				
		
		EXEC adm.Rep_CreateDataFiles @BcpCommand, @TotalRowsAffected OUTPUT	
				
		SET @DataFileName = @FileName+'_'+@TableName+ '_'+CAST(@BatchCounter AS VARCHAR(5))  + '.' + @FileExtension;

		IF OBJECT_ID('tempdb..#tempSize') IS NOT NULL
		DROP TABLE #tempSize
		CREATE TABLE #tempSize(size VARCHAR(MAX))
		-- Get size of file from stored path
		SET @SizeSQL =  'for %I in ('+ @OutputPath + @DataFileName+') do @echo %~zI'
	
		INSERT INTO #tempSize
		EXEC MASTER..xp_cmdshell @sizeSQL
	
		BEGIN TRY
	
			SELECT @size=CAST(size AS FLOAT) FROM #tempSize WHERE size IS NOT NULL

			IF @size IS NOT NULL 
			BEGIN 
				SET @ChangeDate = FORMAT(GETDATE(), 'yyyy-MM-dd hh:mm:ss')
				-- Set file size to 0.001 if its less than that but greater than 0
				SET @SqlQuery = 'UPDATE adm.ProcessFileReplicationAudit
				SET	 FileSize = CASE WHEN ('+CAST(@size AS VARCHAR(100))+'*1.0/1024)/1024>0 and ('+CAST(@size AS VARCHAR(100))+'*1.0/1024)/1024<0.001 THEN 0.001	 ELSE ROUND(('+CAST(@size AS VARCHAR(100))+'*1.0/1024)/1024,3)    END,
					 [Status] = ''FI'', 
					 TotalRecordsInFile = '+CAST(@TotalRowsAffected AS VARCHAR(10))+', 
					 LastChangeDate = '''+CONVERT(VARCHAR(23),@ChangeDate,21)+'''
				WHERE ProcessReplicationAuditId = '+CAST((SELECT MAX(ProcessReplicationAuditId) FROM adm.ProcessReplicationAudit WHERE ReplicationAuditId = @ReplicationAuditId AND ProcessId = @ProcessId) AS VARCHAR(10))+'
				AND FileNumber = '+CAST(@BatchCounter AS VARCHAR(10));

				SET @cmd = 'sqlcmd -S '+@PrimaryServer+' '+@unameparam_+' '+@pwdparam_+' -d '+@ReplicationDatabase+' -Q"'+REPLACE(@SqlQuery,CHAR(13)+CHAR(10),' ')+'"'

				EXEC MASTER..xp_cmdshell @cmd
			END

		END TRY
		BEGIN CATCH
			IF XACT_STATE() <> 0
				ROLLBACK TRANSACTION	

			DECLARE @ErrMsg1 VARCHAR(MAX), @ErrSeverity1 VARCHAR(MAX)
			SELECT  @ErrMsg1 = @BcpCommand+'Data file not created for ProcessReplicationId:'+CAST((SELECT MAX(ProcessReplicationAuditId) FROM adm.ProcessReplicationAudit WHERE ReplicationAuditId = @ReplicationAuditId AND ProcessId = @ProcessId) AS VARCHAR)--ERROR_MESSAGE() ,
					,@ErrSeverity1 = ERROR_SEVERITY()		

			RAISERROR (@ErrMsg1, @ErrSeverity1, 1) WITH LOG
			RETURN
		END CATCH	
	
		SET @BatchCounter = @BatchCounter + 1

	END	
	
END


GO	
IF OBJECT_ID('adm.Rep_GetReplicaServerName') IS NOT NULL
    DROP PROCEDURE adm.Rep_GetReplicaServerName
GO

CREATE PROCEDURE adm.Rep_GetReplicaServerName (
@DatabaseName VARCHAR(100) = NULL)
AS
BEGIN

	-- If an AlwaysOn AG exists for this database, let's use
	-- one of the secondary replicas as the source of our
	-- data extracts.  If not, we'll just use the current server.

	SET @DatabaseName = ISNULL(@DatabaseName, DB_NAME());

    IF NOT EXISTS ( SELECT  1
                    FROM    sys.databases
                    WHERE   name = @DatabaseName )
        RAISERROR ('@DatabaseName does not exist on this server.  Aborting.', 16, 1) WITH LOG

	-- By default, use the current server
    DECLARE @ReplicaServerName SYSNAME = @@SERVERNAME;

    IF SERVERPROPERTY('IsHadrEnabled') = 1
        BEGIN
		-- Get the name of the first secondary replica (by replica_id)
            SELECT TOP 1
                    @ReplicaServerName = rcs.replica_server_name
            FROM    sys.availability_groups_cluster agc
                    INNER JOIN sys.dm_hadr_availability_replica_cluster_states rcs ON rcs.group_id = agc.group_id
                    INNER JOIN sys.dm_hadr_availability_replica_states ars ON ars.replica_id = rcs.replica_id
            WHERE   ars.role = 2 -- SECONDARY
                    AND ars.connected_state = 1 -- CONNECTED
                    AND ars.synchronization_health = 2 -- HEALTHY
			-- Make sure that this database is part of the AG cluster
                    AND EXISTS ( SELECT 1
                                 FROM   sys.dm_hadr_availability_replica_states ars1
                                        INNER JOIN sys.databases d ON ars1.replica_id = d.replica_id
                                 WHERE  d.NAME = @DatabaseName
                                        AND ars1.role = 1 -- PRIMARY
                                        AND ars.group_id = ars1.group_id )
            ORDER BY rcs.replica_id;
        END

    SELECT  @ReplicaServerName AS ReplicaServerName;
END
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'adm.Rep_RemovePIIData') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE adm.Rep_RemovePIIData
GO 


CREATE PROCEDURE adm.Rep_RemovePIIData(
@OdsCustomerId INT = 0,
@IsIncremental INT,
@ProcessId INT,
@DBSnapshotName VARCHAR(255) = NULL,
@OdsCutoffPostingGroupAuditId INT,
@OdsMaxPostingGroupAuditId INT,
@FileSize INT,
@SQLSelect VARCHAR(MAX) OUTPUT,
@NumberOfBatches INT OUTPUT)
AS
BEGIN
DECLARE  @srcColumnList VARCHAR(MAX)
		,@TargetTableName VARCHAR(255)
		,@TargetSchemaName VARCHAR(50)
		,@BatchColumnName VARCHAR(128)
		,@BatchColumnType VARCHAR(50)
		,@ColQuery VARCHAR(MAX)
		,@BatchQuery NVARCHAR(MAX)
		,@BatchColumnQuery NVARCHAR(2000)
		,@TableSQL NVARCHAR(1000)
		,@SchemaSQL NVARCHAR(1000)
		,@DBName VARCHAR(255) = DB_NAME()
		,@FileSizeQuery NVARCHAR(MAX)

	--Variable to hold data types used for replacing CRLF
DECLARE @Char VARCHAR(10) = 'CHAR'
		,@NChar VARCHAR(10) = 'NCHAR'
		,@VarChar VARCHAR(10) = 'VARCHAR'
		,@NVarChar VARCHAR(10) = 'NVARCHAR'
		,@Text VARCHAR(10) = 'TEXT'
		,@NText VARCHAR(10) = 'NTEXT'

	IF OBJECT_ID('tempdb..#ColumnLists') IS NOT NULL DROP TABLE #ColumnLists
		CREATE TABLE #ColumnLists(
		TABLE_NAME VARCHAR(50),
		COLUMN_NAME VARCHAR(150),
		ORDINAL_POSITION INT,
		TABLE_SCHEMA VARCHAR(10)
		); 		

	IF OBJECT_ID('tempdb..#FileSize') IS NOT NULL DROP TABLE #FileSize
		CREATE TABLE #FileSize(
		TableName VARCHAR(25),
		TotalRows INT,
		TotalSpaceAllocated VARCHAR(500),
		TotalSpaceUsed VARCHAR(500),
		TotalSpaceforIndex VARCHAR(500),
		TotalUnusedSpace VARCHAR(500)
		)


	SET @TableSQL  = 'SELECT @TargetTableName =  TargetTableName 
					  FROM '+@DBSnapshotName+'.adm.Process
					  WHERE ProcessId = '+CAST(@ProcessId AS VARCHAR(10))

	EXEC sys.sp_executesql @TableSQL, N'@TargetTableName VARCHAR(1000) OUTPUT, @DBSnapshotName VARCHAR(255), @ProcessId INT'
						, @DBSnapshotName = @DBSnapshotName
						, @ProcessId = @ProcessId
						, @TargetTableName = @TargetTableName OUTPUT

	SET @SchemaSQL = 'SELECT @TargetSchemaName =  TargetSchemaName 
					  FROM '+@DBSnapshotName+'.adm.Process 
					  WHERE ProcessId = '+CAST(@ProcessId AS VARCHAR(10))

	EXEC sys.sp_executesql @SchemaSQL, N'@TargetSchemaName VARCHAR(1000) OUTPUT, @DBSnapshotName VARCHAR(255), @ProcessId INT' 
						, @DBSnapshotName = @DBSnapshotName
						, @ProcessId = @ProcessId
						, @TargetSchemaName = @TargetSchemaName OUTPUT

	SET @TargetSchemaName = CASE WHEN @TargetSchemaName = 'rpt' THEN 'adm' ELSE @TargetSchemaName END



	SET @ColQuery = 'SELECT DISTINCT C.TABLE_NAME, 
								CASE WHEN PC.HoldsPII = 1 THEN 
												CASE WHEN C.DATA_TYPE IN ('''+@Char+''','''+@NChar+'''
																		 ,'''+@VarChar+''' ,'''+@NVarChar+'''
																		 ,'''+@Text+''','''+@NText+''') 
															THEN ISNULL(REPLACE(REPLACE(PC.ObfuscateWithValue, CHAR(13), ''''), CHAR(10), '''') + '' AS '' + C.COLUMN_NAME,''NULL AS '' + C.COLUMN_NAME) 
													ELSE ISNULL(PC.ObfuscateWithValue+ '' AS '' + C.COLUMN_NAME,''NULL  AS '' + C.COLUMN_NAME) 
												END
									ELSE 
												CASE WHEN C.DATA_TYPE IN ('''+@Char+''','''+@NChar+'''
																		 ,'''+@VarChar+''' ,'''+@NVarChar+'''
																		 ,'''+@Text+''','''+@NText+''')
															THEN ''REPLACE(REPLACE(''+C.COLUMN_NAME+'', CHAR(13), ''''''''), CHAR(10), '''''''')  AS '' + C.COLUMN_NAME 
													ELSE C.COLUMN_NAME 
												END 
								END ,
								C.ORDINAL_POSITION, C.TABLE_SCHEMA
					FROM '+@DBSnapshotName+'.INFORMATION_SCHEMA.COLUMNS C 
					LEFT OUTER JOIN '+@DBSnapshotName+'.adm.Process P ON C.TABLE_NAME = P.TargetTableName
					LEFT OUTER JOIN '+@DBName+'.adm.ProcessColumn PC ON P.ProcessId = PC.ProcessId AND C.COLUMN_NAME = PC.ColumnName 
					WHERE TABLE_SCHEMA = '''+@TargetSchemaName+ ''' 
							AND TABLE_NAME = '''+@TargetTableName+ ''' 
							AND (ORDINAL_POSITION <= 7 OR PC.ColumnName IS NOT NULL)
							AND P.ProcessId = '+CAST(@ProcessId AS VARCHAR(10))+ ' 
					ORDER BY ORDINAL_POSITION'; 
	
	
	INSERT INTO #ColumnLists
	EXEC (@ColQuery)
	
	-- We are filtering PII for some columns based on functions, eg. CmtLastName & PolicyNumber
	-- For those, BCP require database name appended to function call in Queryout
	-- So updating column name to append database name where ObfuscateWithValue column is function call under adm.ProcessColumn table.
	
	UPDATE #ColumnLists
	SET COLUMN_NAME = @DBName+'.'+COLUMN_NAME
	WHERE COLUMN_NAME LIKE 'dbo.%'

	SELECT @srcColumnList =  COALESCE(@srcColumnList+CHAR(13)+CHAR(10)+CHAR(9)+',','')+ COLUMN_NAME
	FROM #ColumnLists C 
	ORDER BY ORDINAL_POSITION;	

	IF @IsIncremental = 0
		BEGIN
			--dividing file size by 3 because that will expand 3 times after extracted to flat file
			SET @BatchQuery = 'SELECT @NumberOfBatches = CASE WHEN (((SUM(a.used_pages) * 8) / 1024))>'+CAST(@FileSize/3 AS VARCHAR(5))+' 
																	THEN ((((SUM(a.used_pages) * 8) / 1024))/'+CAST(@FileSize/3 AS VARCHAR(5))+'+1)
															  ELSE 1 
														 END
								FROM '+@DBSnapshotName+'.adm.process pr	
								INNER JOIN  '+@DBSnapshotName+'.sys.tables t ON t.Name = pr.TargetTableName	
								INNER JOIN  '+@DBSnapshotName+'.sys.indexes i ON t.OBJECT_ID = i.object_id
								INNER JOIN  '+@DBSnapshotName+'.sys.partitions p ON i.object_id = p.OBJECT_ID AND i.index_id = p.index_id 
								INNER JOIN  '+@DBSnapshotName+'.sys.allocation_units a ON p.partition_id = a.container_id
								LEFT OUTER JOIN  '+@DBSnapshotName+'.sys.schemas s ON t.schema_id = s.schema_id	
								WHERE s.Name = '''+@TargetSchemaName+''' AND pr.ProcessId = '+CAST(@ProcessId AS VARCHAR(10))+'
								AND p.partition_id = CASE WHEN '+CAST(@OdsCustomerId AS VARCHAR(2))+'= 0 THEN p.partition_id 
														  ELSE '+CAST(@OdsCustomerId AS VARCHAR(2))+' 
													 END'
			EXEC sys.sp_executesql @BatchQuery, N'@FileSize INT,@OdsCustomerId INT, @TargetSchemaName VARCHAR(15), @NumberOfBatches INT OUTPUT', 
									@FileSize = @FileSize,
									@OdsCustomerId = @OdsCustomerId, 
									@TargetSchemaName = @TargetSchemaName,
									@NumberOfBatches = @NumberOfBatches OUTPUT
		END
	ELSE
		BEGIN
			SET @FileSizeQuery = 
						CASE WHEN @TargetSchemaName = 'adm' 
									THEN 'USE tempdb
										  SELECT * INTO #TableTemp 
										  FROM '+@DBSnapshotName+'.'+@TargetSchemaName+'.'+@TargetTableName+' 
										  WHERE PostingGroupAuditId > '+CAST(@OdsCutoffPostingGroupAuditId AS VARCHAR(15))+'; 

										  INSERT INTO #FileSize 
										  EXEC sp_spaceused ''#TableTemp'';'
							 ELSE
										'USE tempdb
										 SELECT * INTO #TableTemp 
										 FROM '+@DBSnapshotName+'.'+@TargetSchemaName+'.'+@TargetTableName+' 
										 WHERE OdsPostingGroupAuditId > '+CAST(@OdsCutoffPostingGroupAuditId AS VARCHAR(15))+'; 

										 INSERT INTO #FileSize 
										 EXEC sp_spaceused ''#TableTemp'';' 
						END

		EXEC sp_executesql @FileSizeQuery

		SELECT @NumberOfBatches = CASE WHEN ((LEFT(TotalSpaceUsed,LEN(TotalspaceUsed)-3))/1024) > @FileSize 
											THEN (((LEFT(TotalSpaceUsed,LEN(TotalspaceUsed)-3))/1024)/@FileSize) + 1
									ELSE 1 
									END 
		FROM #FileSize

	END

	SET @BatchColumnQuery = 'SELECT @BatchColumnName  = C.ColumnName , @BatchColumnType = I.DATA_TYPE
							FROM '+@DBName+'.adm.ProcessColumn C
							INNER JOIN '+@DBSnapshotName+'.adm.Process P 
							ON C.ProcessId = P.ProcessId
							INNER JOIN '+@DBSnapshotName+'.INFORMATION_SCHEMA.COLUMNS I
							ON I.TABLE_NAME = P.TargetTableName
							AND I.COLUMN_NAME = C.ColumnName
							AND I.TABLE_SCHEMA = '''+@TargetSchemaName+ '''
							WHERE C.ProcessId = '+CAST(@ProcessId AS VARCHAR(10))+' 
								  AND C.UseForBatchProcessing = 1'

	EXEC sys.sp_executesql @BatchColumnQuery, N'@BatchColumnName VARCHAR(100) OUTPUT, @BatchColumnType VARCHAR(50) OUTPUT'
						, @BatchColumnName = @BatchColumnName OUTPUT
						, @BatchColumnType = @BatchColumnType OUTPUT;

	SET @NumberOfBatches = CASE WHEN ISNULL(@NumberOfBatches,0) < 2 THEN 0
								--When We don't have column for splitting, we'll create single big extract file.
								WHEN @BatchColumnName IS NULL THEN 0
								ELSE @NumberOfBatches 
						   END

	SET @SQLSelect = CASE WHEN @TargetSchemaName = 'adm' 
								THEN 'SELECT '+@srcColumnList+CHAR(13)+CHAR(10)+'
									  FROM '+@DBSnapshotName+'.'+@TargetSchemaName+'.'+@TargetTableName +
									CASE WHEN @NumberOfBatches > 0 
											THEN CHAR(13)+CHAR(10)+'
											WHERE ABS(CAST('+@BatchColumnName+' AS INT)  % '+CAST(@NumberOfBatches AS VARCHAR(5))+' = <BatchId> 
											AND PostingGroupAuditId > '+CAST(@OdsCutoffPostingGroupAuditId AS VARCHAR(10))+' AND PostingGroupAuditId <= '+CAST(@OdsMaxPostingGroupAuditId AS VARCHAR(10))
										WHEN @NumberOfBatches = 0 THEN ' WHERE PostingGroupAuditId > '+CAST(@OdsCutoffPostingGroupAuditId AS VARCHAR(10)) +' AND PostingGroupAuditId <= '+CAST(@OdsMaxPostingGroupAuditId AS VARCHAR(10))
									END
						 ELSE
							'SELECT '+@srcColumnList+CHAR(13)+CHAR(10)+'
								FROM '+@DBSnapshotName+'.'+@TargetSchemaName+'.'+@TargetTableName +
							CASE WHEN @NumberOfBatches > 0 
									THEN 
									CHAR(13)+CHAR(10)+'WHERE ' + 'ABS('+CASE WHEN @BatchColumnType IN ('INT','TINYINT','SMALLINT','BIGINT') THEN @BatchColumnName ELSE 'ABS(CAST(HASHBYTES(''MD5'', '+@BatchColumnName+') AS INT))' END +')  % '+CAST(@NumberOfBatches AS VARCHAR(5))+' = <BatchId> 
									 AND OdsPostingGroupAuditId > '+CAST(@OdsCutoffPostingGroupAuditId AS VARCHAR(10)) +' AND OdsPostingGroupAuditId <= '+CAST(@OdsMaxPostingGroupAuditId AS VARCHAR(10)) 
								WHEN @NumberOfBatches = 0 
									THEN 
									CHAR(13)+CHAR(10)+'WHERE OdsPostingGroupAuditId > '+CAST(@OdsCutoffPostingGroupAuditId AS VARCHAR(10)) +' AND OdsPostingGroupAuditId <= '+CAST(@OdsMaxPostingGroupAuditId AS VARCHAR(10)) 
							END
					END

	END



GO



IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'adm.Rep_RollbackReplicationAuditId') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE adm.Rep_RollbackReplicationAuditId
GO 

CREATE PROCEDURE adm.Rep_RollbackReplicationAuditId
(
@ReplicationAuditId INT
)
AS
BEGIN
DECLARE @ProcessReplicationAuditId INT

IF NOT EXISTS (SELECT 1 FROM adm.PostingGroupReplicationAudit WHERE ReplicationAuditId = @ReplicationAuditId)
RAISERROR ('ReplicationAudiId does not exists. Aborting.', 16, 1) WITH LOG
	ELSE
	BEGIN
	-- Get the associated ProcessReplicationAuditId for the provided ReplicationAuditId
	SELECT @ProcessReplicationAuditId = MIN(ProcessReplicationAuditId) FROM adm.ProcessReplicationAudit WHERE ReplicationAuditId = @ReplicationAuditId
	-- Deleting rows from ProcessFileReplicationAudit
	DELETE FROM adm.ProcessFileReplicationAudit WHERE ProcessReplicationAuditId >= @ProcessReplicationAuditId
	-- Deleting rows from ProcessReplicationAudit
	DELETE FROM adm.ProcessReplicationAudit WHERE ReplicationAuditId >= @ReplicationAuditId
	-- Deleting rows from PostingGroupReplicationAudit
	DELETE FROM adm.PostingGroupReplicationAudit WHERE ReplicationAuditId >= @ReplicationAuditId
	END
END

GO