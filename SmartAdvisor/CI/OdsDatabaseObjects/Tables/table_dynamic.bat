@ECHO OFF

ECHO "CREATING DYNAMIC TABLE SCRIPT"
TYPE Dynamic\*.SQL > tbldyn.sql
TYPE Dynamic\ExtProp\*.sql >> tbldyn.sql