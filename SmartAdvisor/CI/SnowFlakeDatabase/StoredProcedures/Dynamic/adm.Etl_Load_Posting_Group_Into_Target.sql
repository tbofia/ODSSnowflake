CREATE OR REPLACE PROCEDURE adm.ETL_LOAD_POSTING_GROUP_INTO_TARGET(
    "jsonTables" STRING, -- output.data, get it from sproc #2.
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
    let commands = [];
    let statement;
    let recordSet;
    let targetTableName;
    
    jsonTables = JSON.parse(jsonTables);
    let injestTypeId;
    
    injestTypeId = jsonTables.loadType == 'FULL'? 0 : 1;
 
    let postingGroupAuditId = jsonTables.postingGroupAuditId;
        
    for(let i = 0; i < jsonTables.tableData.length; i++) {
         targetTableName = jsonTables.tableData[i].targetTableName;
         
         command = "CALL ADM.ETL_INSERT_PROCESS_INTO_TARGET_FROM_STAGING ('"+targetTableName+"',"+injestTypeId+","+postingGroupAuditId+",'False')";
         
         if(isDebug){
            output.message.push("--For table " + targetTableName + ", insert into SRC from STG.");
            output.message.push(command);
         }else{
            try{
                statement = snowflake.createStatement({sqlText:command});
                recordSet = statement.execute();
                recordSet.next();
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
        output.message = commands;
    }else if(output.returnStatus != -1){
        output.rowsAffected = -1;
        output.status = "succeeded";
        //output.message = "";
    }
    
    return output;

$$;

