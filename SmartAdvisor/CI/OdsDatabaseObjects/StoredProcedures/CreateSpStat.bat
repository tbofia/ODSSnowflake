@ECHO OFF

ECHO "CREATING STATIC STORED PROCEDURES..."

type  static\*.sql > spstat.sql
