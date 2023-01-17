/*=====================================================================
 * Charter School Capital, Inc
 * Name: calc_CA_EPA_IADA_P3_14_15
 *
 * Date Modified                Modified By                  Description of the update
 * [MON DD, YYYY]               [FirstName LastName]         [Short description for changes]
 * Sep 27, 2016                 John Caughie                 Added logic for Classroom based calculations
 =====================================================================*/

 public class calc_CA_EPA_IADA_P3_14_15 implements FinancialCalculatorAPI{
    
    public Decimal computeReceivable(){
        try {
            if(!FinancialCalcModel.currentProcessHasDistRateCard){
                ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,'CA EPA IADA P1 Calculation Failed. No Active District Rate Card found. Please contact your Salesforce Administrator.');
                ApexPages.addMessage(msg);
                return null;
            } else {
                if(FinancialCalcModel.currentProcessingDistRateCard.Record_Type_Text__c != 'California District'){
                    ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,'CA EPA IADA P1 Calculation failed. School\'s District Active Rate Card not of type "California District". Please contact your Salesforce Administrator.');
                    ApexPages.addMessage(msg);
                    return null;
                }
            }
            if(!FinancialCalcModel.currentProcessHasStateRateCard){
                ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,'CA EPA Calculation Failed. No Active State Rate Card found. Please contact your Salesforce Administrator.');
                ApexPages.addMessage(msg);
                return null;
            } else {
                if(FinancialCalcModel.currentProcessingStateRateCard.Record_Type_Text__c != 'California State'){
                    ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,'CA EPA Calculation failed. School\'s State Active Rate Card not of type "California State". Please contact your Salesforce Administrator.');
                    ApexPages.addMessage(msg);
                    return null;
                }
            }
            if(FinancialCalcModel.currentProcessingSchAttendance.Record_Type_Text__c != 'California'){
                ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,'CA EPA IADA P1 Calculation failed. School\'s Active Attendance record not of type "California". Please contact your Salesforce Administrator.');
                ApexPages.addMessage(msg);
                return null;
            }
            Decimal retVal;
            School_Attendance__c att = FinancialCalcModel.currentProcessingSchAttendance;
            //Rate_Card__c drc = FinancialCalcModel.currentProcessingDistRateCard;
            //Receivable_Type__c rt = FinancialCalcModel.currentProcessingReceivableType;
			Rate_Card__c src = FinancialCalcModel.currentProcessingStateRateCard;
			//Rate_Card__c altdrc = FinancialCalcModel.currentProcessingAltDistRateCard;
            /*#########################################################################################################
            ############################################## EPA Calc ###################################################
            #########################################################################################################*/
            FinancialCalcModel.addLog('#################### START EPA IADA P1 ####################');

            Decimal totalADA = att.ADA_K_3__c + att.ADA_4_6__c + att.ADA_7_8__c + att.ADA_9_12__c + att.ADA_K_3_nonClassroom__c + att.ADA_4_6_nonClassroom__c + att.ADA_7_8_nonClassroom__c + att.ADA_9_12_nonClassroom__c;                     //2016.09.27    J Caughie
            if(totalADA == 0){
                return null;
            }
            FinancialCalcModel.addLog('totalADA - ' + totalADA);

            Decimal totalIADA = att.IADA_K_3_Period_3__c + att.IADA_4_6_Period_3__c + att.IADA_7_8_Period_3__c + att.IADA_9_12_Period_3__c + att.IADA_K_3_Period_3_nonClassroom__c + att.IADA_4_6_Period_3_nonClassroom__c + att.IADA_7_8_Period_3_nonClassroom__c + att.IADA_9_12_Period_3_nonClassroom__c;                    //2016.09.27    J Caughie
            if(totalIADA == 0){
                return null;
            }
            FinancialCalcModel.addLog('totalIADA - ' + totalIADA);
            
            Decimal diffIADA = totalIADA - totalADA;
            Decimal diffK3 = att.IADA_K_3_Period_3__c + att.IADA_K_3_Period_3_nonClassroom__c - att.ADA_K_3__c - att.ADA_K_3_nonClassroom__c;                           //2016.09.27    J Caughie
            Decimal diff46 = att.IADA_4_6_Period_3__c + att.IADA_4_6_Period_3_nonClassroom__c - att.ADA_4_6__c - att.ADA_4_6_nonClassroom__c;                           //2016.09.27    J Caughie
            Decimal diff78 = att.IADA_7_8_Period_3__c + att.IADA_7_8_Period_3_nonClassroom__c - att.ADA_7_8__c - att.ADA_7_8_nonClassroom__c;                           //2016.09.27    J Caughie
            Decimal diff912 = att.IADA_9_12_Period_3__c + att.IADA_9_12_Period_3_nonClassroom__c - att.ADA_9_12__c - att.ADA_9_12_nonClassroom__c;                      //2016.09.27    J Caughie

            if(att.Total_Instructional_Days__c == 0 || att.Number_of_instructional_days_Period_3__c ==0){
            	return null;
            }
            Decimal rateADA = att.Number_of_instructional_days_Period_3__c / att.Total_Instructional_Days__c;
            FinancialCalcModel.addLog('rateADA - ' + rateADA);

            Decimal diffEPA = calc_CA_EPA_IADA_Common_Math_14_15.getEPA_IADA(diffK3, diff46, diff78, diff912, totalIADA);

            FinancialCalcModel.addLog('#################### END EPA IADA P1 ####################');

            retVal = diffEPA * rateADA;       //2016.03.03 J Caughie - moved * src.EPA_Offset_Percent__c/100 to common math level as it was wrongly included in reduced epa

            return retVal;
        } catch (Exception e) {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,'CA EPA IADA P1 Calculation failed. Please contact your Salesforce Administrator. (Error: ' + e.getMessage() + ')');
            ApexPages.addMessage(msg);
            return null;
        }
    }
}