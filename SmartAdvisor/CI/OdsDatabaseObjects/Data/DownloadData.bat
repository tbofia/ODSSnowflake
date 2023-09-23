@echo off

REM determine if they are using NT authentication or not
if "%3"=="nt" goto USING_NT_AUTH
if "%3"=="NT" goto USING_NT_AUTH

goto USING_SQL_AUTH

:USING_NT_AUTH
set unameparm_=/T
set pwdparm_=
goto SET_DB

:USING_SQL_AUTH
set unameparm_=/U%3
set pwdparm_=/P%4

:SET_DB
set database_=%5

ECHO Creating adm.DataTypeMapping.txt
bcp %database_%.adm.DataTypeMapping out %1adm.DataTypeMapping.txt /b 10000 /c /S%2 %unameparm_% %pwdparm_% 

ECHO Creating adm.ProcessColumn.txt
bcp %database_%.adm.ProcessColumn out %1adm.ProcessColumn.txt /b 10000 /c /S%2 %unameparm_% %pwdparm_% 



