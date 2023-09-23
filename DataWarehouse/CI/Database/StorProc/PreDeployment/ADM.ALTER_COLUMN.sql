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
                message.push(OPERATION_TYPE + " is done successfully. " + recordSet.getColumnValue(1) + " COMMAND: " + command[i]);
            }
        }catch(err){
            message.push("For table " + TABLE_SCHEMA + "." + TABLE_NAME + ". Errors identified. " + err.message);
            break;
        }
    }
    message = message.join(" \r\n");
    
    return message;
$$;

