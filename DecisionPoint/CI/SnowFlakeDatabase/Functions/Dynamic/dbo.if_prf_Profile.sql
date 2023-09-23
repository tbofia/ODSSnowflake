CREATE OR REPLACE FUNCTION dbo.if_prf_Profile(
		if_OdsPostingGroupAuditId INT
)
RETURNS TABLE  (
		 OdsPostingGroupAuditId NUMBER(10,0)
		,OdsCustomerId NUMBER(10,0)
		,OdsCreateDate DATETIME
		,OdsSnapshotDate DATETIME
		,OdsRowIsCurrent INT
		,OdsHashbytesValue BINARY(8000)
		,DmlOperation VARCHAR(1)
		,ProfileId NUMBER(10,0)
		,OfficeId NUMBER(10,0)
		,CoverageId VARCHAR(2)
		,StateId VARCHAR(2)
		,AnHeader VARCHAR
		,AnFooter VARCHAR
		,ExHeader VARCHAR
		,ExFooter VARCHAR
		,AnalystEdits NUMBER(19,0)
		,DxEdits NUMBER(10,0)
		,DxNonTraumaDays NUMBER(10,0)
		,DxNonSpecDays NUMBER(10,0)
		,PrintCopies NUMBER(10,0)
		,NewPvdState VARCHAR(2)
		,bDuration NUMBER(5,0)
		,bLimits NUMBER(5,0)
		,iDurPct NUMBER(5,0)
		,iLimitPct NUMBER(5,0)
		,PolicyLimit NUMBER(19,4)
		,CoPayPercent NUMBER(10,0)
		,CoPayMax NUMBER(19,4)
		,Deductible NUMBER(19,4)
		,PolicyWarn NUMBER(5,0)
		,PolicyWarnPerc NUMBER(10,0)
		,FeeSchedules NUMBER(10,0)
		,DefaultProfile NUMBER(5,0)
		,FeeAncillaryPct NUMBER(5,0)
		,iGapdol NUMBER(5,0)
		,iGapTreatmnt NUMBER(5,0)
		,bGapTreatmnt NUMBER(5,0)
		,bGapdol NUMBER(5,0)
		,bPrintAdjustor NUMBER(5,0)
		,sPrinterName VARCHAR(50)
		,ErEdits NUMBER(10,0)
		,ErAllowedDays NUMBER(10,0)
		,UcrFsRules NUMBER(10,0)
		,LogoIdNo NUMBER(10,0)
		,LogoJustify NUMBER(5,0)
		,BillLine VARCHAR(50)
		,Version NUMBER(5,0)
		,ClaimDeductible NUMBER(5,0)
		,IncludeCommitted NUMBER(5,0)
		,FLMedicarePercent NUMBER(5,0)
		,UseLevelOfServiceUrl NUMBER(5,0)
		,LevelOfServiceURL VARCHAR(250)
		,CCIPrimary NUMBER(5,0)
		,CCISecondary NUMBER(5,0)
		,CCIMutuallyExclusive NUMBER(5,0)
		,CCIComprehensiveComponent NUMBER(5,0)
		,PayDRGAllowance NUMBER(5,0)
		,FLHospEmPriceOn NUMBER(5,0)
		,EnableBillRelease NUMBER(5,0)
		,DisableSubmitBill NUMBER(5,0)
		,MaxPaymentsPerBill NUMBER(5,0)
		,NoOfPmtPerBill NUMBER(10,0)
		,DefaultDueDate NUMBER(5,0)
		,CheckForNJCarePaths NUMBER(5,0)
		,NJCarePathPercentFS NUMBER(5,0)
		,ApplyEndnoteForNJCarePaths NUMBER(5,0)
		,FLMedicarePercent2008 NUMBER(5,0)
		,RequireEndnoteDuringOverride NUMBER(5,0)
		,StorePerUnitFSandUCR NUMBER(5,0)
		,UseProviderNetworkEnrollment NUMBER(5,0)
		,UseASCRule NUMBER(5,0)
		,AsstCoSurgeonEligible NUMBER(5,0)
		,LastChangedOn DATETIME
		,IsNJPhysMedCapAfterCTG NUMBER(5,0)
		,IsEligibleAmtFeeBased NUMBER(5,0)
		,HideClaimTreeTotalsGrid NUMBER(5,0)
		,SortBillsBy NUMBER(5,0)
		,SortBillsByOrder NUMBER(5,0)
		,ApplyNJEmergencyRoomBenchmarkFee NUMBER(5,0)
		,AllowIcd10ForNJCarePaths NUMBER(5,0)
		,EnableOverrideDeductible BOOLEAN
		,AnalyzeDiagnosisPointers BOOLEAN
		,MedicareFeePercent NUMBER(5,0)
		,EnableSupplementalNdcData BOOLEAN
		,ApplyOriginalNdcAwp BOOLEAN
		,NdcAwpNotAvailable NUMBER(3,0)
		,PayEapgAllowance NUMBER(5,0)
		,MedicareInpatientApcEnabled BOOLEAN
		,MedicareOutpatientAscEnabled BOOLEAN
		,MedicareAscEnabled BOOLEAN
		,UseMedicareInpatientApcFee BOOLEAN
		,MedicareInpatientDrgEnabled BOOLEAN
		,MedicareInpatientDrgPricingType NUMBER(5,0)
		,MedicarePhysicianEnabled BOOLEAN
		,MedicareAmbulanceEnabled BOOLEAN
		,MedicareDmeposEnabled BOOLEAN
		,MedicareAspDrugAndClinicalEnabled BOOLEAN
		,MedicareInpatientPricingType NUMBER(5,0)
		,MedicareOutpatientPricingRulesEnabled BOOLEAN
		,MedicareAscPricingRulesEnabled BOOLEAN
		,NjUseAdmitTypeEnabled BOOLEAN
		,MedicareClinicalLabEnabled BOOLEAN
		,MedicareInpatientEnabled BOOLEAN
		,MedicareOutpatientApcEnabled BOOLEAN
		,MedicareAspDrugEnabled BOOLEAN
		,ShowAllocationsOnEob BOOLEAN
		,EmergencyCarePricingRuleId NUMBER(3,0)
		,OutOfStatePricingEffectiveDateId NUMBER(3,0)
		,PreAllocation BOOLEAN
		,AssistantCoSurgeonModifiers NUMBER(5,0)
		,AssistantSurgeryModifierNotMedicallyNecessary NUMBER(5,0)
		,AssistantSurgeryModifierRequireAdditionalDocument NUMBER(5,0)
		,CoSurgeryModifierNotMedicallyNecessary NUMBER(5,0)
		,CoSurgeryModifierRequireAdditionalDocument NUMBER(5,0)
		,DxNoDiagnosisDays NUMBER(10,0)
		,ModifierExempted BOOLEAN )
AS
$$
SELECT t.OdsPostingGroupAuditId
		,t.OdsCustomerId
		,t.OdsCreateDate
		,t.OdsSnapshotDate
		,t.OdsRowIsCurrent
		,t.OdsHashbytesValue
		,t.DmlOperation
		,t.ProfileId
		,t.OfficeId
		,t.CoverageId
		,t.StateId
		,t.AnHeader
		,t.AnFooter
		,t.ExHeader
		,t.ExFooter
		,t.AnalystEdits
		,t.DxEdits
		,t.DxNonTraumaDays
		,t.DxNonSpecDays
		,t.PrintCopies
		,t.NewPvdState
		,t.bDuration
		,t.bLimits
		,t.iDurPct
		,t.iLimitPct
		,t.PolicyLimit
		,t.CoPayPercent
		,t.CoPayMax
		,t.Deductible
		,t.PolicyWarn
		,t.PolicyWarnPerc
		,t.FeeSchedules
		,t.DefaultProfile
		,t.FeeAncillaryPct
		,t.iGapdol
		,t.iGapTreatmnt
		,t.bGapTreatmnt
		,t.bGapdol
		,t.bPrintAdjustor
		,t.sPrinterName
		,t.ErEdits
		,t.ErAllowedDays
		,t.UcrFsRules
		,t.LogoIdNo
		,t.LogoJustify
		,t.BillLine
		,t.Version
		,t.ClaimDeductible
		,t.IncludeCommitted
		,t.FLMedicarePercent
		,t.UseLevelOfServiceUrl
		,t.LevelOfServiceURL
		,t.CCIPrimary
		,t.CCISecondary
		,t.CCIMutuallyExclusive
		,t.CCIComprehensiveComponent
		,t.PayDRGAllowance
		,t.FLHospEmPriceOn
		,t.EnableBillRelease
		,t.DisableSubmitBill
		,t.MaxPaymentsPerBill
		,t.NoOfPmtPerBill
		,t.DefaultDueDate
		,t.CheckForNJCarePaths
		,t.NJCarePathPercentFS
		,t.ApplyEndnoteForNJCarePaths
		,t.FLMedicarePercent2008
		,t.RequireEndnoteDuringOverride
		,t.StorePerUnitFSandUCR
		,t.UseProviderNetworkEnrollment
		,t.UseASCRule
		,t.AsstCoSurgeonEligible
		,t.LastChangedOn
		,t.IsNJPhysMedCapAfterCTG
		,t.IsEligibleAmtFeeBased
		,t.HideClaimTreeTotalsGrid
		,t.SortBillsBy
		,t.SortBillsByOrder
		,t.ApplyNJEmergencyRoomBenchmarkFee
		,t.AllowIcd10ForNJCarePaths
		,t.EnableOverrideDeductible
		,t.AnalyzeDiagnosisPointers
		,t.MedicareFeePercent
		,t.EnableSupplementalNdcData
		,t.ApplyOriginalNdcAwp
		,t.NdcAwpNotAvailable
		,t.PayEapgAllowance
		,t.MedicareInpatientApcEnabled
		,t.MedicareOutpatientAscEnabled
		,t.MedicareAscEnabled
		,t.UseMedicareInpatientApcFee
		,t.MedicareInpatientDrgEnabled
		,t.MedicareInpatientDrgPricingType
		,t.MedicarePhysicianEnabled
		,t.MedicareAmbulanceEnabled
		,t.MedicareDmeposEnabled
		,t.MedicareAspDrugAndClinicalEnabled
		,t.MedicareInpatientPricingType
		,t.MedicareOutpatientPricingRulesEnabled
		,t.MedicareAscPricingRulesEnabled
		,t.NjUseAdmitTypeEnabled
		,t.MedicareClinicalLabEnabled
		,t.MedicareInpatientEnabled
		,t.MedicareOutpatientApcEnabled
		,t.MedicareAspDrugEnabled
		,t.ShowAllocationsOnEob
		,t.EmergencyCarePricingRuleId
		,t.OutOfStatePricingEffectiveDateId
		,t.PreAllocation
		,t.AssistantCoSurgeonModifiers
		,t.AssistantSurgeryModifierNotMedicallyNecessary
		,t.AssistantSurgeryModifierRequireAdditionalDocument
		,t.CoSurgeryModifierNotMedicallyNecessary
		,t.CoSurgeryModifierRequireAdditionalDocument
		,t.DxNoDiagnosisDays
		,t.ModifierExempted
FROM src.prf_Profile t
INNER JOIN (
	SELECT 
		OdsCustomerId,
		ProfileId,
		MAX(OdsPostingGroupAuditId) AS OdsPostingGroupAuditId
	FROM src.prf_Profile
	WHERE OdsPostingGroupAuditId <= if_OdsPostingGroupAuditId
	GROUP BY OdsCustomerId,
		ProfileId) s
ON t.OdsPostingGroupAuditId = s.OdsPostingGroupAuditId
	AND t.OdsCustomerId = s.OdsCustomerId
	AND t.ProfileId = s.ProfileId
WHERE t.DmlOperation <> 'D'

$$;


