@ECHO OFF

REM make sure they sent in the first three parameters
if "x%1"=="x" goto SHOW_INSTRUCTIONS
if "x%2"=="x" goto SHOW_INSTRUCTIONS
if "x%3"=="x" goto NO_BLANK_PASSWORD

REM determine if they are using NT authentication or not
if "%2"=="nt" goto USING_NT_AUTH
if "%2"=="NT" goto USING_NT_AUTH

goto USING_SQL_AUTH

:USING_NT_AUTH
set unameparam_=/E
set pwdparam_=
goto CHECK_DB

:USING_SQL_AUTH
set unameparam_=/U%2
set pwdparam_=/P%3

:CHECK_DB

REM determine the database they are writing to
set outfile_="%TEMP%"\SSIS_mmedisql_DM.log
:SKIPMMEDICAL

REM set directory locations for working schema/data
set workingpath_=_working\
set buildpath_=%CD%
set destinationfolder_=%4

ECHO Installation started on %1 > %outfile_%

REM let's verify the user's login info before proceeding
ECHO Checking login credentials...
ECHO Checking login credentials... >> %outfile_%
SET verified_= 0
FOR /F "tokens=1" %%A IN ('sqlcmd -S %1 %unameparam_% %pwdparam_% -Q "SET NOCOUNT ON; SELECT 1" ^| FIND "1"' ) DO SET verified_=%%A

if NOT %verified_% == 1 (
	ECHO.
	ECHO I couldn't successfully log you into the SQL Server.  Please verify your server/login/password information and try again.
	ECHO I couldn't successfully log you into the SQL Server.  Please verify your server/login/password information and try again. >> %outfile_%
	GOTO END
)

set dbcheckcount_=0

ECHO Deploying SSIS Package to Destination Server...
ECHO Deploying SSIS Package to Destination Server... >> %outfile_%
ISDeploymentWizard.exe /Silent /ModelType:Project /SourcePath:"%buildpath_%\SnowFlake Replication.ispac" /DestinationServer:"%1" /DestinationPath:"/SSISDB/%destinationfolder_%/SnowFlake Replication"

ECHO Installation finished.  Please check %outfile_% for any error messages
ECHO Installation finished. >> %outfile_%
goto END

:SHOW_INSTRUCTIONS
echo Send in the name of the server, the user name, and the password
echo as arguments.  Send the Build path_ and destination folder in SSISDB.
echo ...
echo Example:  install.bat MedServer sa admin mypath myfolder
echo ...
goto END

:NO_BLANK_PASSWORD
echo You must specify a password.  Blank passwords are not accepted
goto END


:END
