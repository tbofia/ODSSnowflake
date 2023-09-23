@ECHO OFF

REM make sure they sent in the first three parameters
if "x%1"=="x" goto SHOW_INSTRUCTIONS
if "x%2"=="x" goto SHOW_INSTRUCTIONS
if "x%3"=="x" goto NO_BLANK_PASSWORD
if "x%4"=="x" goto SHOW_INSTRUCTIONS

REM determine if they are using NT authentication or not
if "%2"=="nt" goto USING_NT_AUTH
if "%2"=="NT" goto USING_NT_AUTH

goto USING_SQL_AUTH

:USING_NT_AUTH
set unameparam_=/E
set pwdparam_=
goto SET_DB

:USING_SQL_AUTH
set unameparam_=/U%2
set pwdparam_=/P%3

:SET_DB
set database_=%4

ECHO ETL Meta-data download started on %1:%4

ECHO downloading new data
call data\downloaddata.bat data\ %1 %2 %3 %database_%

ECHO download complete
goto END

:SHOW_INSTRUCTIONS
echo Send in the name of the server, the user name, the password, and the databasename
echo ...
echo Example:  download MedServer sa admin mmedical
echo ...
echo If you are using nt authentication, replace username and password with nt.
echo ...
echo Example:  download MedServer nt nt mmedical
goto END

:NO_BLANK_PASSWORD
echo You must specify a password.  Blank passwords are not accepted

:END

