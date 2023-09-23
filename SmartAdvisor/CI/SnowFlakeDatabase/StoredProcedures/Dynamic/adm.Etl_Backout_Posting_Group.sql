CREATE OR REPLACE PROCEDURE adm.Etl_Backout_Posting_Group(
 "postingGroupAuditId" FLOAT,
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
        message: ""
    }
    
    let command;
    let arrayCommands = [];
    let statement;
    let recordSet;
    let linebreak = "\r\n";
    let tab = "\t";
    let lastChangeDate;
    let localTimeZone = "America/Los_Angeles";
    let localTimestamp;
    let schemaCreateDate;
    let schemaNames = ['RPT','ADM','SRC'];
       
    postingGroupAuditId = Number(postingGroupAuditId);
    
    //get schemaCreateDate
    command = "SHOW SCHEMAS LIKE 'ADM';";
    if(isDebug){
        arrayCommands.push("--get schemaCreateDate");
        arrayCommands.push(command);
        statement = snowflake.createStatement({sqlText:command});
        recordSet = statement.execute();
        recordSet.next();
    }else{
        statement = snowflake.createStatement({sqlText:command});
        recordSet = statement.execute();
        recordSet.next();
    }
    
    command = "SELECT \"created_on\"::timestamp_ntz" + linebreak
            + "FROM TABLE(RESULT_SCAN(LAST_QUERY_ID()));";
    if(isDebug){
        arrayCommands.push("--get schemaCreateDate");
        arrayCommands.push(command);
        statement = snowflake.createStatement({sqlText:command});
        recordSet = statement.execute();
        recordSet.next();
        schemaCreateDate = recordSet.getColumnValue(1);
    }else{
        statement = snowflake.createStatement({sqlText:command});
        recordSet = statement.execute();
        recordSet.next();
        schemaCreateDate = recordSet.getColumnValue(1);
    }
    
    //Get the Lastchange date for the Posting group audit 
    command = "SELECT to_varchar(convert_timezone('" + localTimeZone + "', 'UTC', CREATE_DATE::timestamp_ntz)::TIMESTAMP_LTZ,'DY, DD MON YYYY HH24:MI:SS.FF9 TZHTZM') AS localTimestamp," + linebreak
        + "   MAX(LAST_CHANGE_DATE) AS lastChangeDate" + linebreak
        + "FROM ADM.POSTING_GROUP_INJEST_AUDIT " + linebreak
        + "WHERE POSTING_GROUP_AUDIT_ID = " + postingGroupAuditId.toString() + linebreak
        + "GROUP BY CREATE_DATE;";

    if(isDebug){
        arrayCommands.push("--Get the Lastchange date for the Posting group audit");
        arrayCommands.push(command);
        statement = snowflake.createStatement({sqlText:command});
        recordSet = statement.execute();
        recordSet.next();
        localTimestamp = recordSet.getColumnValue(1);
        lastChangeDate = recordSet.getColumnValue(2);
    }else{
        statement = snowflake.createStatement({sqlText:command});
        recordSet = statement.execute();
        recordSet.next();
        localTimestamp = recordSet.getColumnValue(1);
        lastChangeDate = recordSet.getColumnValue(2);
    }
    
    if(lastChangeDate <= schemaCreateDate){
        output.rowsAffected = -1;
        output.status = "not executed";
        output.message = "schema create date is later than last change date of current posting group (" + postingGroupAuditId.toString() + ")";
        return output;
    }
    
    //For each schame name create restored schema as of the timestamp
    try{
        //BEGIN TRANSACTION
        command = "BEGIN TRANSACTION;";
        if(isDebug){
            arrayCommands.push(command);
        }else{
            statement = snowflake.createStatement({sqlText:command});
            statement.execute();
        }     
        for(let i= 0; i< schemaNames.length ;i++){
            //Create the restored  schemas
            command ="CREATE OR REPLACE SCHEMA restored_" + schemaNames[i] +" CLONE " + schemaNames[i] +" AT(timestamp =>'"+ localTimestamp +"'::timestamp);" ;

            if(isDebug){
                arrayCommands.push("--For each schame name create restored schema as of the timestamp");  
                arrayCommands.push(command);
            }else{
                statement = snowflake.createStatement({sqlText:command});
                recordSet = statement.execute();
                recordSet.next();
            }

            //Rename the exsiting schema to _BAK
            command ="ALTER SCHEMA " + schemaNames[i] +" RENAME TO " + schemaNames[i] +"_BAK;"; 

            if(isDebug){
                arrayCommands.push("--Rename the exsiting schema to _BAK");
                arrayCommands.push(command);
            }else{
                statement = snowflake.createStatement({sqlText:command});
                recordSet = statement.execute();
                recordSet.next();
            }

            //Rename the restored schema to the original schema
            command ="ALTER SCHEMA restored_" + schemaNames[i] +" RENAME TO " + schemaNames[i] + ";"; 

            if(isDebug){
                arrayCommands.push("--Rename the restored schema to the original schema");
                arrayCommands.push(command);
            }else{
                statement = snowflake.createStatement({sqlText:command});
                recordSet = statement.execute();
                recordSet.next();
            }

            //Drop the Backup schemas
            command = " DROP SCHEMA " + schemaNames[i] + "_BAK;";
            if(isDebug){
                arrayCommands.push("--Drop the backup schemas");
                arrayCommands.push(command);
            }else{
                statement = snowflake.createStatement({sqlText:command});
                recordSet = statement.execute();
                recordSet.next();
            }
        }

        //check and remove its record in adm.posting_group_injest_audit
        command = "DELETE FROM ADM.POSTING_GROUP_INJEST_AUDTI" + linebreak
                + "WHERE STATUS = 'S'" + linebreak
                + "AND POSTING_GROUP_AUDIT_ID =" + postingGroupAuditId.toString();
        if(isDebug){
            arrayCommands.push("--check and remove its record in adm.posting_group_injest_audit");
            arrayCommands.push(command);
        }else{
            statement = snowflake.createStatement({sqlText:command});
            statement.execute();
        }

        //commit transaction
        command = "COMMIT;";
        if(isDebug){
            arrayCommands.push("--commit transaction");
            arrayCommands.push(command);
        }else{
            statement = snowflake.createStatement({sqlText:command});
            statement.execute();
        }
    }catch(err){
        //rollback transaction
        command = "ROLLBACK;";
        if(isDebug){
            arrayCommands.push("--rollback transaction");
            arrayCommands.push(command);
        }else{
            statement = snowflake.createStatement({sqlText:command});
            statement.execute();
        }
    }
    
    if(isDebug){
        output.returnStatus = 0;
        output.rowsAffected = -1;
        output.status = "debug";
        output.message = arrayCommands;
    }else{
        output.rowsAffected = -1;
        output.status = "succeeded";
        output.audit = "logged";
    }
    
    return output;
$$;
    
 