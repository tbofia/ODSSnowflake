@ECHO OFF

ECHO "CREATING STATIC TABLE SCRIPTS"
TYPE Static\*.SQL > tblstat.sql
TYPE Static\ExtProp\*.sql >> tblstat.sql
