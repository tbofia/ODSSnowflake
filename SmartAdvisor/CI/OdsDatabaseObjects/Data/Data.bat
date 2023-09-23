@echo off

REM determine if they are using NT auth or not 
if "%3"=="nt" goto USING_NT_AUTH
if "%3"=="NT" goto USING_NT_AUTH

goto USING_SQL_AUTH

:USING_NT_AUTH
set unameparambcp_=/T
set unameparamosql_=/E
set pwdparam_=

goto CHECK_DB

:USING_SQL_AUTH
set unameparambcp_=/U%3
set unameparamosql_=/U%3
set pwdparam_=/P%4

REM determine which database they are writing to
:CHECK_DB
if "%5"=="" goto USEMMEDICAL
set database_=%5
set datafile_="%TEMP%"\data_%5.log
goto SKIPMMEDICAL
:USEMMEDICAL
set database_=mmedical
set datafile_="%TEMP%"\data_DM.log
:SKIPMMEDICAL

ECHO. > %datafile_%
ECHO ****************************** >> %datafile_%
ECHO *** DATA MART STATIC DATA  *** >> %datafile_%
ECHO ****************************** >> %datafile_%
ECHO. >> %datafile_%


FOR %%A IN ("%~1"*.txt) DO (

	ECHO Inserting data into %%~nA table
	ECHO Inserting data into %%~nA table >> %datafile_%
	bcp %database_%.%%~nA in "%~1%%~nA.txt" /b 10000 /c /S%2 %unameparambcp_% %pwdparam_% >> %datafile_%

)
