/*
call ADM.ALTER_COLUMN('add');
call ADM.ALTER_COLUMN('add', 'adm', 'test', 'id3', 'varchar(10)', 'null', 'this is comment');
call ADM.ALTER_COLUMN('drop', 'adm', 'test', 'id3');
call ADM.ALTER_COLUMN('rename', 'adm', 'test', 'id3', 'id3_new');
call ADM.ALTER_COLUMN('alter', 'adm', 'test', 'id3_new', 'varchar(15)', 'not null', 'this is new comment');
*/

--Helper
CREATE OR REPLACE PROCEDURE ADM.ALTER_COLUMN(OPERATION_TYPE STRING)
RETURNS STRING NOT NULL
LANGUAGE JAVASCRIPT
AS
$$
    let message = "";
    let command = "";
    let statement = "";
    let recordSet = "";
    
    command = "CALL ADM.ALTER_COLUMN('" 
        + OPERATION_TYPE 
        + "', NULL, NULL, NULL, NULL, NULL, NULL, NULL);";
    try{
        statement = snowflake.createStatement({sqlText: command});
        recordSet = statement.execute();
        if (recordSet.next())  {
            message = recordSet.getColumnValue(1);
        }
    } catch(err){
        message = err.message;
    }
    
    return message;
$$;

--Add/Alter New Column without Comment
CREATE OR REPLACE PROCEDURE ADM.ALTER_COLUMN(
    OPERATION_TYPE STRING, 
    TABLE_SCHEMA STRING, 
    TABLE_NAME STRING, 
    COLUMN_NAME STRING,
    COLUMN_DATA_TYPE STRING, 
    NULLABILITY STRING
)
RETURNS STRING NOT NULL
LANGUAGE JAVASCRIPT
AS
$$
    OPERATION_TYPE = OPERATION_TYPE.toUpperCase();
    TABLE_SCHEMA = (TABLE_SCHEMA === undefined ? "NULL" : "'" + TABLE_SCHEMA.toUpperCase() + "'");
    TABLE_NAME = (TABLE_NAME === undefined ? "NULL" : "'" + TABLE_NAME.toUpperCase() + "'");
    COLUMN_NAME = (COLUMN_NAME === undefined ? "NULL" : "'" + COLUMN_NAME.toUpperCase() + "'");
    COLUMN_DATA_TYPE = (COLUMN_DATA_TYPE === undefined ? "NULL" : "'" + COLUMN_DATA_TYPE.toUpperCase() + "'");
    NULLABILITY = (NULLABILITY === undefined ? "NULL" : "'" + NULLABILITY.toUpperCase() + "'");
    
    let message = "";
    let command = "";
    let statement = "";
    let recordSet = "";
    
    command = "CALL ADM.ALTER_COLUMN('" 
        + OPERATION_TYPE + "', " 
        + (["ADD", "ALTER"].includes(OPERATION_TYPE) ? TABLE_SCHEMA : "NULL") + ", " 
        + TABLE_NAME + ", "
        + (OPERATION_TYPE == "ADD" ? "NULL" : COLUMN_NAME) + ", "
        + (OPERATION_TYPE == "ADD" ? COLUMN_NAME : "NULL") + ", "
        + COLUMN_DATA_TYPE + ", "
        + NULLABILITY 
        + ", NULL);";
    try{
        statement = snowflake.createStatement({sqlText: command});
        recordSet = statement.execute();
        if (recordSet.next())  {
            message = recordSet.getColumnValue(1);
        }
    } catch(err){
        message = err.message;
    }
    
    return message;
$$;

--Add/Alter New Column with Comment
CREATE OR REPLACE PROCEDURE ADM.ALTER_COLUMN(
    OPERATION_TYPE STRING, 
    TABLE_SCHEMA STRING, 
    TABLE_NAME STRING, 
    COLUMN_NAME STRING,
    COLUMN_DATA_TYPE STRING, 
    NULLABILITY STRING,
    COMMENT STRING
)
RETURNS STRING NOT NULL
LANGUAGE JAVASCRIPT
AS
$$
    OPERATION_TYPE = OPERATION_TYPE.toUpperCase();
    TABLE_SCHEMA = (TABLE_SCHEMA === undefined ? "NULL" : "'" + TABLE_SCHEMA.toUpperCase() + "'");
    TABLE_NAME = (TABLE_NAME === undefined ? "NULL" : "'" + TABLE_NAME.toUpperCase() + "'");
    COLUMN_NAME = (COLUMN_NAME === undefined ? "NULL" : "'" + COLUMN_NAME.toUpperCase() + "'");
    COLUMN_DATA_TYPE = (COLUMN_DATA_TYPE === undefined ? "NULL" : "'" + COLUMN_DATA_TYPE.toUpperCase() + "'");
    NULLABILITY = (NULLABILITY === undefined ? "NULL" : "'" + NULLABILITY.toUpperCase() + "'");
    COMMENT = (COMMENT === undefined ? "NULL" : "'" + COMMENT.toUpperCase() + "'");
    
    let message = "";
    let command = "";
    let statement = "";
    let recordSet = "";
    
    command = "CALL ADM.ALTER_COLUMN('" 
        + OPERATION_TYPE + "', " 
        + (["ADD", "ALTER"].includes(OPERATION_TYPE) ? TABLE_SCHEMA : "NULL") + ", " 
        + TABLE_NAME + ", "
        + (OPERATION_TYPE == "ADD" ? "NULL" : COLUMN_NAME) + ", "
        + (OPERATION_TYPE == "ADD" ? COLUMN_NAME : "NULL") + ", "
        + COLUMN_DATA_TYPE + ", "
        + NULLABILITY + ", "
        + COMMENT + ");";
    try{
        statement = snowflake.createStatement({sqlText: command});
        recordSet = statement.execute();
        if (recordSet.next())  {
            message = recordSet.getColumnValue(1);
        }
    } catch(err){
        message = err.message;
    }
    
    return message;
$$;

--Drop Column
CREATE OR REPLACE PROCEDURE ADM.ALTER_COLUMN(
    OPERATION_TYPE STRING, 
    TABLE_SCHEMA STRING, 
    TABLE_NAME STRING, 
    COLUMN_NAME STRING
)
RETURNS STRING NOT NULL
LANGUAGE JAVASCRIPT
AS
$$
    OPERATION_TYPE = OPERATION_TYPE.toUpperCase();
    TABLE_SCHEMA = (TABLE_SCHEMA === undefined ? "NULL" : "'" + TABLE_SCHEMA.toUpperCase() + "'");
    TABLE_NAME = (TABLE_NAME === undefined ? "NULL" : "'" + TABLE_NAME.toUpperCase() + "'");
    COLUMN_NAME = (COLUMN_NAME === undefined ? "NULL" : "'" + COLUMN_NAME.toUpperCase() + "'");
    
    let message = "";
    let command = "";
    let statement = "";
    let recordSet = "";
    
    command = "CALL ADM.ALTER_COLUMN('" 
        + OPERATION_TYPE + "', " 
        + (OPERATION_TYPE == "DROP" ? TABLE_SCHEMA : "NULL") + ", " 
        + TABLE_NAME + ", "
        + COLUMN_NAME
        + ", NULL, NULL, NULL, NULL);";
    try{
        statement = snowflake.createStatement({sqlText: command});
        recordSet = statement.execute();
        if (recordSet.next())  {
            message = recordSet.getColumnValue(1);
        }
    } catch(err){
        message = err.message;
    }
    
    return message;
$$;

--Rename Column
CREATE OR REPLACE PROCEDURE ADM.ALTER_COLUMN(
    OPERATION_TYPE STRING, 
    TABLE_SCHEMA STRING, 
    TABLE_NAME STRING, 
    COLUMN_NAME_OLD STRING,
    COLUMN_NAME_NEW STRING
)
RETURNS STRING NOT NULL
LANGUAGE JAVASCRIPT
AS
$$
    OPERATION_TYPE = OPERATION_TYPE.toUpperCase();
    TABLE_SCHEMA = (TABLE_SCHEMA === undefined ? "NULL" : "'" + TABLE_SCHEMA.toUpperCase() + "'");
    TABLE_NAME = (TABLE_NAME === undefined ? "NULL" : "'" + TABLE_NAME.toUpperCase() + "'");
    COLUMN_NAME_OLD = (COLUMN_NAME_OLD === undefined ? "NULL" : "'" + COLUMN_NAME_OLD.toUpperCase() + "'");
    COLUMN_NAME_NEW = (COLUMN_NAME_NEW === undefined ? "NULL" : "'" + COLUMN_NAME_NEW.toUpperCase() + "'");
    
    let message = "";
    let command = "";
    let statement = "";
    let recordSet = "";
    
    command = "CALL ADM.ALTER_COLUMN('" 
        + OPERATION_TYPE + "', " 
        + (OPERATION_TYPE == "RENAME" ? TABLE_SCHEMA : "NULL") + ", " 
        + TABLE_NAME + ", "
        + COLUMN_NAME_OLD + ", " 
        + COLUMN_NAME_NEW
        + ", NULL, NULL, NULL);";
    try{
        statement = snowflake.createStatement({sqlText: command});
        recordSet = statement.execute();
        if (recordSet.next())  {
            message = recordSet.getColumnValue(1);
        }
    } catch(err){
        message = err.message;
    }
    
    return message;
$$;

--Base Procedure
CREATE OR REPLACE PROCEDURE ADM.ALTER_COLUMN(
    OPERATION_TYPE STRING, 
    TABLE_SCHEMA STRING, 
    TABLE_NAME STRING, 
    COLUMN_NAME_OLD STRING,
    COLUMN_NAME_NEW STRING,
    COLUMN_DATA_TYPE_NEW STRING, 
    NULLABILITY_NEW STRING,
    COMMENT_NEW STRING
)
RETURNS STRING NOT NULL
LANGUAGE JAVASCRIPT
AS
$$
    OPERATION_TYPE = (OPERATION_TYPE === undefined ? "Undefined" : OPERATION_TYPE.toUpperCase());
    TABLE_SCHEMA = (TABLE_SCHEMA === undefined ? false : TABLE_SCHEMA.toUpperCase());
    TABLE_NAME = (TABLE_NAME === undefined ? false : TABLE_NAME.toUpperCase());
    COLUMN_NAME_OLD = (COLUMN_NAME_OLD === undefined ? false : COLUMN_NAME_OLD.toUpperCase());
    COLUMN_NAME_NEW = (COLUMN_NAME_NEW === undefined ? false : COLUMN_NAME_NEW.toUpperCase());
    COLUMN_DATA_TYPE_NEW = (COLUMN_DATA_TYPE_NEW === undefined ? false : COLUMN_DATA_TYPE_NEW.toUpperCase());
    NULLABILITY_NEW = (NULLABILITY_NEW === undefined ? false : NULLABILITY_NEW.toUpperCase());
    COMMENT_NEW = (COMMENT_NEW === undefined ? false : COMMENT_NEW.toUpperCase());
    
    let SUPPORTED_OPERATION = ["ADD", "DROP", "RENAME", "ALTER"];
    let message = "";
    let command = "";
    let statement = "";
    let recordSet = "";
    let nullability = "";
    let linebreak = "\r\n";
    
    // Let us return this message if the operation is not supported or the command is invalid.
    if (!SUPPORTED_OPERATION.includes(OPERATION_TYPE)) {
        return "Invalid command. '" + OPERATION_TYPE.toUpperCase() 
            + "' is not supported. Only the following operations are currently supported: " 
            + SUPPORTED_OPERATION.join(', ') + ";";
    } else if (OPERATION_TYPE == "ADD"
        && (!TABLE_SCHEMA || !TABLE_NAME || COLUMN_NAME_OLD || !COLUMN_NAME_NEW
        || !COLUMN_DATA_TYPE_NEW || !NULLABILITY_NEW)) {
        return "Invalid command. Please call ADM.ALTER_COLUMN('add', '<SchemaName>', '<TableName>'"
            + ", '<ColumnName>', '<DataType>', '<Nullability>', '<Comment>');";
    } else if (OPERATION_TYPE == "DROP"
        && (!TABLE_SCHEMA || !TABLE_NAME || !COLUMN_NAME_OLD || COLUMN_NAME_NEW
        || COLUMN_DATA_TYPE_NEW || NULLABILITY_NEW || COMMENT_NEW)) {
        return "Invalid command. Please call ADM.ALTER_COLUMN('drop', '<SchemaName>', '<TableName>'"
            + ", '<ColumnName>');";
    } else if (OPERATION_TYPE == "RENAME"
        && (!TABLE_SCHEMA || !TABLE_NAME || !COLUMN_NAME_OLD || !COLUMN_NAME_NEW 
        || COLUMN_DATA_TYPE_NEW || NULLABILITY_NEW || COMMENT_NEW)) {
        return "Invalid command. Please call ADM.ALTER_COLUMN('rename', '<SchemaName>', '<TableName>'"
            + ", '<OldColumnName>', '<NewColumnName>');";
    } else if (OPERATION_TYPE == "ALTER"
        && (!TABLE_SCHEMA || !TABLE_NAME || !COLUMN_NAME_OLD || COLUMN_NAME_NEW 
        || (!COLUMN_DATA_TYPE_NEW && COLUMN_DATA_TYPE_NEW !== "") 
        || (!NULLABILITY_NEW  && NULLABILITY_NEW !== "")
        || (!COMMENT_NEW  && COMMENT_NEW !== ""))) {
        return "Invalid command. Please call ADM.ALTER_COLUMN('alter', '<SchemaName>', '<TableName>'"
            + ", '<ColumnName>', '<NewDataType>', '<NewNullability>', '<NewComment>');";
    }
    
    //Check table exists
    command = "SELECT TABLE_NAME " + linebreak
        + "FROM INFORMATION_SCHEMA.TABLES" + linebreak
        + "WHERE UPPER(TABLE_SCHEMA) = '" + TABLE_SCHEMA + "'" + linebreak
        + "    AND UPPER(TABLE_NAME) = '" + TABLE_NAME + "'" + linebreak
        + "    AND TABLE_TYPE = 'BASE TABLE';";
    
    statement = snowflake.createStatement({sqlText: command});
    recordSet = statement.execute();
    if (!recordSet.next()) {
        return "Not executed. Table " + TABLE_SCHEMA + "." + TABLE_NAME
            + " was not found. Nothing to do.";
    }
    
    //Confirm old column exists.
    if (OPERATION_TYPE != "ADD") {
        command = "SELECT IS_NULLABLE " + linebreak
            + "FROM INFORMATION_SCHEMA.COLUMNS" + linebreak
            + "WHERE UPPER(TABLE_SCHEMA) = '" + TABLE_SCHEMA + "'" + linebreak
            + "    AND UPPER(TABLE_NAME) = '" + TABLE_NAME + "'" + linebreak
            + "    AND UPPER(COLUMN_NAME) = '" + COLUMN_NAME_OLD + "';";

        statement = snowflake.createStatement({sqlText: command});
        recordSet = statement.execute();
        if (!recordSet.next()) {
            return "Not executed. Column " + COLUMN_NAME_OLD + " was not found. Nothing to do.";
        }
        nullability = (recordSet.getColumnValue(1).toUpperCase() == "YES" ? "NULL" : "NOT NULL");
    }
    
    //Confirm new column does not exist.
    if (["ADD", "RENAME"].includes(OPERATION_TYPE)) {
        command = "SELECT COLUMN_NAME " + linebreak
            + "FROM INFORMATION_SCHEMA.COLUMNS" + linebreak
            + "WHERE UPPER(TABLE_SCHEMA) = '" + TABLE_SCHEMA + "'" + linebreak
            + "    AND UPPER(TABLE_NAME) = '" + TABLE_NAME + "'" + linebreak
            + "    AND UPPER(COLUMN_NAME) = '" + COLUMN_NAME_NEW + "';";

        statement = snowflake.createStatement({sqlText: command});
        recordSet = statement.execute();
        if (recordSet.next()) {
            return "Not executed. Column " + COLUMN_NAME_NEW + " already exists. Nothing to do.";
        }
    }
    
    command = [];
    message = [];
    if (OPERATION_TYPE == "ADD") {
        command.push("ALTER TABLE " + TABLE_SCHEMA + "." + TABLE_NAME
            + " ADD COLUMN " + COLUMN_NAME_NEW + " " + COLUMN_DATA_TYPE_NEW 
            + " " + NULLABILITY_NEW 
            + (!COMMENT_NEW ? "" : " COMMENT '" + COMMENT_NEW + "'") + ";");
    } else if (OPERATION_TYPE == "DROP") {
        command.push("ALTER TABLE " + TABLE_SCHEMA + "." + TABLE_NAME 
            + " DROP COLUMN " + COLUMN_NAME_OLD + ";");
    } else if (OPERATION_TYPE == "RENAME") {
        command.push("ALTER TABLE " + TABLE_SCHEMA + "." + TABLE_NAME 
            + " RENAME COLUMN " + COLUMN_NAME_OLD
            + " TO " + COLUMN_NAME_NEW + ";");
    } else if (OPERATION_TYPE == "ALTER") {
        if (![null, nullability, ""].includes(NULLABILITY_NEW)) {
            command.push("ALTER TABLE " + TABLE_SCHEMA + "." + TABLE_NAME 
                + " ALTER COLUMN " + COLUMN_NAME_OLD 
                + (NULLABILITY_NEW == "NULL" ? " DROP " : " ") + "NOT NULL;");
        }
        if (![null, ""].includes(COLUMN_DATA_TYPE_NEW)) {
            command.push("ALTER TABLE " + TABLE_SCHEMA + "." + TABLE_NAME 
                + " ALTER COLUMN " + COLUMN_NAME_OLD 
                + " SET DATA TYPE " + COLUMN_DATA_TYPE_NEW + ";");
        }
        if (![null, ""].includes(COMMENT_NEW)) {
            command.push("ALTER TABLE " + TABLE_SCHEMA + "." + TABLE_NAME 
                + " ALTER COLUMN " + COLUMN_NAME_OLD 
                + " COMMENT '" + COMMENT_NEW + "';");
        }
    }
    if (command.length == 0) {
        message.push("Not executed. Nothing to do.");
    }
    
    for (let i = 0; i < command.length; i++) {
        try{
            statement = snowflake.createStatement({sqlText: command[i]});
            recordSet = statement.execute();
            if (recordSet.next())  {
                message.push(OPERATION_TYPE + " is done successfully. " + recordSet.getColumnValue(1));
                message.push("COMMAND: " + command[i] + "\r\n");
            }
        }catch(err){
            message.push("For table " + TABLE_SCHEMA + "." + TABLE_NAME + ". Errors identified. " + err.message);
            break;
        }
    }
    message = message.join(" \r\n");
    
    return message;
$$;

/*
Snowflake throws an error message when you issue a DROP TABLE IF EXISTS command and a view exists 
with the same name as the table you wanted to drop. Let's write our own custom stored procedure to handle this
gracefully.

Snowflake throws an error message when you issue a ALTER TABLE IF EXISTS aaa RENAME TO bbb command and aaa has 
already been renamed to bbb. Let's write our own custom stored procedure to handle this
gracefully.

Taking advantage of UDF Overloading in Snowflake. 
*/

--Helper Procedure
CREATE OR REPLACE PROCEDURE ADM.DDL_TABLE(OPERATION_TYPE STRING)
RETURNS STRING NOT NULL
LANGUAGE JAVASCRIPT
AS
$$
    let message = "";
    let command = "";
    let statement = "";
    let recordSet = "";
    
    command = "CALL ADM.DDL_TABLE('" + OPERATION_TYPE + "', NULL, NULL, NULL);";
    try{
        statement = snowflake.createStatement({sqlText: command});
        recordSet = statement.execute();
        if (recordSet.next())  {
            message = recordSet.getColumnValue(1);
        }
    } catch(err){
        message = err.message;
    }
    
    return message;
$$;

--DROP Tables.
CREATE OR REPLACE PROCEDURE ADM.DDL_TABLE(OPERATION_TYPE STRING, TABLE_SCHEMA STRING, TABLE_NAME STRING)
RETURNS STRING NOT NULL
LANGUAGE JAVASCRIPT
AS
$$
    let message = "";
    let command = "";
    let statement = "";
    let recordSet = "";
    
    command = "CALL ADM.DDL_TABLE('" + OPERATION_TYPE + "', '" + TABLE_SCHEMA + "', '" + TABLE_NAME + "', NULL);";
    try{
        statement = snowflake.createStatement({sqlText: command});
        recordSet = statement.execute();
        if (recordSet.next())  {
            message = recordSet.getColumnValue(1);
        }
    } catch(err){
        message = err.message;
    }
    
    return message;
$$;

--RENAME Tables.
CREATE OR REPLACE PROCEDURE ADM.DDL_TABLE(OPERATION_TYPE STRING, TABLE_SCHEMA STRING, TABLE_NAME_OLD STRING, TABLE_NAME_NEW STRING)
RETURNS STRING NOT NULL
LANGUAGE JAVASCRIPT
AS
$$
    OPERATION_TYPE = OPERATION_TYPE.toUpperCase();
    let SUPPORTED_OPERATION = ["DROP","RENAME"];
    let PARAMETERS = [TABLE_SCHEMA, TABLE_NAME_OLD, TABLE_NAME_NEW];
    
    // Let us return this message if the operation is  not supported or the command is invalid.
    if (!SUPPORTED_OPERATION.includes(OPERATION_TYPE)) {
        return "Invalid command. '" + OPERATION_TYPE.toUpperCase() 
            + "' is not supported. Only the following operations are currently supported: " 
            + SUPPORTED_OPERATION.join(', ') + ";";
    } else if (OPERATION_TYPE == "DROP"
        && (TABLE_NAME_NEW !== undefined || TABLE_SCHEMA === undefined || TABLE_NAME_OLD === undefined)) {
        return "Invalid command. Please call ADM.DDL_TABLE('drop', '<SchemaName>', '<TableName>');";
    } else if (OPERATION_TYPE == "RENAME"
        && (TABLE_NAME_NEW === undefined || TABLE_SCHEMA === undefined || TABLE_NAME_OLD === undefined)) {
        return "Invalid command. Please call ADM.DDL_TABLE('rename', '<SchemaName>', '<OldTableName>', '<NewTableName>');";
    }
    
    let message = "Not executed. Table was not found. Nothing to do.";
    let command = "";
    let statement = "";
    let recordSet = "";
    let linebreak = "\r\n";
    
    //Confirm old tables exist.
    command = "SELECT TABLE_NAME " + linebreak
        + "FROM INFORMATION_SCHEMA.TABLES" + linebreak
        + "WHERE UPPER(TABLE_SCHEMA) = UPPER('" + TABLE_SCHEMA + "')" + linebreak
        + "    AND UPPER(TABLE_NAME) = UPPER('" + TABLE_NAME_OLD + "')" + linebreak
        + "    AND TABLE_TYPE = 'BASE TABLE';";
    
    statement = snowflake.createStatement({sqlText: command});
    recordSet = statement.execute();
    if (!recordSet.next()) {
        return message;
    }
    
    //Confirm new tables do exist.
    command = "SELECT TABLE_NAME " + linebreak
        + "FROM INFORMATION_SCHEMA.TABLES" + linebreak
        + "WHERE UPPER(TABLE_SCHEMA) = UPPER('" + TABLE_SCHEMA + "')" + linebreak
        + "    AND UPPER(TABLE_NAME) = UPPER('" + TABLE_NAME_NEW + "')" + linebreak
        + "    AND TABLE_TYPE = 'BASE TABLE';";
    
    statement = snowflake.createStatement({sqlText: command});
    recordSet = statement.execute();
    if (recordSet.next()) {
        return "Not executed. New table name already exists. Nothing to do.";
    }
    
    if (OPERATION_TYPE == "DROP") {
        command = "DROP TABLE " + TABLE_SCHEMA + "." + TABLE_NAME_OLD + ";";
    } else if (OPERATION_TYPE == "RENAME") {
        command = "ALTER TABLE " + TABLE_SCHEMA + "." + TABLE_NAME_OLD 
            + " RENAME TO " + TABLE_SCHEMA + "." + TABLE_NAME_NEW + ";";
    }
    
    try{
        statement = snowflake.createStatement({sqlText: command});
        recordSet = statement.execute();
        if (recordSet.next())  {
            message = OPERATION_TYPE + " is done successfully. " + recordSet.getColumnValue(1);
        }
    }catch(err){
        message = "Errors identified. " + err.message;
    }
    
    return message;
$$
;/*
Snowflake throws an error message when you issue a DROP OBJECT IF EXISTS command and a view exists 
with the same name as the table you wanted to drop. Let's write our own custom stored procedure to handle this
gracefully.


Taking advantage of UDF Overloading in Snowflake. 
*/

--Helper Procedure
CREATE OR REPLACE PROCEDURE ADM.DROP_OBJECT(OPERATION_TYPE STRING)
RETURNS STRING NOT NULL
LANGUAGE JAVASCRIPT
AS
$$
    let message = "";
    let command = "";
    let statement = "";
    let recordSet = "";
    
    command = "CALL ADM.DROP_OBJECT('" + OPERATION_TYPE + "', '', NULL, NULL);";
    try{
        statement = snowflake.createStatement({sqlText: command});
        recordSet = statement.execute();
        if (recordSet.next())  {
            message = recordSet.getColumnValue(1);
        }
    } catch(err){
        message = err.message;
    }
    
    return message;
$$;

--DROP OBJECT.
CREATE OR REPLACE PROCEDURE ADM.DROP_OBJECT(OPERATION_TYPE STRING,  OBJECT_TYPE STRING ,OBJECT_SCHEMA STRING, NAME_OF_OBJECT STRING)
RETURNS STRING NOT NULL
LANGUAGE JAVASCRIPT
AS
$$
    OPERATION_TYPE = OPERATION_TYPE.toUpperCase();
	OBJECT_TYPE=OBJECT_TYPE.toUpperCase();
    let SUPPORTED_OPERATION = ["DROP"];
    let PARAMETERS = [OBJECT_SCHEMA, NAME_OF_OBJECT, OBJECT_TYPE];
    
    // Let us return this message if the operation is  not supported or the command is invalid.
    if (!SUPPORTED_OPERATION.includes(OPERATION_TYPE)) {
        return "Invalid command. '" + OPERATION_TYPE.toUpperCase() 
            + "' is not supported. Only the following operations are currently supported: " 
            + SUPPORTED_OPERATION.join(', ') + ";";
    } else if (OPERATION_TYPE == "DROP"
        && (OBJECT_SCHEMA === undefined || NAME_OF_OBJECT === undefined || OBJECT_TYPE === undefined)) {
        return "Invalid command. Please call ADM.DROP_OBJECT('drop','<objecttype>','<SchemaName>', '<ObjectName>');";
    } 
    
    let message = "Not executed. object was not found. Nothing to do.";
    let command = "";
    let statement = "";
    let recordSet = "";
    let linebreak = "\r\n";
    
    //Confirm object exist.
	if (OBJECT_TYPE == "VIEW") {
    command = "SELECT TABLE_NAME " + linebreak
        + "FROM INFORMATION_SCHEMA.VIEWS" + linebreak
        + "WHERE UPPER(TABLE_SCHEMA) = UPPER('" + OBJECT_SCHEMA + "')" + linebreak
        + "    AND UPPER(TABLE_NAME) = UPPER('" + NAME_OF_OBJECT + "')";
	} else if (OBJECT_TYPE == "FUNCTION") {

	let FUNC_NAME =  NAME_OF_OBJECT.substring(0,NAME_OF_OBJECT.indexOf("("))

    command = "SELECT FUNCTION_NAME " + linebreak
        + "FROM INFORMATION_SCHEMA.FUNCTIONS" + linebreak
        + "WHERE UPPER(FUNCTION_SCHEMA) = UPPER('" + OBJECT_SCHEMA + "')" + linebreak
        + "    AND UPPER(FUNCTION_NAME) = UPPER('" + FUNC_NAME + "')";
	} else if (OBJECT_TYPE == "TABLE") {
    command = "SELECT TABLE_NAME " + linebreak
        + "FROM INFORMATION_SCHEMA.TABLES" + linebreak
        + "WHERE UPPER(TABLE_SCHEMA) = UPPER('" + OBJECT_SCHEMA + "')" + linebreak
        + "    AND UPPER(TABLE_NAME) = UPPER('" + NAME_OF_OBJECT + "')";
	} else 
		return message;
	
    statement = snowflake.createStatement({sqlText: command});
    recordSet = statement.execute();
    if (!recordSet.next()) {
        return message;
    }

    
    command = "DROP "+OBJECT_TYPE+" " + OBJECT_SCHEMA + "." + NAME_OF_OBJECT+";";

    try{
        statement = snowflake.createStatement({sqlText: command});
        recordSet = statement.execute();
        if (recordSet.next())  {
            message = OPERATION_TYPE + " is done successfully. " + recordSet.getColumnValue(1);
        }
    }catch(err){
        message = "Errors identified. " + err.message;
    }
    
    return message;
$$
;
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