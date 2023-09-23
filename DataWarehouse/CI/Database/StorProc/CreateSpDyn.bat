@ECHO OFF

ECHO "CREATING DYNAMIC STORED PROCEDURES..."

If Exist spdyn.sql Del /s spdyn.sql

For /R Dynamic\ %%G IN (*.sql) do type "%%G" >> spdyn.sql

