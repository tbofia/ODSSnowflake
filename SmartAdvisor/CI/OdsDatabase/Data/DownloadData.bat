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

ECHO Creating adm.Customer.txt
bcp %database_%.adm.Customer out %1adm.Customer.txt /b 10000 /c /S%2 %unameparm_% %pwdparm_% 

ECHO Creating adm.PostingGroup.txt
bcp %database_%.adm.PostingGroup out %1adm.PostingGroup.txt /b 10000 /c /S%2 %unameparm_% %pwdparm_% 

ECHO Creating adm.Process.txt
bcp %database_%.adm.Process out %1adm.Process.txt /b 10000 /c /S%2 %unameparm_% %pwdparm_% 

ECHO Creating adm.Product.txt
bcp %database_%.adm.Product out %1adm.Product.txt /b 10000 /c /S%2 %unameparm_% %pwdparm_% 

ECHO Creating adm.StatusCode.txt
bcp %database_%.adm.StatusCode out %1adm.StatusCode.txt /b 10000 /c /S%2 %unameparm_% %pwdparm_% 


