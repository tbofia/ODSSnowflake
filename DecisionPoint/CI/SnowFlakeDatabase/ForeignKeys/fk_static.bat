@ECHO OFF

ECHO "CREATING STATIC FOREIGN KEYS..."

type  Static\*.sql > fkstat.sql
