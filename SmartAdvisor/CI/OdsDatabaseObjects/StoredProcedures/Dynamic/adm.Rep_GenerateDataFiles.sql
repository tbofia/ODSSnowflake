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
		IF(LEN(@OutputSQLSelect)>8000)
		BEGIN
			SET @OutputSQLSelect = REPLACE(@OutputSQLSelect,'FROM ','INTO ##'+@FileName+'_'+@TableName+CHAR(13)+CHAR(10)+'FROM ')
			EXEC(@OutputSQLSelect)
			SET @BcpCommand = 'bcp ##'+@FileName+'_'+@TableName+' out ' + @OutputPath + @FileName+'_'+@TableName+ '_'+CAST(@BatchCounter AS VARCHAR(5))  + '.' + @FileExtension + ' -c -t "' + @FileDelimiter + '" -S ' + @SnapshotServer + ' -T';
		END
		ELSE
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

				IF(LEN(@OutputSQLSelect)>8000) 
				BEGIN 
				SET @OutputSQLSelect = 'DROP TABLE ##'+@FileName+'_'+@TableName
				EXEC(@OutputSQLSelect)
				END
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
