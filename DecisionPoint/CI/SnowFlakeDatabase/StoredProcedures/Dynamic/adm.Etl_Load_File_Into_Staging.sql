CREATE OR REPLACE PROCEDURE adm.Etl_Load_File_Into_Staging (
  "processAuditId" FLOAT,
  "tableName" VARCHAR(100),
  "snapshotDateTime" STRING,
  "externalStage" STRING,
  "fileFolder" STRING,
  "arrayFiles" ARRAY,
  "truncateStg" BOOLEAN,
  "isSourceOLTP" BOOLEAN,
  "isDebug" BOOLEAN
)
returns variant
language javascript
execute as caller
as     
$$  
    const output = {
        returnStatus: 0,
        rowsAffected: -1,
        audit: "not logged",
		data: "",
        status: "not executed",
        message: []
    };
    
    const auditData = {
        identity:"",
        identityValue:"",
        jsData:{}
    };
    
    let commandTruncate;
    let commandCopy;
	let command = "";
    let statement;
    let recordSet;  
	let linebreak = "\r\n";
	let tab = "\t";

	let fullTableName = "";
    let arrayFileNamesWithPath = [];
    let stringFileNamesWithPath = "";
    let arrayFileNames = [];
    let stringFileNames = "";
	let formatFileName = "";
    
    let tbl_processFileAudit = isSourceOLTP ? "ADM_OLTP.PROCESS_FILE_AUDIT" : "ADM.PROCESS_FILE_AUDIT";
    let stagingSchema = isSourceOLTP ? "STG_OLTP" : "STG";

    processAuditId = Number(processAuditId);
    arrayFiles.forEach(fileItem => arrayFileNamesWithPath.push((isSourceOLTP ? fileItem.path : fileFolder + "/") + fileItem.fileName));
    stringFileNamesWithPath = "'" + arrayFileNamesWithPath.join("','") + "'";
    arrayFiles.forEach(fileItem => arrayFileNames.push(fileItem.fileName));
    stringFileNames = "'" + arrayFileNames.join("','") + "'";
	externalStage = (externalStage.substring(externalStage.length-1,externalStage.length) == "/"?externalStage:externalStage + "/");
    
	//get format file name
	command = "SELECT FORMAT_FILE_NAME," + linebreak
		+ "    P.TARGET_SCHEMA_NAME||'.'||P.TARGET_TABLE_NAME AS FULL_TABLE_NAME" + linebreak
		+ "FROM ADM.PROCESS_FORMAT_FILES PFF" + linebreak
		+ "INNER JOIN ADM.PROCESS P" + linebreak
		+ "    ON PFF.PROCESS_ID = P.PROCESS_ID" + linebreak
		+ "    AND UPPER(P.TARGET_TABLE_NAME) = UPPER('" + tableName + "');";
	if(isDebug){
		output.returnStatus = 0;
        output.rowsAffected = -1;
        output.status = "debug";
        output.message.push("--get format file name for table " + tableName);
        output.message.push(command);
	}else{
		try{
			statement = snowflake.createStatement({sqlText: command});
            recordSet = statement.execute();
            if(recordSet.next()){
				formatFileName = recordSet.getColumnValue("FORMAT_FILE_NAME");
				fullTableName = recordSet.getColumnValue("FULL_TABLE_NAME");
			}
		}catch(err){
			output.returnStatus = -1;
            output.rowsAffected = -1;
            output.status = "failed";
            output.message.push(err.message);   
			output.message.push("Error Command: " + command);
            return output;
		}
	}

	//load data into STG
    commandTruncate = "TRUNCATE TABLE " + stagingSchema + "." + tableName.toUpperCase() + " ; ";
    
    commandCopy = "COPY INTO " + stagingSchema + "." + tableName.toUpperCase() + " " + linebreak
                + "FROM " + externalStage + linebreak 
                + "FILES = (" + stringFileNamesWithPath + ") " + linebreak
                + "FILE_FORMAT=(FORMAT_NAME = " + formatFileName + ") " + linebreak
                + "ON_ERROR = SKIP_FILE; ";
        
    if(isDebug){
        output.message.push("--load data into STG");
        output.message.push((truncateStg?commandTruncate:"") + linebreak + commandCopy + linebreak);
    }else {
        //execution
        try{
            if(truncateStg){
                statement = snowflake.createStatement({sqlText: commandTruncate});
                recordSet = statement.execute();
            }   
            
            statement = snowflake.createStatement({sqlText: commandCopy});
            recordSet = statement.execute();
            recordSet.next();
            
            command = "select SUM($4) FROM TABLE(RESULT_SCAN(LAST_QUERY_ID()));"
            statement = snowflake.createStatement({sqlText: command});
            recordSet = statement.execute();
            recordSet.next();
            output.rowsAffected = recordSet.getColumnValue(1);
         }catch(err){        
            output.returnStatus = -1;
            output.rowsAffected = -1;
            output.status = "failed";
            output.message.push(err.message);   
			output.message.push("Error Command: " + command);
            return output;
        }
    }
    
  	//create left table stg.tempLoadHistory
	command = "CREATE OR REPLACE TEMPORARY TABLE " + stagingSchema + ".tempLoadHistory " + linebreak
		+ "AS SELECT " + linebreak
		+ tab + "STRTOK(FILE_NAME, '/', ARRAY_SIZE(STRTOK_TO_ARRAY(FILE_NAME, '/'))) AS FILE_NAME, " + linebreak
		+ tab + "STATUS, " + linebreak
		+ tab + "ROW_COUNT, " + linebreak
		+ tab + "LAST_LOAD_TIME, " + linebreak
		+ tab + "FIRST_ERROR_MESSAGE, " + linebreak
		+ tab + "ROW_NUMBER()OVER(PARTITION BY strtok(file_name,'/',(Array_size(strtok_to_array(file_name,'/')))) " + linebreak
		+ tab + tab + " ORDER BY LAST_LOAD_TIME DESC) AS RID " + linebreak
		+ "FROM INFORMATION_SCHEMA.LOAD_HISTORY " + linebreak
		+ "WHERE 1=1 " + linebreak
        + (isSourceOLTP ? "    AND STRTOK(FILE_NAME, '/', ARRAY_SIZE(STRTOK_TO_ARRAY(FILE_NAME, '/'))) IN (" + linebreak
                        + stringFileNames + ")" + linebreak
                        : "    AND FILE_NAME LIKE '%" + snapshotDateTime + "%' " + linebreak
		                + "    AND FILE_NAME LIKE '%/" + fileFolder + "/%'" + linebreak)
		+ "    AND TABLE_NAME  = UPPER('" + tableName + "');";
	if(isDebug){
        output.message.push("--build json to update adm.Process_File_Audit");
		output.message.push("--create left table " + stagingSchema + ".tempLoadHistory");
        output.message.push(command + linebreak);
    }else{
		try{
            statement = snowflake.createStatement({sqlText: command});
            recordSet = statement.execute();
            recordSet.next();
		}catch(err){
			output.returnStatus = -1;
            output.rowsAffected = -1;
            output.status = "failed";
            output.message.push(err.message);   
			output.message.push("Error Command: " + command);
			return output;
		}
	}

	//create right table stg.tempArrayFiles
	command = "CREATE OR REPLACE TEMPORARY TABLE " + stagingSchema + ".tempArrayFiles " + linebreak
		+ "AS SELECT * " + linebreak
		+ "FROM LATERAL FLATTEN(parse_json('" + JSON.stringify(arrayFiles) + "'));";
	if(isDebug){
        output.message.push("--create right table " + stagingSchema + ".tempArrayFiles");
        output.message.push(command + linebreak);
    }else{
		try{
            statement = snowflake.createStatement({sqlText: command});
            recordSet = statement.execute();
            recordSet.next();
		}catch(err){
			output.returnStatus = -1;
            output.rowsAffected = -1;
            output.status = "failed";
            output.message.push(err.message);   
			output.message.push("Error Command: " + command);
			return output;
		}
	}

	//create temp table STG.tempInsert used in Insert Stmt
	command = "CREATE OR REPLACE TEMPORARY TABLE " + stagingSchema + ".tempInsert " + linebreak
		+ "AS " + linebreak
        + (isSourceOLTP ? "WITH CTE AS(" + linebreak
                        + "    SELECT PA.PROCESS_ID, " + linebreak
                        + "        MAX(PROCESS_AUDIT_ID) AS PROCESS_AUDIT_ID,  " + linebreak
                        + "        C.CUSTOMER_DATABASE" + linebreak
                        + "    FROM ADM_OLTP.PROCESS_AUDIT AS PA" + linebreak
                        + "    INNER JOIN ADM_OLTP.POSTING_GROUP_AUDIT AS PGA" + linebreak
                        + "        ON PA.POSTING_GROUP_AUDIT_ID = PGA.POSTING_GROUP_AUDIT_ID" + linebreak
                        + "    INNER JOIN ADM.CUSTOMER AS C" + linebreak
                        + "        ON PGA.CUSTOMER_ID = C.CUSTOMER_ID" + linebreak
                        + "    INNER JOIN ADM.PROCESS AS P " + linebreak
                        + "        ON P.PROCESS_ID = PA.PROCESS_ID" + linebreak
                        + "        AND UPPER(P.TARGET_TABLE_NAME) = '" + tableName.toUpperCase() + "'" + linebreak
                        + "    GROUP BY C.CUSTOMER_DATABASE, " + linebreak
                        + "        PA.PROCESS_ID" + linebreak
                        + ")" + linebreak
                        : "")        
        + "SELECT " + linebreak
        + (isSourceOLTP ? "    CTE.PROCESS_AUDIT_ID," + linebreak
                        + "    STRTOK(f.value:path, '/', 1) AS customerName," + linebreak
                        : "")
        + "    SUM(CASE" + linebreak
        + "            WHEN f.value:totalRowCount != lh.row_count THEN 1" + linebreak
        + "            WHEN lh.Status = 'LOADED' THEN 0" + linebreak
        + "            WHEN lh.Status = 'LOAD_FAILED' THEN 1" + linebreak
        + "            ELSE 0" + linebreak
        + "        END) AS errorCount," + linebreak
        + "    LISTAGG(CASE" + linebreak
        + "            WHEN f.value:totalRowCount != lh.row_count THEN 'Row count does not match between Files and Extracted.'" + linebreak
        + "            WHEN lh.Status = 'LOADED' THEN ''" + linebreak
        + "            WHEN lh.Status = 'LOAD_FAILED' THEN lh.FIRST_ERROR_MESSAGE" + linebreak
        + "            ELSE null" + linebreak
        + "        END,'|') AS errorMessage," + linebreak
        + "    f.value:fileNumber AS fileNumber," + linebreak
        + "    CASE WHEN lh.Status = 'LOADED' THEN 'FI'" + linebreak
        + "         WHEN lh.Status = 'LOAD_FAILED' THEN 'ER'" + linebreak
        + "            ELSE 'NA'" + linebreak
        + "          END AS Status," + linebreak
        + "    f.value:totalRowCount AS totalRecordsInFile," + linebreak
        + "    lh.row_count AS totalRecordsExtracted," + linebreak
        + "    lh.Last_load_time AS loadDate" + linebreak
        + "FROM " + stagingSchema + ".tempArrayFiles f" + linebreak
        + (isSourceOLTP ? "INNER JOIN CTE" + linebreak
                        + "    ON UPPER(STRTOK(f.value:path, '/', 1)) = UPPER(CTE.CUSTOMER_DATABASE)" + linebreak
                        : "")
        + "LEFT OUTER JOIN " + stagingSchema + ".tempLoadHistory lh" + linebreak
        + "    ON lh.file_name = f.value:fileName " + linebreak
        + "WHERE lh.RID = 1" + linebreak
        + "GROUP BY f.value, lh.Status, lh.row_count, lh.Last_load_time"
        + (isSourceOLTP ? ", CTE.PROCESS_AUDIT_ID;"
                        : ";");

    if(isDebug){
      output.message.push("--create temp table " + stagingSchema + ".tempInsert using inserting to Audit tbl");
      output.message.push(command + linebreak);
    }else{
		try{
            statement = snowflake.createStatement({sqlText: command});
            recordSet = statement.execute();
            recordSet.next();
		}catch(err){
			output.returnStatus = -1;
            output.rowsAffected = -1;
            output.status = "failed";
            output.message.push(err.message);   
			output.message.push("Error Command: " + command);
			return output;
		}
	}
    
    //Check for any ErrorCount and Errormessage
    command = "SELECT errorCount ,errorMessage FROM " + stagingSchema + ".tempInsert; ";

    if(isDebug){
        output.message.push("--Check for any ErrorCount and Errormessage");
        output.message.push(command + linebreak);
    }else{
        try{
            statement = snowflake.createStatement({sqlText: command});
            recordSet = statement.execute();
            recordSet.next();
            
            output.status = Number(recordSet.getColumnValue(1)) == 0 ? "succeeded" : "failed";
            output.message.push(Number(recordSet.getColumnValue(1)) == 0 ? "" : recordSet.getColumnValue(2));
            output.returnStatus = Number(recordSet.getColumnValue(1)) == 0 ? 1 : -1;
            output.audit = "logged";
            
            //Log into a file - call stored procedure.
        }catch(err){        
            //Log into a file - call stored procedure.
            
            output.returnStatus = -1;
            output.rowsAffected = -1;
            output.status = "failed";
            output.message.push(err.message);   
			output.message.push("Error Command: " + command);
			return output;
        }
    }

	//Insert to adm.Process_File_Audit
    command = "INSERT INTO " + tbl_processFileAudit + "(" + linebreak
			+ "    PROCESS_AUDIT_ID," + linebreak
			+ "    FILE_NUMBER," + linebreak
			+ "    STATUS," + linebreak
			+ "    TOTAL_RECORDS_IN_FILE," + linebreak
			+ "    TOTAL_RECORDS_EXTRACTED," + linebreak
            + "    TOTAL_RECORDS_WITH_ERRORS," + linebreak
            + "    LOAD_DATE," + linebreak
            + "    CREATE_DATE," + linebreak
            + "    LAST_CHANGE_DATE )" + linebreak
            + "SELECT " 
            + (isSourceOLTP ? "    PROCESS_AUDIT_ID," + linebreak
                            : "    " + processAuditId.toString() +"," + linebreak)
			+ "    fileNumber," + linebreak
			+ "    Status," + linebreak
			+ "    totalRecordsInFile," + linebreak
			+ "    totalRecordsExtracted," + linebreak
			+ "    0," + linebreak
            + "    loadDate," + linebreak
			+ "    CURRENT_TIMESTAMP() ," + linebreak
			+ "    CURRENT_TIMESTAMP() " + linebreak
			+ "FROM " + stagingSchema + ".tempInsert ;";
			     
        if(isDebug){
            output.message.push("--Insert adm.Process_File_Audit");
            output.message.push(command + linebreak);
        }else{
            try{
              statement = snowflake.createStatement({sqlText:command});
              recordSet = statement.execute();
              recordSet.next();
            }catch(err){
              output.returnStatus = -1;
              output.rowsAffected = -1;
              output.status = "failed";
              output.message.push(err.message);   
              output.message.push("Error Command: " + command);
              return output;
		    }  
            
        }

	//Verify primary key constraints
	command = "CALL ADM.ETL_VERIFY_PK_VIOLATION('" 
		+ fullTableName 
        + "', " + processAuditId.toString() 
        + ", " + (isSourceOLTP ? "true" : "false")
        + ", false);";
	if(isDebug){
        output.message.push("--Verify primary key constraints");
        output.message.push(command + linebreak);
    }else{
		statement = snowflake.createStatement({sqlText:command});
        recordSet = statement.execute();
        recordSet.next();
        if(recordSet.getColumnValue(1).returnStatus == 2){
			output.returnStatus = -1;
            output.rowsAffected = -1;
            output.status = "failed";
            output.message.push(command + ". Error: Primary key violation.");
        }else if(recordSet.getColumnValue(1).returnStatus == -1){
            output.returnStatus = -1;
            output.rowsAffected = -1;
            output.status = "failed";
            output.message.push(command + ". Error: Failed.");
        }
	}

    return output;
$$;

