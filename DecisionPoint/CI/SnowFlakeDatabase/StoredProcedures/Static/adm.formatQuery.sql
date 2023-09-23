/*
	-- format the message of the result, if the query is calling a stored procedure.
	1. call adm.formatQuery('call adm.ETL_GET_PROCESS_FILES(''2020-02-10 02:10:04'',true);'); 
	-- debug mode according to adm.procedure_output table.
	2. call adm.formatQuery('ETL_GET_PROCESS_FILES');
	-- format for any given query without running it. Please remember replace ' with ''.
	3. call adm.formatQuery('<any query>'); 
*/

create or replace procedure adm.formatQuery("inputString" string)
returns string
language javascript
as
$$

let command;
let statement;
let recordSet;
let output = "";

let linebreak = "\r\n";
let tab = "\t";

if((inputString.split(" "))[0].toUpperCase() == "CALL"){
    try{
        statement = snowflake.createStatement({sqlText:inputString});
        recordSet = statement.execute();
        recordSet.next();
        recordSet = recordSet.getColumnValue(1);
    }catch(err){
        return err.message;
    }   
}else if(!inputString.includes(" ")){
    command = "SELECT IFNULL(statement,'') FROM ACSODS_DEV.ADM.PROCEDURE_OUTPUT " + linebreak
        + "WHERE PROCEDURENAME = UPPER('" + inputString + "')" + linebreak
        + "AND SCENARIO = 'debug';";
    statement = snowflake.createStatement({sqlText:command});
    recordSet = statement.execute();
    recordSet.next();
    
    command = recordSet.getColumnValue(1);
    if(command == "")
        return "this procedure's input information is currently unavailable.";
    try{
        statement = snowflake.createStatement({sqlText:command});
        recordSet = statement.execute();
        recordSet.next();
        recordSet = recordSet.getColumnValue(1);
    }catch(err){
        return err.message;
    }
}else{
    //this is a query
    return inputString.replace(/\\r\\n/g,linebreak).replace(/\\t/g,tab);
}

if(typeof(recordSet.message) == "string"){
    return recordSet.message.replace(/\\r\\n/g,linebreak).replace(/\\t/g,tab);
}else if(Array.isArray(recordSet.message)){
    recordSet.message.forEach(msg => {output += msg.replace(/\\r\\n/g,linebreak).replace(/\\t/g,tab) + linebreak + linebreak;});
}else{
    return "this type of message \"" + typeof(recordSet.message) + "\" is currently not supported."
}

return output;

$$;