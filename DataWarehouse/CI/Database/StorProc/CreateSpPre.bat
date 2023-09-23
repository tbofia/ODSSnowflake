@ECHO OFF

ECHO "CREATING STATIC STORED PROCEDURES..."

type  PreDeployment\*.sql > sppre.sql
