 CREATE OR REPLACE FILE FORMAT ADM.FORMAT_FILE_DEL_TAB
 COMPRESSION = 'GZIP' 
 FIELD_DELIMITER = '\t' 
 RECORD_DELIMITER = '\n' 
 SKIP_HEADER = 0 
 FIELD_OPTIONALLY_ENCLOSED_BY = 'NONE' 
 TRIM_SPACE = FALSE 
 ERROR_ON_COLUMN_COUNT_MISMATCH = TRUE 
 ESCAPE = 'NONE' 
 ESCAPE_UNENCLOSED_FIELD = '\134' 
 DATE_FORMAT = 'AUTO' 
 TIMESTAMP_FORMAT = 'AUTO' 
 NULL_IF = ('', 'NULL', '\\N', '\x00');
 
 CREATE OR REPLACE FILE FORMAT STG.FORMAT_FILE_DEL_COMMA
COMPRESSION = 'GZIP' 
FIELD_DELIMITER = ',' 
RECORD_DELIMITER = '\n' 
SKIP_HEADER = 0 
FIELD_OPTIONALLY_ENCLOSED_BY = 'NONE' 
TRIM_SPACE = FALSE 
ERROR_ON_COLUMN_COUNT_MISMATCH = TRUE 
ESCAPE = 'NONE' 
ESCAPE_UNENCLOSED_FIELD = '\134' 
DATE_FORMAT = 'AUTO' 
TIMESTAMP_FORMAT = 'AUTO' 
NULL_IF = ('\\N');

 CREATE OR REPLACE FILE FORMAT STG.FORMAT_FILE_DEL_PIPE 
 COMPRESSION = 'GZIP' 
 FIELD_DELIMITER = '|' 
 RECORD_DELIMITER = '\n' 
 SKIP_HEADER = 0 
 FIELD_OPTIONALLY_ENCLOSED_BY = 'NONE' 
 TRIM_SPACE = FALSE 
 ERROR_ON_COLUMN_COUNT_MISMATCH = TRUE 
 ESCAPE = 'NONE' 
 ESCAPE_UNENCLOSED_FIELD = 'NONE'
 ENCODING = 'iso-8859-1' 
 DATE_FORMAT = 'AUTO' 
 TIMESTAMP_FORMAT = 'AUTO' 
 NULL_IF = ('', 'NULL', '\\N');
 
  CREATE OR REPLACE FILE FORMAT STG.FORMAT_FILE_DEL_PIPE_CARET 
 COMPRESSION = 'GZIP' 
 FIELD_DELIMITER = '^|' 
 RECORD_DELIMITER = '\n' 
 SKIP_HEADER = 0 
 FIELD_OPTIONALLY_ENCLOSED_BY = 'NONE' 
 TRIM_SPACE = FALSE 
 ERROR_ON_COLUMN_COUNT_MISMATCH = TRUE 
 ESCAPE = 'NONE' 
 ESCAPE_UNENCLOSED_FIELD = 'NONE'
 ENCODING = 'iso-8859-1'
 DATE_FORMAT = 'AUTO' 
 TIMESTAMP_FORMAT = 'AUTO' 
 NULL_IF = ('', 'NULL', '\\N');
 
 