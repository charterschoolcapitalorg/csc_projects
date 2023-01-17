public class calc_CA_GPBG_IADA_P2_13_14 implements FinancialCalculatorAPI{
    
    public Decimal computeReceivable(){
        try {
            if(!FinancialCalcModel.currentProcessHasDistRateCard){
                ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,'CA GPBG IADA P2 Calculation Failed. No Active District Rate Card found. Please contact your Salesforce Administrator.');
                ApexPages.addMessage(msg);
                return null;
            } else {
                if(FinancialCalcModel.currentProcessingDistRateCard.Record_Type_Text__c != 'California District'){
                    ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,'CA GPBG IADA P2 Calculation failed. School\'s District Active Rate Card not of type "California District". Please contact your Salesforce Administrator.');
                    ApexPages.addMessage(msg);
                    return null;
                }
            }
            if(!FinancialCalcModel.currentProcessHasStateRateCard){
                ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,'CA GPBG IADA P2 Calculation Failed. No Active State Rate Card found. Please contact your Salesforce Administrator.');
                ApexPages.addMessage(msg);
                return null;
            } else {
                if(FinancialCalcModel.currentProcessingStateRateCard.Record_Type_Text__c != 'California State'){
                    ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,'CA GPBG IADA P2 Calculation failed. School\'s State Active Rate Card not of type "California State". Please contact your Salesforce Administrator.');
                    ApexPages.addMessage(msg);
                    return null;
                }
            }
            if(FinancialCalcModel.currentProcessingSchAttendance.Record_Type_Text__c != 'California'){
                ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,'CA GPBG IADA P2 Calculation failed. School\'s Active Attendance record not of type "California". Please contact your Salesforce Administrator.');
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
            FinancialCalcModel.addLog('#################### START GPBG IADA P2 ####################');

            Decimal totalADA = att.ADA_K_3__c + att.ADA_4_6__c + att.ADA_7_8__c + att.ADA_9_12__c;
            if(totalADA <= 0){
                return null;
            }
            FinancialCalcModel.addLog('totalADA - ' + totalADA);

            Decimal totalIADA = att.IADA_K_3_Period_2__c + att.IADA_4_6_Period_2__c + att.IADA_7_8_Period_2__c + att.IADA_9_12_Period_2__c;
            if(totalIADA == 0){
                return null;
            }
            FinancialCalcModel.addLog('totalIADA - ' + totalIADA);
            
            Decimal diffIADA = totalIADA - totalADA;
            Decimal diffK3 = att.IADA_K_3_Period_2__c - att.ADA_K_3__c;
            Decimal diff46 = att.IADA_4_6_Period_2__c - att.ADA_4_6__c;
            Decimal diff78 = att.IADA_7_8_Period_2__c - att.ADA_7_8__c;
            Decimal diff912 = att.IADA_9_12_Period_2__c - att.ADA_9_12__c;

            if(att.Total_Instructional_Days__c == 0 || att.Number_of_instructional_days_Period_2__c ==0){
                return null;
            }
            Decimal rateADA = att.Number_of_instructional_days_Period_2__c / att.Total_Instructional_Days__c;
            FinancialCalcModel.addLog('rateADA - ' + rateADA);

            Decimal diffAnnualGPBG = calc_CA_GPBG_IADA_Common_Math_13_14.getGPBG_IADA(diffK3, diff46, diff78, diff912, totalIADA);

            FinancialCalcModel.addLog('#################### END GPBG IADA P2 ####################');

            retVal = diffAnnualGPBG * rateADA;
            return retVal;
        } catch (Exception e) {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,'CA GPBG IADA P2 Calculation failed. Please contact your Salesforce Administrator. (Error: ' + e.getMessage() + ')');
            ApexPages.addMessage(msg);
            return null;
        }
    }
}