CREATE OR REPLACE PROCEDURE ADM.ETL_GET_PROCESS_FILES(
"snapShotDate"  string,
"isDebug" BOOLEAN
)
returns VARIANT
language javascript
execute as caller
as     
$$ 
	const output = {
		returnStatus: -1,
		data: "",
		rowsAffected: -1,
		audit: "not logged",
		status: "not executed",
		message: ""
	};
   
    let arrayCommands = [];
    let command;
    let statement;
    let recordSet;
    
    let linebreak = "\r\n";
    let tab = "\t";
	let jsData;
    let postingGroupAuditId;
	let totalFileCount;
    
    command = "CALL ADM.ETL_GET_REPLICATION_INFO ('"+snapShotDate+"','False')"
    statement = snowflake.createStatement({sqlText: command });
    recordSet = statement.execute();
    recordSet.next();
    jsData = recordSet.getColumnValue(1).data;
    
    if ((jsData.postingGroupAuditId == -1) && ((jsData.currentReplicationId == jsData.previousReplicationId) || (jsData.previousReplicationId == -1))) {
		// Insert Into POSTING_GROUP_INJEST_AUDIT if the snapshot does not have an entry in postinggroupaudit table
        command = "INSERT INTO ADM.POSTING_GROUP_INJEST_AUDIT("   + linebreak
			+"    ODS_CUTOFF_POSTING_GROUP_AUDIT_ID,"   + linebreak
			+"    CURRENT_REPLICATION_ID,"   + linebreak
			+"    STATUS,"   + linebreak
			+"	  INJEST_TYPE_ID,"   + linebreak
			+"	  ODS_VERSION,"   + linebreak
            +"	  SNAPSHOT_DATE,"   + linebreak
            +"	  CREATE_DATE,"   + linebreak
            +"    LAST_CHANGE_DATE )"   + linebreak
            +"SELECT DISTINCT" + linebreak
			+"    ODS_CUTOFF_POSTING_GROUP_AUDIT_ID," + linebreak
			+"    CURRENT_REPLICATION_ID," + linebreak
			+"    'S'," + linebreak
			+"    CASE WHEN UPPER(LOAD_TYPE) = 'FULL' THEN 0 WHEN UPPER(LOAD_TYPE) = 'INCR' THEN 1 ELSE -1 END," + linebreak
			+"    ODS_VERSION," + linebreak
			+"    SNAPSHOT_DATE," + linebreak
			+"    CURRENT_TIMESTAMP() ," + linebreak
			+"    CURRENT_TIMESTAMP() " + linebreak
			+"FROM STG.ETL_CONTROLFILES" + linebreak
			+"WHERE SNAPSHOT_DATE = '" + snapShotDate + "';";
	    if(isDebug){
			arrayCommands.push("--Insert Record into Posting group audit table");
			arrayCommands.push(command);
	    }
	    statement = snowflake.createStatement({sqlText:command});
		recordSet = statement.execute();
		recordSet.next();
	}
     
    if ((jsData.currentReplicationId == jsData.previousReplicationId) || (jsData.previousReplicationId == -1)){ 
		// Insert Records into Process Injest 
		command = "INSERT INTO ADM.PROCESS_INJEST_AUDIT("   + linebreak
			+"  POSTING_GROUP_AUDIT_ID,"   + linebreak
			+"  PROCESS_ID,"   + linebreak
			+"  STATUS,"   + linebreak
			+"	TOTAL_RECORDS_IN_SOURCE,"   + linebreak
			+"  TOTAL_NUMBER_OF_FILES,"   + linebreak
			+"	CREATE_DATE,"   + linebreak
			+"	LAST_CHANGE_DATE)"   + linebreak

			+"	WITH CTE_LATEST_PROCESSAUDIT AS("   + linebreak
			+"	  SELECT POSTING_GROUP_AUDIT_ID, PROCESS_ID, MAX(PROCESS_AUDIT_ID) PROCESS_AUDIT_ID"   + linebreak
			+"	  FROM ADM.PROCESS_INJEST_AUDIT"   + linebreak
			+"	  GROUP BY POSTING_GROUP_AUDIT_ID,PROCESS_ID),"   + linebreak

			+"	CTE_PROCESS_INJEST_AUDIT AS("   + linebreak
			+"	  SELECT PA.PROCESS_ID,PA.STATUS,PA.POSTING_GROUP_AUDIT_ID"   + linebreak
			+"	  FROM ADM.PROCESS_INJEST_AUDIT PA"   + linebreak
			+"	  INNER JOIN CTE_LATEST_PROCESSAUDIT CTE"   + linebreak
			+"	  ON PA.POSTING_GROUP_AUDIT_ID = CTE.POSTING_GROUP_AUDIT_ID"   + linebreak
			+"	  AND PA.PROCESS_ID = CTE.PROCESS_ID"   + linebreak
			+"	  AND PA.PROCESS_AUDIT_ID = CTE.PROCESS_AUDIT_ID)"   + linebreak

			+"	SELECT DISTINCT "   + linebreak
			+"		PGA.POSTING_GROUP_AUDIT_ID,"   + linebreak
			+"		P.PROCESS_ID,"   + linebreak
			+"		'S' STATUS,"   + linebreak
			+"		CF.TOTAL_RECORDS_IN_SOURCE,"   + linebreak
			+"		CF.TOTAL_FILES,"   + linebreak
			+"		CURRENT_TIMESTAMP(),"   + linebreak
			+"		CURRENT_TIMESTAMP()"   + linebreak
			+"	FROM STG.ETL_CONTROLFILES CF"   + linebreak
			+"	INNER JOIN ADM.PROCESS P"   + linebreak
			+"	    ON UPPER(P.TARGET_TABLE_NAME) = UPPER(CF.TARGET_TABLE_NAME)"   + linebreak
			+"	    AND P.IS_ACTIVE = 'TRUE'"   + linebreak
			+"	LEFT OUTER JOIN ADM.POSTING_GROUP_INJEST_AUDIT PGA"   + linebreak
			+"	    ON CF.SNAPSHOT_DATE = PGA.SNAPSHOT_DATE"   + linebreak
			+"	LEFT OUTER JOIN CTE_PROCESS_INJEST_AUDIT PA"   + linebreak
			+"	    ON PGA.POSTING_GROUP_AUDIT_ID = PA.POSTING_GROUP_AUDIT_ID"   + linebreak
			+"	    AND P.PROCESS_ID = PA.PROCESS_ID"   + linebreak
			+"	WHERE CF.SNAPSHOT_DATE = '" + snapShotDate + "'"   + linebreak
			+"	    AND (PA.POSTING_GROUP_AUDIT_ID IS NULL OR PA.STATUS = 'S');"

		if(isDebug){
			arrayCommands.push("--Insert Records into Process Injest");
			arrayCommands.push(command);
		} else {
			statement = snowflake.createStatement({sqlText:command});
			recordSet = statement.execute();
			recordSet.next();
		}
		
		//GET POSTING GROUP AUDIT ID
		command = "WITH CTE_LATEST_PROCESSAUDIT AS( " + linebreak
			+ "    SELECT POSTING_GROUP_AUDIT_ID, PROCESS_ID, MAX(PROCESS_AUDIT_ID) PROCESS_AUDIT_ID  " + linebreak
			+ "    FROM ADM.PROCESS_INJEST_AUDIT  " + linebreak
			+ "    GROUP BY POSTING_GROUP_AUDIT_ID,PROCESS_ID),  " + linebreak
			+ "CTE_PROCESS_INJEST_AUDIT AS(  " + linebreak
			+ "    SELECT PA.PROCESS_ID,PA.STATUS,PA.POSTING_GROUP_AUDIT_ID  " + linebreak
			+ "    FROM ADM.PROCESS_INJEST_AUDIT PA   " + linebreak
			+ "    INNER JOIN CTE_LATEST_PROCESSAUDIT CTE  " + linebreak
			+ "        ON PA.POSTING_GROUP_AUDIT_ID = CTE.POSTING_GROUP_AUDIT_ID  " + linebreak
			+ "        AND PA.PROCESS_ID = CTE.PROCESS_ID  " + linebreak
			+ "        AND PA.PROCESS_AUDIT_ID = CTE.PROCESS_AUDIT_ID)   " + linebreak
			+ "SELECT  " + linebreak
			+ "    IFNULL(ANY_VALUE(PGA.POSTING_GROUP_AUDIT_ID),-1) AS POSTING_GROUP_AUDIT_ID, " + linebreak
			+ "    COUNT(1) AS TOTAL_FILE_COUNT " + linebreak
			+ "FROM STG.ETL_CONTROLFILES CF  " + linebreak
			+ "INNER JOIN ADM.PROCESS P  " + linebreak
			+ "    ON UPPER(P.TARGET_TABLE_NAME) = UPPER(CF.TARGET_TABLE_NAME)  " + linebreak
			+ "    AND P.IS_ACTIVE = 'TRUE'  " + linebreak
			+ "INNER JOIN ADM.POSTING_GROUP_INJEST_AUDIT PGA  " + linebreak
			+ "    ON CF.SNAPSHOT_DATE = PGA.SNAPSHOT_DATE " + linebreak
			+ "LEFT OUTER JOIN CTE_PROCESS_INJEST_AUDIT PA  " + linebreak
			+ "    ON PGA.POSTING_GROUP_AUDIT_ID = PA.POSTING_GROUP_AUDIT_ID  " + linebreak
			+ "    AND P.PROCESS_ID = PA.PROCESS_ID  " + linebreak
			+ "WHERE CF.SNAPSHOT_DATE = '" + snapShotDate + "' " + linebreak
			+ "    AND (PA.POSTING_GROUP_AUDIT_ID IS NULL OR PA.STATUS = 'S');"

		if(isDebug){
			arrayCommands.push("--GET POSTING GROUP AUDIT ID");
			arrayCommands.push(command);
		}else{
			statement = snowflake.createStatement({sqlText:command});
			recordSet = statement.execute();
			if(recordSet.next()) {
				postingGroupAuditId = recordSet.getColumnValue("POSTING_GROUP_AUDIT_ID");
				totalFileCount = recordSet.getColumnValue("TOTAL_FILE_COUNT");
			} else {
				postingGroupAuditId = -1;
				totalFileCount = 0;
			}
		}
	} 
             
	//Debug mode, output the message
	if(isDebug){
            output.returnStatus = 0;
            output.rowsAffected = -1;
            output.status = 'debug';
            output.message = arrayCommands;
    }else{
            output.returnStatus = 1;
            output.data = {
				"postingGroupAuditId" : postingGroupAuditId,
				"totalFileCount" : totalFileCount
			};
            output.audit= 'logged';
            output.status = 'succeeded';
            output.message = '';
     }

	return output;
$$;

