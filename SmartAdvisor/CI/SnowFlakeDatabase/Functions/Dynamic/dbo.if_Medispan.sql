CREATE OR REPLACE FUNCTION dbo.if_Medispan(
		IF_ODSPOSTINGGROUPAUDITID INT
)
RETURNS TABLE  (
 OdsPostingGroupAuditId NUMBER(10,0)
	 , OdsCustomerId NUMBER(10,0)
	 , OdsCreateDate DATETIME
	 , OdsSnapshotDate DATETIME
	 , OdsRowIsCurrent INT
	 , OdsHashbytesValue BINARY(8000)
	 , DmlOperation VARCHAR(1)
	 , NDC VARCHAR (11)
	 , DEA VARCHAR (5)
	 , Name1 VARCHAR (25)
	 , Name2 VARCHAR (4) 
	 , Name3 VARCHAR (11) 
	 , Strength NUMBER (10,0) 
	 , Unit NUMBER (10,0) 
	 , Pkg VARCHAR (2) 
	 , Factor NUMBER (5,0) 
	 , GenericDrug VARCHAR (1) 
	 , Desicode VARCHAR (1) 
	 , Rxotc VARCHAR (1) 
	 , GPI VARCHAR (14) 
	 , Awp1 NUMBER (10,0) 
	 , Awp0 NUMBER (10,0) 
	 , Awp2 NUMBER (10,0) 
	 , EffectiveDt2 DATETIME 
	 , EffectiveDt1 DATETIME
	 , EffectiveDt0 DATETIME
	 , FDAEquivalence VARCHAR (3)
	 , NDCFormat VARCHAR (1)
	 , RestrictDrugs VARCHAR (1)
	 , GPPC VARCHAR (8)
	 , Status VARCHAR (1)
	 , UpdateDate DATETIME
	 , AAWP NUMBER (10,0)
	 , GAWP NUMBER (10,0)
	 , RepackagedCode VARCHAR (2))
AS
$$
SELECT 
	 T.OdsPostingGroupAuditId
	,T.OdsCustomerId
	,T.OdsCreateDate
	,T.OdsSnapshotDate
	,T.OdsRowIsCurrent
	,T.OdsHashbytesValue
	,T.DmlOperation
	,T.NDC
	,T.DEA
	,T.Name1
	,T.Name2
	,T.Name3
	,T.Strength
	,T.Unit
	,T.Pkg
	,T.Factor
	,T.GenericDrug
	,T.Desicode
	,T.Rxotc
	,T.GPI
	,T.Awp1
	,T.Awp0
	,T.Awp2
	,T.EffectiveDt2
	,T.EffectiveDt1
	,T.EffectiveDt0
	,T.FDAEquivalence
	,T.NDCFormat
	,T.RestrictDrugs
	,T.GPPC
	,T.Status
	,T.UpdateDate
	,T.AAWP
	,T.GAWP
	,T.RepackagedCode
FROM src.Medispan T
INNER JOIN (
	SELECT 
		ODSCUSTOMERID,
		NDC,
		MAX(ODSPOSTINGGROUPAUDITID) AS ODSPOSTINGGROUPAUDITID
	FROM src.Medispan
	WHERE ODSPOSTINGGROUPAUDITID <= IF_ODSPOSTINGGROUPAUDITID
	GROUP BY ODSCUSTOMERID,
		NDC) S
ON T.ODSPOSTINGGROUPAUDITID = S.ODSPOSTINGGROUPAUDITID
	AND T.ODSCUSTOMERID = S.ODSCUSTOMERID
	AND T.NDC = S.NDC
WHERE T.DMLOPERATION <> 'D'

$$;


