CREATE OR REPLACE PROCEDURE ADM.ETL_GET_PROCESS_FILES(
"snapShotDate" STRING,
"isSourceOLTP" BOOLEAN,
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
    
	if (!isSourceOLTP) {
		command = "CALL ADM.ETL_GET_REPLICATION_INFO ('"+snapShotDate+"','False')"
		statement = snowflake.createStatement({sqlText: command });
		recordSet = statement.execute();
		recordSet.next();
		jsData = recordSet.getColumnValue(1).data;
		
		if (jsData.postingGroupAuditId == -1 
			&& jsData.incompletePostingGroupsFromOLTP == -1
			&& (jsData.currentReplicationId == jsData.previousReplicationId || jsData.previousReplicationId == -1)) {
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

		if (jsData.currentReplicationId == jsData.previousReplicationId || jsData.previousReplicationId == -1){ 
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
				+"	    AND (PA.POSTING_GROUP_AUDIT_ID IS NULL OR PA.STATUS = 'S');";
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
	} else {
		//This block is for OLTP -> Snowflake.
		//1. copy the previous auditing data from rpt.postinggroupaudit.
		//2. copy the latest auditing data with Status = 'S' per customer.
		command = "INSERT INTO ADM_OLTP.POSTING_GROUP_AUDIT(" + linebreak
			+ "    POSTING_GROUP_AUDIT_ID" + linebreak
			+ "    , OLTP_POSTING_GROUP_AUDIT_ID" + linebreak
			+ "    , POSTING_GROUP_ID" + linebreak
			+ "    , CUSTOMER_ID" + linebreak
			+ "    , DATA_EXTRACT_TYPE_ID" + linebreak
			+ "    , STATUS" + linebreak
			+ "    , ODS_VERSION" + linebreak
			+ "    , SNAPSHOT_DATE" + linebreak
			+ "    , CREATE_DATE" + linebreak
			+ "    , LAST_CHANGE_DATE" + linebreak
			+ ")" + linebreak
			+ "WITH CTE_MaxPostingGroup_PGIA AS (" + linebreak
			+ "    SELECT " + linebreak
			+ "        MAX(POSTING_GROUP_AUDIT_ID) AS POSTING_GROUP_AUDIT_ID" + linebreak
			+ "        , MAX(ODS_CUTOFF_POSTING_GROUP_AUDIT_ID) AS ODS_CUTOFF_POSTING_GROUP_AUDIT_ID" + linebreak
			+ "        , MAX(SNAPSHOT_DATE) AS SNAPSHOT_DATE" + linebreak
			+ "    FROM ADM.POSTING_GROUP_INJEST_AUDIT" + linebreak
			+ "    WHERE STATUS = 'FI'" + linebreak
			+ ")" + linebreak
			+ "SELECT distinct" + linebreak
			+ "    PGA_MSSQL.POSTINGGROUPAUDITID AS POSTING_GROUP_AUDIT_ID" + linebreak
			+ "    , PGA_MSSQL.OLTPPOSTINGGROUPAUDITID AS OLTP_POSTING_GROUP_AUDIT_ID" + linebreak
			+ "    , PGA_MSSQL.POSTINGGROUPID AS POSTING_GROUP_ID" + linebreak
			+ "    , PGA_MSSQL.CUSTOMERID AS CUSTOMER_ID" + linebreak
			+ "    , PGA_MSSQL.DATAEXTRACTTYPEID AS DATA_EXTRACT_TYPE_ID" + linebreak
			+ "    , IFF(DATEDIFF(second, TCF.SNAPSHOT_DATE, PGA_MSSQL.SNAPSHOTCREATEDATE) < 0, 'FI', 'S') AS STATUS" + linebreak
			+ "    , PGA_MSSQL.ODSVERSION AS ODS_VERSION" + linebreak
			+ "    , PGA_MSSQL.SNAPSHOTCREATEDATE AS SNAPSHOT_DATE" + linebreak
			+ "    , CURRENT_TIMESTAMP() AS CREATE_DATE" + linebreak
			+ "    , CURRENT_TIMESTAMP() AS LAST_CHANGE_DATE" + linebreak
			+ "FROM STG_OLTP.ETL_CONTROLFILES AS CF" + linebreak
			+ "INNER JOIN STG_OLTP.TRANSIENT_CURRENT_ETL_CONTROLFILES AS TCF" + linebreak
			+ "    ON UPPER(CF.CONTROL_FILE_NAME) LIKE UPPER(TCF.CUSTOMER_NAME) || '%'" + linebreak
			+ "    AND CF.SNAPSHOT_DATE = TCF.SNAPSHOT_DATE" + linebreak
			+ "    AND TCF.TABLES_WITHOUT_PRECEDING_FULL_LOAD = 0" + linebreak
			+ "    AND TCF.IS_CURRENT_REPLICATION_QUALIFIED" + linebreak
			+ "INNER JOIN ADM.CUSTOMER AS C" + linebreak
			+ "    ON UPPER(TCF.CUSTOMER_NAME) = UPPER(C.CUSTOMER_DATABASE)" + linebreak
			+ "    AND C.IS_ACTIVE = 'TRUE'" + linebreak
			+ "INNER JOIN RPT.POSTINGGROUPAUDIT AS PGA_MSSQL" + linebreak
			+ "    ON DATEDIFF(second, TCF.SNAPSHOT_DATE, PGA_MSSQL.SNAPSHOTCREATEDATE) <= 0" + linebreak
			+ "    AND C.CUSTOMER_ID = PGA_MSSQL.CUSTOMERID" + linebreak
			+ "INNER JOIN CTE_MaxPostingGroup_PGIA AS CM_PGIA" + linebreak
			+ "    ON PGA_MSSQL.POSTINGGROUPAUDITID <= CM_PGIA.ODS_CUTOFF_POSTING_GROUP_AUDIT_ID" + linebreak
			+ "LEFT OUTER JOIN ADM_OLTP.POSTING_GROUP_AUDIT AS PGIA" + linebreak
			+ "    ON DATEDIFF(SECOND, CF.SNAPSHOT_DATE, PGIA.SNAPSHOT_DATE) = 0" + linebreak
			+ "    AND C.CUSTOMER_ID = PGIA.CUSTOMER_ID" + linebreak
			+ "WHERE PGIA.SNAPSHOT_DATE IS NULL;";
		if(isDebug){
			arrayCommands.push("--Insert Record into Posting group audit table");
			arrayCommands.push(command);
		}
		statement = snowflake.createStatement({sqlText:command});
		recordSet = statement.execute();
		recordSet.next();

		//1. copy the previous auditing data from rpt.processaudit ONLY for the tables which are loaded thru this pipeline.
		//2. insert the auditing records of current PostingGroupAuditId into adm_oltp.process_audit.
		command = "INSERT INTO ADM_OLTP.PROCESS_AUDIT(" + linebreak
			+ "    POSTING_GROUP_AUDIT_ID," + linebreak
			+ "    PROCESS_ID," + linebreak
			+ "    STATUS," + linebreak
			+ "	   TOTAL_RECORDS_IN_SOURCE," + linebreak
			+ "    TOTAL_RECORDS_IN_TARGET," + linebreak
			+ "    TOTAL_DELETED_RECORDS," + linebreak
			+ "    CONTROL_ROW_COUNT," + linebreak
			+ "    EXTRACT_ROW_COUNT," + linebreak
			+ "    UPDATE_ROW_COUNT," + linebreak
			+ "    LOAD_ROW_COUNT," + linebreak
			+ "    EXTRACT_DATE," + linebreak
			+ "    LAST_UPDATE_DATE," + linebreak
			+ "    LOAD_DATE," + linebreak
			+ "	   CREATE_DATE," + linebreak
			+ "	   LAST_CHANGE_DATE)" + linebreak
			+ "SELECT DISTINCT " + linebreak
			+ "	   IFNULL(PA_MSSQL.POSTINGGROUPAUDITID, PGA.POSTING_GROUP_AUDIT_ID) AS POSTING_GROUP_AUDIT_ID, " + linebreak
			+ "    IFNULL(PA_MSSQL.PROCESSID, P.PROCESS_ID) AS PROCESS_ID,                  " + linebreak
			+ "    IFNULL(PA_MSSQL.STATUS, 'S') AS STATUS," + linebreak
			+ "    IFNULL(PA_MSSQL.TOTALRECORDSINSOURCE, CF.TOTAL_RECORDS_IN_SOURCE) AS TOTAL_RECORDS_IN_SOURCE," + linebreak
			+ "    PA_MSSQL.TOTALRECORDSINTARGET," + linebreak
			+ "    PA_MSSQL.TOTALDELETEDRECORDS," + linebreak
			+ "    PA_MSSQL.CONTROLROWCOUNT," + linebreak
			+ "    PA_MSSQL.EXTRACTROWCOUNT," + linebreak
			+ "    PA_MSSQL.UPDATEROWCOUNT," + linebreak
			+ "    PA_MSSQL.LOADROWCOUNT," + linebreak
			+ "    PA_MSSQL.EXTRACTDATE," + linebreak
			+ "    PA_MSSQL.LASTUPDATEDATE," + linebreak
			+ "    PA_MSSQL.LOADDATE," + linebreak
			+ "    IFNULL(PA_MSSQL.CREATEDATE, CURRENT_TIMESTAMP()) AS CREATEDATE," + linebreak
			+ "    IFNULL(PA_MSSQL.LASTCHANGEDATE, CURRENT_TIMESTAMP()) AS LASTCHANGEDATE" + linebreak
			+ "FROM STG_OLTP.ETL_CONTROLFILES CF" + linebreak
			+ "INNER JOIN STG_OLTP.TRANSIENT_CURRENT_ETL_CONTROLFILES AS TCF" + linebreak
			+ "    ON UPPER(CF.CONTROL_FILE_NAME) LIKE UPPER(TCF.CUSTOMER_NAME) || '%'" + linebreak
			+ "    AND CF.SNAPSHOT_DATE = TCF.SNAPSHOT_DATE" + linebreak
			+ "    AND TCF.TABLES_WITHOUT_PRECEDING_FULL_LOAD = 0" + linebreak
			+ "    AND TCF.IS_CURRENT_REPLICATION_QUALIFIED" + linebreak
			+ "INNER JOIN ADM.CUSTOMER AS C" + linebreak
			+ "    ON UPPER(TCF.CUSTOMER_NAME) = UPPER(C.CUSTOMER_DATABASE)" + linebreak
			+ "    AND C.IS_ACTIVE = 'TRUE'" + linebreak
			+ "INNER JOIN ADM.PROCESS P" + linebreak
			+ "    ON UPPER(CF.TARGET_TABLE_NAME) = UPPER(P.TARGET_TABLE_NAME)" + linebreak
			+ "    AND P.IS_ACTIVE = 'TRUE'" + linebreak
			+ "INNER JOIN ADM_OLTP.POSTING_GROUP_AUDIT PGA" + linebreak
			+ "    ON C.CUSTOMER_ID = PGA.CUSTOMER_ID   " + linebreak
			+ "LEFT OUTER JOIN RPT.PROCESSAUDIT AS PA_MSSQL" + linebreak
			+ "    ON P.PROCESS_ID = PA_MSSQL.PROCESSID   " + linebreak
			+ "    AND PGA.POSTING_GROUP_AUDIT_ID = PA_MSSQL.POSTINGGROUPAUDITID" + linebreak
			+ "LEFT OUTER JOIN ADM_OLTP.PROCESS_AUDIT PA" + linebreak
			+ "    ON PGA.POSTING_GROUP_AUDIT_ID = PA.POSTING_GROUP_AUDIT_ID" + linebreak
			+ "    AND P.PROCESS_ID = PA.PROCESS_ID" + linebreak
			+ "WHERE 1 = 1" + linebreak
			+ "    AND ((PGA.STATUS = 'FI' AND PA_MSSQL.PROCESSID IS NOT NULL)" + linebreak
			+ "        OR (PGA.STATUS = 'S' AND PA_MSSQL.PROCESSID IS NULL))" + linebreak
			+ "    AND (PA.POSTING_GROUP_AUDIT_ID IS NULL OR PA.STATUS = 'S')" + linebreak
			+ "ORDER BY POSTING_GROUP_AUDIT_ID ASC, PROCESS_ID;";
		if(isDebug){
			arrayCommands.push("--Insert Records into Process Injest");
			arrayCommands.push(command);
		} else {
			statement = snowflake.createStatement({sqlText:command});
			recordSet = statement.execute();
			recordSet.next();
		}

		//get the posting group audit id per customer.
		command = "WITH CTE_LATEST_PROCESSAUDIT AS( " + linebreak
			+ "    SELECT POSTING_GROUP_AUDIT_ID, PROCESS_ID, MAX(PROCESS_AUDIT_ID) PROCESS_AUDIT_ID  " + linebreak
			+ "    FROM ADM_OLTP.PROCESS_AUDIT AS PA " + linebreak
			+ "    GROUP BY POSTING_GROUP_AUDIT_ID,PROCESS_ID)  " + linebreak
			+ ",CTE_PROCESS_AUDIT AS(  " + linebreak
			+ "    SELECT PA.PROCESS_ID,PA.STATUS,PA.POSTING_GROUP_AUDIT_ID  " + linebreak
			+ "    FROM ADM_OLTP.PROCESS_AUDIT PA   " + linebreak
			+ "    INNER JOIN CTE_LATEST_PROCESSAUDIT CTE  " + linebreak
			+ "        ON PA.POSTING_GROUP_AUDIT_ID = CTE.POSTING_GROUP_AUDIT_ID  " + linebreak
			+ "        AND PA.PROCESS_ID = CTE.PROCESS_ID  " + linebreak
			+ "        AND PA.PROCESS_AUDIT_ID = CTE.PROCESS_AUDIT_ID)   " + linebreak
			+ ",CTE_BASEINFO AS ( " + linebreak
			+ "    SELECT  " + linebreak
			+ "        IFNULL(PGA.POSTING_GROUP_AUDIT_ID,-1) AS POSTING_GROUP_AUDIT_ID, " + linebreak
			+ "        COUNT(DISTINCT P.PROCESS_ID) AS TOTAL_FILE_COUNT " + linebreak
			+ "    FROM STG_OLTP.ETL_CONTROLFILES CF  " + linebreak
			+ "    INNER JOIN ADM.PROCESS P  " + linebreak
			+ "        ON UPPER(P.TARGET_TABLE_NAME) = UPPER(CF.TARGET_TABLE_NAME)  " + linebreak
			+ "        AND P.IS_ACTIVE = 'TRUE'  " + linebreak
			+ "    INNER JOIN ADM.CUSTOMER C " + linebreak
			+ "        ON UPPER(CF.CONTROL_FILE_NAME) LIKE UPPER(C.CUSTOMER_DATABASE) || '%' " + linebreak
			+ "    INNER JOIN ADM_OLTP.POSTING_GROUP_AUDIT PGA  " + linebreak
			+ "        ON DATEDIFF(SECOND, CF.SNAPSHOT_DATE, PGA.SNAPSHOT_DATE) = 0 " + linebreak
			+ "        AND C.CUSTOMER_ID = PGA.CUSTOMER_ID " + linebreak
			+ "    LEFT OUTER JOIN CTE_PROCESS_AUDIT PA  " + linebreak
			+ "        ON PGA.POSTING_GROUP_AUDIT_ID = PA.POSTING_GROUP_AUDIT_ID  " + linebreak
			+ "        AND P.PROCESS_ID = PA.PROCESS_ID  " + linebreak
			+ "    WHERE PA.POSTING_GROUP_AUDIT_ID IS NULL OR PA.STATUS = 'S' " + linebreak
			+ "    GROUP BY IFNULL(PGA.POSTING_GROUP_AUDIT_ID,-1)) " + linebreak
			+ "SELECT  " + linebreak
			+ "    ARRAY_AGG(POSTING_GROUP_AUDIT_ID)WITHIN GROUP(ORDER BY POSTING_GROUP_AUDIT_ID ASC) AS POSTING_GROUP_AUDIT_ID, " + linebreak
			+ "    ARRAY_AGG(TOTAL_FILE_COUNT)WITHIN GROUP(ORDER BY POSTING_GROUP_AUDIT_ID ASC) AS TOTAL_FILE_COUNT " + linebreak
			+ "FROM CTE_BASEINFO; ";
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

