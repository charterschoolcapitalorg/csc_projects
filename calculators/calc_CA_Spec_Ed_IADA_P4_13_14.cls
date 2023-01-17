/*=====================================================================
 * Charter School Capital, Inc
 * Name: calc_CA_Spec_Ed_IADA_P4_13_14
 *
 * Date Modified                Modified By                  Description of the update
 * [MON DD, YYYY]               [FirstName LastName]         [Short description for changes]
 * Sep 27, 2016                 John Caughie                 Added logic for Classroom based calculations
 =====================================================================*/

public class calc_CA_Spec_Ed_IADA_P4_13_14 implements FinancialCalculatorAPI{
    
    public Decimal computeReceivable(){
        try {
            if(!FinancialCalcModel.currentProcessHasDistRateCard){
                ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,'CA Spec Ed IADA P4 Calculation Failed. No Active District Rate Card found. Please contact your Salesforce Administrator.');
                ApexPages.addMessage(msg);
                return null;
            } else {
                if(FinancialCalcModel.currentProcessingDistRateCard.Record_Type_Text__c != 'California District'){
                    ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,'CA Spec Ed IADA P4 Calculation failed. School\'s District Active Rate Card not of type "California District". Please contact your Salesforce Administrator.');
                    ApexPages.addMessage(msg);
                    return null;
                }
            }
            if(FinancialCalcModel.currentProcessingSchAttendance.Record_Type_Text__c != 'California'){
                ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,'CA Spec Ed IADA P4 Calculation failed. School\'s Active Attendance record not of type "California". Please contact your Salesforce Administrator.');
                ApexPages.addMessage(msg);
                return null;
            }
            Decimal retVal;
            School_Attendance__c att = FinancialCalcModel.currentProcessingSchAttendance;
            Rate_Card__c drc = FinancialCalcModel.currentProcessingDistRateCard;
            Receivable_Type__c rt = FinancialCalcModel.currentProcessingReceivableType;
            /*#########################################################################################################
            ########################################## Spec Ed Calc ###################################################
            #########################################################################################################*/
            FinancialCalcModel.addLog('#################### START SPEC ED IADA P4 ####################');

            Decimal totalADA = att.ADA_K_3__c + att.ADA_4_6__c + att.ADA_7_8__c + att.ADA_9_12__c + att.ADA_K_3_nonClassroom__c + att.ADA_4_6_nonClassroom__c + att.ADA_7_8_nonClassroom__c + att.ADA_9_12_nonClassroom__c;                     //2016.09.27    J Caughie
            if(totalADA == 0){
                return null;
            }
            FinancialCalcModel.addLog('totalADA - ' + totalADA);

            Decimal totalIADA = att.IADA_K_3_Period_4__c + att.IADA_4_6_Period_4__c + att.IADA_7_8_Period_4__c + att.IADA_9_12_Period_4__c + att.IADA_K_3_Period_4_nonClassroom__c + att.IADA_4_6_Period_4_nonClassroom__c + att.IADA_7_8_Period_4_nonClassroom__c + att.IADA_9_12_Period_4_nonClassroom__c;                     //2016.09.27    J Caughie
            if(totalIADA == 0){
                return null;
            }
            FinancialCalcModel.addLog('totalIADA - ' + totalIADA);
            
            Decimal diffIADA = totalIADA - totalADA;

            if(att.Total_Instructional_Days__c == 0 || att.Number_of_instructional_days_Period_4__c ==0){
                return null;
            }
            Decimal rateADA = att.Number_of_instructional_days_Period_4__c / att.Total_Instructional_Days__c;
            FinancialCalcModel.addLog('rateADA - ' + rateADA);

            Decimal annualSpecEd = (diffIADA * drc.Spec_Ed_Rate__c * rateADA).setScale(0);
            FinancialCalcModel.addLog('annualSpecEd - ' + annualSpecEd);

            FinancialCalcModel.addLog('#################### END SPEC ED IADA P4 ####################');

            retVal = annualSpecEd;
            return retVal;
        } catch (Exception e) {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,'CA Spec Ed IADA P4 Calculation failed. Please contact your Salesforce Administrator. (Error: ' + e.getMessage() + ')');
            ApexPages.addMessage(msg);
            return null;
        }
    }
}