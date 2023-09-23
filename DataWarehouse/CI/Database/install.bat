@ECHO OFF
SETLOCAL DISABLEDELAYEDEXPANSION

REM Set variables.	
SET SNOWSQL_ACCOUNT=%1
SET SNOWSQL_USER=%2
SET SNOWSQL_PWD=%3
SET SNOWSQL_DATABASE=%4

REM make sure they sent in the first three parameters
IF "%~1"=="" GOTO SHOW_INSTRUCTIONS
IF "%~2"=="" GOTO SHOW_INSTRUCTIONS
IF "%~3"=="" GOTO SHOW_INSTRUCTIONS
IF "%~4"=="" GOTO MISSING_DATABASE

REM Clear optional parameters (for concurrent usage on same cmd window).
SET "warehouseFlag="
SET "logFilePathFlag="
SET "baseFileNameFlag="
SET "argument="
SET "SNOWSQL_WH="
SET "logFilePath="
SET "baseFileName="
SET "snowflakeOutfile="
SET "databaseOutfile="
SET "userName="
SET "userPassword="
SET "userAuthenticator="
SET "installFile="
SET "DWSIZE="


:CHECK_DB

REM Now, we're going to clear out the mandatory parameters that
REM we've saved above...
SHIFT & SHIFT & SHIFT & SHIFT

REM ... and start sorting though the optional flags.
SETLOCAL ENABLEDELAYEDEXPANSION
:ARGLOOP
IF NOT "%~1"=="" (

	REM Fail if any unknown flags are passed
    IF NOT "%~1"=="/w" (
		IF NOT "%~1"=="/p" (
			IF NOT "%~1"=="/f" (
				ECHO ERROR: %~1 is not a recognized optional parameter.  Only acceptable optional parameters are /w, /p, and /f.
				GOTO :END
			)
		)
	)	

	REM Check for view flag
	IF "%~1"=="/w" (

		SET warehouseFlag=%~1
		SET argument=%~2
		
		REM Is there an associated argument?
		IF NOT "!argument:~0,1!"=="/" (
			SET SNOWSQL_WH=!argument!
			SHIFT
		)
	)	
	
	REM Check for path flag
    IF "%~1"=="/p" (

		SET logFilePathFlag=%~1
		SET argument=%~2
		
		REM Is there an associated argument?
		IF NOT "!argument:~0,1!"=="/" (
			SET logFilePath=!argument!
			SHIFT
			
			REM If last character in path is "\", remove it
			IF "!logFilePath:~-1!"=="\" (
				SET logFilePath=!logFilePath:~0,-1!
			)
			
			REM Does this path exist?
			IF NOT EXIST "!logFilePath!" (
				ECHO.
				ECHO ERROR: The path !logFilePath! does not exist.  Please create this path before deployment.
				GOTO :END
			)
			
		)
	)

	REM Check for file name flag
    IF "%~1"=="/f" (

		SET baseFileNameFlag=%~1
		SET argument=%~2
		
		REM Is there an associated argument?
		IF NOT "!argument:~0,1!"=="/" (
			SET baseFileName=!argument!
			SHIFT
			
			REM Change "\" to "_" for SQL Server named instances included in file name
			SET baseFileName=!baseFileName:\=_!

			REM If a user passes a ".", let's replace it with "_".  These files will now always
			REM have the .log extension.
			SET baseFileName=!baseFileName:.=_!

			REM Ensure we don't have restricted characters in file name trying to use them as 
			REM delimiters and requesting the second token in the line
			FOR /f tokens^=2^ delims^=^<^>^:^"^/^\^|^?^*^ eol^= %%y IN ("[!baseFileName!]") DO (
				REM If we are here there is a second token, so, there is a special character
				ECHO ERROR: Non allowed characters in file name !baseFileName!
				GOTO :END
			)
		)
	)
	
	REM move to next argument, reset argument variable, and start loop again
	SHIFT
	SET "argument="
	GOTO :ARGLOOP
)	

SETLOCAL DISABLEDELAYEDEXPANSION

IF "%SNOWSQL_WH%" == ""  GOTO MISSING_WAREHOUSE

REM defaults to optional parameters
IF "%logFilePath%" == "" (
	SET logFilePath=%TEMP%
)
IF "%baseFileName%" == "" (
	SET baseFileName=%SNOWSQL_DATABASE%
)

REM set outfile variables
IF "%snowflakeOutfile%" == "" (
	SET snowflakeOutfile="%logFilePath%\%basefilename%_snowflake.log"
)
IF "%databaseOutfile%" == "" (
	SET databaseOutfile="%logFilePath%\%basefilename%_mmedisql.log"
)

REM Initialize outfile.
ECHO Installation started on %SNOWSQL_ACCOUNT%:%SNOWSQL_DATABASE%
ECHO [%date:~10,4%-%date:~4,2%-%date:~7,2% %time:~0,8%]: Installation started on %SNOWSQL_ACCOUNT%:%SNOWSQL_DATABASE% > %databaseOutfile%

:SET_WORKING_PATHS
ECHO Setting working paths.
ECHO [%date:~10,4%-%date:~4,2%-%date:~7,2% %time:~0,8%]: Setting working paths. >> %databaseOutfile%
SET workingPath=_working\

ECHO Creating Data Loading Script for Put.
ECHO [%date:~10,4%-%date:~4,2%-%date:~7,2% %time:~0,8%]: Creating Data Loading Script for Put. >> %databaseOutfile%
CALL Data\tbldata_put.bat Data\ %SNOWSQL_DATABASE%

ECHO Creating Data Loading Script for Copy.
ECHO [%date:~10,4%-%date:~4,2%-%date:~7,2% %time:~0,8%]: Creating Data Loading Script for Copy. >> %databaseOutfile%
CALL Data\tbldata_copy.bat Data\ %SNOWSQL_DATABASE%

break>%snowflakeOutfile%

REM Setup Parameter Value
FOR /f "delims=" %%n in ('whoami /upn') do SET userName=%%n
IF /I "%SNOWSQL_USER%"=="nt" (
    ECHO getting user email
	SET SNOWSQL_USER=%userName:@corp.int=@mitchell.com%
	SET userPassword=
	SET userAuthenticator=externalbrowser
) ELSE (
	SET userPassword=--variable SNOWSQL_PWD=%SNOWSQL_PWD%
	SET userAuthenticator=snowflake
)

ECHO Deploying Database Objects.
IF EXIST "%workingPath%" (
    SET installFile=install_dev.snowsql
) ELSE (
    SET installFile=install_prod.snowsql
)

ECHO Doing the Install..calling snowsql

snowsql -a %SNOWSQL_ACCOUNT% -d %SNOWSQL_DATABASE% -u %SNOWSQL_USER% %userPassword% --authenticator %userAuthenticator% -f %installFile% -o output_file=%snowflakeOutfile% -o quiet=true -o header=false -o timing=false -o output_format=plain -o friendly=false -o variable_substitution=true -D DB_NAME=%SNOWSQL_DATABASE% -D SNOWSQL_WH=%SNOWSQL_WH% -D DWSIZE=%SNOWSQL_WH% 


findstr /v /r /c:"^$" /c:"^[\ \	]*$" %snowflakeOutfile% >> %snowflakeOutfile%.log
move /y  %snowflakeOutfile%.log %snowflakeOutfile% > nul

findstr /v /i "successfully succeeded" %snowflakeOutfile% >> %databaseOutfile%

ECHO Installation finished.  Please check %snowflakeOutfile% and %databaseOutfile% for any error messages.
ECHO [%date:~10,4%-%date:~4,2%-%date:~7,2% %time:~0,8%]: Installation finished. >> %databaseOutfile%

GOTO END

:MISSING_DATABASE
ECHO You must specify a database to which to deploy.  This no longer defaults to mmedical.
ECHO(

:MISSING_WAREHOUSE
ECHO To deploy tasks associated with the ODS, you must specify a warehouse.  This no longer defaults to WH_ETL_XS.
ECHO(

:SHOW_INSTRUCTIONS
ECHO Send in the name of the server, the user name, the password, 
ECHO and the database as arguments. You can also pass along the following optional parameters:
ECHO * /w - Warhouse used for tasks (ignored if no tasks are created)
ECHO * /p - The path where the log file should be written (the default is %TEMP%).
ECHO * /f - The base name and extension of our log files (the default is SNOWSQL_DATABASE_mmedisql.log).
ECHO(
ECHO If a supplied database name does  not exist, you will be given an opporunity 
ECHO to have the script create the database for you.
ECHO(
ECHO Example:  install MedServer sa admin mmedical
ECHO Example:  install MyServer nt nt mmedical
ECHO Example:  install MyServer sa admin mmedical /w WH_ETL_XS
ECHO Example:  install MyServer sa admin mmedical /p c:\temp
ECHO Example:  install MyServer sa admin mmedical /f MyFileLogName
ECHO(
GOTO END

:DATABASE_DOES_NOT_EXIST
ECHO ERROR: %SNOWSQL_DATABASE% db creation failed!
ECHO [%date% %time%]: ERROR: %SNOWSQL_DATABASE% db creation failed! >> %databaseOutfile%

:END

ENDLOCAL

REM NOTES:
REM Use ECHO( instead of ECHO. to create an empty line:
REM https://www.dostips.com/forum/viewtopic.php?f=3&t=774&start=0&hilit=echo+blank+line

