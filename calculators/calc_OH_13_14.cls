public class calc_OH_13_14 implements FinancialCalculatorAPI{
    
    public Decimal computeReceivable(){
        try {
            if(FinancialCalcModel.currentProcessingSchAttendance.Record_Type_Text__c != 'Ohio'){
                ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,'Ohio Calculation failed. School\'s Active Attendance record not of type "Ohio". Please contact your Salesforce Administrator.');
                ApexPages.addMessage(msg);
                return null;
            }
            Decimal retVal;
            Receivable_Type__c rt = FinancialCalcModel.currentProcessingReceivableType;
            School_Attendance__c att = FinancialCalcModel.currentProcessingSchAttendance;

            /*#########################################################################################################
            ######################################### Total Transfer Calculation ######################################
            #########################################################################################################*/
            FinancialCalcModel.addLog('######################## Total Transfer Calculation ########################');
            Decimal totalTransfer = att.Opportunity_Grant__c + att.Targeted_Assistance__c + att.K_3_Literacy__c + att.Economic_Disadvantaged_Funding__c;
            totalTransfer += att.Limited_English_Proficiency__c + att.Special_Education_Funding__c + att.Career_Technical_Funding__c + att.Transportation__c;
            FinancialCalcModel.addLog('totalTransfer = ' + totalTransfer);

            if(Integer.valueOf(rt.Fiscal_Year__c.left(2)) > Integer.valueOf(att.Fiscal_Year__c.left(2))){
                //if Receivable is future FY, calculate using full total transfer amount
                retVal = totalTransfer;
            }else{
                /*#########################################################################################################
                ####################################### Balance Due Current Calculation ###################################
                #########################################################################################################*/
                FinancialCalcModel.addLog('######################## Balance Due Current Calculation ########################');
                Decimal balanceDueCurrent = totalTransfer - att.Prior_Period_YTD_Total_State_Support__c;
                FinancialCalcModel.addLog('balanceDueCurrent = ' + balanceDueCurrent);

                /*#########################################################################################################
                ###################################### Actual Payment Gross Calculation ###################################
                #########################################################################################################*/
                FinancialCalcModel.addLog('######################## Actual Payment Gross Calculation ########################');
                Decimal actualPaymentGross = att.Actual_Payment_Net__c - att.Facilities_Adjustment__c - att.ESC_Deduction__c - att.State_Teacher_Retirement__c;
                actualPaymentGross = actualPaymentGross - att.School_Employee_Retirement__c - att.Audit_Adjustments__c - att.Sponsor_Fee_Deduction__c - att.JV44__c;
                FinancialCalcModel.addLog('actualPaymentGross = ' + actualPaymentGross);

                /*#########################################################################################################
                ###################################### Balance Due For Year Calculation ###################################
                #########################################################################################################*/
                FinancialCalcModel.addLog('######################## Balance Due For Year Calculation ########################');
                Decimal currentMonthNum = Decimal.valueOf(att.Attendance_Type__c.substring(0,2));
                FinancialCalcModel.addLog('currentMonthNum = ' + currentMonthNum);
                Decimal monthsLeft = 12-currentMonthNum;
                FinancialCalcModel.addLog('monthsLeft = ' + monthsLeft);

                Decimal yearTotalReceivable = 0;
                if(currentMonthNum < 12){
                    yearTotalReceivable = (balanceDueCurrent - actualPaymentGross) * 12 / monthsLeft;
                }else{
                    yearTotalReceivable = totalTransfer;
                }
                FinancialCalcModel.addLog('yearTotalReceivable = ' + yearTotalReceivable);

                retVal = yearTotalReceivable;
            }

            return retVal;
        } catch (Exception e) {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,'Ohio Calculation failed. Please contact your Salesforce Administrator. (Error: ' + e.getMessage() + ')');
            ApexPages.addMessage(msg);
            return null;
        }
    }
}