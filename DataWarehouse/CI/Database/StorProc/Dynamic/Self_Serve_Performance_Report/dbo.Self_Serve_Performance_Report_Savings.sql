CREATE OR REPLACE PROCEDURE dbo.Self_Serve_Performance_Report_Savings(
    "sourceDatabaseName" STRING,
    "targetDatabaseName" STRING,
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
        status: "not executed",
        message: []
    };
    
    let command;
	let arrayCommand = [];
	let arrayComment = [];
    let statement;
    let recordSet;
    
    let today = new Date();
	let runDate  = today.getFullYear()+'-'+(today.getMonth()+1)+'-'+today.getDate();
	let startDate = today.getFullYear()-2+'-'+(today.getMonth()+1)+'-'+today.getDate();
    let endDate = today.getFullYear()+'-'+(today.getMonth()+1)+'-'+today.getDate();
    
    let linebreak = "\r\n";
    let tab = "\t";
    
    //Set Statement load line data into staging
    command = "CALL dbo.Self_Serve_Performance_Report_Savings_Data(" + linebreak
		+ "'" + sourceDatabaseName + "'," + linebreak
		+ "'" + targetDatabaseName + "'," + linebreak
		+ "'" + runDate + "'," + linebreak
		+ "'" + startDate + "'," + linebreak
		+ "'" + endDate + "'," + linebreak
		+ "False);";
	arrayComment.push("--load line data into staging");
	arrayCommand.push(command);
    
    //Set Statement load adjustment data
    command = "CALL dbo.Self_Serve_Performance_Report_Savings_Adjustments(" + linebreak
		+ "'" + sourceDatabaseName + "'," + linebreak
		+ "'" + targetDatabaseName + "'," + linebreak
		+ "'" + runDate + "'," + linebreak
		+ "False);";
    arrayComment.push("--load adjustment data");
	arrayCommand.push(command);

	//Set Statement load line data into final table
    command = "CALL dbo.Self_Serve_Performance_Report_Savings_claim_detail_billline(" + linebreak
		+ "'" + targetDatabaseName + "'," + linebreak
		+ "'" + runDate + "'," + linebreak
        + "False);";
    arrayComment.push("--load line data into final table");
	arrayCommand.push(command);

	//Set Statement load adjustment data into final table
    command = "CALL dbo.Self_Serve_Performance_Report_Savings_claim_detail_billline_adjsubcatname(" + linebreak
		+ "'" + targetDatabaseName + "'," + linebreak
		+ "'" + runDate + "'," + linebreak
        + "False);";
    arrayComment.push("--load adjustment data into final table");
	arrayCommand.push(command);

	//Set Statement load bill data into final table
    command = "CALL dbo.Self_Serve_Performance_Report_Savings_claim_detail_bill(" + linebreak
		+ "'" + targetDatabaseName + "'," + linebreak
		+ "'" + runDate + "'," + linebreak
        + "False);";
    arrayComment.push("--load bill data into final table");
	arrayCommand.push(command);

	let i;
	for (i = 0; i < arrayCommand.length; i++) {
		if(isDebug){
			output.returnStatus = 0;
			output.rowsAffected = -1;
			output.status = "debug";
			output.message.push(arrayComment[i]);
			output.message.push(arrayCommand[i]);
		}else{
			try{
				statement = snowflake.createStatement({sqlText: arrayCommand[i]});
				recordSet = statement.execute();
				recordSet.next();
				if(recordSet.getColumnValue(1).returnStatus == -1){
					output.returnStatus = -1;
					output.rowsAffected = -1;
					output.status = "failed";
					output.message.push(recordSet.getColumnValue(1).message);   
					output.message.push("Error Command: " + arrayCommand[i]);
					return output;
				}
				if (i < arrayCommand.length - 1) continue;
				output.audit = 'Load';
                output.status = 'succeeded';
                output.message = 'Data Insert SucessFully.';
			}catch(err){
				output.returnStatus = -1;
				output.rowsAffected = -1;
				output.status = "failed";
				output.message.push(err.message);   
				output.message.push("Error Command: " + arrayCommand[i]);
				return output;
			}
		}
	}
		
	return output;
    
$$
;    
    