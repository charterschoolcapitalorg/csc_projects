/*=====================================================================
 * Charter School Capital, Inc
 * Name: calc_CA_PENSEC_Initial_Payment_16_17
 *
 * Date Modified                Modified By                  Description of the update
 * [MON DD, YYYY]               [FirstName LastName]         [Short description for changes]
 * Sep 27, 2016                 John Caughie                 Added logic for Classroom based calculations
 =====================================================================*/

public class calc_CA_PENSEC_Initial_Payment_16_17 implements FinancialCalculatorAPI{
    
    public Decimal computeReceivable(){
        try {
            if(!FinancialCalcModel.currentProcessHasDistRateCard){
                ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,'CA PENSEC Initial Payment Calculation Failed. No Active District Rate Card found. Please contact your Salesforce Administrator.');
                ApexPages.addMessage(msg);
                return null;
            } else {
                if(FinancialCalcModel.currentProcessingDistRateCard.Record_Type_Text__c != 'California District'){
                    ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,'CA PENSEC Initial Payment Calculation failed. School\'s District Active Rate Card not of type "California District". Please contact your Salesforce Administrator.');
                    ApexPages.addMessage(msg);
                    return null;
                }
            }
            if(!FinancialCalcModel.currentProcessHasStateRateCard){
                ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,'CA PENSEC Initial Payment Calculation Failed. No Active State Rate Card found. Please contact your Salesforce Administrator.');
                ApexPages.addMessage(msg);
                return null;
            } else {
                if(FinancialCalcModel.currentProcessingStateRateCard.Record_Type_Text__c != 'California State'){
                    ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,'CA PENSEC Initial Payment Calculation failed. School\'s State Active Rate Card not of type "California State". Please contact your Salesforce Administrator.');
                    ApexPages.addMessage(msg);
                    return null;
                }
            }
            if(FinancialCalcModel.currentProcessingSchAttendance.Record_Type_Text__c != 'California'){
                ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,'CA PENSEC Initial Payment Calculation failed. School\'s Active Attendance record not of type "California". Please contact your Salesforce Administrator.');
                ApexPages.addMessage(msg);
                return null;
            }

            Decimal retVal;
            School_Attendance__c att = FinancialCalcModel.currentProcessingSchAttendance;
            Rate_Card__c src = FinancialCalcModel.currentProcessingStateRateCard;
            Rate_Card__c drc = FinancialCalcModel.currentProcessingDistRateCard;
            Rate_Card__c altdrc = FinancialCalcModel.currentProcessingAltDistRateCard;
            /*#########################################################################################################
            ############################################# PENSEC Initial Payment Calc ###################################################
            #########################################################################################################*/
            FinancialCalcModel.addLog('#################### START PENSEC Initial Payment ####################');

            Decimal FloorEntitlement = (att.ADA_K_3_Initial_PENSEC__c + att.ADA_4_6_Initial_PENSEC__c + att.ADA_7_8_Initial_PENSEC__c + att.ADA_9_12_Initial_PENSEC__c + att.ADA_K_3_Initial_PENSEC_nonClassroom__c + att.ADA_4_6_Initial_PENSEC_nonClassroom__c + att.ADA_7_8_Initial_PENSEC_nonClassroom__c + att.ADA_9_12_Initial_PENSEC_nonClassroom__c) * att.Base_Floor_Rate__c;      //2016.09.27    J Caughie
            FinancialCalcModel.addLog('Floor Entitlement - ' + FloorEntitlement.setScale(2));

            Decimal FullRateK3 = (att.ADA_K_3_Initial_PENSEC__c + att.ADA_K_3_Initial_PENSEC_nonClassroom__c) * src.Full_Rate_K_3__c;                                         //2016.09.27  J Caughie
            Decimal FullRate46 = (att.ADA_4_6_Initial_PENSEC__c + att.ADA_4_6_Initial_PENSEC_nonClassroom__c) * src.Full_Rate_4_6__c;                                         //2016.09.27  J Caughie
            Decimal FullRate78 = (att.ADA_7_8_Initial_PENSEC__c + att.ADA_7_8_Initial_PENSEC_nonClassroom__c) * src.Full_Rate_7_8__c;                                         //2016.09.27  J Caughie
            Decimal FullRate912 = (att.ADA_9_12_Initial_PENSEC__c + att.ADA_9_12_Initial_PENSEC_nonClassroom__c) * src.Full_Rate_9_12__c;                                     //2016.09.27  J Caughie
            Decimal FullRateSum = (FullRateK3 + FullRate46 + FullRate78 + FullRate912).round();
            FinancialCalcModel.addLog('FullRateSum - ' + FullRateSum.setScale(2));

            if(att.Total_Students__c==0){
            	ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,'CA PENSEC Initial Payment Calculation failed. Total Students cannot be ZERO. Please contact your Salesforce Administrator.');
                ApexPages.addMessage(msg);
                return null;
            }
            Decimal schoolRate = att.Unduplicated_Count__c/att.Total_Students__c;
            Decimal Supp20RateSum = (FullRateSum * 0.2 * schoolRate).round();
            FinancialCalcModel.addLog('Supp20RateSum - ' + Supp20RateSum.setScale(2));

            Decimal Conc50RateSum = 0;

            Decimal DistrictRatePercent = 0; 
            if (FinancialCalcModel.currentProcessHasAltDistRateCard){
                DistrictRatePercent = altdrc.District_Rate_Percent__c;
            }else{
                DistrictRatePercent = drc.District_Rate_Percent__c;
            }
            FinancialCalcModel.addLog('rate' + DistrictRatePercent);
            
            if(Math.min(schoolRate,(DistrictRatePercent/100))-0.55>0){
                Decimal effectiveRate = Math.min(schoolRate,(DistrictRatePercent/100))-0.55;
                Conc50RateSum = (FullRateSum * effectiveRate * 0.65).round();
            }

            FinancialCalcModel.addLog('Conc50RateSum - ' + Conc50RateSum.setScale(2));

            Decimal totalLCFF = FullRateSum + Supp20RateSum + Conc50RateSum;
            FinancialCalcModel.addLog('totalLCFF - ' + totalLCFF.setScale(2));

            Decimal GapRate = ((totalLCFF - FloorEntitlement) * src.Gap_Percent__c / 100).round();
			FinancialCalcModel.addLog('GapRate - ' + GapRate.setScale(2));

            Decimal totalFunding = (GapRate > 0) ? (FloorEntitlement + GapRate) : totalLCFF;
			FinancialCalcModel.addLog('totalFunding - ' + totalFunding.setScale(2));

			Decimal totalInitPensecADA = att.ADA_K_3_Initial_PENSEC__c + att.ADA_4_6_Initial_PENSEC__c + att.ADA_7_8_Initial_PENSEC__c + att.ADA_9_12_Initial_PENSEC__c + att.ADA_K_3_Initial_PENSEC_nonClassroom__c + att.ADA_4_6_Initial_PENSEC_nonClassroom__c + att.ADA_7_8_Initial_PENSEC_nonClassroom__c + att.ADA_9_12_Initial_PENSEC_nonClassroom__c;      //2016.09.27    J Caughieatt.ADA_K_3_Initial_PENSEC__c + att.ADA_4_6_Initial_PENSEC__c + att.ADA_7_8_Initial_PENSEC__c + att.ADA_9_12_Initial_PENSEC__c;
            FinancialCalcModel.addLog('totalInitPensecADA - ' + totalInitPensecADA.setScale(2));

            Decimal EPAOffset = (totalInitPensecADA * src.EPA_PENSEC_Rate__c).round();
			FinancialCalcModel.addLog('EPAOffset - ' + EPAOffset.setScale(2));

			Decimal annualInLieu = (totalInitPensecADA * drc.In_Lieu_Rate__c).setScale(0);
            FinancialCalcModel.addLog('annualInLieu - ' + annualInLieu);

            Decimal annualGross = totalFunding - EPAOffset - annualInLieu;
            FinancialCalcModel.addLog('annualGross - ' + annualGross.setScale(2));

            FinancialCalcModel.addLog('#################### END PENSEC Initial Payment ####################');

            retVal = annualGross * 0.37;		//Calculator intial payment percentage
            return retVal;
        } catch (Exception e) {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,'CA PENSEC Initial Payment Calculation failed. Please contact your Salesforce Administrator. (Error: ' + e.getMessage() + ')');
            ApexPages.addMessage(msg);
            return null;
        }
    }
}