create or replace procedure adm.executeTaskThenSuspend(
  "taskStatements" string,
  "taskName" string,
  "isDebug" boolean
)
returns variant
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

    taskStatements = taskStatements.split("~$~");

    for(let i = 0; i < taskStatements.length; i++){
        if(isDebug){
            output.message.push(taskStatements[i]);
        }else{
            try{
                cmd = taskStatements[i];
                stmt = snowflake.createStatement({sqlText:cmd});
                rs = stmt.execute();
                if(rs.next()){
                    if(rs.getColumnValue(1).status == "failed"){
                        output.returnStatus = -1;
                        output.message.push(rs.getColumnValue(1).message);
                    }
                }
            }catch(err){
                output.returnStatus = -1;
                output.message.push(err.message);
                output.message.push(cmd);
            }
        }
    }

    cmd = "ALTER TASK " + taskName + " SUSPEND;";
    if(isDebug){
        output.message.push(cmd);
    }else{
        stmt = snowflake.createStatement({sqlText:cmd});
        rs = stmt.execute();
    }

    if(output.returnStatus == -1){
        cmd = "call system$set_return_value('" + output.message.join(";\r\n").replace(/'/g,"''") + "');";
        if(isDebug){
            output.message.push(cmd);
        }else{
            stmt = snowflake.createStatement({sqlText:cmd});
            rs = stmt.execute();
        }
    }
    
    return output;

$$;