/*
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
