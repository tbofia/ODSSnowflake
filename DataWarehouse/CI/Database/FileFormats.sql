CREATE OR REPLACE FILE FORMAT ADM.MYTABFORMAT
TYPE = CSV
COMPRESSION = NONE
FIELD_DELIMITER = '\t'
FILE_EXTENSION = 'txt'
ERROR_ON_COLUMN_COUNT_MISMATCH = TRUE;

CREATE OR REPLACE FILE FORMAT ADM.MYZIPPEDTABFORMAT
TYPE = CSV
COMPRESSION = GZIP
FIELD_DELIMITER = '\t'
FILE_EXTENSION = 'txt.gz'
ERROR_ON_COLUMN_COUNT_MISMATCH = TRUE;

CREATE OR REPLACE FILE FORMAT ADM.MYZIPPEDPIPEFORMAT
TYPE = CSV
COMPRESSION = GZIP
FIELD_DELIMITER = '|'
FILE_EXTENSION = 'txt.gz'
ERROR_ON_COLUMN_COUNT_MISMATCH = TRUE;