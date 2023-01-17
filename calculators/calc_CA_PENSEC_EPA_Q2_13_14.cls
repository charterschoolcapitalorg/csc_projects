/*=====================================================================
 * Charter School Capital, Inc
 * Name: calc_CA_PENSEC_EPA_Q2_13_14
 *
 * Date Modified                Modified By                  Description of the update
 * [MON DD, YYYY]               [FirstName LastName]         [Short description for changes]
 * Sep 27, 2016                 John Caughie                 Added logic for Classroom based calculations
 =====================================================================*/

public class calc_CA_PENSEC_EPA_Q2_13_14 implements FinancialCalculatorAPI{
    
    public Decimal computeReceivable(){
        try {
            if(!FinancialCalcModel.currentProcessHasStateRateCard){
                ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,'CA PENSEC EPA Q2 Calculation Failed. No Active State Rate Card found. Please contact your Salesforce Administrator.');
                ApexPages.addMessage(msg);
                return null;
            } else {
                if(FinancialCalcModel.currentProcessingStateRateCard.Record_Type_Text__c != 'California State'){
                    ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,'CA PENSEC EPA Q2 Calculation failed. School\'s State Active Rate Card not of type "California State". Please contact your Salesforce Administrator.');
                    ApexPages.addMessage(msg);
                    return null;
                }
            }
            if(FinancialCalcModel.currentProcessingSchAttendance.Record_Type_Text__c != 'California'){
                ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,'CA PENSEC EPA Q2 Calculation failed. School\'s Active Attendance record not of type "California". Please contact your Salesforce Administrator.');
                ApexPages.addMessage(msg);
                return null;
            }
            Decimal retVal;
            School_Attendance__c att = FinancialCalcModel.currentProcessingSchAttendance;
            Rate_Card__c src = FinancialCalcModel.currentProcessingStateRateCard;
            Receivable_Type__c rt = FinancialCalcModel.currentProcessingReceivableType;
            /*#########################################################################################################
            ####################################### PENSEC EPA Q2 Calc ################################################
            #########################################################################################################*/
            FinancialCalcModel.addLog('#################### START PENSEC EPA Q2 ####################');

            Decimal totalInitPensecADA = att.ADA_K_3_Initial_PENSEC__c + att.ADA_4_6_Initial_PENSEC__c + att.ADA_7_8_Initial_PENSEC__c + att.ADA_9_12_Initial_PENSEC__c + att.ADA_K_3_Initial_PENSEC_nonClassroom__c + att.ADA_4_6_Initial_PENSEC_nonClassroom__c + att.ADA_7_8_Initial_PENSEC_nonClassroom__c + att.ADA_9_12_Initial_PENSEC_nonClassroom__c;       //2016.09.27    J Caughie
            FinancialCalcModel.addLog('totalInitPensecADA - ' + totalInitPensecADA);
            if(totalInitPensecADA == 0){
                return null;
            }

            Decimal HalfEPAOffset = (totalInitPensecADA * src.EPA_PENSEC_Rate__c / 2).round();

            Decimal QuarterEPAOffset = (totalInitPensecADA * src.EPA_PENSEC_Rate__c / 4).round();
            If(att.Actual_Q1_EPA__c > 0){
            	QuarterEPAOffset = (HalfEPAOffset - att.Actual_Q1_EPA__c).round();
            }
            FinancialCalcModel.addLog('QuarterEPAOffset - ' + QuarterEPAOffset);

            FinancialCalcModel.addLog('#################### END PENSEC EPA Q2 ####################');

            retVal = QuarterEPAOffset;
            return retVal;
        } catch (Exception e) {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,'CA PENSEC EPA Q2 Calculation failed. Please contact your Salesforce Administrator. (Error: ' + e.getMessage() + ')');
            ApexPages.addMessage(msg);
            return null;
        }
    }
}