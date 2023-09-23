@ECHO OFF
SETLOCAL DISABLEDELAYEDEXPANSION

REM Set variables.	
SET SNOWSQL_ACCOUNT=%1
SET SNOWSQL_USER=%2
SET SNOWSQL_PWD=%3
SET SNOWSQL_DATABASE=%4
SET SNOWSQL_WH=%5

REM make sure they sent in the first three parameters
IF "%~1"=="" GOTO SHOW_INSTRUCTIONS
IF "%~2"=="" GOTO SHOW_INSTRUCTIONS
IF "%~3"=="" GOTO SHOW_INSTRUCTIONS
IF "%~4"=="" GOTO MISSING_DATABASE
IF "%~5"=="" GOTO MISSING_WAREHOUSE

REM make sure they sent in the first three parameters
if "x%1"=="x" GOTO SHOW_INSTRUCTIONS
if "x%2"=="x" GOTO SHOW_INSTRUCTIONS
if "x%3"=="x" GOTO NO_BLANK_PASSWORD
if "x%4"=="x" GOTO SHOW_INSTRUCTIONS
if "x%5"=="x" GOTO SHOW_INSTRUCTIONS

ECHO generating query
CALL Data\tbldata_download.bat _working\ Data\ %SNOWSQL_DATABASE% %SNOWSQL_WH%

REM determine if they are using NT authentication or not
if /I "%SNOWSQL_USER%"=="nt" GOTO USING_NT_AUTH


ECHO downloading new data
snowsql -a %SNOWSQL_ACCOUNT% -d %SNOWSQL_DATABASE% -u %SNOWSQL_USER% --authenticator externalbrowser -f Data\tbldata_download.sql -o quiet=true -o friendly=false -o header=false -o output_format=tsv

ECHO download complete
GOTO END

:USING_NT_AUTH
ECHO getting user email
for /f "delims=" %%n in ('whoami /upn') do set userName=%%n
SET SNOWSQL_USER=%userName:@corp.int=@mitchell.com%

ECHO downloading new data using NT AUTHENTICATION
snowsql -a %SNOWSQL_ACCOUNT% -d %SNOWSQL_DATABASE% -u %SNOWSQL_USER% --authenticator externalbrowser -o output_file=%databaseOutfile%  -o quiet=true -o friendly=false -o header=false -o output_format=tsv

ECHO download complete
GOTO END

:MISSING_DATABASE
ECHO You must specify a database from which to extract data. 
GOTO END

:MISSING_WAREHOUSE
ECHO To extract data from %SNOWSQL_DATABASE%, you must specify a warehouse.
GOTO END

:SHOW_INSTRUCTIONS
ECHO Send in the name of the server, the user name, the password, the databasename, and the warehouse name
ECHO ...
ECHO Example:  download <AccountName> sa admin <DatabaseName> <Warehouse>
ECHO ...
ECHO If you are using nt authentication, replace username and password with nt.
ECHO ...
ECHO Example:  download <AccountName> nt nt <DatabaseName> <Warehouse>
GOTO END

:NO_BLANK_PASSWORD
ECHO You must specify a password.  Blank passwords are not accepted

:END
