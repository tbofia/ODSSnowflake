USE ROLE DB_DEV; 
 
USE WAREHOUSE WH_ETL_XS; 
 
COPY INTO @ACSODS_VLAB.adm.%Customer/unload/adm.Customer.txt 
FROM ACSODS_VLAB.adm.Customer 
FILE_FORMAT = ( 
    FORMAT_NAME = 'ADM.FORMAT_FILE_DEL_TAB' 
    EMPTY_FIELD_AS_NULL = FALSE 
    COMPRESSION = NONE 
) 
SINGLE = TRUE 
OVERWRITE = TRUE; 
 
GET @ACSODS_VLAB.adm.%Customer/unload/adm.Customer.txt file://C:\tfs\CSG\Enterprise\Database\OperationalDataStore\Snowflake\DecisionPoint\CI\SnowFlakeDatabase\Data\; 
 
 
COPY INTO @ACSODS_VLAB.adm.%Data_Extract_Type/unload/adm.Data_Extract_Type.txt 
FROM ACSODS_VLAB.adm.Data_Extract_Type 
FILE_FORMAT = ( 
    FORMAT_NAME = 'ADM.FORMAT_FILE_DEL_TAB' 
    EMPTY_FIELD_AS_NULL = FALSE 
    COMPRESSION = NONE 
) 
SINGLE = TRUE 
OVERWRITE = TRUE; 
 
GET @ACSODS_VLAB.adm.%Data_Extract_Type/unload/adm.Data_Extract_Type.txt file://C:\tfs\CSG\Enterprise\Database\OperationalDataStore\Snowflake\DecisionPoint\CI\SnowFlakeDatabase\Data\; 
 
 
COPY INTO @ACSODS_VLAB.adm.%Event/unload/adm.Event.txt 
FROM ACSODS_VLAB.adm.Event 
FILE_FORMAT = ( 
    FORMAT_NAME = 'ADM.FORMAT_FILE_DEL_TAB' 
    EMPTY_FIELD_AS_NULL = FALSE 
    COMPRESSION = NONE 
) 
SINGLE = TRUE 
OVERWRITE = TRUE; 
 
GET @ACSODS_VLAB.adm.%Event/unload/adm.Event.txt file://C:\tfs\CSG\Enterprise\Database\OperationalDataStore\Snowflake\DecisionPoint\CI\SnowFlakeDatabase\Data\; 
 
 
COPY INTO @ACSODS_VLAB.adm.%Posting_Group/unload/adm.Posting_Group.txt 
FROM ACSODS_VLAB.adm.Posting_Group 
FILE_FORMAT = ( 
    FORMAT_NAME = 'ADM.FORMAT_FILE_DEL_TAB' 
    EMPTY_FIELD_AS_NULL = FALSE 
    COMPRESSION = NONE 
) 
SINGLE = TRUE 
OVERWRITE = TRUE; 
 
GET @ACSODS_VLAB.adm.%Posting_Group/unload/adm.Posting_Group.txt file://C:\tfs\CSG\Enterprise\Database\OperationalDataStore\Snowflake\DecisionPoint\CI\SnowFlakeDatabase\Data\; 
 
 
COPY INTO @ACSODS_VLAB.adm.%Process/unload/adm.Process.txt 
FROM ACSODS_VLAB.adm.Process 
FILE_FORMAT = ( 
    FORMAT_NAME = 'ADM.FORMAT_FILE_DEL_TAB' 
    EMPTY_FIELD_AS_NULL = FALSE 
    COMPRESSION = NONE 
) 
SINGLE = TRUE 
OVERWRITE = TRUE; 
 
GET @ACSODS_VLAB.adm.%Process/unload/adm.Process.txt file://C:\tfs\CSG\Enterprise\Database\OperationalDataStore\Snowflake\DecisionPoint\CI\SnowFlakeDatabase\Data\; 
 
 
COPY INTO @ACSODS_VLAB.adm.%Process_Format_Files/unload/adm.Process_Format_Files.txt 
FROM ACSODS_VLAB.adm.Process_Format_Files 
FILE_FORMAT = ( 
    FORMAT_NAME = 'ADM.FORMAT_FILE_DEL_TAB' 
    EMPTY_FIELD_AS_NULL = FALSE 
    COMPRESSION = NONE 
) 
SINGLE = TRUE 
OVERWRITE = TRUE; 
 
GET @ACSODS_VLAB.adm.%Process_Format_Files/unload/adm.Process_Format_Files.txt file://C:\tfs\CSG\Enterprise\Database\OperationalDataStore\Snowflake\DecisionPoint\CI\SnowFlakeDatabase\Data\; 
 
 
COPY INTO @ACSODS_VLAB.adm.%Process_Primary_Key/unload/adm.Process_Primary_Key.txt 
FROM ACSODS_VLAB.adm.Process_Primary_Key 
FILE_FORMAT = ( 
    FORMAT_NAME = 'ADM.FORMAT_FILE_DEL_TAB' 
    EMPTY_FIELD_AS_NULL = FALSE 
    COMPRESSION = NONE 
) 
SINGLE = TRUE 
OVERWRITE = TRUE; 
 
GET @ACSODS_VLAB.adm.%Process_Primary_Key/unload/adm.Process_Primary_Key.txt file://C:\tfs\CSG\Enterprise\Database\OperationalDataStore\Snowflake\DecisionPoint\CI\SnowFlakeDatabase\Data\; 
 
 
COPY INTO @ACSODS_VLAB.adm.%Product/unload/adm.Product.txt 
FROM ACSODS_VLAB.adm.Product 
FILE_FORMAT = ( 
    FORMAT_NAME = 'ADM.FORMAT_FILE_DEL_TAB' 
    EMPTY_FIELD_AS_NULL = FALSE 
    COMPRESSION = NONE 
) 
SINGLE = TRUE 
OVERWRITE = TRUE; 
 
GET @ACSODS_VLAB.adm.%Product/unload/adm.Product.txt file://C:\tfs\CSG\Enterprise\Database\OperationalDataStore\Snowflake\DecisionPoint\CI\SnowFlakeDatabase\Data\; 
 
 
COPY INTO @ACSODS_VLAB.adm.%Status_Code/unload/adm.Status_Code.txt 
FROM ACSODS_VLAB.adm.Status_Code 
FILE_FORMAT = ( 
    FORMAT_NAME = 'ADM.FORMAT_FILE_DEL_TAB' 
    EMPTY_FIELD_AS_NULL = FALSE 
    COMPRESSION = NONE 
) 
SINGLE = TRUE 
OVERWRITE = TRUE; 
 
GET @ACSODS_VLAB.adm.%Status_Code/unload/adm.Status_Code.txt file://C:\tfs\CSG\Enterprise\Database\OperationalDataStore\Snowflake\DecisionPoint\CI\SnowFlakeDatabase\Data\; 
 
 
