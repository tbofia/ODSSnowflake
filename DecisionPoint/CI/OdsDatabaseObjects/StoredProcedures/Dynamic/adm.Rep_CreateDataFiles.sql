
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


