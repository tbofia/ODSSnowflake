@ECHO OFF

ECHO "CREATING DYNAMIC TABLE SCRIPT"

If Exist tbldyn.sql Del /s tbldyn.sql

For /R Dynamic\ %%G IN (*.sql) do type "%%G" >> tbldyn.sql


