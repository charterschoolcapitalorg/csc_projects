public class calc_AZ_13_14 implements FinancialCalculatorAPI{
    
    public Decimal computeReceivable(){
    	try {
	    	if(FinancialCalcModel.currentProcessHasStateRateCard != true){
	    		ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,'Arizona Calculation failed. No Active State Rate Card found. Please contact your Salesforce Administrator.');
	            ApexPages.addMessage(msg);
	            return null;
	    	} else {
	    		if(FinancialCalcModel.currentProcessingStateRateCard.Record_Type_Text__c != 'Arizona'){
	    			ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,'Arizona Calculation failed. School\'s Operating State Active Rate Card not of type "Arizona". Please contact your Salesforce Administrator.');
		            ApexPages.addMessage(msg);
		            return null;
	    		}
	    	}
	    	if(FinancialCalcModel.currentProcessingSchAttendance.Record_Type_Text__c != 'Arizona'){
    			ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,'Arizona Calculation failed. School\'s Active Attendance record not of type "Arizona". Please contact your Salesforce Administrator.');
	            ApexPages.addMessage(msg);
	            return null;
    		}

	        Decimal retVal;
	        School_Attendance__c att = FinancialCalcModel.currentProcessingSchAttendance;
	    	Rate_Card__c src = FinancialCalcModel.currentProcessingStateRateCard;
	    	Receivable_Type__c rt = FinancialCalcModel.currentProcessingReceivableType;
	    	String log = FinancialCalcModel.currentDebugLog;
	        /*#########################################################################################################
	        ########################################## Worksheet A Calculations #######################################
	        #########################################################################################################*/
	        FinancialCalcModel.addLog('######################## Worksheet A ########################');
	        Decimal supportLevelWeightK8 = 0;
	        Decimal supportLevelWeight912 = 0;
	        Decimal supportLevelWeightPSD = 1.450;
	        Decimal studentCountRawK8 = att.Student_Count_K_8_AOI_Full__c + att.Student_Count_K_8_AOI_Part__c + att.Student_Count_K_8_Non_AOI__c;
	        Decimal studentCountRaw912 = att.Student_Count_9_12_AOI_Full__c + att.Student_Count_9_12_AOI_Part__c + att.Student_Count_9_12_Non_AOI__c;
	        //New 2014: PSD
	        Decimal studentCountRawPSD = att.Student_Count_PSD_Non_AOI__c;
	        //End Change 2014

	        //Calculate K-8 Support Level Weight
	        if(studentCountRawK8<100){
	        	supportLevelWeightK8 = 1.399;
	        }else if(studentCountRawK8<500){
	        	supportLevelWeightK8 = 1.278 + ((500-studentCountRawK8)*0.0003);
	        }else if(studentCountRawK8<600){
	        	supportLevelWeightK8 = 1.158 + ((600-studentCountRawK8)*0.0012);
	        }else{
	        	supportLevelWeightK8 = 1.158;
	        }
	        supportLevelWeightK8 = supportLevelWeightK8.setScale(3); //Round to 3 decimals
	        FinancialCalcModel.addLog('supportLevelWeightK8 = ' + supportLevelWeightK8);
	        //Calculate 9-12 Support Level Weight
	        if(studentCountRaw912<100){
	        	supportLevelWeight912 = 1.559;
	        }else if(studentCountRaw912<500){
	        	supportLevelWeight912 = 1.398 + ((500-studentCountRaw912)*0.0004);
	        }else if(studentCountRaw912<600){
	        	supportLevelWeight912 = 1.268 + ((600-studentCountRaw912)*0.0013);
	        }else{
	        	supportLevelWeight912 = 1.268;
	        }
	        supportLevelWeight912 = supportLevelWeight912.setScale(3); //Round to 3 decimals
	        FinancialCalcModel.addLog('supportLevelWeight912 = ' + supportLevelWeight912);

	        /*#########################################################################################################
	        ########################################## Worksheet B Calculations #######################################
	        #########################################################################################################*/
	        FinancialCalcModel.addLog('######################## Worksheet B ########################');
	        Decimal studentCountK8 = (att.Student_Count_K_8_Non_AOI__c + (att.Student_Count_K_8_AOI_Full__c * .95) + (att.Student_Count_K_8_AOI_Part__c * .85));
	        FinancialCalcModel.addLog('studentCountK8 = ' + studentCountK8);
	        Decimal weightedStudentCountK8 = studentCountK8 * supportLevelWeightK8;
	        FinancialCalcModel.addLog('weightedStudentCountK8 = ' + weightedStudentCountK8);
	        Decimal studentCount912 = (att.Student_Count_9_12_Non_AOI__c + (att.Student_Count_9_12_AOI_Full__c * .95) + (att.Student_Count_9_12_AOI_Part__c * .85));
	        FinancialCalcModel.addLog('studentCount912 = ' + studentCount912);
	        Decimal weightedStudentCount912 = studentCount912 * supportLevelWeight912;
	        FinancialCalcModel.addLog('weightedStudentCount912 = ' + weightedStudentCount912);
	        //NEW 2014: PSD
	        Decimal studentCountPSD = att.Student_Count_PSD_Non_AOI__c;
	        FinancialCalcModel.addLog('studentCountPSD = ' + studentCountPSD);
	        Decimal weightedStudentCountPSD = studentCountPSD * supportLevelWeightPSD;
	        FinancialCalcModel.addLog('weightedStudentCountPSD = ' + weightedStudentCountPSD);
	        //End Change 2014

	        Decimal weightedK3Reading = (att.K_3_Reading_Non_AOI__c + (att.K_3_Reading_AOI_Full__c * .95) + (att.K_3_Reading_AOI_Part__c * .85)) * src.K_3_Reading_Rate__c;
			FinancialCalcModel.addLog('weightedK3Reading = ' + weightedK3Reading);
			Decimal weightedK3 = (att.K_3_Non_AOI__c + (att.K_3_AOI_Full__c * .95) + (att.K_3_AOI_Part__c * .85)) * src.K_3_Rate__c;
			FinancialCalcModel.addLog('weightedK3 = ' + weightedK3);
			Decimal weightedELL = (att.ELL_English_Learners_Non_AOI__c + (att.ELL_English_Learners_AOI_Full__c * .95) + (att.ELL_English_Learners_AOI_Part__c * .85)) * src.ELL_English_Learners_Rate__c;
			FinancialCalcModel.addLog('weightedELL = ' + weightedELL);
			Decimal weightedHearImp = (att.Hearing_Impairment_Non_AOI__c + (att.Hearing_Impairment_AOI_Full__c * .95) + (att.Hearing_Impairment_AOI_Part__c * .85)) * src.Hearing_Impairment_Rate__c;
			FinancialCalcModel.addLog('weightedHearImp = ' + weightedHearImp);
			Decimal weightedMDR = (att.MDR_AR_and_SMRR_Non_AOI__c + (att.MDR_AR_and_SMRR_AOI_Full__c * .95) + (att.MDR_AR_and_SMRR_AOI_Part__c * .85)) * src.MDR_AR_and_SMRR_Rate__c;
			FinancialCalcModel.addLog('weightedMDR = ' + weightedMDR);
			Decimal weightedMDSC = (att.MDSC_ASC_and_SMRSC_Non_AOI__c + (att.MDSC_ASC_and_SMRSC_AOI_Full__c * .95) + (att.MDSC_ASC_and_SMRSC_AOI_Part__c * .85)) * src.MDSC_ASC_and_SMRSC_Rate__c;
			FinancialCalcModel.addLog('weightedMDSC = ' + weightedMDSC);
			Decimal weightedMultiDis = (att.Multiple_Disabilities_SSI_Non_AOI__c + (att.Multiple_Disabilities_SSI_AOI_Full__c * .95) + (att.Multiple_Disabilities_SSI_AOI_Part__c * .85)) * src.Multiple_Disabilities_SSI_Rate__c;
			FinancialCalcModel.addLog('weightedMultiDis = ' + weightedMultiDis);
			Decimal weightedOrthoRes = (att.Ortho_Impairment_Resource_Non_AOI__c + (att.Ortho_Impairment_Resource_AOI_Full__c * .95) + (att.Ortho_Impairment_Resource_AOI_Part__c * .85)) * src.Ortho_Impairment_Resource_Rate__c;
			FinancialCalcModel.addLog('weightedOrthoRes = ' + weightedOrthoRes);
			Decimal weightedOrthoSelfs = (att.Ortho_Impairment_Self_Cont_Non_AOI__c + (att.Ortho_Impairment_Self_Cont_AOI_Full__c * .95) + (att.Ortho_Impairment_Self_Cont_AOI_Part__c * .85)) * src.Ortho_Impairment_Self_Cont_Rate__c;
			FinancialCalcModel.addLog('weightedOrthoSelfs = ' + weightedOrthoSelfs);
			//NEW 2014: PSD
			Decimal weightedPSD = (att.Preschool_Severe_Delay_Non_AOI__c + (att.Preschool_Severe_Delay_AOI_Full__c * .95) + (att.Preschool_Severe_Delay_AOI_Part__c * .85)) * src.Preschool_Severe_Delay_Rate__c;
			FinancialCalcModel.addLog('weightedPSD = ' + weightedPSD);
			//End Change 2014
			Decimal weightedDD = (att.DD_ED_MIMR_SLD_SLI_OHI_Non_AOI__c + (att.DD_ED_MIMR_SLD_SLI_OHI_AOI_Full__c * .95) + (att.DD_ED_MIMR_SLD_SLI_OHI_AOI_Part__c * .85)) * src.DD_ED_MIMR_SLD_SLI_OHI_Rate__c;
			FinancialCalcModel.addLog('weightedDD = ' + weightedDD);
			Decimal weightedEmoDis = (att.Emotionally_Disabled_Private_Non_AOI__c + (att.Emotionally_Disabled_Private_AOI_Full__c * .95) + (att.Emotionally_Disabled_Private_AOI_Part__c * .85)) * src.Emotionally_Disabled_Private_Rate__c;
			FinancialCalcModel.addLog('weightedEmoDis = ' + weightedEmoDis);
			Decimal weightedModMen = (att.Moderate_Mental_Retardation_Non_AOI__c + (att.Moderate_Mental_Retardation_AOI_Full__c * .95) + (att.Moderate_Mental_Retardation_AOI_Partl__c * .85)) * src.Moderate_Mental_Retardation_Rate__c;
			FinancialCalcModel.addLog('weightedModMen = ' + weightedModMen);
			Decimal weightedVisImp = (att.Visual_Impairment_Non_AOI__c + (att.Visual_Impairment_AOI_Full__c * .95) + (att.Visual_Impairment_AOI_Part__c * .85)) * src.Visual_Impairment_Rate__c;
			FinancialCalcModel.addLog('weightedVisImp = ' + weightedVisImp);
			Decimal totalAddOnCount = weightedK3+weightedK3Reading+weightedELL+weightedHearImp+weightedMDR+weightedMDSC+weightedMultiDis+weightedOrthoRes+weightedOrthoSelfs+weightedDD+weightedEmoDis+weightedModMen+weightedVisImp+weightedPSD; //NEW 2014: PSD
			FinancialCalcModel.addLog('totalAddOnCount = ' + totalAddOnCount);
			Decimal totalWeightedStudentCount = weightedStudentCountK8 + weightedStudentCount912 + totalAddOnCount;
			totalWeightedStudentCount = totalWeightedStudentCount + weightedStudentCountPSD;//NEW 2014: PSD
			FinancialCalcModel.addLog('totalWeightedStudentCount = ' + totalWeightedStudentCount);

			/*#########################################################################################################
	        ########################################## Worksheet C Calculations #######################################
	        #########################################################################################################*/
	        FinancialCalcModel.addLog('######################## Worksheet C ########################');
	        Decimal baseLevelAmount = src.BSL_Base_Level_Rate__c;
	        Decimal adjustedBaseLevelAmount = 0;
	        if (att.Increase_for_200_Days_of_Instruction__c==TRUE){
	        	adjustedBaseLevelAmount = baseLevelAmount * 1.05;
	        } else {
	        	adjustedBaseLevelAmount = baseLevelAmount;
	        }
	        FinancialCalcModel.addLog('adjustedBaseLevelAmount = ' + adjustedBaseLevelAmount);
	        Decimal BSL = adjustedBaseLevelAmount * totalWeightedStudentCount;
	        BSL = BSL.setScale(2); //Round to 2 decimals
	        FinancialCalcModel.addLog('BSL = ' + BSL);
	        Decimal adjustedBSL = bsl - Math.abs(att.Decrease_for_Federal_State_Monies_Rec__c) + att.Non_Federal_Audit_Service_Actual_Expense__c;
	        FinancialCalcModel.addLog('adjustedBSL = ' + adjustedBSL);

	        /*#########################################################################################################
	        ########################################## Worksheet D Calculations #######################################
	        #########################################################################################################*/
	        FinancialCalcModel.addLog('######################## Worksheet D ########################');
	        Decimal addAssistancePerK8Rate = src.Additional_Assistance_K_8_Rate__c;
	        Decimal addAssistancePerK8 = addAssistancePerK8Rate * studentCountRawK8;
	        FinancialCalcModel.addLog('addAssistancePerK8 = ' + addAssistancePerK8);
	        Decimal addAssistancePer912Rate = src.Additional_Assistance_9_12_Rate__c;
	        Decimal addAssistancePer912 = addAssistancePer912Rate * studentCountRaw912;
	        FinancialCalcModel.addLog('addAssistancePer912 = ' + addAssistancePer912);
	        //NEW 2014: PSD
	        Decimal addAssistancePerPSDRate = src.Additional_Assistance_PSD_Rate__c;
	        Decimal addAssistancePerPSD = addAssistancePerPSDRate * studentCountRawPSD;
	        FinancialCalcModel.addLog('addAssistancePerPSD = ' + addAssistancePerPSD);
	        //End Change 2014
	        Decimal totalAdditionalAssistance = addAssistancePerK8 + addAssistancePer912 + addAssistancePerPSD; //New 2014: PSD

	        Decimal aaAdjustment = totalAdditionalAssistance * (src.Default_Additional_Assistance_Rate__c/100);
	        if(Integer.valueOf(rt.Fiscal_Year__c.left(2)) > Integer.valueOf(att.Fiscal_Year__c.left(2))){
	        	If(att.Adjst_to_Additional_Assistance_Next_FY__c <> 0){
	        		aaAdjustment = att.Adjst_to_Additional_Assistance_Next_FY__c;
	        	}
	        }else{
	        	If(att.Adjustment_to_Additional_Assistance__c <> 0){
	        		aaAdjustment = att.Adjustment_to_Additional_Assistance__c;
	        	}
	        }
	        FinancialCalcModel.addLog('aaAdjustment = ' + aaAdjustment);

	        totalAdditionalAssistance = totalAdditionalAssistance + aaAdjustment;
	        FinancialCalcModel.addLog('totalAdditionalAssistance = ' + totalAdditionalAssistance);

	        /*#########################################################################################################
	        ########################################## Worksheet E Calculations #######################################
	        #########################################################################################################*/
	        FinancialCalcModel.addLog('######################## Worksheet E ########################');
	        Decimal totalEqualization = adjustedBSL + totalAdditionalAssistance;
	        FinancialCalcModel.addLog('totalEqualization = ' + totalEqualization);

	        /*#########################################################################################################
	        ########################################## Worksheet F Calculations #######################################
	        #########################################################################################################*/
	        FinancialCalcModel.addLog('######################## Worksheet F ########################');
	        Decimal adjustment = att.Total_Actual_Equal_Base_Assistance__c - att.Total_Estimated_Equal_Base_Assistance__c;
	        Decimal adjustedEqualization = totalEqualization + adjustment;
	        FinancialCalcModel.addLog('adjustedEqualization = ' + adjustedEqualization);
	        Decimal equalizationAssistanceBase = adjustedEqualization + att.CHAR_64_Equalization_Adjustments__c;
	        FinancialCalcModel.addLog('equalizationAssistanceBase = ' + equalizationAssistanceBase);

	        retVal = equalizationAssistanceBase;
	        
	        return retVal;
	    } catch (Exception e) {
	    	ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,'Arizona Calculation failed. Please contact your Salesforce Administrator. (Error: ' + e.getMessage() + ')');
            ApexPages.addMessage(msg);
            return null;
		}
    }
}