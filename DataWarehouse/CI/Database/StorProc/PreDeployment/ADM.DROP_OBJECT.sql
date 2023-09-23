/*
Snowflake throws an error message when you issue a DROP OBJECT IF EXISTS command and a view exists 
with the same name as the table you wanted to drop. Let's write our own custom stored procedure to handle this
gracefully.

call ADM.DROP_OBJECT('TABLE');

*/

--Helper Procedure
CREATE OR REPLACE PROCEDURE ADM.DROP_OBJECT(OBJECT_TYPE STRING)
RETURNS STRING NOT NULL
LANGUAGE JAVASCRIPT
AS
$$
    let message = "";
    let command = "";
    let statement = "";
    let recordSet = "";
    
    command = "CALL ADM.DROP_OBJECT('drop', '" + OBJECT_TYPE + "', NULL, NULL, NULL);";
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

--DROP TABLE, VIEW, FUNCTION
CREATE OR REPLACE PROCEDURE ADM.DROP_OBJECT(
    OPERATION_TYPE STRING, 
    OBJECT_TYPE STRING, 
    OBJECT_SCHEMA STRING, 
    OBJECT_NAME STRING
)
RETURNS STRING NOT NULL
LANGUAGE JAVASCRIPT
AS
$$
    let message = "";
    let command = "";
    let statement = "";
    let recordSet = "";
    
    command = "CALL ADM.DROP_OBJECT('" 
        + OPERATION_TYPE + "', '"
        + OBJECT_TYPE + "', NULL, '"
        + OBJECT_SCHEMA + "', '"
        + OBJECT_NAME + "');";
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

--DROP OBJECTS including CONSTRAINT
CREATE OR REPLACE PROCEDURE ADM.DROP_OBJECT(
    OPERATION_TYPE STRING, 
    OBJECT_TYPE STRING, 
    CONSTRAINT_TYPE STRING, 
    OBJECT_SCHEMA STRING, 
    OBJECT_NAME STRING
)
RETURNS STRING NOT NULL
LANGUAGE JAVASCRIPT
AS
$$
    OPERATION_TYPE = (OPERATION_TYPE === undefined ? false : OPERATION_TYPE.toUpperCase());
	OBJECT_TYPE = (OBJECT_TYPE === undefined ? false : OBJECT_TYPE.toUpperCase());
    CONSTRAINT_TYPE = (CONSTRAINT_TYPE === undefined ? false : CONSTRAINT_TYPE.toUpperCase());
    let SUPPORTED_OPERATION = ["DROP"];
    let SUPPORTED_OBJECT = ["TABLE", "VIEW", "FUNCTION", "CONSTRAINT"];
    let SUPPORTED_CONSTRAINT = ["PRIMARY KEY", "FOREIGN KEY"];
    let PARAMETERS = [OBJECT_SCHEMA, OBJECT_NAME, OBJECT_TYPE];
    
    // Let us return this message if the operation is  not supported or the command is invalid.
    if (!SUPPORTED_OPERATION.includes(OPERATION_TYPE)) {
        return "Invalid command. '" + OPERATION_TYPE.toUpperCase() 
            + "' is not supported. Only the following operations are currently supported: " 
            + SUPPORTED_OPERATION.join(', ') + ";";
    } else if (!SUPPORTED_OBJECT.includes(OBJECT_TYPE)) {
        return "Invalid command. Please specify a supported object type. Only the following object types are currently supported: " 
            + SUPPORTED_OBJECT.join(', ') + ";";
    } else if (OBJECT_TYPE != "CONSTRAINT" && (!OBJECT_SCHEMA || !OBJECT_NAME || !OBJECT_TYPE || CONSTRAINT_TYPE)) {
        return "Invalid command. Please call ADM.DROP_OBJECT('drop', '<ObjectType>', '<SchemaName>', '<ObjectName>');";
    } else if (OBJECT_TYPE == "CONSTRAINT") {
        if (!OBJECT_TYPE || !CONSTRAINT_TYPE || (!OBJECT_SCHEMA && OBJECT_NAME)) {
            return "Invalid command. Please call ADM.DROP_OBJECT('drop', 'constraint', '<ConstraintType>', '<SchemaName>', '<ObjectName>');";
        } else if (!SUPPORTED_CONSTRAINT.includes(CONSTRAINT_TYPE)) {
            return "Invalid command. '" + CONSTRAINT_TYPE.toUpperCase() 
                + "' is not supported. Only the following types of constraints are currently supported: " 
                + SUPPORTED_CONSTRAINT.join(', ') + ";";
        }
    } 
    
    let message = "Not executed. object was not found. Nothing to do.";
    let command = "";
    let statement = "";
    let recordSet = "";
    let linebreak = "\r\n";
    
    //Confirm object exist.
    if (OBJECT_TYPE == "VIEW") {
        command = "SELECT 'DROP ' || '" + OBJECT_TYPE + " ' || '" + OBJECT_SCHEMA + "' || '.' || '" + OBJECT_NAME + ";' " + linebreak
            + "FROM INFORMATION_SCHEMA.VIEWS" + linebreak
            + "WHERE UPPER(TABLE_SCHEMA) = UPPER('" + OBJECT_SCHEMA + "')" + linebreak
            + "    AND UPPER(TABLE_NAME) = UPPER('" + OBJECT_NAME + "')";
	} else if (OBJECT_TYPE == "FUNCTION") {
        let FUNC_NAME =  OBJECT_NAME.substring(0,OBJECT_NAME.indexOf("("))
        command = "SELECT 'DROP ' || '" + OBJECT_TYPE + " ' || '" + OBJECT_SCHEMA + "' || '.' || '" + OBJECT_NAME + ";' " + linebreak
            + "FROM INFORMATION_SCHEMA.FUNCTIONS" + linebreak
            + "WHERE UPPER(FUNCTION_SCHEMA) = UPPER('" + OBJECT_SCHEMA + "')" + linebreak
            + "    AND UPPER(FUNCTION_NAME) = UPPER('" + FUNC_NAME + "')";
	} else if (OBJECT_TYPE == "TABLE") {
        command = "SELECT 'DROP ' || '" + OBJECT_TYPE + " ' || '" + OBJECT_SCHEMA + "' || '.' || '" + OBJECT_NAME + ";' " + linebreak
            + "FROM INFORMATION_SCHEMA.TABLES" + linebreak
            + "WHERE UPPER(TABLE_SCHEMA) = UPPER('" + OBJECT_SCHEMA + "')" + linebreak
            + "    AND UPPER(TABLE_NAME) = UPPER('" + OBJECT_NAME + "')";
	} else if (OBJECT_TYPE == "CONSTRAINT") {
        command = "SELECT 'ALTER TABLE '||TABLE_SCHEMA||'.'||TABLE_NAME||' DROP CONSTRAINT \"'||CONSTRAINT_NAME||'\";' " + linebreak
            + "FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS" + linebreak
            + "WHERE CONSTRAINT_TYPE = '" + CONSTRAINT_TYPE + "'"
            + (!OBJECT_SCHEMA ? "" : linebreak + "    AND UPPER(TABLE_SCHEMA) = UPPER('" + OBJECT_SCHEMA + "')")
            + (!OBJECT_NAME ? "" : linebreak + "    AND UPPER(TABLE_NAME) = UPPER('" + OBJECT_NAME + "')")
            + ";";
	} else {
        return message;
    }
		
    statement = snowflake.createStatement({sqlText: command});
    recordSet = statement.execute();
    
    if (!recordSet.next()) {
        return message;
    } else {
        message = [];
        command = recordSet.getColumnValue(1);
        statement = snowflake.createStatement({sqlText:command});
        try{
            statement.execute();
            message.push(OPERATION_TYPE + " is done successfully. " + recordSet.getColumnValue(1));
        }catch(err){
            message.push("Errors identified. " + err.message);
        }
    }

    while(recordSet.next()){
        command = recordSet.getColumnValue(1);
        statement = snowflake.createStatement({sqlText:command});
        try{
            statement.execute();
            message.push(OPERATION_TYPE + " is done successfully. " + recordSet.getColumnValue(1));
        }catch(err){
            message.push("Errors identified. " + err.message);
        }
    }

    return message.join(" \r\n");
$$;

