@ECHO OFF

ECHO "CREATING STATIC VIEWS..."

type Static\Before\*.sql > vwstat.sql
type Static\*.sql >> vwstat.sql