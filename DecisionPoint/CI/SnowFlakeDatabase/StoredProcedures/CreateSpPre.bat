@ECHO OFF

ECHO "CREATING STATIC STORED PROCEDURES..."
break>sppre.sql
For /R PreDeployment\ %%G IN (*.sql) do type "%%G" >> sppre.sql