CREATE OR REPLACE PROCEDURE adm.ETL_Load_Balancer(
  "numberOfPipelines" FLOAT,
  "postingGroupAuditId" FLOAT,
  "isTruncate" BOOLEAN,
  "isDebug" BOOLEAN
)
returns VARIANT
language javascript
execute as caller
as
$$
    const output = {
        returnStatus: 1,
        data: "",
        rowsAffected: -1,
        audit: "not logged",
        status: "not executed",
        message: []
    };
    
    let cmd, stmt, rs;
    let linebreak = "\r\n";
    
    postingGroupAuditId = Number(postingGroupAuditId).toString();
    numberOfPipelines = Number(numberOfPipelines);
    
    let data = [];
    let size = [];
    let sumOfEachPipeline = [];
    let tableNames = new Set();
    let entry = [];
    let totalFileSize, threshold;
    let loadType, snapshotDate, snapshotDateTime, totalTableNumber;
    let i = 0;
    
    let count = 0, sum = 0;
    let pipeline = [];
    let tmp = [];
    
    for (i = 0; i < numberOfPipelines; i++) {
        sumOfEachPipeline.push(0);
		pipeline[i] = [];
    }
    
    i = 0;
    //get process files information.
    cmd = "WITH CTE_LATEST_PROCESSAUDIT AS( " + linebreak 
		+ "    SELECT POSTING_GROUP_AUDIT_ID, PROCESS_ID, MAX(PROCESS_AUDIT_ID) PROCESS_AUDIT_ID " + linebreak 
		+ "    FROM ADM.PROCESS_INJEST_AUDIT " + linebreak 
		+ "    GROUP BY POSTING_GROUP_AUDIT_ID,PROCESS_ID), " + linebreak 
		+ "CTE_PROCESS_INJEST_AUDIT AS( " + linebreak 
		+ "    SELECT PA.PROCESS_ID,PA.STATUS,PA.POSTING_GROUP_AUDIT_ID " + linebreak 
		+ "    FROM ADM.PROCESS_INJEST_AUDIT PA  " + linebreak 
		+ "    INNER JOIN CTE_LATEST_PROCESSAUDIT CTE " + linebreak 
		+ "        ON PA.POSTING_GROUP_AUDIT_ID = CTE.POSTING_GROUP_AUDIT_ID " + linebreak 
		+ "        AND PA.PROCESS_ID = CTE.PROCESS_ID " + linebreak 
		+ "        AND PA.PROCESS_AUDIT_ID = CTE.PROCESS_AUDIT_ID), " + linebreak 
		+ "CTE AS(" + linebreak 
		+ "    SELECT " + linebreak 
		+ "        ANY_VALUE(CF.LOAD_TYPE) AS LOADTYPE, " + linebreak 
		+ "        ANY_VALUE(TO_VARCHAR(CF.snapshot_date,'yyyy-mm-dd')) AS SNAPSHOTDATE, " + linebreak 
		+ "        ANY_VALUE(TO_VARCHAR(CF.snapshot_date,'yyyymmddhhmiss')) AS SNAPSHOTDATETIME, " + linebreak 
		+ "        ANY_VALUE(P.PROCESS_ID) AS PROCESSID, " + linebreak 
		+ "        ANY_VALUE(P.TARGET_TABLE_NAME) AS TARGETTABLENAME, " + linebreak 
		+ "        OBJECT_CONSTRUCT('processId',P.PROCESS_ID," + linebreak 
		+ "            'targetTableName',ANY_VALUE(P.TARGET_TABLE_NAME)," + linebreak 
		+ "            'tableFiles',ARRAY_AGG(OBJECT_CONSTRUCT(" + linebreak 
		+ "                'fileNumber',CF.FILE_NUMBER," + linebreak 
		+ "                'fileName',CF.FILE_NAME||'.gz'," + linebreak 
		+ "                'totalRowCount',CF.TOTAL_ROW_COUNT))) as jsObject," + linebreak 
		+ "        SUM(CF.FILE_SIZE) AS TABLEFILESIZE" + linebreak
		+ "    FROM STG.ETL_CONTROLFILES CF " + linebreak 
		+ "    INNER JOIN ADM.PROCESS P " + linebreak 
		+ "        ON UPPER(P.TARGET_TABLE_NAME) = UPPER(CF.TARGET_TABLE_NAME) " + linebreak 
		+ "        AND P.IS_ACTIVE = 'TRUE' " + linebreak 
		+ "    INNER JOIN ADM.POSTING_GROUP_INJEST_AUDIT PGA " + linebreak 
		+ "        ON PGA.POSTING_GROUP_AUDIT_ID = " + postingGroupAuditId.toString() + linebreak 
		+ "        AND CF.SNAPSHOT_DATE = PGA.SNAPSHOT_DATE " + linebreak 
		+ "    LEFT OUTER JOIN CTE_PROCESS_INJEST_AUDIT PA " + linebreak 
		+ "        ON PGA.POSTING_GROUP_AUDIT_ID = PA.POSTING_GROUP_AUDIT_ID " + linebreak 
		+ "        AND P.PROCESS_ID = PA.PROCESS_ID " + linebreak 
		+ "    WHERE PA.POSTING_GROUP_AUDIT_ID IS NULL OR PA.STATUS = 'S' " + linebreak 
		+ "    GROUP BY P.PROCESS_ID)" + linebreak 
		+ "SELECT " + linebreak 
		+ "    LOADTYPE," + linebreak 
		+ "    SNAPSHOTDATE," + linebreak 
		+ "    SNAPSHOTDATETIME, " + linebreak 
		+ "    PROCESSID, " + linebreak 
		+ "    TARGETTABLENAME, " + linebreak
		+ "    JSOBJECT," + linebreak 
		+ "    COUNT(1)OVER() AS TOTALTABLENUMBER," + linebreak 
		+ "    TABLEFILESIZE," + linebreak 
		+ "    SUM(TABLEFILESIZE)OVER() AS TOTALFILESIZE" + linebreak 
		+ "FROM CTE" + linebreak 
		+ "ORDER BY TABLEFILESIZE DESC," + linebreak 
		+ "    PROCESSID ASC;";
    if (isDebug) {
        output.message.push("--get process files information.");
        output.message.push(cmd);
    }
    try {
        stmt = snowflake.createStatement({sqlText: cmd});
        rs = stmt.execute();
        while (true) {
            if(!rs.next()) {
                if (size.length == 0) {
                    //no records returned.
                    output.returnStatus = -1;
                    output.rowsAffected = -1;
                    output.status = "failed";
                    output.message.push("Error Message: no records returned.");
                    output.message.push("Error Command: " + cmd);
                    return output;
                } else {
                    //no more records and quit the loop.
                    break;
                }
            } else if (size.length == 0) {
                totalFileSize = rs.getColumnValue("TOTALFILESIZE");
                threshold = Math.ceil(totalFileSize * 1.0 / numberOfPipelines);
                loadType = rs.getColumnValue("LOADTYPE");
                snapshotDate = rs.getColumnValue("SNAPSHOTDATE");
                snapshotDateTime = rs.getColumnValue("SNAPSHOTDATETIME");
                totalTableNumber = rs.getColumnValue("TOTALTABLENUMBER");
            }
            size.push(rs.getColumnValue("TABLEFILESIZE"));
            tableNames.add(rs.getColumnValue("TARGETTABLENAME").toUpperCase());
            entry[i++] = rs.getColumnValue("JSOBJECT");
        }
    } catch (err) {
        output.returnStatus = -1;
        output.rowsAffected = -1;
        output.status = "failed";
        output.message.push(err.message);
        output.message.push("Error Command: " + cmd);
        return output;
    }
    
    //truncate table if enabled.
    if (isTruncate) {
        for (let tableName of tableNames) {
            cmd = "TRUNCATE TABLE STG." + tableName + ";";
            if (isDebug) {
                output.message.push("--truncate table if enabled.");
                output.message.push(cmd);
            } else {
                try {
                    stmt = snowflake.createStatement({sqlText: cmd});
                    stmt.execute();
                } catch (err) {
                    output.returnStatus = -1;
                    output.rowsAffected = -1;
                    output.status = "failed";
                    output.message.push(err.message);
                    output.message.push("Error Command: " + cmd);
                    return output;
                }
            }
        }
    }
        
    //balance the load.  
	let j = 0
	let l = sumOfEachPipeline.length;
    for (i = 0; i < size.length; i++) {
        //find first available pipeline
		while (sumOfEachPipeline[j] >= threshold) {
			j = (j + 1) % l; 
		}

		pipeline[j].push(entry[i]);
		sumOfEachPipeline[j] += size[i];
		j = (j + 1) % l;
    }
    
    for (i = 0; i < pipeline.length; i++) {
        pipeline[i] = {
            "loadType" : loadType,
            "postingGroupAuditId" : postingGroupAuditId,
            "snapshotDate" : snapshotDate,
            "snapshotDateTime" : snapshotDateTime,
            "pipelineTotalSize" : sumOfEachPipeline[i].toFixed(3).toString(),
            "tableData" : pipeline[i]
        }
    }
    
    if(isDebug){
        output.returnStatus = 0;
        output.rowsAffected = -1;
        output.status = "debug";
    }else if(output.returnStatus != -1){
        output.rowsAffected = -1;
        output.status = "succeeded";
        output.data = {
            "totalTableNumber" : totalTableNumber.toString(),
            "totalFileSize" : totalFileSize.toString(),
            "threshold" : threshold.toString(),
            "tableData" : pipeline,
			"actualNumberOfPipelines" : pipeline.length
        };
    }
    
    return output;
$$;

