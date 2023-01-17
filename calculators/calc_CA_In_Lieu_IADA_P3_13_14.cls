/*=====================================================================
 * Charter School Capital, Inc
 * Name: calc_CA_In_Lieu_IADA_P3_13_14
 *
 * Date Modified                Modified By                  Description of the update
 * [MON DD, YYYY]               [FirstName LastName]         [Short description for changes]
 * Sep 27, 2016                 John Caughie                 Added logic for Classroom based calculations
 =====================================================================*/

public class calc_CA_In_Lieu_IADA_P3_13_14 implements FinancialCalculatorAPI{
    
    public Decimal computeReceivable(){
        try {
            if(!FinancialCalcModel.currentProcessHasDistRateCard){
                ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,'CA In-Lieu IADA P3 Calculation Failed. No Active District Rate Card found. Please contact your Salesforce Administrator.');
                ApexPages.addMessage(msg);
                return null;
            } else {
                if(FinancialCalcModel.currentProcessingDistRateCard.Record_Type_Text__c != 'California District'){
                    ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,'CA In-Lieu IADA P3 Calculation failed. School\'s District Active Rate Card not of type "California District". Please contact your Salesforce Administrator.');
                    ApexPages.addMessage(msg);
                    return null;
                }
            }
            if(FinancialCalcModel.currentProcessingSchAttendance.Record_Type_Text__c != 'California'){
                ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,'CA In-Lieu IADA P3 Calculation failed. School\'s Active Attendance record not of type "California". Please contact your Salesforce Administrator.');
                ApexPages.addMessage(msg);
                return null;
            }
            Decimal retVal;
            School_Attendance__c att = FinancialCalcModel.currentProcessingSchAttendance;
            Rate_Card__c drc = FinancialCalcModel.currentProcessingDistRateCard;
            Receivable_Type__c rt = FinancialCalcModel.currentProcessingReceivableType;
            /*#########################################################################################################
            ########################################## In Lieu Calc ###################################################
            #########################################################################################################*/
            FinancialCalcModel.addLog('#################### START IN LIEU IADA P3 ####################');

            Decimal totalADA = att.ADA_K_3__c + att.ADA_4_6__c + att.ADA_7_8__c + att.ADA_9_12__c + att.ADA_K_3_nonClassroom__c + att.ADA_4_6_nonClassroom__c + att.ADA_7_8_nonClassroom__c + att.ADA_9_12_nonClassroom__c;                     //2016.09.27    J Caughie
            if(totalADA == 0){
                return null;
            }
            FinancialCalcModel.addLog('totalADA - ' + totalADA);

            Decimal totalIADA = att.IADA_K_3_Period_3__c + att.IADA_4_6_Period_3__c + att.IADA_7_8_Period_3__c + att.IADA_9_12_Period_3__c + att.IADA_K_3_Period_3_nonClassroom__c + att.IADA_4_6_Period_3_nonClassroom__c + att.IADA_7_8_Period_3_nonClassroom__c + att.IADA_9_12_Period_3_nonClassroom__c;            //2016.09.27    J Caughie
            if(totalIADA == 0){
                return null;
            }
            FinancialCalcModel.addLog('totalIADA - ' + totalIADA);
            
            Decimal diffIADA = totalIADA - totalADA;

            if(att.Total_Instructional_Days__c == 0 || att.Number_of_instructional_days_Period_3__c ==0){
                return null;
            }
            Decimal rateADA = att.Number_of_instructional_days_Period_3__c / att.Total_Instructional_Days__c;
            FinancialCalcModel.addLog('rateADA - ' + rateADA);

            Decimal diffInLieu = (diffIADA * drc.In_Lieu_Rate__c).setScale(0);
            FinancialCalcModel.addLog('diffInLieu - ' + diffInLieu);

            FinancialCalcModel.addLog('#################### END IN LIEU IADA P3 ####################');

            retVal = diffInLieu * rateADA;

            retval = retval / 0.42;                 //2014.09.24 J Caughie - IADA is paid out over a reduced timeframe therefore the "Gross" is pro-rated
            
            return retVal;
        } catch (Exception e) {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,'CA In-Lieu IADA P3 Calculation failed. Please contact your Salesforce Administrator. (Error: ' + e.getMessage() + ')');
            ApexPages.addMessage(msg);
            return null;
        }
    }
}