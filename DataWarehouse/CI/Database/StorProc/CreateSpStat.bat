@ECHO OFF

ECHO "CREATING STATIC STORED PROCEDURES..."

type  Static\*.sql > spstat.sql
