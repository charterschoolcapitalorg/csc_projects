/*=====================================================================
 * Charter School Capital, Inc
 * Name: calc_CA_PENSEC_In_Lieu_14_15
 *
 * Date Modified                Modified By                  Description of the update
 * [MON DD, YYYY]               [FirstName LastName]         [Short description for changes]
 * Sep 27, 2016                 John Caughie                 Added logic for Classroom based calculations
 =====================================================================*/

public class calc_CA_PENSEC_In_Lieu_14_15 implements FinancialCalculatorAPI{
    
    public Decimal computeReceivable(){
        try {
            if(!FinancialCalcModel.currentProcessHasDistRateCard){
                ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,'CA PENSEC In Lieu Calculation Failed. No Active District Rate Card found. Please contact your Salesforce Administrator.');
                ApexPages.addMessage(msg);
                return null;
            } else {
                if(FinancialCalcModel.currentProcessingDistRateCard.Record_Type_Text__c != 'California District'){
                    ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,'CA PENSEC In Lieu Calculation failed. School\'s District Active Rate Card not of type "California District". Please contact your Salesforce Administrator.');
                    ApexPages.addMessage(msg);
                    return null;
                }
            }
            if(FinancialCalcModel.currentProcessingSchAttendance.Record_Type_Text__c != 'California'){
                ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,'CA PENSEC In Lieu Calculation failed. School\'s Active Attendance record not of type "California". Please contact your Salesforce Administrator.');
                ApexPages.addMessage(msg);
                return null;
            }
            Decimal retVal;
            School_Attendance__c att = FinancialCalcModel.currentProcessingSchAttendance;
            Rate_Card__c drc = FinancialCalcModel.currentProcessingDistRateCard;
            Receivable_Type__c rt = FinancialCalcModel.currentProcessingReceivableType;
            /*#########################################################################################################
            ################################### PENSEC In Lieu Calc ###################################################
            #########################################################################################################*/
            FinancialCalcModel.addLog('#################### START PENSEC IN LIEU ####################');


            //2015.10.13 J Caughie - added logic to use 20 day over initial if it exists.
            //Decimal totalInitPensecADA = att.ADA_K_3_Initial_PENSEC__c + att.ADA_4_6_Initial_PENSEC__c + att.ADA_7_8_Initial_PENSEC__c + att.ADA_9_12_Initial_PENSEC__c;
            Decimal totalInitPensecADA = (att.ADA_K_3_PENSEC_20_Day__c + att.ADA_4_6_PENSEC_20_Day__c + att.ADA_7_8_PENSEC_20_Day__c + att.ADA_9_12_PENSEC_20_Day__c + att.ADA_K_3_PENSEC_20_Day_nonClassroom__c + att.ADA_4_6_PENSEC_20_Day_nonClassroom__c + att.ADA_7_8_PENSEC_20_Day_nonClassroom__c + att.ADA_9_12_PENSEC_20_Day_nonClassroom__c) > 0.0 
            	? (att.ADA_K_3_PENSEC_20_Day__c + att.ADA_4_6_PENSEC_20_Day__c + att.ADA_7_8_PENSEC_20_Day__c + att.ADA_9_12_PENSEC_20_Day__c + att.ADA_K_3_PENSEC_20_Day_nonClassroom__c + att.ADA_4_6_PENSEC_20_Day_nonClassroom__c + att.ADA_7_8_PENSEC_20_Day_nonClassroom__c + att.ADA_9_12_PENSEC_20_Day_nonClassroom__c)
            	: (att.ADA_K_3_Initial_PENSEC__c + att.ADA_4_6_Initial_PENSEC__c + att.ADA_7_8_Initial_PENSEC__c + att.ADA_9_12_Initial_PENSEC__c + att.ADA_K_3_Initial_PENSEC_nonClassroom__c + att.ADA_4_6_Initial_PENSEC_nonClassroom__c + att.ADA_7_8_Initial_PENSEC_nonClassroom__c + att.ADA_9_12_Initial_PENSEC_nonClassroom__c);                               //2016.09.27    J Caughie

            FinancialCalcModel.addLog('totalInitPensecADA - ' + totalInitPensecADA);
            if(totalInitPensecADA == 0){
                return null;
            }
            Decimal annualInLieu = (totalInitPensecADA * drc.In_Lieu_Rate__c).setScale(0);
            FinancialCalcModel.addLog('annualInLieu - ' + annualInLieu);

            FinancialCalcModel.addLog('#################### END PENSEC IN LIEU ####################');

            retVal = annualInLieu;
            return retVal;
        } catch (Exception e) {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,'CA PENSEC In Lieu Calculation failed. Please contact your Salesforce Administrator. (Error: ' + e.getMessage() + ')');
            ApexPages.addMessage(msg);
            return null;
        }
    }
}