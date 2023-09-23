@ECHO OFF

ECHO "CREATING STATIC VIEWS..."

type Static\*.sql > vwstat.sql
type Static\After\*.sql >> vwstat.sql
