	/*

	call ADM.ETL_GET_CONTROLFILES (
		'@ACSODS_DEV.stg.etl_dev'
		,'STG.FORMAT_FILE_DEL_COMMA'
		,true
		,false);

	*/

	CREATE OR REPLACE PROCEDURE ADM.ETL_GET_CONTROLFILES(
		"externalStage" STRING,
		"formatFile" STRING,
		"isSourceOLTP" BOOLEAN, 
		"isDebug" BOOLEAN
	)
	RETURNS VARIANT
	LANGUAGE JAVASCRIPT
	EXECUTE AS CALLER
	as     
	$$ 
		const output = {
			returnStatus: -1,
			data: {
				customers: [],
				snapshotDates: [],
				maxCountOfPostingGroups: 0
			},
			rowsAffected: -1,
			audit: "not logged",
			status: "not executed",
			message: []
		};
	
		let command = "";
		let statement;
		let recordSet;
		let controlFileNames = "";
		let linebreak = "\r\n";

		let schema_staging = isSourceOLTP ? "STG_OLTP" : "STG";
		externalStage = externalStage.toUpperCase();

		//Truncate stg.Etl_ControlFiles table 
		command = " TRUNCATE TABLE " + schema_staging + ".ETL_CONTROLFILES;";
		if(isDebug){
			output.returnStatus = 0;
			output.rowsAffected = -1;
			output.status = "debug";
			output.message.push("--Truncate " + schema_staging + ".Etl_ControlFiles table");
			output.message.push(command);
		}else{
			try{
				statement = snowflake.createStatement({sqlText: command});
				statement.execute();
			}catch(err){
				output.returnStatus = -1;
				output.rowsAffected = -1;
				output.audit= 'logged';
				output.status = 'failed';
				output.message.push(err.message);
				return output;
			}
		}

		//Load All Control files from the external stage
		command = "ls " + externalStage + linebreak
			+ "pattern = '.*.ctl.gz';";        
		if(isDebug){
			output.message.push("--Load All Control files from the external stage");
			output.message.push(command);
		}else{
			try{
				statement = snowflake.createStatement({sqlText: command});
				statement.execute();
			}catch(err){
				output.returnStatus = -1;
				output.rowsAffected = -1;
				output.audit= "logged";
				output.status = "failed";
				output.message.push(err.message);
				output.message.push("Error Command: " + command);
				return output;
			}
		}	
		
		command = "WITH CTE_BaseInfo AS (" + linebreak 
			+ "    SELECT " + linebreak 
			+ (isSourceOLTP ? "        UPPER(STRTOK(\"name\", '/', (ARRAY_SIZE(STRTOK_TO_ARRAY(\"name\", '/'))) - 2)) || '/'" + linebreak 
							: "        ''" + linebreak)
			+ "            || STRTOK(\"name\", '/', (ARRAY_SIZE(STRTOK_TO_ARRAY(\"name\", '/'))) - 1)" + linebreak 
			+ "            || '/' || STRTOK(\"name\", '/', (ARRAY_SIZE(STRTOK_TO_ARRAY(\"name\", '/')))) AS FileName" + linebreak 
			+ "        , TRY_TO_TIMESTAMP(STRTOK(STRTOK(\"name\"" + linebreak 
			+ "                                        , '/'" + linebreak 
			+ "                                        , (ARRAY_SIZE(STRTOK_TO_ARRAY(\"name\", '/'))))" + linebreak 
			+ "                                 , '_'" + linebreak 
			+ "                                 , REGEXP_COUNT(STRTOK(\"name\"" + linebreak 
			+ "                                                      , '/'" + linebreak 
			+ "                                                      , (ARRAY_SIZE(STRTOK_TO_ARRAY(\"name\", '/'))))" + linebreak 
			+ "                                               , '_') - 1)" + linebreak 
			+ "                          , 'YYYYMMDDhhmiss') AS SnapshotDate" + linebreak 
			+ (isSourceOLTP ? "        ,STRTOK(\"name\", '/', (ARRAY_SIZE(STRTOK_TO_ARRAY(\"name\", '/'))) - 2) AS CustomerName" + linebreak 
							: "        ,'ACSODS' AS CustomerName" + linebreak)
			+ "    FROM TABLE(RESULT_SCAN(LAST_QUERY_ID()))" + linebreak 
			+ ")" + linebreak

			+ ", CTE_MaxSnapshotDatePerCustomer AS (" + linebreak 
			+ "    SELECT " + linebreak 
			+ "        MAX(SNAPSHOT_DATE) AS MaxSnapshotDate" + linebreak 
			+ (isSourceOLTP ? "        , CUSTOMER_ID" + linebreak : "") 
			+ (isSourceOLTP ? "    FROM ADM_OLTP.POSTING_GROUP_AUDIT " + linebreak 
							: "    FROM ADM.POSTING_GROUP_INJEST_AUDIT " + linebreak)
			+ "    WHERE STATUS = 'FI' " + linebreak
			+ (isSourceOLTP ? "    GROUP BY CUSTOMER_ID " + linebreak : "")
			+ ")" + linebreak 
			+ "SELECT " + linebreak 
			+ "    LISTAGG(RS.FileName, ''',''') AS ControlFiles" + linebreak 
			+ "FROM CTE_BaseInfo AS RS" + linebreak 
			+ (isSourceOLTP ? "INNER JOIN ADM.CUSTOMER AS C" + linebreak 
							+ "    ON UPPER(RS.CustomerName) = UPPER(C.Customer_Database)" + linebreak 
							: "")
			+ "LEFT OUTER JOIN CTE_MaxSnapshotDatePerCustomer AS PGIA" + linebreak 
			+ "    ON 1 = 1" + linebreak 
			+ (isSourceOLTP ? "    AND C.Customer_Id = PGIA.Customer_Id" + linebreak : "")
			+ "WHERE NULLIF(RS.SnapshotDate ,'1900-01-01') > IFNULL(PGIA.MaxSnapshotDate, '1900-01-01');";
		
		if(isDebug){
			output.message.push(command);
		}else{
			try{
				statement = snowflake.createStatement({sqlText: command});
				recordSet = statement.execute();
				if(recordSet.next()){
					controlFileNames = recordSet.getColumnValue(1);
				}
			}catch(err){
				output.returnStatus = -1;
				output.rowsAffected = -1;
				output.audit= "logged";
				output.status = "failed";
				output.message.push(err.message);
				output.message.push("Error Command: " + command);
				return output;
			}
		}	

		command = " COPY INTO " + schema_staging + ".ETL_CONTROLFILES" + linebreak
			+ " FROM "+  externalStage + linebreak
			+ " FILES = ('" + controlFileNames + "')" + linebreak
			+ " FILE_FORMAT = ( FORMAT_NAME = "+ formatFile + ")" + linebreak
			+ " ON_ERROR = ABORT_STATEMENT ;";   
		if(isDebug){
			output.message.push(command);
		}else{
			try{
				statement = snowflake.createStatement({sqlText: command});
				statement.execute();
			}catch(err){
				output.returnStatus = -1;
				output.rowsAffected = -1;
				output.audit= "logged";
				output.status = "failed";
				output.message.push(err.message);
				output.message.push("Error Command: " + command);
				return output;
			}
		}

		//Cleanup the STG.ETL_ControlFiles table
		//1. remove full load table extraction for those who have preceding successful full load extractions.
		command = "DELETE FROM " + schema_staging + ".ETL_CONTROLFILES AS CF" + linebreak 
			+ "USING (" + linebreak 
			+ "    SELECT UPPER(P.TARGET_TABLE_NAME) AS TARGET_TABLE_NAME" + linebreak
			+ "        , UPPER(C.CUSTOMER_DATABASE) AS CUSTOMER_DATABASE" + linebreak
			+ "        , PGA.SNAPSHOT_DATE" + linebreak
			+ "    FROM ADM_OLTP.POSTING_GROUP_AUDIT AS PGA" + linebreak
			+ "    INNER JOIN ADM.CUSTOMER AS C" + linebreak
			+ "        ON PGA.CUSTOMER_ID = C.CUSTOMER_ID" + linebreak
			+ "    INNER JOIN ADM_OLTP.PROCESS_AUDIT AS PA" + linebreak
			+ "        ON PGA.DATA_EXTRACT_TYPE_ID = 0" + linebreak
			+ "        AND PGA.STATUS = 'FI'" + linebreak
			+ "        AND PGA.POSTING_GROUP_AUDIT_ID = PA.POSTING_GROUP_AUDIT_ID" + linebreak
			+ "    INNER JOIN ADM.PROCESS AS P" + linebreak
			+ "        ON PA.PROCESS_ID = P.PROCESS_ID" + linebreak 
			+ ") AS BI" + linebreak 
			+ "WHERE UPPER(BI.TARGET_TABLE_NAME) = UPPER(CF.TARGET_TABLE_NAME)" + linebreak 
			+ "    AND UPPER(ARRAY_TO_STRING(ARRAY_SLICE(STRTOK_TO_ARRAY(CONTROL_FILE_NAME, '_')" + linebreak 
			+ "            , 0" + linebreak 
			+ "            , (ARRAY_SIZE(STRTOK_TO_ARRAY(CONTROL_FILE_NAME, '_'))) - 3), '_'))" + linebreak 
			+ "        = UPPER(BI.CUSTOMER_DATABASE)" + linebreak
			+ "    AND STRTOK(STRTOK(CONTROL_FILE_NAME, '_', (ARRAY_SIZE(STRTOK_TO_ARRAY(CONTROL_FILE_NAME, '_')))), '.', 1)" + linebreak
			+ "        = 'FULL';";
		if(isDebug && isSourceOLTP){
			output.message.push("--Cleanup the " + schema_staging + ".ETL_ControlFiles table.");
			output.message.push("--1. remove full records for those who have preceding successful full load extractions.");
			output.message.push(command);
		}else if (isSourceOLTP){
			try{
				statement = snowflake.createStatement({sqlText: command});
				statement.execute();
			}catch(err){
				output.returnStatus = -1;
				output.rowsAffected = -1;
				output.audit= "logged";
				output.status = "failed";
				output.message.push(err.message);
				output.message.push("Error Command: " + command);
				return output;
			}
		}

		//Get the customer names and their snapshot dates respectively.
		command = "WITH CTE AS (" + linebreak 
			+ "    SELECT " + linebreak 
			+ (isSourceOLTP ? "        UPPER(ANY_VALUE(ARRAY_TO_STRING(ARRAY_SLICE(STRTOK_TO_ARRAY(CONTROL_FILE_NAME, '_')" + linebreak 
							+ "            , 0" + linebreak 
							+ "            , (ARRAY_SIZE(STRTOK_TO_ARRAY(CONTROL_FILE_NAME, '_'))) - 3), '_'))) AS CustomerName" + linebreak 
							: "        'ACSODS' AS CustomerName" + linebreak)
			+ "        , ARRAY_AGG(DISTINCT S.SNAPSHOT_DATE)WITHIN GROUP(ORDER BY S.SNAPSHOT_DATE ASC) AS SnapshotDates" + linebreak 
			+ "    FROM " + schema_staging + ".ETL_CONTROLFILES S " + linebreak 
			+ (isSourceOLTP ? "    INNER JOIN ADM.CUSTOMER C" + linebreak 
							+ "        ON UPPER(S.CONTROL_FILE_NAME) LIKE UPPER(C.CUSTOMER_DATABASE) || '%'" + linebreak 
							+ "    LEFT OUTER JOIN ADM_OLTP.POSTING_GROUP_AUDIT P " + linebreak 
							+ "        ON P.CUSTOMER_ID = C.CUSTOMER_ID" + linebreak 
							: "    LEFT OUTER JOIN ADM.POSTING_GROUP_INJEST_AUDIT P " + linebreak 
							+ "        ON 1 = 1" + linebreak)
			+ "        AND S.SNAPSHOT_DATE = P.SNAPSHOT_DATE" + linebreak 
			+ "    WHERE P.STATUS <> 'FI' OR P.POSTING_GROUP_AUDIT_ID IS NULL" + linebreak 
			+ "    GROUP BY UPPER(STRTOK(CONTROL_FILE_NAME, '_', (ARRAY_SIZE(STRTOK_TO_ARRAY(CONTROL_FILE_NAME, '_'))) - 3))" + linebreak 
			+ ")" + linebreak 
			+ "SELECT " + linebreak 
			+ "    ARRAY_AGG(CustomerName)WITHIN GROUP(ORDER BY CustomerName) AS CustomerName," + linebreak 
			+ "    ARRAY_AGG(SnapshotDates)WITHIN GROUP(ORDER BY CustomerName) AS SnapshotDate," + linebreak 
			+ "    MAX(ARRAY_SIZE(SnapshotDates)) AS MaxCountOfPostingGroups" + linebreak 
			+ "FROM CTE;";
		if(isDebug){
			output.message.push("--Get the customer names and their snapshot dates respectively.");
			output.message.push(command);
		}else{
			try{
				statement = snowflake.createStatement({sqlText: command});
				recordSet = statement.execute();
				recordSet.next();
				
				output.returnStatus = 1;
				output.data.customers = recordSet.getColumnValue("CUSTOMERNAME");
				output.data.snapshotDates = recordSet.getColumnValue("SNAPSHOTDATE");
				output.data.maxCountOfPostingGroups = recordSet.getColumnValue("MAXCOUNTOFPOSTINGGROUPS");
				output.audit= "logged";
				output.status = "succeeded";
				output.message = "";
			}catch(err){
				output.returnStatus = -1;
				output.rowsAffected = -1;
				output.audit= "logged";
				output.status = "failed";
				output.message.push(err.message);
				output.message.push("Error Command: " + command);
			}
		}

		return output;
	$$;

