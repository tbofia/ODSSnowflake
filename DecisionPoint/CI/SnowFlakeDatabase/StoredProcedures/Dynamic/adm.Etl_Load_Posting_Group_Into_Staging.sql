CREATE OR REPLACE PROCEDURE adm.ETL_LOAD_POSTING_GROUP_INTO_STAGING(
    "jsonTables" STRING, -- output.data, get it from sproc #2.
    "externalStage" STRING, --= 'ACSODS_DEV.STG.@DEV_ETL',
	"fileFolder" STRING,
	"isSourceOLTP" BOOLEAN,
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
    
    let command;
    let statement;
    let recordSet;
    
    let linebreak = "\r\n";
    let tab = "\t";
    
    jsonTables = JSON.parse(jsonTables);
    let processAuditId = "";
    let auditTableData = "";
    let totalRecodsLoaded = 0;

	let tbl_ProcessAudit = isSourceOLTP ? "ADM_OLTP.PROCESS_AUDIT" : "ADM.PROCESS_INJEST_AUDIT";
    let tbl_PostingGroupAudit = isSourceOLTP ? "ADM_OLTP.POSTING_GROUP_AUDIT" : "ADM.POSTING_GROUP_INJEST_AUDIT";
            
    for(let i = 0; i < jsonTables.tableData.length; i++) {
		if (!isSourceOLTP) {
			//get processAuditId
			command = "SELECT PROCESS_AUDIT_ID FROM ADM.PROCESS_INJEST_AUDIT " + linebreak
				+ " WHERE POSTING_GROUP_AUDIT_ID = " + jsonTables.postingGroupAuditId.toString() + linebreak
				+ " AND PROCESS_ID = " + jsonTables.tableData[i].processId.toString() + linebreak
				+ " AND STATUS = 'S' " + linebreak
				+ " ORDER BY PROCESS_AUDIT_ID DESC LIMIT 1;";
			if(isDebug){
				output.message.push("--get processAuditId for " + jsonTables.tableData[i].targetTableName);
				output.message.push(command);
			}else{
				//execution
				try{
					statement = snowflake.createStatement({sqlText:command});
					recordSet = statement.execute();
					recordSet.next();
					processAuditId = recordSet.getColumnValue(1);
				}catch(err){
					output.returnStatus = -1;
					output.rowsAffected = -1;
					output.status = "failed";
					output.message.push(command + ". Error: " + err.message);
					continue;
				}
			}

			//load it into STG table
			command = "CALL adm.Etl_Load_File_Into_Staging( " + linebreak
				+ processAuditId.toString() + linebreak
				+ ", '" + jsonTables.tableData[i].targetTableName + "'" + linebreak
				+ ", '" + jsonTables.snapshotDateTime + "'" + linebreak
				+ ",'" + externalStage + "'" + linebreak
				+ ",'" + fileFolder + "'" + linebreak
				+ ",parse_json('" + JSON.stringify(jsonTables.tableData[i].tableFiles) + "')" + linebreak
				+ ",false" + linebreak
				+ ",false" + linebreak
				+ ",false);";
		} else {
			//load it into STG table for OLTP -> Snowflake
			command = "CALL adm.Etl_Load_File_Into_Staging( " + linebreak
				+ "-1" + linebreak
				+ ", '" + jsonTables.tableData[i].targetTableName + "'" + linebreak
				+ ", ''" + linebreak
				+ ", '" + externalStage + "'" + linebreak
				+ ", ''" + linebreak
				+ ",parse_json('" + JSON.stringify(jsonTables.tableData[i].tableFiles) + "')" + linebreak
				+ ",false" + linebreak
				+ ",true" + linebreak
				+ ",false);";
		}
         
        if(isDebug){
			output.message.push("--load it into STG table for " + jsonTables.tableData[i].targetTableName);
			output.message.push(command);
        }else{
			try{
				statement = snowflake.createStatement({sqlText:command});
				recordSet = statement.execute();
				recordSet.next();
				totalRecodsLoaded = recordSet.getColumnValue(1).rowsAffected;
				if(recordSet.getColumnValue(1).returnStatus == -1){
					output.returnStatus = -1;
					output.rowsAffected = -1;
					output.status = "failed";
					output.message.push(recordSet.getColumnValue(1).message);
					output.message.push("Error Command: " + command);
					continue;
				}
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
        output.rowsAffected = -1;
        output.status = "debug";
    }else if(output.returnStatus != -1){
        output.rowsAffected = -1;
        output.status = "succeeded";
    }
    
    return output;
$$;

