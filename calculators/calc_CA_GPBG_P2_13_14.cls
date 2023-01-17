public class calc_CA_GPBG_P2_13_14 implements FinancialCalculatorAPI{
    
    public Decimal computeReceivable(){
        try {
            if(!FinancialCalcModel.currentProcessHasDistRateCard){
                ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,'CA GPBG Calculation Failed. No Active District Rate Card found. Please contact your Salesforce Administrator.');
                ApexPages.addMessage(msg);
                return null;
            } else {
                if(FinancialCalcModel.currentProcessingDistRateCard.Record_Type_Text__c != 'California District'){
                    ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,'CA GPBG Calculation failed. School\'s District Active Rate Card not of type "California District". Please contact your Salesforce Administrator.');
                    ApexPages.addMessage(msg);
                    return null;
                }
            }
            if(!FinancialCalcModel.currentProcessHasStateRateCard){
                ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,'CA GPBG Calculation Failed. No Active State Rate Card found. Please contact your Salesforce Administrator.');
                ApexPages.addMessage(msg);
                return null;
            } else {
                if(FinancialCalcModel.currentProcessingStateRateCard.Record_Type_Text__c != 'California State'){
                    ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,'CA GPBG Calculation failed. School\'s State Active Rate Card not of type "California State". Please contact your Salesforce Administrator.');
                    ApexPages.addMessage(msg);
                    return null;
                }
            }
            if(FinancialCalcModel.currentProcessingSchAttendance.Record_Type_Text__c != 'California'){
                ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,'CA GPBG Calculation failed. School\'s Active Attendance record not of type "California". Please contact your Salesforce Administrator.');
                ApexPages.addMessage(msg);
                return null;
            }
            Decimal retVal;
            School_Attendance__c att = FinancialCalcModel.currentProcessingSchAttendance;
            Rate_Card__c src = FinancialCalcModel.currentProcessingStateRateCard;
            Rate_Card__c drc = FinancialCalcModel.currentProcessingDistRateCard;
            Receivable_Type__c rt = FinancialCalcModel.currentProcessingReceivableType;
            /*#########################################################################################################
            ############################################# GPBG Calc ###################################################
            #########################################################################################################*/
            FinancialCalcModel.addLog('#################### START GPBG ####################');

            Decimal totalADA = att.ADA_K_3__c + att.ADA_4_6__c + att.ADA_7_8__c + att.ADA_9_12__c;
            if(totalADA <= 0){
                return null;
            }

            Decimal BaseRateK3 = att.ADA_K_3__c * src.Base_Rate_K_3__c;
            Decimal BaseRate46 = att.ADA_4_6__c * src.Base_Rate_4_6__c;
            Decimal BaseRate78 = att.ADA_7_8__c * src.Base_Rate_7_8__c;
            Decimal BaseRate912 = att.ADA_9_12__c * src.Base_Rate_9_12__c;
            Decimal BaseRateSum = (BaseRateK3 + BaseRate46 + BaseRate78 + BaseRate912).round();
            FinancialCalcModel.addLog('BaseRateSum - ' + BaseRateSum);

            Decimal totalADALastFY = att.ADA_K_3_Last_FY__c + att.ADA_4_6_Last_FY__c + att.ADA_7_8_Last_FY__c + att.ADA_9_12_Last_FY__c;
            Decimal categoricalsRate = 1;
            if(totalADALastFY > 0){
                categoricalsRate = totalADA/totalADALastFY;
            }
            FinancialCalcModel.addLog('categoricalsRate - ' + categoricalsRate);
            Decimal lastFYCategoricals = ((att.CBG_EIA_Last_FY__c * categoricalsRate) + att.Other_Last_FY__c).round();
            FinancialCalcModel.addLog('lastFYCategoricals - ' + lastFYCategoricals);
            Decimal totalBase = BaseRateSum + lastFYCategoricals + att.LCFF_Gap_Amount_Last_FY__c;
            FinancialCalcModel.addLog('totalBase - ' + totalBase);

            Decimal FullRateK3 = att.ADA_K_3__c * src.Full_Rate_K_3__c;
            Decimal FullRate46 = att.ADA_4_6__c * src.Full_Rate_4_6__c;
            Decimal FullRate78 = att.ADA_7_8__c * src.Full_Rate_7_8__c;
            Decimal FullRate912 = att.ADA_9_12__c * src.Full_Rate_9_12__c;
            Decimal FullRateSum = (FullRateK3 + FullRate46 + FullRate78 + FullRate912).round();
            FinancialCalcModel.addLog('FullRateSum - ' + FullRateSum);

            Decimal ExtraFundsRateK3 = att.ADA_K_3__c * src.Extra_Funds_Rate_K_3__c;
            Decimal ExtraFundsRate46 = att.ADA_4_6__c * src.Extra_Funds_Rate_4_6__c;
            Decimal ExtraFundsRate78 = att.ADA_7_8__c * src.Extra_Funds_Rate_7_8__c;
            Decimal ExtraFundsRate912 = att.ADA_9_12__c * src.Extra_Funds_Rate_9_12__c;
            Decimal ExtraFundsRateSum = (ExtraFundsRateK3 + ExtraFundsRate46 + ExtraFundsRate78 + ExtraFundsRate912).round();
            FinancialCalcModel.addLog('ExtraFundsRateSum - ' + ExtraFundsRateSum);

            if(att.Total_Students__c==0){   // removed || att.Unduplicated_Count__c==0 from IF test - J Caughie 2014.07.02
                ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,'CA GPBG Calculation failed. Total Students cannot be ZERO. Please contact your Salesforce Administrator.');
                ApexPages.addMessage(msg);
                return null;
            }
            Decimal schoolRate = (att.Unduplicated_Count__c/att.Total_Students__c).setScale(4);
            FinancialCalcModel.addLog('schoolRate - ' + schoolRate);
            Decimal Supp20RateSum = ((FullRateSum+ExtraFundsRateSum) * 0.2 * schoolRate).round();
            FinancialCalcModel.addLog('Supp20RateSum - ' + Supp20RateSum);

            Decimal Conc50RateSum = 0;
            if(Math.min(schoolRate,(drc.District_Rate_Percent__c/100))-0.55>0){
                Decimal effectiveRate = Math.min(schoolRate,(drc.District_Rate_Percent__c/100))-0.55;
                Conc50RateSum = ((FullRateSum+ExtraFundsRateSum) * effectiveRate * 0.5).round();
            }
            FinancialCalcModel.addLog('Conc50RateSum - ' + Conc50RateSum);

            Decimal totalLCFF = FullRateSum + ExtraFundsRateSum + Supp20RateSum + Conc50RateSum;
            FinancialCalcModel.addLog('totalLCFF - ' + totalLCFF);

            Decimal GapRate = ((totalLCFF - totalBase) * src.Gap_Percent__c / 100).round();
            FinancialCalcModel.addLog('GapRate - ' + GapRate);

            Decimal totalFunding = totalBase + GapRate;
            FinancialCalcModel.addLog('totalFunding - ' + totalFunding);

            Decimal EPAOffset = (totalFunding * src.EPA_Offset_Percent__c / 100).round();
            FinancialCalcModel.addLog('EPAOffset - ' + EPAOffset);

            Decimal annualInLieu = (totalADA * drc.In_Lieu_Rate__c).setScale(0);
            FinancialCalcModel.addLog('annualInLieu - ' + annualInLieu);

            Decimal annualGPBG = totalFunding - EPAOffset - annualInLieu;
            FinancialCalcModel.addLog('annualGPBG - ' + annualGPBG);

            FinancialCalcModel.addLog('#################### END GPBG ####################');

            retVal = annualGPBG;
            return retVal;
        } catch (Exception e) {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,'CA GPBG Calculation failed. Please contact your Salesforce Administrator. (Error: ' + e.getMessage() + ')');
            ApexPages.addMessage(msg);
            return null;
        }
    }
}