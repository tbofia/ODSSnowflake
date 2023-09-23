@ECHO OFF

ECHO "CREATING Tasks"
TYPE Static\*.sql > taskstat.sql

SETLOCAL DISABLEDELAYEDEXPANSION

break>"%FILE_PATH%"taskstat_resume.sql

FOR %%A IN (Static\*.sql) DO (
	SETLOCAL ENABLEDELAYEDEXPANSION
	SET TASK_NAME=%%~nA
	
	IF /I !TASK_NAME! == ADM.ETL_Snowflake_Ods_Load (
		echo ALTER TASK !TASK_NAME! SET USER_TASK_TIMEOUT_MS = 10800000; >> taskstat_resume.sql
	) 
	echo ALTER TASK !TASK_NAME! RESUME; >> taskstat_resume.sql
	SETLOCAL DISABLEDELAYEDEXPANSION
)

SETLOCAL DISABLEDELAYEDEXPANSION

findstr /v /r /c:"^$" /c:"^[\ \	]*$" "taskstat_resume.sql" >> "taskstat_resume_temp.sql"
move /y  taskstat_resume_temp.sql "taskstat_resume.sql"

