CREATE OR REPLACE TABLE stg.prf_Profile (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , ProfileId NUMBER(10, 0) NOT NULL
	 , OfficeId NUMBER(10, 0) NULL
	 , CoverageId VARCHAR(2) NULL
	 , StateId VARCHAR(2) NULL
	 , AnHeader VARCHAR NULL
	 , AnFooter VARCHAR NULL
	 , ExHeader VARCHAR NULL
	 , ExFooter VARCHAR NULL
	 , AnalystEdits NUMBER(19, 0) NULL
	 , DxEdits NUMBER(10, 0) NULL
	 , DxNonTraumaDays NUMBER(10, 0) NULL
	 , DxNonSpecDays NUMBER(10, 0) NULL
	 , PrintCopies NUMBER(10, 0) NULL
	 , NewPvdState VARCHAR(2) NULL
	 , bDuration NUMBER(5, 0) NULL
	 , bLimits NUMBER(5, 0) NULL
	 , iDurPct NUMBER(5, 0) NULL
	 , iLimitPct NUMBER(5, 0) NULL
	 , PolicyLimit NUMBER(19, 4) NULL
	 , CoPayPercent NUMBER(10, 0) NULL
	 , CoPayMax NUMBER(19, 4) NULL
	 , Deductible NUMBER(19, 4) NULL
	 , PolicyWarn NUMBER(5, 0) NULL
	 , PolicyWarnPerc NUMBER(10, 0) NULL
	 , FeeSchedules NUMBER(10, 0) NULL
	 , DefaultProfile NUMBER(5, 0) NULL
	 , FeeAncillaryPct NUMBER(5, 0) NULL
	 , iGapdol NUMBER(5, 0) NULL
	 , iGapTreatmnt NUMBER(5, 0) NULL
	 , bGapTreatmnt NUMBER(5, 0) NULL
	 , bGapdol NUMBER(5, 0) NULL
	 , bPrintAdjustor NUMBER(5, 0) NULL
	 , sPrinterName VARCHAR(50) NULL
	 , ErEdits NUMBER(10, 0) NULL
	 , ErAllowedDays NUMBER(10, 0) NULL
	 , UcrFsRules NUMBER(10, 0) NULL
	 , LogoIdNo NUMBER(10, 0) NULL
	 , LogoJustify NUMBER(5, 0) NULL
	 , BillLine VARCHAR(50) NULL
	 , Version NUMBER(5, 0) NULL
	 , ClaimDeductible NUMBER(5, 0) NULL
	 , IncludeCommitted NUMBER(5, 0) NULL
	 , FLMedicarePercent NUMBER(5, 0) NULL
	 , UseLevelOfServiceUrl NUMBER(5, 0) NULL
	 , LevelOfServiceURL VARCHAR(250) NULL
	 , CCIPrimary NUMBER(5, 0) NULL
	 , CCISecondary NUMBER(5, 0) NULL
	 , CCIMutuallyExclusive NUMBER(5, 0) NULL
	 , CCIComprehensiveComponent NUMBER(5, 0) NULL
	 , PayDRGAllowance NUMBER(5, 0) NULL
	 , FLHospEmPriceOn NUMBER(5, 0) NULL
	 , EnableBillRelease NUMBER(5, 0) NULL
	 , DisableSubmitBill NUMBER(5, 0) NULL
	 , MaxPaymentsPerBill NUMBER(5, 0) NULL
	 , NoOfPmtPerBill NUMBER(10, 0) NULL
	 , DefaultDueDate NUMBER(5, 0) NULL
	 , CheckForNJCarePaths NUMBER(5, 0) NULL
	 , NJCarePathPercentFS NUMBER(5, 0) NULL
	 , ApplyEndnoteForNJCarePaths NUMBER(5, 0) NULL
	 , FLMedicarePercent2008 NUMBER(5, 0) NULL
	 , RequireEndnoteDuringOverride NUMBER(5, 0) NULL
	 , StorePerUnitFSandUCR NUMBER(5, 0) NULL
	 , UseProviderNetworkEnrollment NUMBER(5, 0) NULL
	 , UseASCRule NUMBER(5, 0) NULL
	 , AsstCoSurgeonEligible NUMBER(5, 0) NULL
	 , LastChangedOn DATETIME NULL
	 , IsNJPhysMedCapAfterCTG NUMBER(5, 0) NULL
	 , IsEligibleAmtFeeBased NUMBER(5, 0) NULL
	 , HideClaimTreeTotalsGrid NUMBER(5, 0) NULL
	 , SortBillsBy NUMBER(5, 0) NULL
	 , SortBillsByOrder NUMBER(5, 0) NULL
	 , ApplyNJEmergencyRoomBenchmarkFee NUMBER(5, 0) NULL
	 , AllowIcd10ForNJCarePaths NUMBER(5, 0) NULL
	 , EnableOverrideDeductible BOOLEAN NULL
	 , AnalyzeDiagnosisPointers BOOLEAN NULL
	 , MedicareFeePercent NUMBER(5, 0) NULL
	 , EnableSupplementalNdcData BOOLEAN NULL
	 , ApplyOriginalNdcAwp BOOLEAN NULL
	 , NdcAwpNotAvailable NUMBER(3, 0) NULL
	 , PayEapgAllowance NUMBER(5, 0) NULL
	 , MedicareInpatientApcEnabled BOOLEAN NULL
	 , MedicareOutpatientAscEnabled BOOLEAN NULL
	 , MedicareAscEnabled BOOLEAN NULL
	 , UseMedicareInpatientApcFee BOOLEAN NULL
	 , MedicareInpatientDrgEnabled BOOLEAN NULL
	 , MedicareInpatientDrgPricingType NUMBER(5, 0) NULL
	 , MedicarePhysicianEnabled BOOLEAN NULL
	 , MedicareAmbulanceEnabled BOOLEAN NULL
	 , MedicareDmeposEnabled BOOLEAN NULL
	 , MedicareAspDrugAndClinicalEnabled BOOLEAN NULL
	 , MedicareInpatientPricingType NUMBER(5, 0) NULL
	 , MedicareOutpatientPricingRulesEnabled BOOLEAN NULL
	 , MedicareAscPricingRulesEnabled BOOLEAN NULL
	 , NjUseAdmitTypeEnabled BOOLEAN NULL
	 , MedicareClinicalLabEnabled BOOLEAN NULL
	 , MedicareInpatientEnabled BOOLEAN NULL
	 , MedicareOutpatientApcEnabled BOOLEAN NULL
	 , MedicareAspDrugEnabled BOOLEAN NULL
	 , ShowAllocationsOnEob BOOLEAN NULL
	 , EmergencyCarePricingRuleId NUMBER(3, 0) NULL
	 , OutOfStatePricingEffectiveDateId NUMBER(3, 0) NULL
	 , PreAllocation BOOLEAN NULL
	 , AssistantCoSurgeonModifiers NUMBER(5, 0) NULL
	 , AssistantSurgeryModifierNotMedicallyNecessary NUMBER(5, 0) NULL
	 , AssistantSurgeryModifierRequireAdditionalDocument NUMBER(5, 0) NULL
	 , CoSurgeryModifierNotMedicallyNecessary NUMBER(5, 0) NULL
	 , CoSurgeryModifierRequireAdditionalDocument NUMBER(5, 0) NULL
	 , DxNoDiagnosisDays NUMBER(10, 0) NULL
	 , ModifierExempted BOOLEAN NULL
);

