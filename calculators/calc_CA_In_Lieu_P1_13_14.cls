/*=====================================================================
 * Charter School Capital, Inc
 * Name: calc_CA_In_Lieu_P1_13_14
 *
 * Date Modified                Modified By                  Description of the update
 * [MON DD, YYYY]               [FirstName LastName]         [Short description for changes]
 * Sep 27, 2016                 John Caughie                 Added logic for Classroom based calculations
 =====================================================================*/

public class calc_CA_In_Lieu_P1_13_14 implements FinancialCalculatorAPI{
    
    public Decimal computeReceivable(){
        try {
            if(!FinancialCalcModel.currentProcessHasDistRateCard){
                ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,'CA In-Lieu Calculation Failed. No Active District Rate Card found. Please contact your Salesforce Administrator.');
                ApexPages.addMessage(msg);
                return null;
            } else {
                if(FinancialCalcModel.currentProcessingDistRateCard.Record_Type_Text__c != 'California District'){
                    ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,'CA In-Lieu Calculation failed. School\'s District Active Rate Card not of type "California District". Please contact your Salesforce Administrator.');
                    ApexPages.addMessage(msg);
                    return null;
                }
            }
            if(FinancialCalcModel.currentProcessingSchAttendance.Record_Type_Text__c != 'California'){
                ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,'CA In-Lieu Calculation failed. School\'s Active Attendance record not of type "California". Please contact your Salesforce Administrator.');
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
            FinancialCalcModel.addLog('#################### START P-1 IN LIEU ####################');

            Decimal totalADA = att.ADA_K_3__c + att.ADA_4_6__c + att.ADA_7_8__c + att.ADA_9_12__c + att.ADA_K_3_nonClassroom__c + att.ADA_4_6_nonClassroom__c + att.ADA_7_8_nonClassroom__c + att.ADA_9_12_nonClassroom__c;                     //2016.09.27    J Caughie
            if(totalADA == 0){
                return null;
            }
            Decimal annualInLieu = (totalADA * drc.In_Lieu_Rate__c).setScale(0);
            FinancialCalcModel.addLog('annualInLieu - ' + annualInLieu);

            Decimal inLieuAdjustments = 0;
            if(Integer.valueOf(rt.Fiscal_Year__c.left(2)) == Integer.valueOf(att.Fiscal_Year__c.left(2))){
                inLieuAdjustments = (Math.abs(att.In_Lieu_Actual_Paid_CDE__c) + Math.abs(att.In_Lieu_Prior_Year_Adjustments__c)).round();
            }
            FinancialCalcModel.addLog('inLieuAdjustments - ' + inLieuAdjustments);

            Decimal grossInLieu = annualInLieu - inLieuAdjustments;
            FinancialCalcModel.addLog('grossInLieu - ' + grossInLieu);

            FinancialCalcModel.addLog('#################### END IN LIEU ####################');

            retVal = grossInLieu/0.42;                                                  //2014.12.05 J Caughie - pro-rated for P-1
            return retVal;
        } catch (Exception e) {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,'CA In-Lieu Calculation failed. Please contact your Salesforce Administrator. (Error: ' + e.getMessage() + ')');
            ApexPages.addMessage(msg);
            return null;
        }
    }
}