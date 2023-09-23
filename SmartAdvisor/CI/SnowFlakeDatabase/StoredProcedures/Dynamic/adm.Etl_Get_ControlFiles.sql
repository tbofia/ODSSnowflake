/*

call ADM.ETL_GET_CONTROLFILES (
            '@ACSODS_DEV.stg.etl_dev'
            ,'ADM.COMMAFORMATFILES'
            ,true)

*/

CREATE OR REPLACE PROCEDURE ADM.ETL_GET_CONTROLFILES(
"externalStage"  string,
"formatFile"   string,
"isDebug" BOOLEAN
  
)
returns VARIANT
language javascript
execute as caller
as     
$$ 
    const output = {
        returnStatus: -1,
        data: "",
        rowsAffected: -1,
        audit: "not logged",
        status: "not executed",
        message: []
    };
   
    let command = "";
    let statement;
    let recordSet;
	let controlFileNames = "";

	let linebreak = "\r\n";

	externalStage = (externalStage.substring(externalStage.length-1,externalStage.length) == "/"?externalStage:externalStage + "/");
  
	//Truncate stg.Etl_ControlFiles table 
    command = " TRUNCATE TABLE STG.ETL_CONTROLFILES;";
    if(isDebug){
		output.returnStatus = 0;
        output.rowsAffected = -1;
        output.status = "debug";
        output.message.push("--Truncate stg.Etl_ControlFiles table");
		output.message.push(command);
	}else{
		try{
            statement = snowflake.createStatement({sqlText: command});
            statement.execute();
		}catch(err){
			output.returnStatus = -1;
            output.rowsAffected = -1;
			output.audit= 'logged';
            output.status = 'failed';
            output.message.push(err.message);
			return output;
		}
	}

	//Load All Control files from the external stage
    command = "ls " + externalStage + linebreak
		+ "pattern = '.*.ctl.gz';";        
	if(isDebug){
		output.message.push("--Load All Control files from the external stage");
		output.message.push(command);
	}else{
		try{
            statement = snowflake.createStatement({sqlText: command});
            statement.execute();
		}catch(err){
			output.returnStatus = -1;
            output.rowsAffected = -1;
			output.audit= "logged";
            output.status = "failed";
            output.message.push(err.message);
			output.message.push("Error Command: " + command);
			return output;
		}
	}	
	
	command = "SELECT LISTAGG(strtok(\"name\", '/', (Array_size(strtok_to_array(\"name\",'/'))) - 1)||"
		+ "'/'||strtok(\"name\", '/', (Array_size(strtok_to_array(\"name\",'/')))),''',''')" + linebreak
		+ "FROM TABLE(RESULT_SCAN(LAST_QUERY_ID()))" + linebreak
		+ "WHERE strtok(strtok(\"name\", '/', (Array_size(strtok_to_array(\"name\",'/')))),'_',2) " + linebreak
		+ "    > (SELECT TO_VARCHAR(IFNULL(MAX(SNAPSHOT_DATE),'1900-01-01'),'yyyymmddhhmiss')" + linebreak
		+ "        FROM ADM.POSTING_GROUP_INJEST_AUDIT" + linebreak
		+ "		   WHERE STATUS = 'FI');";
	if(isDebug){
		output.message.push(command);
	}else{
		try{
            statement = snowflake.createStatement({sqlText: command});
            recordSet = statement.execute();
			if(recordSet.next()){
				controlFileNames = recordSet.getColumnValue(1);
			}
		}catch(err){
			output.returnStatus = -1;
            output.rowsAffected = -1;
			output.audit= "logged";
            output.status = "failed";
            output.message.push(err.message);
			output.message.push("Error Command: " + command);
			return output;
		}
	}	

	command = " COPY INTO STG.ETL_CONTROLFILES" + linebreak
		+ " FROM "+  externalStage + linebreak
		+ " FILES = ('" + controlFileNames + "')" + linebreak
		+ " FILE_FORMAT = ( FORMAT_NAME = "+ formatFile + ")" + linebreak
		+ " ON_ERROR = CONTINUE;";   
	if(isDebug){
		output.message.push(command);
	}else{
		try{
            statement = snowflake.createStatement({sqlText: command});
            statement.execute();
		}catch(err){
			output.returnStatus = -1;
            output.rowsAffected = -1;
			output.audit= "logged";
            output.status = "failed";
            output.message.push(err.message);
			output.message.push("Error Command: " + command);
			return output;
		}
	}
               
	//Get Control file names to be loaded
    command = "SELECT array_agg(DISTINCT S.SNAPSHOT_DATE)WITHIN GROUP(ORDER BY S.SNAPSHOT_DATE) " + linebreak
		+ " FROM STG.ETL_CONTROLFILES S " + linebreak
		+ " LEFT OUTER JOIN ADM.POSTING_GROUP_INJEST_AUDIT P " + linebreak
		+ " ON S.SNAPSHOT_DATE = P.SNAPSHOT_DATE" + linebreak
		+ " WHERE P.STATUS <> 'FI' OR P.POSTING_GROUP_AUDIT_ID IS NULL;";
	if(isDebug){
		output.message.push("--Get Control file names to be loaded");
		output.message.push(command);
	}else{
		try{
            statement = snowflake.createStatement({sqlText: command});
            recordSet = statement.execute();
            recordSet.next();
            
            output.returnStatus = 1;
            output.data = recordSet.getColumnValue(1);
            output.audit= "logged";
            output.status = "succeeded";
            output.message = "";
		}catch(err){
			output.returnStatus = -1;
            output.rowsAffected = -1;
			output.audit= "logged";
            output.status = "failed";
            output.message.push(err.message);
			output.message.push("Error Command: " + command);
		}
	}

	return output;
 
 $$;

