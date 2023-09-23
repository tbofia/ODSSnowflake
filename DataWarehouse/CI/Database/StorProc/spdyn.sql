CREATE OR REPLACE PROCEDURE dbo.Self_Serve_Performance_Report_Operational_Data(
    "sourceDatabaseName" STRING,
    "targetDatabaseName" STRING,
    "runDate" STRING,
	"startDate" STRING,
    "endDate" STRING,
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
    let statement;
    let recordSet;
    let OdsPostingGroupAuditId = 0
    
    let linebreak = "\r\n";
    let tab = "\t";
    
    //Get PostingGroupAudit ID
    command = "SELECT "+sourceDatabaseName+".adm.Mnt_GetPostingGroupAuditIdAsOfSnapshotDate(0,'"+runDate+"')";
    
   	if(isDebug){
		output.returnStatus = 0;
        output.rowsAffected = -1;
        output.status = "debug";
        output.message.push("--get posting group audit id");
        output.message.push(command);
	}else{
		try{
			statement = snowflake.createStatement({sqlText: command});
            recordSet = statement.execute();
            if(recordSet.next()){
				OdsPostingGroupAuditId = recordSet.getColumnValue(1);
			}
		}catch(err){
			output.returnStatus = -1;
            output.rowsAffected = -1;
            output.status = "failed";
            output.message.push(err.message);   
			output.message.push("Error Command: " + command);
            return output;
		}
	}

	// Truncate claims detail table
    command = "TRUNCATE TABLE "+targetDatabaseName+".STG.CLAIM_DETAIL_OPERATIONAL";
    
   	if(isDebug){
		output.returnStatus = 0;
        output.rowsAffected = -1;
        output.status = "debug";
        output.message.push("--Truncate claims detail table");
        output.message.push(command);
	}else{
		try{
			statement = snowflake.createStatement({sqlText: command});
            recordSet = statement.execute();
            recordSet.next();
			
		}catch(err){
			output.returnStatus = -1;
            output.rowsAffected = -1;
            output.status = "failed";
            output.message.push(err.message);   
			output.message.push("Error Command: " + command);
            return output;
		}
      }  
    
    
    //Set Statement
    command =    "INSERT INTO  "+targetDatabaseName+".STG.CLAIM_DETAIL_OPERATIONAL(" + linebreak 
				+"     	 OdsCustomerId                 " + linebreak
				+"		,CompanyName" + linebreak
				+"		,OfficeName" + linebreak
				+"		,SOJ     " + linebreak
				+"		,BillIDNo" + linebreak
				+"		,CreateDate" + linebreak
				+"		,DateCommitted " + linebreak
				+"		,DateRcv" + linebreak
				+"		,MitchellReceivedDate            					" + linebreak
				+"		,LINE_NO                      " + linebreak
				+"		,LineType                      " + linebreak
				+"		,NDC                      " + linebreak
				+"		,DateSaved" + linebreak
				+"		,UserId" + linebreak
				+"		,lAdjIdNo					" + linebreak
				+"		,OfficeIdNo						" + linebreak
				+"		,BillType" + linebreak
				+"		,FirstNurseCompleteDate" + linebreak
				+"		,SecondNurseCompleteDate" + linebreak
				+"		,ThirdNurseCompleteDate" + linebreak
				+"      ,MitchellCmptDate" + linebreak
				+"      ,DateLoss" + linebreak
				+"      ,PPOReturnedDate" + linebreak
				+"      ,PPOReceivedDate)" + linebreak 
				+"SELECT DISTINCT " + linebreak
				+"		 BH.OdsCustomerId                 " + linebreak
				+"		,IFNULL(CO.CompanyName, 'NA')" + linebreak
				+"		,IFNULL(O.OfcName , 'NA') " + linebreak
				+"		,CM.CmtStateOfJurisdiction     " + linebreak
				+"		,BH.BillIDNo" + linebreak
				+"		,BH.CreateDate" + linebreak
				+"		,BH.DateCommitted " + linebreak
				+"		,BH.DateRcv" + linebreak
				+"		,CASE WHEN MRD.MitchellReceivedDate = '1899-12-30 00:00:00.000' THEN NULL ELSE MRD.MitchellReceivedDate END AS MitchellReceivedDate " + linebreak
				+"		,B.LINE_NO                      " + linebreak
				+"		,B.LineType                      " + linebreak
				+"		,B.NDC                      " + linebreak
				+"		,BO.DateSaved" + linebreak
				+"		,BO.UserId" + linebreak
				+"		,AD.lAdjIdNo					" + linebreak
				+"		,AD.OfficeIdNo						" + linebreak
				+"		,BH.BillType" + linebreak
				+"		,MCD.FirstNurseCompleteDate" + linebreak
				+"		,MCD.SecondNurseCompleteDate" + linebreak
				+"		,MCD.ThirdNurseCompleteDate" + linebreak
				+"		,CD.MitchellCmptDate" + linebreak
				+"		,CL.DateLoss" + linebreak
				+"		,PPO.PPOReturnedDate" + linebreak
				+"		,PPO.PPOReceivedDate" + linebreak
				+"" + linebreak
				+"--Get BillIdNo " + linebreak
				+"FROM (SELECT DISTINCT" + linebreak
				+"           BH.OdsCustomerId" + linebreak
				+"          ,BH.BillIDNo" + linebreak
				+"          ,BH.CreateDate" + linebreak
				+"          ,BH.CMT_HDR_IDNo" + linebreak
				+"          ,bhs.DateCommitted " + linebreak
				+"          ,CASE WHEN BH.DateRcv = '1899-12-30 00:00:00.000' THEN NULL ELSE  BH.DateRcv END AS DateRcv" + linebreak
				+"          ,CASE WHEN BITAND(BH.Flags, 4096) = 4096 THEN 'UB-04'  ELSE 'CMS-1500'  END AS BillType" + linebreak
				+"" + linebreak
				+"      FROM TABLE(" + sourceDatabaseName + ".dbo.if_BILL_HDR(" + OdsPostingGroupAuditId.toString() + ")) BH" + linebreak
				+"      -- Get Bill Committed Date" + linebreak
				+"      LEFT OUTER JOIN (SELECT bhs.OdsCustomerId" + linebreak
				+"                          ,bhs.billIDNo" + linebreak
				+"                          ,max(bhs.DateCommitted) as DateCommitted " + linebreak
				+"" + linebreak
				+"                      FROM TABLE(" + sourceDatabaseName + ".dbo.if_Bill_History(" + OdsPostingGroupAuditId.toString() + ")) bhs" + linebreak
				+"" + linebreak
				+"                      GROUP BY bhs.OdsCustomerId" + linebreak
				+"                          ,bhs.billIDNo) bhs " + linebreak
				+"          ON BH.OdsCustomerId = bhs.OdsCustomerId " + linebreak
				+"          AND BH.BillIDNo = bhs.BillIDNo ) BH  " + linebreak
				+"INNER JOIN TABLE(" + sourceDatabaseName + ".dbo.if_CMT_HDR(" + OdsPostingGroupAuditId.toString() + ")) CH " + linebreak
				+"	ON BH.OdsCustomerId = CH.OdsCustomerId" + linebreak
				+"	AND BH.CMT_HDR_IDNo = CH.CMT_HDR_IDNo" + linebreak
				+"INNER JOIN TABLE(" + sourceDatabaseName + ".dbo.if_CLAIMANT(" + OdsPostingGroupAuditId.toString() + ")) CM " + linebreak
				+"	ON CH.OdsCustomerId = CM.OdsCustomerId" + linebreak
				+"	AND CH.CmtIDNo = CM.CmtIDNo " + linebreak
				+"INNER JOIN (SELECT" + linebreak
				+"				 OdsCustomerId " + linebreak
				+"				,BillIDNo" + linebreak
				+"				,LINE_NO_DISP" + linebreak
				+"				,LINE_NO" + linebreak
				+"				,PRC_CD AS NDC " + linebreak
				+"				,1 AS LineType" + linebreak
				+"			FROM TABLE(" + sourceDatabaseName + ".dbo.if_BILLS(" + OdsPostingGroupAuditId.toString() + "))" + linebreak
				+"			WHERE CHARGED IS NOT NULL" + linebreak
				+"			UNION " + linebreak
				+"			SELECT " + linebreak
				+"				 OdsCustomerId" + linebreak
				+"				,BillIDNo" + linebreak
				+"				,LINE_NO_DISP" + linebreak
				+"				,LINE_NO" + linebreak
				+"				,NDC" + linebreak
				+"				,2 AS LineType" + linebreak
				+"			FROM  TABLE(" + sourceDatabaseName + ".dbo.if_BILLS_Pharm(" + OdsPostingGroupAuditId.toString() + "))" + linebreak
				+"			WHERE CHARGED IS NOT NULL" + linebreak
				+"			) AS B" + linebreak
				+"	ON BH.OdsCustomerId = B.OdsCustomerId" + linebreak
				+"	AND BH.BillIDNo = B.BillIDNo" + linebreak
				+"INNER JOIN TABLE(" + sourceDatabaseName + ".dbo.if_CLAIMS(" + OdsPostingGroupAuditId.toString() + ")) CL " + linebreak
				+"    ON  CM.OdsCustomerId = CL.OdsCustomerId" + linebreak
				+"    AND CM.ClaimIDNo  = CL.ClaimIDNo" + linebreak
				+"    AND IFNULL(CL.ClaimNo, '-1') NOT LIKE '%TEST%'" + linebreak
				+"    AND (CL.OdsCustomerId NOT IN (70,71) OR CL.Status <> 'C')" + linebreak
				+"LEFT OUTER JOIN (SELECT  OdsCustomerId " + linebreak
				+"                       ,BillIdNo" + linebreak
				+"                       ,MAX(CASE WHEN EventId = 10 THEN logDate ELSE NULL END) PPOReturnedDate" + linebreak
				+"                       ,MIN(CASE WHEN EventId = 11 THEN logDate ELSE NULL END) PPOReceivedDate" + linebreak
				+"                FROM TABLE(" + sourceDatabaseName + ".dbo.if_ProviderNetworkEventLog(" + OdsPostingGroupAuditId.toString() + "))" + linebreak
				+"                WHERE EventId IN (11, 10 )" + linebreak
				+"                GROUP BY        OdsCustomerId " + linebreak
				+"                       ,BillIdNo) PPO" + linebreak
				+"    ON BH.OdsCustomerId = PPO.OdsCustomerId" + linebreak
				+"	AND BH.BillIDNo = PPO.BillIDNo" + linebreak
				+"-- MitchellClaimant complete date" + linebreak
				+"LEFT OUTER JOIN (SELECT DISTINCT OdsCustomerId, CmtIdNo " + linebreak
				+"                             ,CASE  WHEN UDFIdNo = '-3' THEN UDFValueDate END AS FirstNurseCompleteDate" + linebreak
				+"                             ,CASE  WHEN UDFIdNo = '-4' THEN UDFValueDate END AS SecondNurseCompleteDate" + linebreak
				+"                             ,CASE  WHEN UDFIdNo = '-5' THEN UDFValueDate END AS ThirdNurseCompleteDate" + linebreak
				+"" + linebreak
				+"                FROM TABLE(" + sourceDatabaseName + ".dbo.if_UDFClaimant(" + OdsPostingGroupAuditId.toString() + "))" + linebreak
				+"                WHERE UDFIdNo  IN ('-3','-4','-5') AND UDFValueDate <> '1899-12-30 00:00:00.000') MCD  " + linebreak
				+"	ON CM.OdsCustomerId = MCD.OdsCustomerId" + linebreak
				+"	AND CM.CmtIDNo = MCD.CmtIDNo" + linebreak
				+"LEFT OUTER JOIN (SELECT OdsCustomerId" + linebreak
				+"                    ,CmtIdNo" + linebreak
				+"                    ,CASE WHEN Max(UDFValueDate) = '1899-12-30 00:00:00.000' THEN NULL   ELSE Max(UDFValueDate) END AS MitchellCmptDate" + linebreak
				+"                FROM TABLE(" + sourceDatabaseName + ".dbo.if_UDFClaimant(" + OdsPostingGroupAuditId.toString() + "))" + linebreak
				+"                WHERE UDFIdNo IN ('-3', '-4', '5')" + linebreak
				+"                GROUP BY OdsCustomerId" + linebreak
				+"                    ,CmtIdNo) CD" + linebreak
				+"   ON CM.OdsCustomerId = CD.OdsCustomerId" + linebreak
				+"   AND CM.CmtIDNo = CD.CmtIDNo" + linebreak
				+"-- Get MitchellRecievedDate " + linebreak
				+"LEFT OUTER JOIN (SELECT DISTINCT OdsCustomerId, BillIdNo " + linebreak
				+"                             ,CASE  WHEN UDFIdNo = '-1' THEN UDFValueDate END AS MitchellReceivedDate" + linebreak
				+"" + linebreak
				+"                FROM TABLE(" + sourceDatabaseName + ".dbo.if_UDFBill(" + OdsPostingGroupAuditId.toString() + "))" + linebreak
				+"                WHERE UDFIdNo  IN ('-1')) MRD" + linebreak
				+"	ON MRD.OdsCustomerId = BH.OdsCustomerId" + linebreak
				+"	AND MRD.BillIDNo = BH.BillIDNo" + linebreak
				+"LEFT OUTER JOIN TABLE(" + sourceDatabaseName + ".dbo.if_BillsOverride(" + OdsPostingGroupAuditId.toString() + ")) BO" + linebreak
				+"	ON BO.OdsCustomerId = B.OdsCustomerId" + linebreak
				+"	AND BO.BillIDNo = B.BillIDNo" + linebreak
				+"	AND BO.Line_NO = B.LINE_NO" + linebreak
				+"LEFT OUTER JOIN TABLE(" + sourceDatabaseName + ".dbo.if_Adjustor(" + OdsPostingGroupAuditId.toString() + ")) AD" + linebreak
				+"	ON AD.OdsCustomerId = BO.OdsCustomerId" + linebreak
				+"	AND AD.UserId = BO.UserId" + linebreak
				+"LEFT OUTER JOIN TABLE(" + sourceDatabaseName + ".dbo.if_prf_Office(" + OdsPostingGroupAuditId.toString() + ")) O" + linebreak
				+"	ON O.OdsCustomerId = AD.OdsCustomerId" + linebreak
				+"	AND O.OfficeID = AD.OfficeIdNo" + linebreak
				+"	AND O.OfcName NOT LIKE '%TEST%'" + linebreak
				+"	AND O.OfcName NOT LIKE '%TRAIN%'" + linebreak
				+"LEFT OUTER JOIN TABLE(" + sourceDatabaseName + ".dbo.if_prf_COMPANY(" + OdsPostingGroupAuditId.toString() + ")) CO " + linebreak
				+"	ON CO.OdsCustomerId = O.OdsCustomerId" + linebreak
				+"	AND CO.CompanyId = O.CompanyId" + linebreak
				+"	AND CO.CompanyName NOT LIKE '%TEST%'" + linebreak
				+"	AND CO.CompanyName NOT LIKE '%TRAIN%'" + linebreak
				+"WHERE BH.CreateDate BETWEEN '" + startDate + "' AND '" + endDate + "'";
              
      if(isDebug){
            output.message.push("--Insert Into Staging table data for self serve operational");
            output.message.push(command + linebreak);
        }else{
            try{
              statement = snowflake.createStatement({sqlText:command});
              recordSet = statement.execute();
              recordSet.next();
              
              output.audit= 'Load';
              output.status = 'succeeded';
              output.message = 'Data Insert SucessFully.';
            }catch(err){
              output.returnStatus = -1;
              output.rowsAffected = -1;
              output.status = "failed";
              output.message.push(err.message);   
              output.message.push("Error Command: " + command);
              return output;
		    }  
            
        }
        
    return output;
    
$$
;  
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
    CREATE OR REPLACE PROCEDURE dbo.Self_Serve_Performance_Report_Savings_Adjustments(
    "sourceDatabaseName" STRING,
    "targetDatabaseName" STRING,
    "runDate" STRING,
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
    let OdsPostingGroupAuditId = 0
    
    let linebreak = "\r\n";
    let tab = "\t";
    
    //Get PostingGroupAudit ID
    command = "SELECT " + sourceDatabaseName + ".adm.Mnt_GetPostingGroupAuditIdAsOfSnapshotDate(0, '" + runDate + "');";
   	if(isDebug){
		output.returnStatus = 0;
        output.rowsAffected = -1;
        output.status = "debug";
        output.message.push("--get posting group audit id");
        output.message.push(command);
	}else{
		try{
			statement = snowflake.createStatement({sqlText: command});
            recordSet = statement.execute();
            if(recordSet.next()){
				OdsPostingGroupAuditId = recordSet.getColumnValue(1);
			}
		}catch(err){
			output.returnStatus = -1;
            output.rowsAffected = -1;
            output.status = "failed";
            output.message.push(err.message);   
			output.message.push("Error Command: " + command);
            return output;
		}
	}
    
    //Truncate adjustment table
    command = "TRUNCATE TABLE " + targetDatabaseName + ".STG.CLAIM_DETAIL_BILLLINE_ADJSUBCATNAME;";    
   	arrayComment.push("--Truncate adjustment table");
	arrayCommand.push(command);
    
	//Get Rsn Overrirde
	command = "CREATE OR REPLACE TEMPORARY TABLE STG.TMP_RsnOverride AS " + linebreak 
		+ "SELECT OdsCustomerId," + linebreak
        + "    ReasonNumber," + linebreak
        + "    ShortDesc," + linebreak
        + "    LongDesc" + linebreak
        + "FROM TABLE (" + sourceDatabaseName + ".dbo.if_Rsn_Override(" + OdsPostingGroupAuditId.toString() + "))" + linebreak
        + "UNION ALL" + linebreak
        + "SELECT Customer_Id," + linebreak
        + "    0," + linebreak
        + "    'No endnote given'," + linebreak
        + "    'No endnote given'" + linebreak
        + "FROM " + sourceDatabaseName + ".adm.Customer" + linebreak
        + "WHERE Is_Active = 1;";
    arrayComment.push("--Get Rsn Overrirde");
	arrayCommand.push(command);

	//Get Adjustment360OverrideEndNoteSubCategory
	command = "CREATE OR REPLACE TEMPORARY TABLE STG.TMP_Adjustment360OverrideEndNoteSubCategory AS " + linebreak 
		+ "SELECT OdsCustomerId," + linebreak
        + "    ReasonNumber," + linebreak
        + "    SubCategoryId" + linebreak
        + "FROM TABLE (" + sourceDatabaseName + ".dbo.if_Adjustment360OverrideEndNoteSubCategory(" + OdsPostingGroupAuditId.toString() + "))" + linebreak
        + "UNION ALL" + linebreak
        + "SELECT Customer_Id," + linebreak
        + "    0," + linebreak
        + "    6" + linebreak
        + "FROM " + sourceDatabaseName + ".adm.Customer" + linebreak
        + "WHERE Is_Active = 1;";
    arrayComment.push("--Get Adjustment360OverrideEndNoteSubCategory");
	arrayCommand.push(command);

	//Get the latest description UB_APC_DICT
	command = "CREATE OR REPLACE TEMPORARY TABLE STG.TMP_UbApcDict AS " + linebreak 
		+ "SELECT OdsCustomerId," + linebreak
        + "    APC," + linebreak
        + "    MAX(EndDate) AS EndDate" + linebreak
        + "FROM TABLE (" + sourceDatabaseName + ".dbo.if_UB_APC_DICT("+OdsPostingGroupAuditId.toString() + ")) rs" + linebreak
        + "GROUP BY APC, OdsCustomerId;";
    arrayComment.push("--Get the latest description UB_APC_DICT");
	arrayCommand.push(command);

	//Get Endnote and Descriptions 
	command = "CREATE OR REPLACE TEMPORARY TABLE STG.TMP_EndNoteDescriptions AS " + linebreak 
		+ "SELECT rs.OdsCustomerId," + linebreak
        + "    rs.ReasonNumber AS Endnote," + linebreak
        + "    rs.ShortDesc AS ShortDescription," + linebreak
        + "    rs.LongDesc AS LongDescription," + linebreak
        + "    1 AS EndnoteTypeId," + linebreak
        + "    sc.SubCategoryId AS Adjustment360SubCategoryId" + linebreak
        + "FROM TABLE (" + sourceDatabaseName + ".dbo.if_rsn_REASONS(" + OdsPostingGroupAuditId.toString() + ")) rs " + linebreak
        + "LEFT OUTER JOIN TABLE (" + sourceDatabaseName + ".dbo.if_Adjustment360EndNoteSubCategory(" + OdsPostingGroupAuditId.toString() + ")) sc" + linebreak
        + "    ON rs.OdsCustomerId = sc.OdsCustomerId" + linebreak
		+ "    AND rs.ReasonNumber = sc.ReasonNumber " + linebreak
        + "UNION ALL" + linebreak
        + "SELECT OdsCustomerId," + linebreak
        + "    rs.RuleID," + linebreak
        + "    rs.EndnoteShort," + linebreak
        + "    rs.EndnoteLong," + linebreak
        + "    2 AS EndNoteTypeId, " + linebreak
        + "    15 AS SubCategoryId" + linebreak
        + "FROM TABLE (" + sourceDatabaseName + ".dbo.if_SENTRY_RULE_ACTION_HEADER(" + OdsPostingGroupAuditId.toString() + ")) rs" + linebreak
        + "UNION ALL" + linebreak
        + "SELECT rs.OdsCustomerId," + linebreak
        + "    rs.ReasonNumber," + linebreak
        + "    rs.ShortDesc," + linebreak
        + "    rs.LongDesc," + linebreak
        + "    4 AS EndNoteTypeId, " + linebreak
        + "    sc.SubCategoryId" + linebreak
        + "FROM STG.TMP_RsnOverride rs" + linebreak
        + "LEFT OUTER JOIN STG.TMP_Adjustment360OverrideEndNoteSubCategory sc" + linebreak
        + "    ON rs.OdsCustomerId = sc.OdsCustomerId" + linebreak
		+ "    AND rs.ReasonNumber = sc.ReasonNumber" + linebreak
        + "UNION ALL" + linebreak
        + "SELECT rs.OdsCustomerId," + linebreak
        + "    rs.APC," + linebreak
        + "    rs.Description," + linebreak
        + "    rs.Description," + linebreak
        + "    5 AS EndNoteTypeId, " + linebreak
        + "    sc.SubCategoryId" + linebreak
        + "FROM TABLE (" + sourceDatabaseName + ".dbo.if_UB_APC_DICT(" + OdsPostingGroupAuditId.toString() + ")) rs" + linebreak
        + "INNER JOIN STG.TMP_UbApcDict rs1" + linebreak
        + "    ON rs.OdsCustomerId = rs1.OdsCustomerId " + linebreak
		+ "    AND rs1.APC = rs.APC" + linebreak
        + "    AND rs1.EndDate = rs.EndDate" + linebreak
        + "LEFT OUTER JOIN TABLE (" + sourceDatabaseName + ".dbo.if_Adjustment360ApcEndNoteSubCategory(" + OdsPostingGroupAuditId.toString() + ")) sc" + linebreak
        + "    ON rs.OdsCustomerId = sc.OdsCustomerId " + linebreak
        + "    AND rs.APC = sc.ReasonNumber;";
    arrayComment.push("--Get Endnote and Descriptions");
	arrayCommand.push(command);

	//Insert Adjustments data into staging table 
	command = "INSERT INTO " + targetDatabaseName + ".STG.CLAIM_DETAIL_BILLLINE_ADJSUBCATNAME(" + linebreak
        + "    OdsCustomerId" + linebreak
        + "    ,billID" + linebreak
        + "    ,BillLine" + linebreak
        + "    ,ReductionType" + linebreak
        + "    ,AdjSubCatName" + linebreak
        + "    ,Adjustment" + linebreak
        + "    ,RunDate)" + linebreak
        + "SELECT DISTINCT A.OdsCustomerId" + linebreak
        + "    ,A.billIDno" + linebreak
        + "    ,A.LineNumber" + linebreak
        + "    ,CASE WHEN AC.Name IS NULL AND A.Adjustment > 0 THEN 'Uncategorized' " + linebreak
		+ "        ELSE AC.Name END AS ReductionType" + linebreak
        + "    ,CASE WHEN A3S.Name IS NULL AND A.Adjustment > 0 THEN 'Uncategorized' " + linebreak
		+ "        ELSE A3S.Name END AS AdjSubCatName" + linebreak
        + "    ,A.Adjustment " + linebreak
        + "    ,'"+runDate+"'" + linebreak
        + "FROM TABLE (" + sourceDatabaseName + ".dbo.if_BillAdjustment(" + OdsPostingGroupAuditId.toString() + ")) A" + linebreak
        + "LEFT OUTER JOIN STG.TMP_EndNoteDescriptions R" + linebreak
        + "    ON A.OdsCustomerId = R.OdsCustomerId" + linebreak
        + "    AND A.EndNote = R.Endnote" + linebreak
        + "    AND A.EndNoteTypeId = R.EndnoteTypeId" + linebreak
        + "LEFT OUTER JOIN TABLE (" + sourceDatabaseName + ".dbo.if_Adjustment360SubCategory(" + OdsPostingGroupAuditId.toString() + ")) A3S" + linebreak
        + "    ON R.OdsCustomerId = A3S.OdsCustomerId" + linebreak
        + "    AND R.Adjustment360SubCategoryId = A3S.Adjustment360SubCategoryId" + linebreak
        + "LEFT OUTER JOIN TABLE (" + sourceDatabaseName + ".dbo.if_Adjustment360Category(" + OdsPostingGroupAuditId.toString() + ")) AC" + linebreak
        + "    ON A3S.OdsCustomerId = AC.OdsCustomerId" + linebreak
        + "    AND A3S.Adjustment360CategoryId = AC.Adjustment360CategoryId;";
    arrayComment.push("--Insert Adjustments data into staging table");
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
    CREATE OR REPLACE PROCEDURE dbo.Self_Serve_Performance_Report_Savings_claim_detail_bill(
    "targetDatabaseName" STRING,
    "runDate" STRING,
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
	let currentdate = new Date();
	let currentTimestamp = currentdate.getFullYear().toString()
		+ (currentdate.getMonth() + 1 < 10 ? "0" : "") + (currentdate.getMonth() + 1).toString()
		+ (currentdate.getDate() < 10 ? "0" : "") + currentdate.getDate().toString() + "_"
		+ (currentdate.getHours() < 10 ? "0" : "") + currentdate.getHours().toString()
		+ (currentdate.getMinutes() < 10 ? "0" : "") + currentdate.getMinutes().toString()
		+ (currentdate.getSeconds() < 10 ? "0" : "") + currentdate.getSeconds().toString();
    let tableName = "CLAIM_DETAIL_BILL";
	let swapTableName = tableName + "_" + currentTimestamp;
    let linebreak = "\r\n";
    let tab = "\t";

    //Clone target table and retain the access privileges from the original table 
	command = "CREATE OR REPLACE TABLE " + targetDatabaseName + ".DBO." + swapTableName + linebreak
		+ "CLONE " + targetDatabaseName + ".DBO." + tableName + linebreak
		+ "COPY GRANTS;";
	arrayComment.push("--Clone target table and retain the access privileges from the original table");
	arrayCommand.push(command);

    //Swap two tables
	command = "ALTER TABLE " + targetDatabaseName + ".DBO." + swapTableName + linebreak
		+ "SWAP WITH " + targetDatabaseName + ".DBO." + tableName + ";";
    arrayComment.push("--Swap two tables");
	arrayCommand.push(command);

	//Truncate switched target table
	command = "TRUNCATE TABLE " + targetDatabaseName + ".DBO." + swapTableName + ";";
	arrayComment.push("--Truncate switched target table");
	arrayCommand.push(command);

    //Insert into target table
    command =  "INSERT INTO " + targetDatabaseName + ".DBO." + swapTableName + linebreak
		+ "(" + linebreak
		+ "    ODS_CUSTOMER_ID," + linebreak
		+ "    CUSTOMER_NAME," + linebreak
		+ "    COMPANY," + linebreak
		+ "    OFFICE," + linebreak
		+ "    SOJ," + linebreak
		+ "    CLAIM_COVERAGE_TYPE," + linebreak
		+ "    BILL_COVERAGE_TYPE," + linebreak
		+ "    FORM_TYPE," + linebreak
		+ "    CLAIM_NO," + linebreak
		+ "    CLAIMANT_ID," + linebreak
		+ "    PROVIDER_TIN," + linebreak
		+ "    BILL_ID," + linebreak
		+ "    BILL_CREATE_DATE," + linebreak
		+ "    BILL_COMMIT_DATE," + linebreak
		+ "    MITCHELL_COMPLETE_DATE," + linebreak
		+ "    CLAIM_CREATE_DATE," + linebreak
		+ "    CLAIM_DATE_OF_LOSS," + linebreak
		+ "    EXPECTED_RECOVERY_DATE," + linebreak
		+ "    DUPLICATE_BILL_FLAG," + linebreak
		+ "    ADJUSTMENT," + linebreak
		+ "    PROVIDER_CHARGES," + linebreak
		+ "    TOTAL_ALLOWED," + linebreak
		+ "    TOTAL_UNITS," + linebreak
		+ "    EXPECTED_RECOVERY_DURATION," + linebreak
		+ "    COMPANY_ID," + linebreak
		+ "    OFFICE_ID," + linebreak
		+ "    BILL_CREATE_DATE_YEAR," + linebreak
		+ "    BILL_CREATE_DATE_QUARTER," + linebreak
		+ "    BILL_CREATE_DATE_MONTH," + linebreak
		+ "    BILL_CREATE_DATE_WEEK," + linebreak
		+ "    BILL_CREATE_DATE_DAY," + linebreak
		+ "    BILL_COMMIT_DATE_YEAR," + linebreak
		+ "    BILL_COMMIT_DATE_QUARTER," + linebreak
		+ "    BILL_COMMIT_DATE_MONTH," + linebreak
		+ "    BILL_COMMIT_DATE_WEEK," + linebreak
		+ "    BILL_COMMIT_DATE_DAY," + linebreak
		+ "    CMT_ZIP," + linebreak
		+ "    PVD_LAST_NAME," + linebreak
		+ "    PVD_FIRST_NAME," + linebreak
		+ "    PVD_GROUP," + linebreak
		+ "    PVD_ZOS," + linebreak
		+ "    PVD_STATE," + linebreak
		+ "    PVD_SPC_LIST," + linebreak
		+ "    CMT_DOB," + linebreak
		+ "    DX," + linebreak
		+ "    ICD_DIAGNOSIS_CODE_DICTIONARY_DESCRIPTION," + linebreak
		+ "    ICD_VERSION," + linebreak
		+ "    DX_MAJOR_GROUP," + linebreak
		+ "    TYPE_OF_BILL," + linebreak
		+ "    UB_BILL_TYPE_DESCRIPTION," + linebreak
		+ "    REV_CODE," + linebreak
		+ "    POS_CODE," + linebreak
		+ "    ADJUSTOR_ID," + linebreak
		+ "    USER_ID," + linebreak
		+ "    PPO_RECEIVED_DATE," + linebreak
		+ "    PPO_RETURNED_DATE," + linebreak
		+ "    CARRIER_RECEIVED_DATE," + linebreak
		+ "    MITCHELL_RECEIVED_DATE," + linebreak
		+ "    OVERRIDE_DATE_TIME," + linebreak
		+ "    FIRST_NURSE_COMPLETE_DATE," + linebreak
		+ "    SECOND_NURSE_COMPLETE_DATE," + linebreak
		+ "    THIRD_NURSE_COMPLETE_DATE," + linebreak
		+ "    EBILL_FLAG," + linebreak
		+ "    ADJUSTOR_LAST_NAME," + linebreak
		+ "    ADJUSTOR_FIRST_NAME" + linebreak
		+ ")" + linebreak
		+ "SELECT" + linebreak
        + "    ODS_CUSTOMER_ID," + linebreak
		+ "    ANY_VALUE(CUSTOMER_NAME)," + linebreak
		+ "    ANY_VALUE(COMPANY)," + linebreak
		+ "    ANY_VALUE(OFFICE)," + linebreak
		+ "    ANY_VALUE(SOJ)," + linebreak
		+ "    ANY_VALUE(CLAIM_COVERAGE_TYPE)," + linebreak
		+ "    ANY_VALUE(BILL_COVERAGE_TYPE)," + linebreak
		+ "    ANY_VALUE(FORM_TYPE)," + linebreak
		+ "    ANY_VALUE(CLAIM_NO)," + linebreak
		+ "    ANY_VALUE(CLAIMANT_ID)," + linebreak
		+ "    ANY_VALUE(PROVIDER_TIN)," + linebreak
		+ "    BILL_ID," + linebreak
		+ "    ANY_VALUE(BILL_CREATE_DATE)," + linebreak
		+ "    ANY_VALUE(BILL_COMMIT_DATE)," + linebreak
		+ "    ANY_VALUE(MITCHELL_COMPLETE_DATE)," + linebreak
		+ "    ANY_VALUE(CLAIM_CREATE_DATE)," + linebreak
		+ "    ANY_VALUE(CLAIM_DATE_OF_LOSS)," + linebreak
		+ "    ANY_VALUE(EXPECTED_RECOVERY_DATE)," + linebreak
		+ "    ANY_VALUE(DUPLICATE_BILL_FLAG)," + linebreak
		+ "    SUM(ADJUSTMENT)," + linebreak
		+ "    SUM(PROVIDER_CHARGES)," + linebreak
		+ "    SUM(TOTAL_ALLOWED)," + linebreak
		+ "    SUM(TOTAL_UNITS)," + linebreak
		+ "    ANY_VALUE(EXPECTED_RECOVERY_DURATION)," + linebreak
		+ "    ANY_VALUE(COMPANY_ID)," + linebreak
		+ "    ANY_VALUE(OFFICE_ID)," + linebreak
		+ "    ANY_VALUE(BILL_CREATE_DATE_YEAR)," + linebreak
		+ "    ANY_VALUE(BILL_CREATE_DATE_QUARTER)," + linebreak
		+ "    ANY_VALUE(BILL_CREATE_DATE_MONTH)," + linebreak
		+ "    ANY_VALUE(BILL_CREATE_DATE_WEEK)," + linebreak
		+ "    ANY_VALUE(BILL_CREATE_DATE_DAY)," + linebreak
		+ "    ANY_VALUE(BILL_COMMIT_DATE_YEAR)," + linebreak
		+ "    ANY_VALUE(BILL_COMMIT_DATE_QUARTER)," + linebreak
		+ "    ANY_VALUE(BILL_COMMIT_DATE_MONTH)," + linebreak
		+ "    ANY_VALUE(BILL_COMMIT_DATE_WEEK)," + linebreak
		+ "    ANY_VALUE(BILL_COMMIT_DATE_DAY)," + linebreak
		+ "    ANY_VALUE(CMT_ZIP)," + linebreak
		+ "    ANY_VALUE(PVD_LAST_NAME)," + linebreak
		+ "    ANY_VALUE(PVD_FIRST_NAME)," + linebreak
		+ "    ANY_VALUE(PVD_GROUP)," + linebreak
		+ "    ANY_VALUE(PVD_ZOS)," + linebreak
		+ "    ANY_VALUE(PVD_STATE)," + linebreak
		+ "    ANY_VALUE(PVD_SPC_LIST)," + linebreak
		+ "    ANY_VALUE(CMT_DOB)," + linebreak
		+ "    ANY_VALUE(DX)," + linebreak
		+ "    ANY_VALUE(ICD_DIAGNOSIS_CODE_DICTIONARY_DESCRIPTION)," + linebreak
		+ "    ANY_VALUE(ICD_VERSION)," + linebreak
		+ "    ANY_VALUE(DX_MAJOR_GROUP)," + linebreak
		+ "    ANY_VALUE(TYPE_OF_BILL)," + linebreak
		+ "    ANY_VALUE(UB_BILL_TYPE_DESCRIPTION)," + linebreak
		+ "    ANY_VALUE(REV_CODE)," + linebreak
		+ "    ANY_VALUE(POS_CODE)," + linebreak
		+ "    ANY_VALUE(ADJUSTOR_ID)," + linebreak
		+ "    ANY_VALUE(USER_ID)," + linebreak
		+ "    ANY_VALUE(PPO_RECEIVED_DATE)," + linebreak
		+ "    ANY_VALUE(PPO_RETURNED_DATE)," + linebreak
		+ "    ANY_VALUE(CARRIER_RECEIVED_DATE)," + linebreak
		+ "    ANY_VALUE(MITCHELL_RECEIVED_DATE)," + linebreak
		+ "    ANY_VALUE(OVERRIDE_DATE_TIME)," + linebreak
		+ "    ANY_VALUE(FIRST_NURSE_COMPLETE_DATE)," + linebreak
		+ "    ANY_VALUE(SECOND_NURSE_COMPLETE_DATE)," + linebreak
		+ "    ANY_VALUE(THIRD_NURSE_COMPLETE_DATE)," + linebreak
		+ "    ANY_VALUE(EBILL_FLAG)," + linebreak
		+ "    ANY_VALUE(ADJUSTOR_LAST_NAME)," + linebreak
		+ "    ANY_VALUE(ADJUSTOR_FIRST_NAME)" + linebreak
        + "FROM " + targetDatabaseName + ".DBO.CLAIM_DETAIL_BILLLINE" + linebreak
		+ "GROUP BY ODS_CUSTOMER_ID, BILL_ID;";
        
	arrayComment.push("--Insert into target table");
	arrayCommand.push(command);

	//Swap two tables back
	command = "ALTER TABLE " + targetDatabaseName + ".DBO." + swapTableName + linebreak
		+ "SWAP WITH " + targetDatabaseName + ".DBO." + tableName + ";";
	arrayComment.push("--Swap two tables back");
	arrayCommand.push(command);

	//drop the swapped table
	command = "DROP TABLE " + targetDatabaseName + ".DBO." + swapTableName + ";";
	arrayComment.push("--Drop the swapped table");
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
    CREATE OR REPLACE PROCEDURE dbo.Self_Serve_Performance_Report_Savings_claim_detail_billline(
    "targetDatabaseName" STRING,
    "runDate" STRING,
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
	let currentdate = new Date();
	let currentTimestamp = currentdate.getFullYear().toString()
		+ (currentdate.getMonth() + 1 < 10 ? "0" : "") + (currentdate.getMonth() + 1).toString()
		+ (currentdate.getDate() < 10 ? "0" : "") + currentdate.getDate().toString() + "_"
		+ (currentdate.getHours() < 10 ? "0" : "") + currentdate.getHours().toString()
		+ (currentdate.getMinutes() < 10 ? "0" : "") + currentdate.getMinutes().toString()
		+ (currentdate.getSeconds() < 10 ? "0" : "") + currentdate.getSeconds().toString();
    let tableName = "CLAIM_DETAIL_BILLLINE";
	let swapTableName = tableName + "_" + currentTimestamp;
    let linebreak = "\r\n";
    let tab = "\t";

    //Clone target table and retain the access privileges from the original table 
	command = "CREATE OR REPLACE TABLE " + targetDatabaseName + ".DBO." + swapTableName + linebreak
		+ "CLONE " + targetDatabaseName + ".DBO." + tableName + linebreak
		+ "COPY GRANTS;";
	arrayComment.push("--Clone target table and retain the access privileges from the original table");
	arrayCommand.push(command);

    //Swap two tables
	command = "ALTER TABLE " + targetDatabaseName + ".DBO." + swapTableName + linebreak
		+ "SWAP WITH " + targetDatabaseName + ".DBO." + tableName + ";";
    arrayComment.push("--Swap two tables");
	arrayCommand.push(command);

	//Truncate switched target table
	command = "TRUNCATE TABLE " + targetDatabaseName + ".DBO." + swapTableName + ";";
	arrayComment.push("--Truncate switched target table");
	arrayCommand.push(command);

    //Insert into target table
    command =  "INSERT INTO " + targetDatabaseName + ".DBO." + swapTableName + linebreak
		+ "(" + linebreak
		+ "    ODS_CUSTOMER_ID," + linebreak
		+ "    CUSTOMER_NAME," + linebreak
		+ "    COMPANY," + linebreak
		+ "    OFFICE," + linebreak
		+ "    SOJ," + linebreak
		+ "    CLAIM_COVERAGE_TYPE," + linebreak
		+ "    BILL_COVERAGE_TYPE," + linebreak
		+ "    FORM_TYPE," + linebreak
		+ "    CLAIM_NO," + linebreak
		+ "    CLAIMANT_ID," + linebreak
		+ "    PROVIDER_TIN," + linebreak
		+ "    BILL_ID," + linebreak
		+ "    BILL_CREATE_DATE," + linebreak
		+ "    BILL_COMMIT_DATE," + linebreak
		+ "    MITCHELL_COMPLETE_DATE," + linebreak
		+ "    CLAIM_CREATE_DATE," + linebreak
		+ "    CLAIM_DATE_OF_LOSS," + linebreak
		+ "    EXPECTED_RECOVERY_DATE," + linebreak
		+ "    BILL_LINE," + linebreak
		+ "    LINE_TYPE," + linebreak
		+ "    NDC," + linebreak
		+ "    PROCEDURE_CODE," + linebreak
		+ "    PROCEDURE_CODE_DESCRIPTION," + linebreak
		+ "    PROCEDURE_CODE_MAJOR_GROUP," + linebreak
		+ "    DUPLICATE_BILL_FLAG," + linebreak
		+ "    DUPLICATE_LINE_FLAG," + linebreak
		+ "    ADJUSTMENT," + linebreak
		+ "    PROVIDER_CHARGES," + linebreak
		+ "    TOTAL_ALLOWED," + linebreak
		+ "    TOTAL_UNITS," + linebreak
		+ "    EXPECTED_RECOVERY_DURATION," + linebreak
		+ "    COMPANY_ID," + linebreak
		+ "    OFFICE_ID," + linebreak
		+ "    BILL_CREATE_DATE_YEAR," + linebreak
		+ "    BILL_CREATE_DATE_QUARTER," + linebreak
		+ "    BILL_CREATE_DATE_MONTH," + linebreak
		+ "    BILL_CREATE_DATE_WEEK," + linebreak
		+ "    BILL_CREATE_DATE_DAY," + linebreak
		+ "    BILL_COMMIT_DATE_YEAR," + linebreak
		+ "    BILL_COMMIT_DATE_QUARTER," + linebreak
		+ "    BILL_COMMIT_DATE_MONTH," + linebreak
		+ "    BILL_COMMIT_DATE_WEEK," + linebreak
		+ "    BILL_COMMIT_DATE_DAY," + linebreak
		+ "    NETWORK_NAME," + linebreak
		+ "    CMT_ZIP," + linebreak
		+ "    LINE_START_DATE_OF_SERVICE," + linebreak
		+ "    LINE_END_DATE_OF_SERVICE," + linebreak
		+ "    PVD_LAST_NAME," + linebreak
		+ "    PVD_FIRST_NAME," + linebreak
		+ "    PVD_GROUP," + linebreak
		+ "    PVD_ZOS," + linebreak
		+ "    PVD_STATE," + linebreak
		+ "    PVD_SPC_LIST," + linebreak
		+ "    CMT_DOB," + linebreak
		+ "    DX," + linebreak
		+ "    ICD_DIAGNOSIS_CODE_DICTIONARY_DESCRIPTION," + linebreak
		+ "    ICD_VERSION," + linebreak
		+ "    DX_MAJOR_GROUP," + linebreak
		+ "    MODIFIER," + linebreak
		+ "    MODIFIER_DICTIONARY_DESCRIPTION," + linebreak
		+ "    TYPE_OF_BILL," + linebreak
		+ "    UB_BILL_TYPE_DESCRIPTION," + linebreak
		+ "    REV_CODE," + linebreak
		+ "    POS_CODE," + linebreak
		+ "    ADJUSTOR_ID," + linebreak
		+ "    USER_ID," + linebreak
		+ "    PPO_RECEIVED_DATE," + linebreak
		+ "    PPO_RETURNED_DATE," + linebreak
		+ "    CARRIER_RECEIVED_DATE," + linebreak
		+ "    MITCHELL_RECEIVED_DATE," + linebreak
		+ "    OVERRIDE_DATE_TIME," + linebreak
		+ "    FIRST_NURSE_COMPLETE_DATE," + linebreak
		+ "    SECOND_NURSE_COMPLETE_DATE," + linebreak
		+ "    THIRD_NURSE_COMPLETE_DATE," + linebreak
		+ "    EBILL_FLAG," + linebreak
		+ "    ADJUSTOR_LAST_NAME," + linebreak
		+ "    ADJUSTOR_FIRST_NAME" + linebreak
		+ ")" + linebreak
		+ "SELECT" + linebreak
        + "    C.OdsCustomerId," + linebreak
        + "    C.CustomerName," + linebreak
        + "    C.Company," + linebreak
        + "    C.Office," + linebreak
        + "    C.SOJ," + linebreak
        + "    C.ClaimCoverageType," + linebreak
        + "    C.BillCoverageType," + linebreak
        + "    C.FormType," + linebreak
        + "    C.ClaimNo," + linebreak
        + "    C.ClaimantID," + linebreak
        + "    C.ProviderTIN," + linebreak
        + "    C.BillID," + linebreak
        + "    C.BillCreateDate," + linebreak
        + "    C.BillCommitDate," + linebreak
        + "    C.MitchellCompleteDate," + linebreak
        + "    C.ClaimCreateDate," + linebreak
        + "    C.ClaimDateofLoss," + linebreak
        + "    C.ExpectedRecoveryDate," + linebreak
        + "    C.BillLine," + linebreak
		+ "    C.LineType," + linebreak
		+ "    C.NDC," + linebreak
        + "    C.ProcedureCode," + linebreak
        + "    C.ProcedureCodeDescription," + linebreak
        + "    C.ProcedureCodeMajorGroup," + linebreak
        + "    C.DuplicateBillFlag," + linebreak
        + "    C.DuplicateLineFlag," + linebreak
        + "    A.Adjustment," + linebreak
        + "    C.ProviderCharges, " + linebreak
        + "    C.TotalAllowed," + linebreak
        + "    C.TotalUnits," + linebreak
        + "    C.ExpectedRecoveryDuration," + linebreak
        + "    C.CompanyId," + linebreak
        + "    C.OfficeId," + linebreak
        + "    YEAR(C.BillCreateDate) BillCreateDate_Year," + linebreak
        + "    QUARTER(C.BillCreateDate) BillCreateDate_Quarter," + linebreak
        + "    MONTH(C.BillCreateDate) BillCreateDate_Month," + linebreak
        + "    WEEK(C.BillCreateDate) BillCreateDate_Week," + linebreak
        + "    DAY(C.BillCreateDate) BillCreateDate_Day," + linebreak
        + "    YEAR(C.BillCommitDate) BillCommitDate_Year," + linebreak
        + "    QUARTER(C.BillCommitDate) BillCommitDate_Quarter," + linebreak
        + "    MONTH(C.BillCommitDate) BillCommitDate_Month," + linebreak
        + "    WEEK(C.BillCommitDate) BillCommitDate_Week," + linebreak
        + "    DAY(C.BillCommitDate) BillCommitDate_Day," + linebreak
        + "    C.NetworkName," + linebreak 
        + "    C.CMTZIP," + linebreak 
        + "    C.LineStartDateOfService," + linebreak 
        + "    C.LineEndDateOfService," + linebreak 
        + "    C.PVDLastName," + linebreak 
        + "    C.PVDFirstName," + linebreak 
        + "    C.PVDGroup," + linebreak 
        + "    C.PVDZOS," + linebreak 
        + "    C.PVDState," + linebreak 
        + "    C.PVDSPC_List," + linebreak 
        + "    C.CMTDOB," + linebreak 
        + "    C.DX," + linebreak 
        + "    C.DXCodeDescription," + linebreak 
        + "    C.ICDVersion," + linebreak 
        + "    C.DXMajorGroup," + linebreak 
        + "    C.Modifier," + linebreak 
        + "    C.ModifierDescription," + linebreak 
        + "    C.TypeOfBill," + linebreak 
        + "    C.Description," + linebreak 
        + "    C.REVCode," + linebreak 
        + "    C.POSCode," + linebreak 
		+ "    C.AdjustorId," + linebreak 
		+ "    C.UserId," + linebreak 
		+ "    C.PPOReceivedDate," + linebreak 
		+ "    C.PPOReturnedDate," + linebreak 
		+ "    C.CarrierReceivedDate," + linebreak 
		+ "    C.MitchellReceivedDate," + linebreak 
		+ "    C.OverrideDateTime," + linebreak 
		+ "    C.FirstNurseCompleteDate," + linebreak 
		+ "    C.SecondNurseCompleteDate," + linebreak 
		+ "    C.ThirdNurseCompleteDate," + linebreak 
		+ "    C.EBILL_FLAG," + linebreak
		+ "    C.ADJUSTOR_LAST_NAME," + linebreak
		+ "    C.ADJUSTOR_FIRST_NAME" + linebreak
        + "FROM " + targetDatabaseName + ".STG.CLAIM_DETAIL_BILLLINE C" + linebreak
        + "LEFT OUTER JOIN (" + linebreak
        + "    SELECT A.OdsCustomerId, " + linebreak
        + "        A.BillId, " + linebreak
        + "        A.BillLine, " + linebreak
        + "        SUM(A.Adjustment) AS Adjustment" + linebreak
        + "    FROM " + targetDatabaseName + ".STG.CLAIM_DETAIL_BILLLINE_ADJSUBCATNAME A" + linebreak
        + "    GROUP BY A.OdsCustomerId, A.BillId, A.BillLine" + linebreak
        + ") A" + linebreak
        + "    ON C.OdsCustomerId = A.OdsCustomerId" + linebreak
        + "    AND C.BillId = A.BillId" + linebreak
        + "    AND C.BillLine = A.BillLine;";
	arrayComment.push("--Insert into target table");
	arrayCommand.push(command);

	//Swap two tables back
	command = "ALTER TABLE " + targetDatabaseName + ".DBO." + swapTableName + linebreak
		+ "SWAP WITH " + targetDatabaseName + ".DBO." + tableName + ";";
	arrayComment.push("--Swap two tables back");
	arrayCommand.push(command);

	//drop the swapped table
	command = "DROP TABLE " + targetDatabaseName + ".DBO." + swapTableName + ";";
	arrayComment.push("--Swap two tables back");
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
    CREATE OR REPLACE PROCEDURE dbo.Self_Serve_Performance_Report_Savings_claim_detail_billline_adjsubcatname(
    "targetDatabaseName" STRING,
    "runDate" STRING,
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
    let currentdate = new Date();
	let currentTimestamp = currentdate.getFullYear().toString()
		+ (currentdate.getMonth() + 1 < 10 ? "0" : "") + (currentdate.getMonth() + 1).toString()
		+ (currentdate.getDate() < 10 ? "0" : "") + currentdate.getDate().toString() + "_"
		+ (currentdate.getHours() < 10 ? "0" : "") + currentdate.getHours().toString()
		+ (currentdate.getMinutes() < 10 ? "0" : "") + currentdate.getMinutes().toString()
		+ (currentdate.getSeconds() < 10 ? "0" : "") + currentdate.getSeconds().toString();
    let tableName = "CLAIM_DETAIL_BILLLINE_ADJSUBCATNAME";
	let swapTableName = tableName + "_" + currentTimestamp;
    let linebreak = "\r\n";
    let tab = "\t";
    
	//Clone target table and retain the access privileges from the original table 
	command = "CREATE OR REPLACE TABLE " + targetDatabaseName + ".DBO." + swapTableName + linebreak
		+ "CLONE " + targetDatabaseName + ".DBO." + tableName + linebreak
		+ "COPY GRANTS;";
	arrayComment.push("--Clone target table and retain the access privileges from the original table");
	arrayCommand.push(command);

    //Swap two tables
	command = "ALTER TABLE " + targetDatabaseName + ".DBO." + swapTableName + linebreak
		+ "SWAP WITH " + targetDatabaseName + ".DBO." + tableName + ";";
    arrayComment.push("--Swap two tables");
	arrayCommand.push(command);

	//Truncate switched target table
	command = "TRUNCATE TABLE " + targetDatabaseName + ".DBO." + swapTableName + ";";
	arrayComment.push("--Truncate switched target table");
	arrayCommand.push(command);

    //Insert into target table
    command = "INSERT INTO " + targetDatabaseName + ".DBO." + swapTableName + linebreak
		+ "(" + linebreak
		+ "    ODS_CUSTOMER_ID," + linebreak
		+ "    CUSTOMER_NAME," + linebreak
		+ "    COMPANY," + linebreak
		+ "    OFFICE," + linebreak
		+ "    SOJ," + linebreak
		+ "    CLAIM_COVERAGE_TYPE," + linebreak
		+ "    BILL_COVERAGE_TYPE," + linebreak
		+ "    FORM_TYPE," + linebreak
		+ "    CLAIM_NO," + linebreak
		+ "    CLAIMANT_ID," + linebreak
		+ "    PROVIDER_TIN," + linebreak
		+ "    BILL_ID," + linebreak
		+ "    BILL_CREATE_DATE," + linebreak
		+ "    BILL_COMMIT_DATE," + linebreak
		+ "    MITCHELL_COMPLETE_DATE," + linebreak
		+ "    CLAIM_CREATE_DATE," + linebreak
		+ "    CLAIM_DATE_OF_LOSS," + linebreak
		+ "    EXPECTED_RECOVERY_DATE," + linebreak
		+ "    BILL_LINE," + linebreak
		+ "    LINE_TYPE," + linebreak
		+ "    NDC," + linebreak
		+ "    PROCEDURE_CODE," + linebreak
		+ "    PROCEDURE_CODE_DESCRIPTION," + linebreak
		+ "    PROCEDURE_CODE_MAJOR_GROUP," + linebreak
		+ "    REDUCTION_TYPE," + linebreak
		+ "    ADJ_SUB_CAT_NAME," + linebreak
		+ "    ADJUSTMENT," + linebreak
		+ "    DUPLICATE_BILL_FLAG," + linebreak
		+ "    DUPLICATE_LINE_FLAG," + linebreak
		+ "    COMPANY_ID," + linebreak
		+ "    OFFICE_ID," + linebreak
		+ "    BILL_CREATE_DATE_YEAR," + linebreak
		+ "    BILL_CREATE_DATE_QUARTER," + linebreak
		+ "    BILL_CREATE_DATE_MONTH," + linebreak
		+ "    BILL_CREATE_DATE_WEEK," + linebreak
		+ "    BILL_CREATE_DATE_DAY," + linebreak
		+ "    BILL_COMMIT_DATE_YEAR," + linebreak
		+ "    BILL_COMMIT_DATE_QUARTER," + linebreak
		+ "    BILL_COMMIT_DATE_MONTH," + linebreak
		+ "    BILL_COMMIT_DATE_WEEK," + linebreak
		+ "    BILL_COMMIT_DATE_DAY," + linebreak
		+ "    NETWORK_NAME," + linebreak
		+ "    CMT_ZIP," + linebreak
		+ "    LINE_START_DATE_OF_SERVICE," + linebreak
		+ "    LINE_END_DATE_OF_SERVICE," + linebreak
		+ "    PVD_LAST_NAME," + linebreak
		+ "    PVD_FIRST_NAME," + linebreak
		+ "    PVD_GROUP," + linebreak
		+ "    PVD_ZOS," + linebreak
		+ "    PVD_STATE," + linebreak
		+ "    PVD_SPC_LIST," + linebreak
		+ "    CMT_DOB," + linebreak
		+ "    DX," + linebreak
		+ "    ICD_DIAGNOSIS_CODE_DICTIONARY_DESCRIPTION," + linebreak
		+ "    ICD_VERSION," + linebreak
		+ "    DX_MAJOR_GROUP," + linebreak
		+ "    MODIFIER," + linebreak
		+ "    MODIFIER_DICTIONARY_DESCRIPTION," + linebreak
		+ "    TYPE_OF_BILL," + linebreak
		+ "    UB_BILL_TYPE_DESCRIPTION," + linebreak
		+ "    REV_CODE," + linebreak
		+ "    POS_CODE," + linebreak
		+ "    ADJUSTOR_ID," + linebreak
		+ "    USER_ID," + linebreak
		+ "    PPO_RECEIVED_DATE," + linebreak
		+ "    PPO_RETURNED_DATE," + linebreak
		+ "    CARRIER_RECEIVED_DATE," + linebreak
		+ "    MITCHELL_RECEIVED_DATE," + linebreak
		+ "    OVERRIDE_DATE_TIME," + linebreak
		+ "    FIRST_NURSE_COMPLETE_DATE," + linebreak
		+ "    SECOND_NURSE_COMPLETE_DATE," + linebreak
		+ "    THIRD_NURSE_COMPLETE_DATE," + linebreak
		+ "    EBILL_FLAG," + linebreak
		+ "    ADJUSTOR_LAST_NAME," + linebreak
		+ "    ADJUSTOR_FIRST_NAME" + linebreak
		+ ")" + linebreak
		+ "SELECT DISTINCT" + linebreak
		+ "    C.OdsCustomerId," + linebreak
		+ "    C.CustomerName," + linebreak
		+ "    C.Company," + linebreak
		+ "    C.Office," + linebreak
		+ "    C.SOJ," + linebreak
		+ "    C.ClaimCoverageType," + linebreak
		+ "    C.BillCoverageType," + linebreak
		+ "    C.FormType," + linebreak
		+ "    C.ClaimNo," + linebreak
		+ "    C.ClaimantID," + linebreak
		+ "    C.ProviderTIN," + linebreak
		+ "    C.BillID," + linebreak
		+ "    C.BillCreateDate," + linebreak
		+ "    C.BillCommitDate," + linebreak
		+ "    C.MitchellCompleteDate," + linebreak
		+ "    C.ClaimCreateDate," + linebreak
		+ "    C.ClaimDateofLoss," + linebreak
		+ "    C.ExpectedRecoveryDate," + linebreak
		+ "    C.BillLine," + linebreak
		+ "    C.LineType," + linebreak
		+ "    C.NDC," + linebreak
		+ "    C.ProcedureCode," + linebreak
		+ "    C.ProcedureCodeDescription," + linebreak
		+ "    C.ProcedureCodeMajorGroup," + linebreak
		+ "    A.ReductionType," + linebreak
		+ "    A.AdjSubCatName," + linebreak
		+ "    A.Adjustment," + linebreak
		+ "    C.DuplicateBillFlag," + linebreak
		+ "    C.DuplicateLineFlag," + linebreak
		+ "    C.CompanyId," + linebreak
		+ "    C.OfficeId," + linebreak
		+ "    YEAR(C.BillCreateDate) BillCreateDate_Year ," + linebreak
		+ "    QUARTER(C.BillCreateDate) BillCreateDate_Quarter ," + linebreak
		+ "    MONTH(C.BillCreateDate) BillCreateDate_Month ," + linebreak
		+ "    WEEK(C.BillCreateDate) BillCreateDate_Week ," + linebreak
		+ "    DAY(C.BillCreateDate) BillCreateDate_Day ," + linebreak
		+ "    YEAR(C.BillCommitDate) BillCommitDate_Year ," + linebreak
		+ "    QUARTER(C.BillCommitDate) BillCommitDate_Quarter ," + linebreak
		+ "    MONTH(C.BillCommitDate) BillCommitDate_Month ," + linebreak
		+ "    WEEK(C.BillCommitDate) BillCommitDate_Week ," + linebreak
		+ "    DAY(C.BillCommitDate) BillCommitDate_Day," + linebreak
		+ "    C.NetworkName," + linebreak 
        + "    C.CMTZIP," + linebreak 
        + "    C.LineStartDateOfService," + linebreak 
        + "    C.LineEndDateOfService," + linebreak 
        + "    C.PVDLastName," + linebreak 
        + "    C.PVDFirstName," + linebreak 
        + "    C.PVDGroup," + linebreak 
        + "    C.PVDZOS," + linebreak 
        + "    C.PVDState," + linebreak 
        + "    C.PVDSPC_List," + linebreak 
        + "    C.CMTDOB," + linebreak 
        + "    C.DX," + linebreak 
        + "    C.DXCodeDescription," + linebreak 
        + "    C.ICDVersion," + linebreak 
        + "    C.DXMajorGroup," + linebreak 
        + "    C.Modifier," + linebreak 
        + "    C.ModifierDescription," + linebreak 
        + "    C.TypeOfBill," + linebreak 
        + "    C.Description," + linebreak 
        + "    C.REVCode," + linebreak 
        + "    C.POSCode," + linebreak 
		+ "    C.AdjustorId," + linebreak 
		+ "    C.UserId," + linebreak 
		+ "    C.PPOReceivedDate," + linebreak 
		+ "    C.PPOReturnedDate," + linebreak 
		+ "    C.CarrierReceivedDate," + linebreak 
		+ "    C.MitchellReceivedDate," + linebreak 
		+ "    C.OverrideDateTime," + linebreak 
		+ "    C.FirstNurseCompleteDate," + linebreak 
		+ "    C.SecondNurseCompleteDate," + linebreak 
		+ "    C.ThirdNurseCompleteDate," + linebreak 
		+ "    C.EBILL_FLAG," + linebreak
		+ "    C.ADJUSTOR_LAST_NAME," + linebreak
		+ "    C.ADJUSTOR_FIRST_NAME" + linebreak
		+ "FROM " + targetDatabaseName + ".STG.CLAIM_DETAIL_BILLLINE C" + linebreak
		+ "LEFT OUTER JOIN " + targetDatabaseName + ".STG.CLAIM_DETAIL_BILLLINE_ADJSUBCATNAME A" + linebreak
		+ "    ON C.OdsCustomerId = A.OdsCustomerId" + linebreak
		+ "    AND C.BillId = A.BillId" + linebreak
		+ "    AND C.BillLine = A.BillLine;";
	arrayComment.push("--Truncate switched target table");
	arrayCommand.push(command);
	
	//Swap two tables back
	command = "ALTER TABLE " + targetDatabaseName + ".DBO." + swapTableName + linebreak
		+ "SWAP WITH " + targetDatabaseName + ".DBO." + tableName + ";";
	arrayComment.push("--Swap two tables back");
	arrayCommand.push(command);
	
	//drop the swapped table
	command = "DROP TABLE " + targetDatabaseName + ".DBO." + swapTableName + ";";
	arrayComment.push("--Swap two tables back");
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
    CREATE OR REPLACE PROCEDURE dbo.Self_Serve_Performance_Report_Savings_Data(
    "sourceDatabaseName" STRING,
    "targetDatabaseName" STRING,
    "runDate" STRING,
	"startDate" STRING,
    "endDate" STRING,
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
    let OdsPostingGroupAuditId = 0
    
    let linebreak = "\r\n";
    let tab = "\t";
    
    //Get PostingGroupAudit ID
    command = "SELECT " + sourceDatabaseName + ".adm.Mnt_GetPostingGroupAuditIdAsOfSnapshotDate(0, '" + runDate + "');";
   	if(isDebug){
		output.returnStatus = 0;
        output.rowsAffected = -1;
        output.status = "debug";
        output.message.push("--get posting group audit id");
        output.message.push(command);
	}
	try{
		statement = snowflake.createStatement({sqlText: command});
        recordSet = statement.execute();
        if(recordSet.next()){
			OdsPostingGroupAuditId = recordSet.getColumnValue(1);
		}
	}catch(err){
		output.returnStatus = -1;
        output.rowsAffected = -1;
        output.status = "failed";
        output.message.push(err.message);   
		output.message.push("Error Command: " + command);
        return output;
	}

	//Truncate claims detail table
    command = "TRUNCATE TABLE " + targetDatabaseName + ".STG.CLAIM_DETAIL_BILLLINE;";
	arrayComment.push("--Truncate staging claims detail table");
	arrayCommand.push(command);

	//Get the DX For Body Part
	command = "CREATE OR REPLACE TEMPORARY TABLE STG.TMP_Diagnosis AS " + linebreak 
		+ "SELECT dx.OdsCustomerId" + linebreak 
		+ "    ,dx.BillIDNo" + linebreak 
		+ "    ,dx.DX" + linebreak 
		+ "    ,dx.IcdVersion" + linebreak 
		+ "FROM TABLE(" + sourceDatabaseName + ".dbo.if_CMT_DX(" + OdsPostingGroupAuditId.toString() + ")) dx" + linebreak 
		+ "INNER JOIN (SELECT OdsCustomerId" + linebreak 
		+ "    ,BillIDNo" + linebreak 
		+ "    ,MIN(SeqNum) SeqNum" + linebreak 
		+ "    FROM TABLE(" + sourceDatabaseName + ".dbo.if_CMT_DX(" + OdsPostingGroupAuditId.toString() + "))" + linebreak 
		+ "    GROUP BY OdsCustomerId" + linebreak 
		+ "        ,BillIDNo) M" + linebreak 
		+ "    ON dx.OdsCustomerId = M.OdsCustomerId" + linebreak 
		+ "    AND dx.BillIDNo = M.BillIDNo" + linebreak 
		+ "    AND dx.SeqNum = M.SeqNum;";
	arrayComment.push("--Get the DX For Body Part");
	arrayCommand.push(command);
	
	//Get MitchellCompleteDate Claimants
	command = "CREATE OR REPLACE TEMPORARY TABLE STG.TMP_MitchellCompleteDateClaimants AS " + linebreak 
		+ "SELECT OdsCustomerId" + linebreak 
		+ "    ,CmtIdNo" + linebreak 
		+ "    ,CASE WHEN Max(UDFValueDate) = '1899-12-30 00:00:00.000' THEN NULL " + linebreak 
		+ "        ELSE Max(UDFValueDate) END AS MitchellCmptDate" + linebreak 
		+ "FROM TABLE(" + sourceDatabaseName + ".dbo.if_UDFClaimant(" + OdsPostingGroupAuditId.toString() + "))" + linebreak 
		+ "WHERE UDFIdNo IN ('-3', '-4', '5')" + linebreak 
		+ "GROUP BY OdsCustomerId" + linebreak 
		+ "    ,CmtIdNo;";
	arrayComment.push("--Get MitchellCompleteDate Claimants");
	arrayCommand.push(command);

	//Get Bill Committed Date
	command = "CREATE OR REPLACE TEMPORARY TABLE STG.TMP_BillHistory AS " + linebreak 
		+ "SELECT bhs.OdsCustomerId" + linebreak 
		+ "    ,bhs.billIDNo" + linebreak 
		+ "    ,max(bhs.DateCommitted) as DateCommitted " + linebreak 
		+ "FROM TABLE(" + sourceDatabaseName + ".dbo.if_Bill_History(" + OdsPostingGroupAuditId.toString() + ")) bhs" + linebreak 
		+ "GROUP BY bhs.OdsCustomerId" + linebreak 
		+ "    ,bhs.billIDNo;"; 
	arrayComment.push("--Get Bill Committed Date");
	arrayCommand.push(command);
	
	//Get BillIdNo
	command = "CREATE OR REPLACE TEMPORARY TABLE STG.TMP_BillHdr AS " + linebreak 
		+ "SELECT DISTINCT" + linebreak 
		+ "    BH.OdsCustomerId" + linebreak 
		+ "    ,BH.BillIDNo" + linebreak 
		+ "    ,BH.CMT_HDR_IDNo" + linebreak 
		+ "    ,bhs.DateCommitted " + linebreak 
		+ "    ,BH.CreateDate" + linebreak 
		+ "    ,CASE WHEN BITAND(BH.Flags,4096) > 0 THEN 'UB-04'  " + linebreak
		+ "        ELSE 'CMS-1500'  END AS Form_Type" + linebreak 
		+ "    ,IFNULL(d.DX,'-1') AS DiagnosisCode" + linebreak 
		+ "    ,BH.CV_Type" + linebreak 
		+ "    ,C.Customer_Name" + linebreak
		+ "    ,BH.PvdZOS" + linebreak
		+ "    ,BH.TypeOfBill" + linebreak  
		+ "    ,BH.Flags" + linebreak  
		+ "    ,CASE WHEN BITAND(BH.Flags,524288) = 524288 THEN TRUE ELSE FALSE END AS eBill " + linebreak  
		+ "    ,BH.DateRcv" + linebreak  
		+ "FROM TABLE(" + sourceDatabaseName + ".dbo.if_BILL_HDR(" + OdsPostingGroupAuditId.toString() + ")) BH" + linebreak 
		+ "INNER JOIN " + sourceDatabaseName + ".adm.Customer C" + linebreak 
		+ "    ON C.Customer_Id = BH.OdsCustomerId" + linebreak 
		+ "LEFT OUTER JOIN STG.TMP_BillHistory bhs " + linebreak 
		+ "    ON BH.OdsCustomerId = bhs.OdsCustomerId " + linebreak 
		+ "    AND BH.BillIDNo = bhs.BillIDNo " + linebreak 
		+ "LEFT OUTER JOIN STG.TMP_Diagnosis d " + linebreak 
		+ "    ON BH.OdsCustomerId = d.OdsCustomerId" + linebreak 
		+ "    AND BH.BillIDNo = d.BillIDNo " + linebreak 
		+ "WHERE BH.CreateDate BETWEEN '" + startDate + "' AND '" + endDate + "'" + linebreak 
		+ "    AND BITAND(BH.Flags, 16) = 0;";
	arrayComment.push("--Get BillIdNo");
	arrayCommand.push(command);
	
	//Get VPN Data
	command = "CREATE OR REPLACE TEMPORARY TABLE STG.TMP_VPN AS " + linebreak 
	    + "SELECT DISTINCT" + linebreak 
		+ "    vbh.OdsCustomerId," + linebreak 
		+ "    vbh.BillIdNo," + linebreak 
		+ "    v.NetworkName" + linebreak 
		+ "FROM TABLE(" + sourceDatabaseName + ".dbo.if_Vpn_Billing_History(" + OdsPostingGroupAuditId.toString() + ")) vbh" + linebreak 
		+ "INNER JOIN TABLE(" + sourceDatabaseName + ".dbo.if_VPN(" + OdsPostingGroupAuditId.toString() + ")) v" + linebreak 
		+ "    ON vbh.OdsCustomerId = v.OdsCustomerId" + linebreak 
		+ "    AND vbh.VPNID = v.VPNID;";
	arrayComment.push("--Get VPN Data");
	arrayCommand.push(command);

	//Get the latest ProcCode Desc
	command = "CREATE OR REPLACE TEMPORARY TABLE STG.TMP_ProCodeDesc AS " + linebreak 
		+ "SELECT CP.OdsCustomerId" + linebreak 
		+ "    ,CP.PRC_CD" + linebreak 
		+ "    ,CP.PRC_DESC" + linebreak 
		+ "FROM TABLE(" + sourceDatabaseName + ".dbo.if_cpt_PRC_DICT(" + OdsPostingGroupAuditId.toString() + ")) CP" + linebreak 
		+ "INNER JOIN (" + linebreak 
		+ "    SELECT CP.OdsCustomerId" + linebreak 
		+ "    ,CP.PRC_CD" + linebreak 
		+ "    ,MAX(Startdate) Startdate" + linebreak 
		+ "	   FROM TABLE("+sourceDatabaseName+".dbo.if_cpt_PRC_DICT(" + OdsPostingGroupAuditId.toString() + ")) CP" + linebreak 
		+ "	   GROUP BY CP.OdsCustomerId, CP.PRC_CD" + linebreak
		+ ") X " + linebreak 
		+ "    ON X.OdsCustomerId = CP.OdsCustomerId" + linebreak 
		+ "    AND X.PRC_CD = CP.PRC_CD" + linebreak 
		+ "    AND X.Startdate = CP.Startdate;";
	arrayComment.push("--Get the latest ProcCode Desc");
	arrayCommand.push(command);

	//Get Provider Data into temp table
	command = "CREATE OR REPLACE TEMPORARY TABLE STG.TMP_Provider AS " + linebreak 
		+ "SELECT DISTINCT " + linebreak 
		+ "    OdsCustomerId" + linebreak 
		+ "	   ,PvdIDNo" + linebreak 
		+ "	   ,PvdTIN" + linebreak 
		+ "    ,PvdLastName" + linebreak 
		+ "    ,PvdFirstName" + linebreak 
		+ "    ,PvdGroup" + linebreak 
		+ "    ,PvdState" + linebreak 
		+ "    ,PvdSPC_List" + linebreak 
		+ "FROM TABLE(" + sourceDatabaseName + ".dbo.if_PROVIDER(" + OdsPostingGroupAuditId.toString() + ")) P;";
	arrayComment.push("--Get Provider Data into temp table");
	arrayCommand.push(command);

	//Get ICD Diagnosis Code
	command = "CREATE OR REPLACE TEMPORARY TABLE STG.TMP_IcdDiagnosisCodeDictionary AS " + linebreak 
		+ "SELECT D.OdsCustomerId" + linebreak 
		+ "    ,D.DiagnosisCode" + linebreak 
		+ "    ,D.IcdVersion" + linebreak 
		+ "    ,D.InjuryNatureId" + linebreak 
		+ "    ,D.Description" + linebreak 
		+ "FROM TABLE(" + sourceDatabaseName + ".dbo.if_IcdDiagnosisCodeDictionary(" + OdsPostingGroupAuditId.toString() + ")) D" + linebreak 
		+ "INNER JOIN (" + linebreak 
		+ "    SELECT OdsCustomerId" + linebreak 
		+ "        ,DiagnosisCode" + linebreak 
		+ "        ,IcdVersion" + linebreak 
		+ "        ,InjuryNatureId" + linebreak 
		+ "        ,MAX(EndDate) EndDate" + linebreak 
		+ "    FROM TABLE(" + sourceDatabaseName + ".dbo.if_IcdDiagnosisCodeDictionary(" + OdsPostingGroupAuditId.toString() + "))" + linebreak 
		+ "    GROUP BY 1, 2, 3, 4" + linebreak 	
		+ ") X " + linebreak 
		+ "    ON D.OdsCustomerId = X.OdsCustomerId" + linebreak 
		+ "    AND D.DiagnosisCode = X.DiagnosisCode" + linebreak 
		+ "    AND D.IcdVersion = X.IcdVersion" + linebreak 
		+ "    AND D.InjuryNatureId = X.InjuryNatureId" + linebreak 
		+ "    AND D.EndDate = X.EndDate;";
	arrayComment.push("--Get ICD Diagnosis Code");
	arrayCommand.push(command);

	//Get CMT DX
	command = "CREATE OR REPLACE TEMPORARY TABLE STG.TMP_CmtDx AS " + linebreak 
		+ "SELECT cdx.OdsCustomerId" + linebreak
		+ "    ,cdx.BILLIDNO" + linebreak
		+ "    ,cdx.dx" + linebreak
		+ "    ,cdx.IcdVersion" + linebreak
		+ "FROM TABLE(" + sourceDatabaseName + ".dbo.if_CMT_DX(" + OdsPostingGroupAuditId.toString() + ")) cdx;";
	arrayComment.push("--Get CMT DX");
	arrayCommand.push(command);

	//Get Bill DxCodeDescription and IcdVersion
	command = "CREATE OR REPLACE TEMPORARY TABLE STG.TMP_BillDx AS " + linebreak 
	    + "SELECT CDX.OdsCustomerId" + linebreak
		+ "    ,CDX.BILLIDNO" + linebreak
		+ "    ,CDX.dx" + linebreak
		+ "    ,CDX.IcdVersion" + linebreak
		+ "    ,IDX.Description AS DXCodeDescription" + linebreak
		+ "    ,I.Description AS DXMajorGroup" + linebreak
		+ "FROM STG.TMP_Diagnosis CDX" + linebreak 
		+ "INNER JOIN STG.TMP_IcdDiagnosisCodeDictionary IDX" + linebreak 
		+ "    ON CDX.OdsCustomerId = IDX.OdsCustomerId" + linebreak 
		+ "    AND CDX.Dx = IDX.DiagnosisCode" + linebreak 
		+ "    AND CDX.IcdVersion = IDX.IcdVersion" + linebreak
		+ "LEFT OUTER JOIN TABLE(" + sourceDatabaseName + ".dbo.if_InjuryNature(" + OdsPostingGroupAuditId.toString() + ")) I" + linebreak 
		+ "    ON IDX.OdsCustomerId = I.OdsCustomerId" + linebreak 
		+ "    AND IDX.InjuryNatureId = I.InjuryNatureId;"; 
	arrayComment.push("--Get Bill DxCodeDescription and IcdVersion");
	arrayCommand.push(command);

	//Get Modifier Description from ModifierDictionary
	command = "CREATE OR REPLACE TEMPORARY TABLE STG.TMP_ModifierDictionary AS " + linebreak
	    + "SELECT OdsCustomerId" + linebreak
		+ "    ,Modifier" + linebreak
		+ "    ,Description" + linebreak
		+ "FROM (" + linebreak
		+ "    SELECT OdsCustomerId" + linebreak
		+ "        ,Modifier" + linebreak
		+ "        ,Description" + linebreak
		+ "        ,ROW_NUMBER()OVER(PARTITION BY OdsCustomerId, Modifier " + linebreak
		+ "            ORDER BY StartDate) AS rnk" + linebreak
		+ "    FROM TABLE(" + sourceDatabaseName + ".dbo.if_ModifierDictionary(" + OdsPostingGroupAuditId.toString() + "))" + linebreak 
		+ ") " + linebreak
		+ "WHERE rnk = 1;";
	arrayComment.push("--Get Modifier Description from ModifierDictionary");
	arrayCommand.push(command);

	//Get ExpectedrecoverDate and Duration
	command = "CREATE OR REPLACE TEMPORARY TABLE STG.TMP_Erd AS " + linebreak 
		+ "SELECT DISTINCT OdsCustomerId" + linebreak
		+ "    ,CmtIDNo" + linebreak
		+ "    ,IFNULL(Duration, 0) * 7 AS ExpectedRecoveryDuration" + linebreak
		+ "FROM (" + linebreak
		+ "    SELECT cdx.OdsCustomerId" + linebreak
		+ "        ,CH.CmtIDNo" + linebreak
		+ "        ,cdx.BillIDNo" + linebreak
		+ "        ,dx.DiagnosisCode" + linebreak
		+ "        ,IFNULL(dx.Duration, 0) Duration" + linebreak
		+ "        ,I.InjuryNaturePriority" + linebreak
		+ "        ,ROW_NUMBER()OVER(PARTITION BY cdx.OdsCustomerId, ch.CmtIDNo " + linebreak
		+ "             ORDER BY IFNULL(dx.Duration,0) desc, InjuryNaturePriority desc) rnk " + linebreak
		+ "    FROM STG.TMP_CmtDx cdx  " + linebreak
		+ "    INNER JOIN STG.TMP_BillHdr BH" + linebreak
		+ "        ON BH.OdsCustomerID = cdx.OdsCustomerID" + linebreak
		+ "        AND BH.BillIDNo = cdx.BillIDNo" + linebreak
		+ "    INNER JOIN TABLE(" + sourceDatabaseName + ".dbo.if_CMT_HDR(" + OdsPostingGroupAuditId.toString() + ")) CH" + linebreak
		+ "        ON CH.OdsCustomerID = BH.OdsCustomerID " + linebreak
		+ "        AND BH.CMT_HDR_IDNo = CH.CMT_HDR_IDNo" + linebreak
		+ "    LEFT OUTER JOIN (" + linebreak
		+ "        SELECT " + linebreak
		+ "            OdsCustomerID" + linebreak
		+ "            ,ICD9 AS DiagnosisCode" + linebreak
		+ "            ,Duration" + linebreak
		+ "            ,9 AS IcdVersion" + linebreak
		+ "        FROM TABLE(" + sourceDatabaseName + ".dbo.if_cpt_DX_DICT(" + OdsPostingGroupAuditId.toString() + "))" + linebreak
		+ "        UNION ALL" + linebreak
		+ "        SELECT " + linebreak
		+ "            OdsCustomerID" + linebreak
		+ "            ,DiagnosisCode" + linebreak
		+ "            ,Duration" + linebreak
		+ "            ,10 AS IcdVersion" + linebreak
		+ "        FROM TABLE(" + sourceDatabaseName + ".dbo.if_Icd10DiagnosisVersion(" + OdsPostingGroupAuditId.toString() + "))" + linebreak
		+ "    )dx "
		+ "        ON  dx.OdsCustomerID = cdx.ODSCustomerID" + linebreak
		+ "        AND dx.DiagnosisCode = cdx.dx" + linebreak
		+ "        AND dx.IcdVersion = cdx.IcdVersion" + linebreak
		+ "    LEFT OUTER JOIN (" + linebreak
		+ "        SELECT OdsCustomerId" + linebreak
		+ "            ,DiagnosisCode" + linebreak
		+ "            ,IcdVersion" + linebreak
		+ "            ,InjuryNatureId" + linebreak
		+ "        FROM (" + linebreak
		+ "            SELECT OdsCustomerId" + linebreak
		+ "                ,DiagnosisCode" + linebreak
		+ "                ,IcdVersion" + linebreak
		+ "                ,InjuryNatureId" + linebreak
		+ "                ,ROW_NUMBER()OVER(PARTITION BY OdsCustomerId, DiagnosisCode, IcdVersion " + linebreak
		+ "                    ORDER BY EndDate DESC) rnk" + linebreak
		+ "            FROM TABLE(" + sourceDatabaseName + ".dbo.if_IcdDiagnosisCodeDictionary(" + OdsPostingGroupAuditId.toString() + "))" + linebreak
		+ "        ) X WHERE rnk = 1" + linebreak
		+ "    ) dict" + linebreak
		+ "        ON dx.OdsCustomerId = dict.OdsCustomerId" + linebreak
		+ "        AND dx.DiagnosisCode = dict.DiagnosisCode" + linebreak
		+ "        AND dx.IcdVersion = dict.IcdVersion" + linebreak
		+ "    LEFT OUTER JOIN TABLE(" + sourceDatabaseName + ".dbo.if_InjuryNature(" + OdsPostingGroupAuditId.toString() + ")) I " + linebreak
		+ "        ON dict.OdsCustomerId = I.OdsCustomerId" + linebreak
		+ "        AND dict.InjuryNatureId = I.InjuryNatureId" + linebreak
		+ ") X " + linebreak
		+ "WHERE rnk = 1;";
	arrayComment.push("--Get ExpectedrecoverDate and Duration");
	arrayCommand.push(command);

	//Get Max PrePpoBillInfo
	command = "CREATE OR REPLACE TEMPORARY TABLE STG.TMP_MaxPrePpoBillInfo AS " + linebreak 
        + "SELECT" + linebreak 
		+ "    P.OdsCustomerId" + linebreak
		+ "    ,P.billIDNo" + linebreak
		+ "    ,P.line_no"+ linebreak
		+ "    ,CASE WHEN P.PharmacyLine = 0 THEN 1 " + linebreak
		+ "        WHEN P.PharmacyLine = 1 THEN 2 " + linebreak
		+ "        END Line_type" + linebreak
		+ "    ,MAX(P.PrePPOBillInfoId) AS LatestPrePPOBillInfoId" + linebreak
		+ "FROM TABLE(" + sourceDatabaseName + ".dbo.if_PREPPOBILLINFO(" + OdsPostingGroupAuditId.toString() + ")) P" + linebreak
		+ "WHERE P.PharmacyLine = 0" + linebreak
		+ "GROUP BY 1, 2, 3, 4;";
	arrayComment.push("--Get Max PrePpoBillInfo");
	arrayCommand.push(command);

	//Get PrePpoBillInfoLine
	command = "CREATE OR REPLACE TEMPORARY TABLE STG.TMP_PrePpoBillInfoLine AS " + linebreak 
		+ "SELECT DISTINCT " + linebreak
		+ "    E.OdsCustomerId" + linebreak
		+ "    ,E.billIDNo " + linebreak
		+ "    ,E.line_no" + linebreak
		+ "    ,CASE WHEN E.Endnotes = '4' OR E.Endnotes LIKE '%,4,%' OR E.Endnotes LIKE '4,%' OR E.Endnotes LIKE '%,4' THEN 1" + linebreak
		+ "        ELSE 0 END AS DuplicateLine" + linebreak
		+ "FROM TABLE(" + sourceDatabaseName + ".dbo.if_PREPPOBILLINFO(" + OdsPostingGroupAuditId.toString() + ")) E" + linebreak
		+ "INNER JOIN STG.TMP_MaxPrePpoBillInfo P" + linebreak
		+ "    ON p.OdsCustomerId = E.OdsCustomerId" + linebreak
		+ "    AND p.LatestPrePPOBillInfoId = E.PrePPOBillInfoId" + linebreak
		+ "    AND p.billIDNo = E.billIDNo" + linebreak
		+ "    AND p.line_no = E.line_no" + linebreak
		+ "    AND p.Line_type = CASE WHEN E.PharmacyLine = 0 THEN 1 WHEN E.PharmacyLine = 1 THEN 2 END" + linebreak
		+ "INNER JOIN STG.TMP_BillHdr S" + linebreak
		+ "    ON S.OdsCustomerId = E.OdsCustomerId" + linebreak
		+ "    AND S.BillIdNo = E.billIDNo;";
	arrayComment.push("--Get PrePpoBillInfoLine");
	arrayCommand.push(command);

	//Get PrePpoBillInfo
	command = "CREATE OR REPLACE TEMPORARY TABLE STG.TMP_PrePpoBillInfo AS " + linebreak 
		+ "SELECT " + linebreak
		+ "    OdsCustomerId" + linebreak
		+ "    ,billIDNo" + linebreak
		+ "    ,SUM(DuplicateLine) AS DuplicateLineFlag" + linebreak
		+ "    ,COUNT(DISTINCT line_no) AS LineCount" + linebreak
		+ "FROM STG.TMP_PrePpoBillInfoLine" + linebreak 
		+ "GROUP BY OdsCustomerId" + linebreak
		+ "    ,billIDNo;";
	arrayComment.push("--Get PrePpoBillInfo");
	arrayCommand.push(command);

	//Get PPO received and return dates
	command = "CREATE OR REPLACE TEMPORARY TABLE STG.TMP_ProviderNetworkEventLog AS " + linebreak 
		+ "SELECT  OdsCustomerId " + linebreak
		+ "    ,BillIdNo" + linebreak
		+ "    ,MAX(CASE WHEN EventId = 10 THEN logDate ELSE NULL END) PPOReturnedDate" + linebreak
		+ "    ,MIN(CASE WHEN EventId = 11 THEN logDate ELSE NULL END) PPOReceivedDate" + linebreak
		+ "FROM TABLE(" + sourceDatabaseName + ".dbo.if_ProviderNetworkEventLog(" + OdsPostingGroupAuditId.toString() + "))" + linebreak
		+ "WHERE EventId IN (11, 10)" + linebreak
		+ "GROUP BY OdsCustomerId " + linebreak
		+ "    ,BillIdNo;";
	arrayComment.push("--Get PPO received and return dates");
	arrayCommand.push(command);

	//Get Mitchell Received Date
	command = "CREATE OR REPLACE TEMPORARY TABLE STG.TMP_MitchellReceivedDate AS " + linebreak 
		+ "SELECT DISTINCT OdsCustomerId " + linebreak
		+ "    ,BillIdNo" + linebreak
		+ "    ,CASE WHEN UDFIdNo = '-1' THEN UDFValueDate END AS MitchellReceivedDate" + linebreak
		+ "FROM TABLE(" + sourceDatabaseName + ".dbo.if_UDFBill(" + OdsPostingGroupAuditId.toString() + "))" + linebreak
		+ "WHERE UDFIdNo IN ('-1');";
	arrayComment.push("--Get Mitchell Received Date");
	arrayCommand.push(command);

	//Get Nurse Complete Dates
	command = "CREATE OR REPLACE TEMPORARY TABLE STG.TMP_NurseCompleteDate AS " + linebreak 
		+ "SELECT DISTINCT OdsCustomerId " + linebreak
		+ "    ,CmtIdNo" + linebreak
		+ "    ,CASE WHEN UDFIdNo = '-3' THEN UDFValueDate END AS FirstNurseCompleteDate" + linebreak
		+ "    ,CASE WHEN UDFIdNo = '-4' THEN UDFValueDate END AS SecondNurseCompleteDate" + linebreak
		+ "    ,CASE WHEN UDFIdNo = '-5' THEN UDFValueDate END AS ThirdNurseCompleteDate" + linebreak
		+ "FROM TABLE(" + sourceDatabaseName + ".dbo.if_UDFClaimant(" + OdsPostingGroupAuditId.toString() + "))" + linebreak
		+ "WHERE UDFIdNo IN ('-3', '-4', '-5')" + linebreak
		+ "    AND UDFValueDate != '1899-12-30 00:00:00.000';";
	arrayComment.push("--Get Nurse Complete Dates");
	arrayCommand.push(command);

	//Insert into Staging Table
    command = "INSERT INTO " + targetDatabaseName + ".STG.CLAIM_DETAIL_BILLLINE(" + linebreak 
		+ "    OdsCustomerId" + linebreak 
		+ "    ,CustomerName" + linebreak 
		+ "    ,CompanyId" + linebreak 
		+ "    ,Company" + linebreak 
		+ "    ,OfficeId" + linebreak 
		+ "    ,Office" + linebreak 
		+ "    ,SOJ" + linebreak 
		+ "    ,ClaimCoverageType" + linebreak 
		+ "    ,BillCoverageType" + linebreak 
		+ "    ,FormType" + linebreak 
		+ "    ,ClaimNo" + linebreak 
		+ "    ,ClaimantID" + linebreak 
		+ "    ,ProviderTIN" + linebreak 
		+ "    ,BillID" + linebreak 
		+ "    ,BillCreateDate" + linebreak 
		+ "    ,BillCommitDate" + linebreak 
		+ "    ,MitchellCompleteDate" + linebreak 
		+ "    ,ClaimCreateDate" + linebreak 
		+ "    ,ClaimDateofLoss" + linebreak 
		+ "    ,ExpectedRecoveryDate" + linebreak 
		+ "    ,BillLine" + linebreak
		+ "    ,LineType" + linebreak
		+ "    ,NDC" + linebreak
		+ "    ,DuplicateBillFlag" + linebreak
		+ "    ,DuplicateLineFlag" + linebreak
		+ "    ,ProcedureCode" + linebreak 
		+ "    ,ProcedureCodeDescription" + linebreak 
		+ "    ,ProcedureCodeMajorGroup" + linebreak 
		+ "    ,NetworkName" + linebreak 
        + "    ,CMTZIP" + linebreak 
        + "    ,LineStartDateOfService" + linebreak 
        + "    ,LineEndDateOfService" + linebreak 
        + "    ,PVDLastName" + linebreak 
        + "    ,PVDFirstName" + linebreak 
        + "    ,PVDGroup" + linebreak 
        + "    ,PVDZOS" + linebreak 
        + "    ,PVDState" + linebreak 
        + "    ,PVDSPC_List" + linebreak 
        + "    ,CMTDOB" + linebreak 
        + "    ,DX" + linebreak 
        + "    ,DXCodeDescription" + linebreak 
        + "    ,ICDVersion" + linebreak 
        + "    ,DXMajorGroup" + linebreak 
        + "    ,Modifier" + linebreak 
        + "    ,ModifierDescription" + linebreak 
        + "    ,TypeOfBill" + linebreak 
        + "    ,Description" + linebreak 
        + "    ,REVCode" + linebreak 
        + "    ,POSCode" + linebreak 
		+ "    ,AdjustorId" + linebreak 
		+ "    ,UserId" + linebreak 
		+ "    ,PPOReceivedDate" + linebreak 
		+ "    ,PPOReturnedDate" + linebreak 
		+ "    ,CarrierReceivedDate" + linebreak 
		+ "    ,MitchellReceivedDate" + linebreak 
		+ "    ,OverrideDateTime" + linebreak 
		+ "    ,FirstNurseCompleteDate" + linebreak 
		+ "    ,SecondNurseCompleteDate" + linebreak 
		+ "    ,ThirdNurseCompleteDate" + linebreak 
		+ "    ,ProviderCharges" + linebreak 
		+ "    ,TotalAllowed" + linebreak 
		+ "    ,TotalUnits" + linebreak 
		+ "    ,ExpectedRecoveryDuration" + linebreak 
		+ "    ,EBILL_FLAG" + linebreak
		+ "    ,ADJUSTOR_LAST_NAME" + linebreak
		+ "    ,ADJUSTOR_FIRST_NAME" + linebreak
		+ ")" + linebreak 			
		+ "SELECT" + linebreak 
		+ "    BH.OdsCustomerId" + linebreak 
		+ "    ,BH.Customer_Name" + linebreak 
		+ "    ,IFNULL(CO.CompanyID, -1)" + linebreak 
		+ "    ,IFNULL(CO.CompanyName, 'NA')" + linebreak
		+ "    ,IFNULL(O.OfficeID, -1)" + linebreak 
		+ "    ,IFNULL(O.OfcName, 'NA')" + linebreak
		+ "    ,CM.CmtStateOfJurisdiction" + linebreak 
		+ "    ,CL.CV_Code" + linebreak 
		+ "    ,BH.CV_type" + linebreak 
		+ "    ,BH.Form_Type" + linebreak 
		+ "    ,CL.ClaimNo" + linebreak 
		+ "    ,CM.CmtIDNo" + linebreak 
		+ "    ,Pvd.PvdTIN" + linebreak 
		+ "    ,BH.BillIDNo" + linebreak 
		+ "    ,bh.CreateDate" + linebreak 
		+ "    ,BH.DateCommitted" + linebreak 
		+ "    ,MCD.MitchellCmptDate" + linebreak 
		+ "    ,CL.CreateDate" + linebreak 
		+ "    ,CL.DateLoss" + linebreak 
		+ "    ,DATEADD(day, dx.ExpectedRecoveryDuration, CL.DateLoss) " + linebreak 
		+ "    ,B.LINE_NO" + linebreak 
		+ "    ,B.LineType" + linebreak 
		+ "    ,B.NDC" + linebreak 
		+ "    ,IFNULL(CASE WHEN P.DuplicateLineFlag = 0 THEN 0 " + linebreak
		+ "        WHEN P.DuplicateLineFlag > 0 AND  P.DuplicateLineFlag < P.LineCount THEN 1 " + linebreak
		+ "        WHEN  P.LineCount = P.DuplicateLineFlag THEN 2 END, 0)" + linebreak 
		+ "    ,IFNULL(M.DuplicateLine, 0)" + linebreak 
		+ "    ,B.PRC_CD" + linebreak 
		+ "    ,PRCT.PRC_DESC" + linebreak 
		+ "    ,PCG.MajorCategory" + linebreak 
		+ "    ,V.NetworkName" + linebreak 
		+ "    ,CM.CmtZip" + linebreak
		+ "    ,B.DT_SVC" + linebreak 
		+ "    ,B.EndDateOfService" + linebreak 
		+ "    ,Pvd.PvdLastName" + linebreak 
		+ "    ,Pvd.PvdFirstName" + linebreak 
		+ "    ,Pvd.PvdGroup" + linebreak 
		+ "    ,BH.PvdZos" + linebreak 
		+ "    ,Pvd.PvdState" + linebreak 
		+ "    ,Pvd.PvdSPC_List" + linebreak 
		+ "    ,CM.CmtDOB" + linebreak 
		+ "    ,BH.DiagnosisCode" + linebreak 
		+ "    ,BD.DXCodeDescription" + linebreak 
		+ "    ,BD.IcdVersion" + linebreak 
		+ "    ,BD.DXMajorGroup" + linebreak 
		+ "    ,B.TS_CD" + linebreak
		+ "    ,MD.Description" + linebreak
		+ "    ,BH.TypeOfBill" + linebreak
		+ "    ,UBT.Description" + linebreak
		+ "    ,CASE " + linebreak
		+ "        WHEN BITAND(BH.Flags, 4096) = 4096 THEN B.POS_RevCode" + linebreak
		+ "        ELSE ''" + linebreak
		+ "    END AS REVCode" + linebreak
		+ "    ,CASE " + linebreak
		+ "        WHEN BITAND(BH.Flags, 4096) <> 4096 THEN B.POS_RevCode" + linebreak
		+ "        ELSE ''" + linebreak
		+ "    END AS POSCode" + linebreak
		+ "    ,AD.lAdjIdNo" + linebreak
		+ "    ,BO.UserId" + linebreak
		+ "    ,PPO.PPOReceivedDate" + linebreak
		+ "    ,PPO.PPOReturnedDate" + linebreak
		+ "    ,BH.DateRcv" + linebreak
		+ "    ,MRD.MitchellReceivedDate" + linebreak
		+ "    ,BO.DateSaved" + linebreak
		+ "    ,NCD.FirstNurseCompleteDate" + linebreak
		+ "    ,NCD.SecondNurseCompleteDate" + linebreak
		+ "    ,NCD.ThirdNurseCompleteDate" + linebreak
		+ "    ,IFNULL(B.CHARGED, 0)" + linebreak 
		+ "    ,IFNULL(B.ALLOWED,0)" + linebreak 
		+ "    ,IFNULL(B.UNITS, 0)" + linebreak 
		+ "    ,dx.ExpectedRecoveryDuration" + linebreak 
		+ "    ,BH.eBill" + linebreak 
		+ "    ,AD.LASTNAME" + linebreak 
		+ "    ,AD.FIRSTNAME" + linebreak 
		+ "FROM STG.TMP_BillHdr BH" + linebreak 
		+ "INNER JOIN TABLE(" + sourceDatabaseName + ".dbo.if_CMT_HDR(" + OdsPostingGroupAuditId.toString() + ")) CH " + linebreak 
		+ "    ON BH.OdsCustomerId = CH.OdsCustomerId" + linebreak 
		+ "    AND BH.CMT_HDR_IDNo = CH.CMT_HDR_IDNo" + linebreak 
		+ "INNER JOIN TABLE(" + sourceDatabaseName + ".dbo.if_CLAIMANT(" + OdsPostingGroupAuditId.toString() + ")) CM " + linebreak 
		+ "    ON CH.OdsCustomerId = CM.OdsCustomerId" + linebreak 
		+ "    AND CH.CmtIDNo = CM.CmtIDNo " + linebreak 
		+ "INNER JOIN TABLE(" + sourceDatabaseName + ".dbo.if_CLAIMS(" + OdsPostingGroupAuditId.toString() + ")) CL " + linebreak 
		+ "    ON  CM.OdsCustomerId = CL.OdsCustomerId" + linebreak 
		+ "    AND CM.ClaimIDNo  = CL.ClaimIDNo" + linebreak 
		+ "    AND IFNULL(CL.ClaimNo, '-1') NOT LIKE '%TEST%'" + linebreak 
		+ "    AND (CL.OdsCustomerId NOT IN (70,71) OR CL.Status <> 'C')" + linebreak 
		+ "INNER JOIN TABLE(" + sourceDatabaseName + ".dbo.if_prf_COMPANY(" + OdsPostingGroupAuditId.toString() + ")) CO " + linebreak 
		+ "    ON CO.OdsCustomerId = CL.OdsCustomerId" + linebreak 
		+ "    AND CO.CompanyID = CL.CompanyID" + linebreak 
		+ "    AND IFNULL(CO.CompanyName, '-1') NOT LIKE '%TEST%'" + linebreak 
		+ "    AND IFNULL(CO.CompanyName, '-1') NOT LIKE '%TRAIN%'" + linebreak 
		+ "INNER JOIN TABLE(" + sourceDatabaseName + ".dbo.if_prf_Office(" + OdsPostingGroupAuditId.toString() + ")) O" + linebreak 
		+ "    ON O.OdsCustomerId = CL.OdsCustomerId" + linebreak 
		+ "    AND O.OfficeID = CL.OfficeIndex" + linebreak 
		+ "    AND IFNULL(O.OfcName, '-1') NOT LIKE '%TEST%'" + linebreak 
		+ "    AND IFNULL(O.OfcName, '-1') NOT LIKE '%TRAIN%'" + linebreak 
		+ "INNER JOIN (SELECT" + linebreak
		+ "				 OdsCustomerId " + linebreak
		+ "				,BillIDNo" + linebreak
		+ "				,LINE_NO_DISP" + linebreak
		+ "				,LINE_NO" + linebreak
		+ "				,PRC_CD" + linebreak
		+ "				,'' AS NDC" + linebreak
		+ "				,TS_CD" + linebreak
		+ "				,DT_SVC" + linebreak
		+ "				,EndDateOfService" + linebreak
		+ "				,POS_RevCode" + linebreak
		+ "				,IFNULL(CHARGED, 0) CHARGED" + linebreak
		+ "				,IFNULL(PreApportionedAmount ,ALLOWED) ALLOWED" + linebreak 
		+ "				,IFNULL(UNITS, 0) UNITS" + linebreak
		+ "				,1 AS LineType" + linebreak
		+ "			FROM TABLE(" + sourceDatabaseName + ".dbo.if_BILLS(" + OdsPostingGroupAuditId.toString() + "))" + linebreak
		+ "			WHERE CHARGED IS NOT NULL" + linebreak
		+ "			UNION " + linebreak
		+ "			SELECT " + linebreak
		+ "				 OdsCustomerId" + linebreak
		+ "				,BillIDNo" + linebreak
		+ "				,LINE_NO_DISP" + linebreak
		+ "				,LINE_NO" + linebreak
		+ "				,'' AS PRC_CD" + linebreak
		+ "				,NDC" + linebreak
		+ "				,'' AS TS_CD" + linebreak
		+ "				,DateOfService" + linebreak
		+ "				,EndDateOfService" + linebreak
		+ "				,POS_RevCode" + linebreak
		+ "				,IFNULL(CHARGED, 0) CHARGED" + linebreak
		+ "				,IFNULL(PreApportionedAmount ,ALLOWED) ALLOWED" + linebreak 
		+ "				,IFNULL(UNITS, 0) UNITS" + linebreak
		+ "				,2 AS LineType" + linebreak
		+ "			FROM  TABLE(" + sourceDatabaseName + ".dbo.if_BILLS_Pharm(" + OdsPostingGroupAuditId.toString() + "))" + linebreak
		+ "			WHERE CHARGED IS NOT NULL" + linebreak
		+ "			) AS B" + linebreak
		+ "    ON BH.OdsCustomerId = B.OdsCustomerId" + linebreak
		+ "    AND BH.BillIDNo = B.BillIDNo" + linebreak
		+ "    AND B.CHARGED IS NOT NULL" + linebreak
		+ "LEFT OUTER JOIN TABLE(" + sourceDatabaseName + ".dbo.if_BillsOverride(" + OdsPostingGroupAuditId.toString() + ")) BO" + linebreak
		+ "    ON BO.OdsCustomerId = B.OdsCustomerId" + linebreak
		+ "    AND BO.BillIDNo = B.BillIDNo" + linebreak
		+ "    AND BO.Line_NO = B.LINE_NO" + linebreak
		+ "LEFT OUTER JOIN TABLE(" + sourceDatabaseName + ".dbo.if_Adjustor(" + OdsPostingGroupAuditId.toString() + ")) AD" + linebreak
		+ "    ON AD.OdsCustomerId = BO.OdsCustomerId" + linebreak
		+ "    AND AD.UserId = BO.UserId" + linebreak
		+ "LEFT OUTER JOIN STG.TMP_ProviderNetworkEventLog PPO" + linebreak
		+ "    ON BH.OdsCustomerId = PPO.OdsCustomerId" + linebreak
		+ "    AND BH.BillIDNo = PPO.BillIDNo" + linebreak
		+ "LEFT OUTER JOIN STG.TMP_MitchellReceivedDate MRD" + linebreak
		+ "    ON BH.OdsCustomerId = MRD.OdsCustomerId" + linebreak
		+ "    AND BH.BillIDNo = MRD.BillIDNo" + linebreak 
		+ "LEFT OUTER JOIN STG.TMP_NurseCompleteDate NCD" + linebreak
		+ "    ON CM.OdsCustomerId = NCD.OdsCustomerId" + linebreak
		+ "    AND CM.CmtIDNo = NCD.CmtIDNo" + linebreak 
		+ "LEFT OUTER JOIN STG.TMP_ModifierDictionary MD" + linebreak
		+ "    ON B.OdsCustomerId = MD.OdsCustomerId" + linebreak
		+ "    AND B.TS_CD = MD.Modifier" + linebreak
		+ "LEFT OUTER JOIN TABLE(" + sourceDatabaseName + ".dbo.if_UB_BillType(" + OdsPostingGroupAuditId.toString() + ")) UBT" + linebreak
		+ "    ON BH.OdsCustomerId = UBT.OdsCustomerId" + linebreak 
		+ "    AND BH.TypeOfBill = UBT.TOB" + linebreak 
		+ "LEFT OUTER JOIN STG.TMP_VPN V" + linebreak
		+ "    ON BH.OdsCustomerId = V.OdsCustomerId" + linebreak 
		+ "    AND BH.BillIDNo = V.BillIDNo" + linebreak 
		+ "LEFT OUTER JOIN STG.TMP_BillDx BD" + linebreak
		+ "    ON BH.OdsCustomerId = BD.OdsCustomerId" + linebreak 
		+ "    AND BH.BillIdNo = BD.BillIdNo" + linebreak 
		+ "LEFT OUTER JOIN STG.TMP_MitchellCompleteDateClaimants MCD" + linebreak 
		+ "    ON CM.OdsCustomerId = MCD.OdsCustomerId" + linebreak 
		+ "    AND CM.CmtIDNo = MCD.CmtIDNo" + linebreak 
		+ "LEFT OUTER JOIN TABLE(" + sourceDatabaseName + ".dbo.if_ProcedureCodeGroup(" + OdsPostingGroupAuditId.toString() + ")) PCG" + linebreak 
		+ "    ON PCG.ProcedureCode = B.PRC_CD" + linebreak 
		+ "    AND PCG.OdsCustomerId = B.OdsCustomerId	" + linebreak 
		+ "LEFT OUTER JOIN STG.TMP_ProCodeDesc PRCT" + linebreak 
		+ "    ON PRCT.PRC_CD = B.PRC_CD" + linebreak 
		+ "    AND PRCT.OdsCustomerId = B.OdsCustomerId" + linebreak 
		+ "LEFT OUTER JOIN STG.TMP_Provider Pvd" + linebreak 
		+ "    ON Pvd.OdsCustomerId = CH.OdsCustomerId" + linebreak 
		+ "    AND Pvd.PvdIDNo = CH.PvdIDNo " + linebreak 
		+ "LEFT OUTER JOIN STG.TMP_Erd dx" + linebreak 
		+ "    ON dx.OdsCustomerID = CM.ODSCustomerID" + linebreak 
		+ "    AND dx.CmtIDNo = CM.CmtIDNo" + linebreak
		+ "LEFT OUTER JOIN STG.TMP_PrePPOBillInfoLine M" + linebreak
		+ "    ON B.OdsCustomerId = M.OdsCustomerId" + linebreak
		+ "    AND B.BillIdNo = M.billIDNo" + linebreak
		+ "    AND B.LINE_NO = M.line_no" + linebreak
		+ "LEFT OUTER JOIN STG.TMP_PrePPOBillInfo P" + linebreak
		+ "    ON BH.OdsCustomerId = P.OdsCustomerId" + linebreak
		+ "    AND BH.BillIdNo = P.billIDNo;";
	arrayComment.push("--Insert into Staging Table");
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
    