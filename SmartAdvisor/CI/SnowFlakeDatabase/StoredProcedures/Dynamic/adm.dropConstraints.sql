CREATE OR REPLACE PROCEDURE ADM.DropConstraints("constraintType" VARCHAR)
RETURNS STRING
LANGUAGE JAVASCRIPT
AS
$$
    let cmd, stmt, rs;
    let linebreak = "\r\n";
    try{
        cmd = "SELECT 'ALTER TABLE '||TABLE_SCHEMA||'.'||TABLE_NAME||' DROP CONSTRAINT \"'||CONSTRAINT_NAME||'\";'" + linebreak
            + "FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS" + linebreak
            + "WHERE CONSTRAINT_TYPE = '" + constraintType.toUpperCase() + "';";
        stmt = snowflake.createStatement({sqlText:cmd});
        rs = stmt.execute();

        while(rs.next()){
            cmd = rs.getColumnValue(1);
            stmt = snowflake.createStatement({sqlText:cmd});
            try{
				stmt.execute();
			}catch(err){
				cmd = "";
			}
        }
        return "All foreign keys have successfully dropped.";
    }catch(err){
        return "Failed to drop foreign keys. " + err.message;
    }
$$;

