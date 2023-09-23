COPY INTO WCSODS_FK.adm.Customer FROM @WCSODS_FK.adm.%Customer FILES = ('adm.Customer.txt.gz') FILE_FORMAT = ( FORMAT_NAME = ADM.FORMAT_FILE_DEL_TAB ); 
COPY INTO WCSODS_FK.adm.Data_Extract_Type FROM @WCSODS_FK.adm.%Data_Extract_Type FILES = ('adm.Data_Extract_Type.txt.gz') FILE_FORMAT = ( FORMAT_NAME = ADM.FORMAT_FILE_DEL_TAB ); 
COPY INTO WCSODS_FK.adm.Event FROM @WCSODS_FK.adm.%Event FILES = ('adm.Event.txt.gz') FILE_FORMAT = ( FORMAT_NAME = ADM.FORMAT_FILE_DEL_TAB ); 
COPY INTO WCSODS_FK.adm.Posting_Group FROM @WCSODS_FK.adm.%Posting_Group FILES = ('adm.Posting_Group.txt.gz') FILE_FORMAT = ( FORMAT_NAME = ADM.FORMAT_FILE_DEL_TAB ); 
COPY INTO WCSODS_FK.adm.Process FROM @WCSODS_FK.adm.%Process FILES = ('adm.Process.txt.gz') FILE_FORMAT = ( FORMAT_NAME = ADM.FORMAT_FILE_DEL_TAB ); 
COPY INTO WCSODS_FK.adm.Process_Format_Files FROM @WCSODS_FK.adm.%Process_Format_Files FILES = ('adm.Process_Format_Files.txt.gz') FILE_FORMAT = ( FORMAT_NAME = ADM.FORMAT_FILE_DEL_TAB ); 
COPY INTO WCSODS_FK.adm.Process_Primary_Key FROM @WCSODS_FK.adm.%Process_Primary_Key FILES = ('adm.Process_Primary_Key.txt.gz') FILE_FORMAT = ( FORMAT_NAME = ADM.FORMAT_FILE_DEL_TAB ); 
COPY INTO WCSODS_FK.adm.Product FROM @WCSODS_FK.adm.%Product FILES = ('adm.Product.txt.gz') FILE_FORMAT = ( FORMAT_NAME = ADM.FORMAT_FILE_DEL_TAB ); 
COPY INTO WCSODS_FK.adm.Status_Code FROM @WCSODS_FK.adm.%Status_Code FILES = ('adm.Status_Code.txt.gz') FILE_FORMAT = ( FORMAT_NAME = ADM.FORMAT_FILE_DEL_TAB ); 