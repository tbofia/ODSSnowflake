CREATE OR REPLACE PROCEDURE ADM.ETL_GET_REPLICATION_INFO(
"snapShotDate"  string,
"isDebug" BOOLEAN
  
)
//returns varchar not null
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
        message: ""
    };
   
    let dmlCommand;
    let statement;
    let recordSet;
	let linebreak = "\r\n";
    
	// Get PostingGroupAuditId for Given Snapshot if already created and also get current and previous replicationids
    dmlCommand =  "SELECT object_construct('postingGroupAuditId',IFNULL((SELECT POSTING_GROUP_AUDIT_ID"
                      +" FROM ADM.POSTING_GROUP_INJEST_AUDIT"
                      +" WHERE SNAPSHOT_DATE = '" + snapShotDate + "'),-1)," + linebreak
                      +" 'currentReplicationId',IFNULL((SELECT MAX(CURRENT_REPLICATION_ID) AS CURRENTREPLICATIONID"
                      +" FROM ADM.POSTING_GROUP_INJEST_AUDIT "
					  +" WHERE SNAPSHOT_DATE < '" + snapShotDate + "'),-1)," + linebreak
                      +" 'previousReplicationId',(SELECT DISTINCT PREVIOUS_REPLICATION_ID"
                      +" FROM STG.ETL_CONTROLFILES"
                      +" WHERE SNAPSHOT_DATE = '" + snapShotDate + "'));";
      
    //Debug mode, output the message
   if(isDebug){
            output.returnStatus = 0;
            output.rowsAffected = -1;
            output.status = 'debug';
            output.message = dmlCommand;
    }else {
        //execution
        try{
            statement = snowflake.createStatement({
            sqlText: dmlCommand
                            });
            recordSet = statement.execute();
            recordSet.next();
            
            output.returnStatus = 1;
            output.data = recordSet.getColumnValue(1);
            output.audit= 'logged';
            output.status = 'succeeded';
            output.message = '';
        }catch(err){        
                      
            output.returnStatus = -1;
            output.rowsAffected = -1;
			output.audit= 'logged';
            output.status = 'failed';
            output.message = err.message;   
         }
     }

  return output;
 
 $$;

