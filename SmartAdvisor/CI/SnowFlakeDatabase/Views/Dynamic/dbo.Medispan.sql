CREATE OR REPLACE  VIEW dbo.Medispan
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,NDC
	,DEA
	,Name1
	,Name2
	,Name3
	,Strength
	,Unit
	,Pkg
	,Factor
	,GenericDrug
	,Desicode
	,Rxotc
	,GPI
	,Awp1
	,Awp0
	,Awp2
	,EffectiveDt2
	,EffectiveDt1
	,EffectiveDt0
	,FDAEquivalence
	,NDCFormat
	,RestrictDrugs
	,GPPC
	,Status
	,UpdateDate
	,AAWP
	,GAWP
	,RepackagedCode
FROM src.Medispan
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';



