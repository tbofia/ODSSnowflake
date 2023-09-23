USE ROLE DB_DEV; 
 
USE WAREHOUSE WH_ETL_XS; 
 
COPY INTO @WCSODS_FK.adm.%Customer/unload/adm.Customer.txt 
FROM WCSODS_FK.adm.Customer 
FILE_FORMAT = ( 
    FORMAT_NAME = 'ADM.FORMAT_FILE_DEL_TAB' 
    EMPTY_FIELD_AS_NULL = FALSE 
    COMPRESSION = NONE 
) 
SINGLE = TRUE 
OVERWRITE = TRUE; 
 
GET @WCSODS_FK.adm.%Customer/unload/adm.Customer.txt file://C:\TFS\CSG\Enterprise\Database\OperationalDataStore\Snowflake\SmartAdvisor\CI\SnowFlakeDatabase\Data\; 
 
 
COPY INTO @WCSODS_FK.adm.%Data_Extract_Type/unload/adm.Data_Extract_Type.txt 
FROM WCSODS_FK.adm.Data_Extract_Type 
FILE_FORMAT = ( 
    FORMAT_NAME = 'ADM.FORMAT_FILE_DEL_TAB' 
    EMPTY_FIELD_AS_NULL = FALSE 
    COMPRESSION = NONE 
) 
SINGLE = TRUE 
OVERWRITE = TRUE; 
 
GET @WCSODS_FK.adm.%Data_Extract_Type/unload/adm.Data_Extract_Type.txt file://C:\TFS\CSG\Enterprise\Database\OperationalDataStore\Snowflake\SmartAdvisor\CI\SnowFlakeDatabase\Data\; 
 
 
COPY INTO @WCSODS_FK.adm.%Event/unload/adm.Event.txt 
FROM WCSODS_FK.adm.Event 
FILE_FORMAT = ( 
    FORMAT_NAME = 'ADM.FORMAT_FILE_DEL_TAB' 
    EMPTY_FIELD_AS_NULL = FALSE 
    COMPRESSION = NONE 
) 
SINGLE = TRUE 
OVERWRITE = TRUE; 
 
GET @WCSODS_FK.adm.%Event/unload/adm.Event.txt file://C:\TFS\CSG\Enterprise\Database\OperationalDataStore\Snowflake\SmartAdvisor\CI\SnowFlakeDatabase\Data\; 
 
 
COPY INTO @WCSODS_FK.adm.%Posting_Group/unload/adm.Posting_Group.txt 
FROM WCSODS_FK.adm.Posting_Group 
FILE_FORMAT = ( 
    FORMAT_NAME = 'ADM.FORMAT_FILE_DEL_TAB' 
    EMPTY_FIELD_AS_NULL = FALSE 
    COMPRESSION = NONE 
) 
SINGLE = TRUE 
OVERWRITE = TRUE; 
 
GET @WCSODS_FK.adm.%Posting_Group/unload/adm.Posting_Group.txt file://C:\TFS\CSG\Enterprise\Database\OperationalDataStore\Snowflake\SmartAdvisor\CI\SnowFlakeDatabase\Data\; 
 
 
COPY INTO @WCSODS_FK.adm.%Process/unload/adm.Process.txt 
FROM WCSODS_FK.adm.Process 
FILE_FORMAT = ( 
    FORMAT_NAME = 'ADM.FORMAT_FILE_DEL_TAB' 
    EMPTY_FIELD_AS_NULL = FALSE 
    COMPRESSION = NONE 
) 
SINGLE = TRUE 
OVERWRITE = TRUE; 
 
GET @WCSODS_FK.adm.%Process/unload/adm.Process.txt file://C:\TFS\CSG\Enterprise\Database\OperationalDataStore\Snowflake\SmartAdvisor\CI\SnowFlakeDatabase\Data\; 
 
 
COPY INTO @WCSODS_FK.adm.%Process_Format_Files/unload/adm.Process_Format_Files.txt 
FROM WCSODS_FK.adm.Process_Format_Files 
FILE_FORMAT = ( 
    FORMAT_NAME = 'ADM.FORMAT_FILE_DEL_TAB' 
    EMPTY_FIELD_AS_NULL = FALSE 
    COMPRESSION = NONE 
) 
SINGLE = TRUE 
OVERWRITE = TRUE; 
 
GET @WCSODS_FK.adm.%Process_Format_Files/unload/adm.Process_Format_Files.txt file://C:\TFS\CSG\Enterprise\Database\OperationalDataStore\Snowflake\SmartAdvisor\CI\SnowFlakeDatabase\Data\; 
 
 
COPY INTO @WCSODS_FK.adm.%Process_Primary_Key/unload/adm.Process_Primary_Key.txt 
FROM WCSODS_FK.adm.Process_Primary_Key 
FILE_FORMAT = ( 
    FORMAT_NAME = 'ADM.FORMAT_FILE_DEL_TAB' 
    EMPTY_FIELD_AS_NULL = FALSE 
    COMPRESSION = NONE 
) 
SINGLE = TRUE 
OVERWRITE = TRUE; 
 
GET @WCSODS_FK.adm.%Process_Primary_Key/unload/adm.Process_Primary_Key.txt file://C:\TFS\CSG\Enterprise\Database\OperationalDataStore\Snowflake\SmartAdvisor\CI\SnowFlakeDatabase\Data\; 
 
 
COPY INTO @WCSODS_FK.adm.%Product/unload/adm.Product.txt 
FROM WCSODS_FK.adm.Product 
FILE_FORMAT = ( 
    FORMAT_NAME = 'ADM.FORMAT_FILE_DEL_TAB' 
    EMPTY_FIELD_AS_NULL = FALSE 
    COMPRESSION = NONE 
) 
SINGLE = TRUE 
OVERWRITE = TRUE; 
 
GET @WCSODS_FK.adm.%Product/unload/adm.Product.txt file://C:\TFS\CSG\Enterprise\Database\OperationalDataStore\Snowflake\SmartAdvisor\CI\SnowFlakeDatabase\Data\; 
 
 
COPY INTO @WCSODS_FK.adm.%Status_Code/unload/adm.Status_Code.txt 
FROM WCSODS_FK.adm.Status_Code 
FILE_FORMAT = ( 
    FORMAT_NAME = 'ADM.FORMAT_FILE_DEL_TAB' 
    EMPTY_FIELD_AS_NULL = FALSE 
    COMPRESSION = NONE 
) 
SINGLE = TRUE 
OVERWRITE = TRUE; 
 
GET @WCSODS_FK.adm.%Status_Code/unload/adm.Status_Code.txt file://C:\TFS\CSG\Enterprise\Database\OperationalDataStore\Snowflake\SmartAdvisor\CI\SnowFlakeDatabase\Data\; 
 
 
