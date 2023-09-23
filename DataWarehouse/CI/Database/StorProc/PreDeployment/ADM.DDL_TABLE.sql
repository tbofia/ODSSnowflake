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
;