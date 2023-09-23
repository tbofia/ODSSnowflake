CREATE OR REPLACE PROCEDURE adm.Etl_Backout_Posting_Group_By_Delete(
  "postingGroupAuditId" FLOAT,
  "previousCutoffPostingGroupauditId" FLOAT,
  "tableNames" VARCHAR,
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
        status: "",
        message: []
    }
    
    let command;
    let statement;
    let recordSet;
    let linebreak = "\r\n";
    let tab = "\t";
    
    let tableName = "";
    let schemaName = "";
    let localTimestamp;
    let lastChangeDate;
    let localTimeZone = "America/Los_Angeles";
    let joinClause = "";
    let innerJoinClause = "";
    let outerJoinCluase = "";
    let columnList = "";
    tableNames = tableNames.split(",");
    postingGroupAuditId = Number(postingGroupAuditId);
    previousCutoffPostingGroupauditId = Number(previousCutoffPostingGroupauditId);
    
    //Get the Lastchange date for the Posting group audit 
    command = "SELECT to_varchar(convert_timezone('" + localTimeZone + "', 'UTC', CREATE_DATE::timestamp_ntz)::TIMESTAMP_LTZ,'DY, DD MON YYYY HH24:MI:SS.FF9 TZHTZM') AS localTimestamp," + linebreak
        + "   MAX(LAST_CHANGE_DATE) AS lastChangeDate" + linebreak
        + "FROM ADM.POSTING_GROUP_INJEST_AUDIT " + linebreak
        + "WHERE POSTING_GROUP_AUDIT_ID = " + postingGroupAuditId.toString() + linebreak
        + "GROUP BY CREATE_DATE;";

    if(isDebug){
        output.message.push("--Get the Lastchange date for the Posting group audit");
        output.message.push(command);
    }
    statement = snowflake.createStatement({sqlText:command});
    recordSet = statement.execute();
    recordSet.next();
    localTimestamp = recordSet.getColumnValue(1);
    lastChangeDate = recordSet.getColumnValue(2);
    
    //backout posting_group in each table.
    for(let i = 0; i < tableNames.length; i++){
        tableName = tableNames[i].toUpperCase();
        schemaName = (tableName.split("."))[0];
        
		if(schemaName.split("_")[0].toUpperCase() != "RPT"){
            //when column with timestamp_ntz is part of primary key, cast it to timestamp_ntz(3) in the join clause.
            command = "SELECT  " + linebreak
				+"    LISTAGG( 'S.' || C.COLUMN_NAME || ' = ' || 'T.' || C.COLUMN_NAME ,' AND ') AS outerJoinClause,  " + linebreak
				+"    LISTAGG( CASE  " + linebreak
				+"        WHEN C.COLUMN_NAME = 'ODSPOSTINGGROUPAUDITID'  " + linebreak
				+"            THEN NULL  " + linebreak
				+"        ELSE 'A.' || C.COLUMN_NAME || ' = ' || 'B.' || C.COLUMN_NAME " + linebreak
				+"        END ,' AND ') AS innerJoinClause,  " + linebreak
				+"    LISTAGG( 'B.' || C.COLUMN_NAME ,',')||',B.ODSROWISCURRENT' AS columnList  " + linebreak
				+"FROM ADM.PROCESS_PRIMARY_KEY PPK " + linebreak
				+"INNER JOIN ADM.PROCESS P " + linebreak
				+"    ON PPK.PROCESS_ID = P.PROCESS_ID " + linebreak
				+"    AND UPPER(P.TARGET_TABLE_NAME) = UPPER('" + tableName.split(".")[1] + "') " + linebreak
				+"    AND UPPER(P.TARGET_SCHEMA_NAME) = UPPER('" + schemaName.split("_")[0] + "') " + linebreak
				+"INNER JOIN INFORMATION_SCHEMA.COLUMNS C " + linebreak
				+"    ON UPPER(PPK.PRIMARY_KEY_COLUMN) = C.COLUMN_NAME " + linebreak
				+"    AND UPPER(P.TARGET_TABLE_NAME) = C.TABLE_NAME " + linebreak
				+"    AND UPPER(P.TARGET_SCHEMA_NAME) = C.TABLE_SCHEMA;";
			
			if(isDebug){
                output.message.push("--For table " + tableNames[i] + ", Build the join clause to find the matched records from previous posting group.");
				output.message.push(command);
            }
            statement = snowflake.createStatement({sqlText:command});
            recordSet = statement.execute();
            if(recordSet.next()){
                outerJoinClause = recordSet.getColumnValue(1);
                innerJoinClause = recordSet.getColumnValue(2);
                columnList = recordSet.getColumnValue(3);
            }
            
            //flip back the odsrowiscurrent, OdsRowIsCurrent update 0 -> 1.
            command = " update " + tableName + " S" + linebreak
                + " set odsrowiscurrent = 1" + linebreak
                + " from (select " + columnList + linebreak
                + "       from " + tableName + " AT (timestamp => '" + localTimestamp + "'::timestamp) B" + linebreak
                + "       join " + tableName + " A" + linebreak
                + "           on " + innerJoinClause + linebreak
                + "           and A.odsrowiscurrent = 1" + linebreak
                + "           and B.odsrowiscurrent = 1" + linebreak
                + "           and A.odspostinggroupauditid > " + previousCutoffPostingGroupauditId.toString() + ") T" + linebreak
                + " where " + outerJoinClause + linebreak
                + "     and S.odsrowiscurrent = 0" + linebreak
                + "     and T.odsrowiscurrent = 1;";
            if(isDebug){
                output.message.push("--flip back the odsrowiscurrent, OdsRowIsCurrent update 0 -> 1.");
                output.message.push(command);
            }else{
                try{
                    statement = snowflake.createStatement({sqlText:command});
                    statement.execute(); 
                }catch(err){
                    output.returnStatus = -1;
                    output.rowsAffected = -1;
                    output.status = "failed";
                    output.message.push(err.message);
                    output.message.push("Error Command: " + command);
                    continue;
                }
            }
        }
        
        //delete the records of the latest postinggroup
        command = "DELETE FROM " + tableName + linebreak
            + "WHERE " + (schemaName.split("_")[0].toUpperCase() == "RPT" ? "POSTINGGROUPAUDITID" : "ODSPOSTINGGROUPAUDITID")
            + " > " + previousCutoffPostingGroupauditId.toString() + ";";
        if(isDebug){
            output.message.push("--delete the records of the latest postinggroup.");
            output.message.push(command);
        }else{
            try{
                statement = snowflake.createStatement({sqlText:command});
                statement.execute(); 
            }catch(err){
                output.returnStatus = -1;
                output.rowsAffected = -1;
                output.status = "failed";
                output.message.push(err.message);
                output.message.push("Error Command: " + command);
                continue;
            }
        }
    }
    
    if(isDebug){
        output.returnStatus = 0;
        output.status = "debug";
    }else if(output.returnStatus == 1){
        output.status = "succeeded";
    }
    
    return output;
$$;
