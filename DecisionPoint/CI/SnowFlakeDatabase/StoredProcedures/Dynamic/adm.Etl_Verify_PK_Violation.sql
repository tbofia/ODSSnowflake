CREATE OR REPLACE PROCEDURE ADM.ETL_VERIFY_PK_VIOLATION(
   "fullTableName" STRING,
   "processAuditId" FLOAT,
   "isSourceOLTP" BOOLEAN,
   "isDebug" BOOLEAN
)
returns VARIANT
language javascript
execute as caller
as
$$

    const output = {
        returnStatus: 1, // 2-ErrorIdentified
        data: "",
        rowsAffected: -1, 
        audit: "not logged",
        status: "",
        message: []
    }
    
    let command;
    let arrayCommands = [];
    let statement;
    let recordSet;
    let linebreak = "\r\n";
    let pkColumns = "";
	let stagingSchema = isSourceOLTP ? "STG_OLTP" : "STG";
         
    //Get the PK Columns for Src/Rpt Schema
    command = "SELECT LISTAGG(C.COLUMN_NAME, ' ,') within group (ORDER BY C.ORDINAL_POSITION) AS pkColumns " + linebreak
		+"FROM ADM.PROCESS_PRIMARY_KEY PPK " + linebreak
		+"INNER JOIN ADM.PROCESS P " + linebreak
		+"    ON PPK.PROCESS_ID = P.PROCESS_ID " + linebreak
		+"    AND UPPER(P.TARGET_TABLE_NAME) = UPPER('" + fullTableName.split(".")[1] + "') " + linebreak
		+"    AND UPPER(P.TARGET_SCHEMA_NAME) = UPPER('" + fullTableName.split(".")[0] + "') " + linebreak
		+"INNER JOIN INFORMATION_SCHEMA.COLUMNS C " + linebreak
		+"    ON UPPER(PPK.PRIMARY_KEY_COLUMN) = C.COLUMN_NAME " + linebreak
		+"    AND UPPER(P.TARGET_TABLE_NAME) = C.TABLE_NAME " + linebreak
		+"    AND UPPER(P.TARGET_SCHEMA_NAME) = C.TABLE_SCHEMA " + linebreak
		+"    AND UPPER(PPK.PRIMARY_KEY_COLUMN) != 'ODSPOSTINGGROUPAUDITID';";

	if(isDebug){
		arrayCommands.push("--Get the PK Columns from Src Schema")
		arrayCommands.push(command);
	}else if(output.returnStatus > -1){
		try{
			statement = snowflake.createStatement({sqlText:command});
			recordSet = statement.execute();
			recordSet.next();
			pkColumns = recordSet.getColumnValue(1).toUpperCase();
		}catch(err){
			output.returnStatus = -1;
			output.rowsAffected = -1;
			output.audit= 'not logged';
			output.status = 'failed';
			output.message.push(err.message);   
			output.message.push("Error Command: " + command);
		}
	}

	pkColumns = isSourceOLTP ? pkColumns.replace("ODSCUSTOMERID", "CUSTOMERDATABASE") : pkColumns;

    //Find any duplicates in the stg where odsRowIsCurrent = 1 based on the PK from the src
    command = "INSERT INTO ADM.ERROR_LOG" + linebreak
		+ (isSourceOLTP ? "WITH CTE AS(" + linebreak
                        + "    SELECT PA.POSTING_GROUP_AUDIT_ID, " + linebreak
                        + "        PA.PROCESS_ID, " + linebreak
                        + "        MAX(PROCESS_AUDIT_ID) AS PROCESS_AUDIT_ID,  " + linebreak
                        + "        C.CUSTOMER_DATABASE" + linebreak
                        + "    FROM ADM_OLTP.PROCESS_AUDIT AS PA" + linebreak
                        + "    INNER JOIN ADM_OLTP.POSTING_GROUP_AUDIT AS PGA" + linebreak
                        + "        ON PA.POSTING_GROUP_AUDIT_ID = PGA.POSTING_GROUP_AUDIT_ID" + linebreak
                        + "    INNER JOIN ADM.CUSTOMER AS C" + linebreak
                        + "        ON PGA.CUSTOMER_ID = C.CUSTOMER_ID" + linebreak
                        + "    INNER JOIN ADM.PROCESS AS P " + linebreak
                        + "        ON P.PROCESS_ID = PA.PROCESS_ID" + linebreak
                        + "        AND UPPER(P.TARGET_TABLE_NAME) = 'BILLS_PHARM'" + linebreak
                        + "    GROUP BY PA.POSTING_GROUP_AUDIT_ID, " + linebreak
                        + "        C.CUSTOMER_DATABASE, " + linebreak
                        + "        PA.PROCESS_ID" + linebreak
                        + ")" + linebreak
                        : "")
		+ "SELECT " 
		+ (isSourceOLTP ? "CTE.PROCESS_AUDIT_ID" : processAuditId)
		+ ", 1, CONCAT_WS(','," + pkColumns +"), CURRENT_DATE()" + linebreak
        + "FROM " + stagingSchema + "." + fullTableName.split(".")[1] + " AS S" + linebreak
        + (isSourceOLTP ? "INNER JOIN CTE" + linebreak
						+ "    ON UPPER(S.CUSTOMERDATABASE) = UPPER(CTE.CUSTOMER_DATABASE)" + linebreak
						: "")
		+ "WHERE 1 = 1 "  + linebreak
        + (fullTableName.split(".")[0].toUpperCase() == "SRC" && !isSourceOLTP ? "    AND ODSROWISCURRENT = 1 " + linebreak : "")
		+ "GROUP BY  " + pkColumns  + linebreak
		+ (isSourceOLTP ? "    ,CTE.PROCESS_AUDIT_ID" + linebreak : "")
        + "HAVING COUNT(*) > 1 ; "

   if(isDebug){
        arrayCommands.push("--Find any duplicates in the stg where odsRowIsCurrent = 1 based on the PK from the src")
        arrayCommands.push(command);
        output.returnStatus = 0;
        output.rowsAffected = -1;
        output.status = "debug";
        output.message = arrayCommands;
    }else if(output.returnStatus > -1){
        //execution
        try{
			statement = snowflake.createStatement({sqlText:command});
			recordSet = statement.execute();
			recordSet.next();

			//Check if the table has a duplicate inserted into Process_Error_Log table
			command = "SELECT $1 FROM TABLE(RESULT_SCAN(LAST_QUERY_ID()));" 
			statement = snowflake.createStatement({sqlText:command});
			recordSet = statement.execute();
			recordSet.next();
			output.rowsAffected = recordSet.getColumnValue(1);
			if( output.rowsAffected > 0){
				output.returnStatus = 2; 
			}else{
				output.returnStatus = 1; 
			}
			output.audit= 'logged';
			output.status = 'succeeded';
			output.message = '';
		}catch(err){        
			output.returnStatus = -1;
			output.rowsAffected = -1;
			output.audit= 'logged';
			output.status = 'failed';
			output.message = err.message;   
		}
 }

  return output
    
$$;

