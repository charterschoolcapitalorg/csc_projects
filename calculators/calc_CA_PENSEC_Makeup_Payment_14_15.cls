/*=====================================================================
 * Charter School Capital, Inc
 * Name: calc_CA_PENSEC_Makeup_Payment_14_15
 *
 * Date Modified                Modified By                  Description of the update
 * [MON DD, YYYY]               [FirstName LastName]         [Short description for changes]
 * Sep 27, 2016                 John Caughie                 Added logic for Classroom based calculations
 =====================================================================*/

public class calc_CA_PENSEC_Makeup_Payment_14_15 implements FinancialCalculatorAPI{
    
    public Decimal computeReceivable(){
        try {
            if(!FinancialCalcModel.currentProcessHasDistRateCard){
                ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,'CA PENSEC Makeup Payment Calculation Failed. No Active District Rate Card found. Please contact your Salesforce Administrator.');
                ApexPages.addMessage(msg);
                return null;
            } else {
                if(FinancialCalcModel.currentProcessingDistRateCard.Record_Type_Text__c != 'California District'){
                    ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,'CA PENSEC Makeup Payment Calculation failed. School\'s District Active Rate Card not of type "California District". Please contact your Salesforce Administrator.');
                    ApexPages.addMessage(msg);
                    return null;
                }
            }
            if(!FinancialCalcModel.currentProcessHasStateRateCard){
                ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,'CA PENSEC Makeup Payment Calculation Failed. No Active State Rate Card found. Please contact your Salesforce Administrator.');
                ApexPages.addMessage(msg);
                return null;
            } else {
                if(FinancialCalcModel.currentProcessingStateRateCard.Record_Type_Text__c != 'California State'){
                    ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,'CA PENSEC Makeup Payment Calculation failed. School\'s State Active Rate Card not of type "California State". Please contact your Salesforce Administrator.');
                    ApexPages.addMessage(msg);
                    return null;
                }
            }
            if(FinancialCalcModel.currentProcessingSchAttendance.Record_Type_Text__c != 'California'){
                ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,'CA PENSEC Makeup Payment Calculation failed. School\'s Active Attendance record not of type "California". Please contact your Salesforce Administrator.');
                ApexPages.addMessage(msg);
                return null;
            }
            Decimal retVal;
            School_Attendance__c att = FinancialCalcModel.currentProcessingSchAttendance;
            Rate_Card__c src = FinancialCalcModel.currentProcessingStateRateCard;
            Rate_Card__c drc = FinancialCalcModel.currentProcessingDistRateCard;
            Rate_Card__c altdrc = FinancialCalcModel.currentProcessingAltDistRateCard;                                           //2014.08.19 J Caughie - used to get Unduplicated Count District 
            Receivable_Type__c rt = FinancialCalcModel.currentProcessingReceivableType;
            /*#########################################################################################################
            ############################################# PENSEC Makeup Payment Calc ###################################################
            #########################################################################################################*/
            FinancialCalcModel.addLog('#################### START PENSEC Makeup Payment ####################');

			/*																													//2015.10.05 J Caughie - Updated logic
			Decimal BaseRateK3 = att.ADA_K_3_PENSEC_20_Day__c * src.Base_Rate_K_3__c;
            Decimal BaseRate46 = att.ADA_4_6_PENSEC_20_Day__c * src.Base_Rate_4_6__c;
            Decimal BaseRate78 = att.ADA_7_8_PENSEC_20_Day__c * src.Base_Rate_7_8__c;
            Decimal BaseRate912 = att.ADA_9_12_PENSEC_20_Day__c * src.Base_Rate_9_12__c;
            Decimal BaseRateSum = (BaseRateK3 + BaseRate46 + BaseRate78 + BaseRate912).round();
            FinancialCalcModel.addLog('BaseRateSum - ' + BaseRateSum);
			*/

			Decimal BaseRateSum = (att.ADA_K_3_PENSEC_20_Day__c + att.ADA_4_6_PENSEC_20_Day__c + att.ADA_7_8_PENSEC_20_Day__c + att.ADA_9_12_PENSEC_20_Day__c + att.ADA_K_3_PENSEC_20_Day_nonClassroom__c + att.ADA_4_6_PENSEC_20_Day_nonClassroom__c + att.ADA_7_8_PENSEC_20_Day_nonClassroom__c + att.ADA_9_12_PENSEC_20_Day_nonClassroom__c) * att.Base_Floor_Rate__c;         //2016.09.27    J Caughie

            if(BaseRateSum == 0){
            	return null;
            }

            Decimal FullRateK3 = (att.ADA_K_3_PENSEC_20_Day__c + att.ADA_K_3_PENSEC_20_Day_nonClassroom__c) * src.Full_Rate_K_3__c;                                                     //2016.09.27    J Caughie
            Decimal FullRate46 = (att.ADA_4_6_PENSEC_20_Day__c + att.ADA_4_6_PENSEC_20_Day_nonClassroom__c) * src.Full_Rate_4_6__c;                                                     //2016.09.27    J Caughie
            Decimal FullRate78 = (att.ADA_7_8_PENSEC_20_Day__c + att.ADA_7_8_PENSEC_20_Day_nonClassroom__c) * src.Full_Rate_7_8__c;                                                     //2016.09.27    J Caughie
            Decimal FullRate912 = (att.ADA_9_12_PENSEC_20_Day__c + att.ADA_9_12_PENSEC_20_Day_nonClassroom__c) * src.Full_Rate_9_12__c;                                                 //2016.09.27    J Caughie
            Decimal FullRateSum = (FullRateK3 + FullRate46 + FullRate78 + FullRate912).round();
            FinancialCalcModel.addLog('FullRateSum - ' + FullRateSum);

            Decimal ExtraFundsRateK3 = (att.ADA_K_3_PENSEC_20_Day__c + att.ADA_K_3_PENSEC_20_Day_nonClassroom__c) * src.Extra_Funds_Rate_K_3__c;                                                     //2016.09.27    J Caughie
            Decimal ExtraFundsRate46 = (att.ADA_4_6_PENSEC_20_Day__c + att.ADA_4_6_PENSEC_20_Day_nonClassroom__c) * src.Extra_Funds_Rate_4_6__c;                                                     //2016.09.27    J Caughie
            Decimal ExtraFundsRate78 = (att.ADA_7_8_PENSEC_20_Day__c + att.ADA_7_8_PENSEC_20_Day_nonClassroom__c) * src.Extra_Funds_Rate_7_8__c;                                                     //2016.09.27    J Caughie
            Decimal ExtraFundsRate912 = (att.ADA_9_12_PENSEC_20_Day__c + att.ADA_9_12_PENSEC_20_Day_nonClassroom__c) * src.Extra_Funds_Rate_9_12__c;                                                 //2016.09.27    J Caughie
            Decimal ExtraFundsRateSum = (ExtraFundsRateK3 + ExtraFundsRate46 + ExtraFundsRate78 + ExtraFundsRate912).round();
            FinancialCalcModel.addLog('ExtraFundsRateSum - ' + ExtraFundsRateSum);

            if(att.Total_Students__c==0){   // removed || att.Unduplicated_Count__c==0 from IF test - J Caughie 2014.07.02
            	ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,'CA PENSEC Initial Payment Calculation failed. Total Students cannot be ZERO. Please contact your Salesforce Administrator.');
                ApexPages.addMessage(msg);
                return null;
            }
            Decimal schoolRate = att.Unduplicated_Count__c/att.Total_Students__c;
            Decimal Supp20RateSum = ((FullRateSum+ExtraFundsRateSum) * 0.2 * schoolRate).round();
            FinancialCalcModel.addLog('Supp20RateSum - ' + Supp20RateSum);

            Decimal Conc50RateSum = 0;
            //2014.08.19 J Caughie - new logic added for schools withunduplicated count based on a different District
            Decimal DistrictRatePercent = 0; 
            if (FinancialCalcModel.currentProcessHasAltDistRateCard){
                DistrictRatePercent = altdrc.District_Rate_Percent__c;
            }else{
                DistrictRatePercent = drc.District_Rate_Percent__c;
            }
            FinancialCalcModel.addLog('rate' + DistrictRatePercent);
            
            if(Math.min(schoolRate,(DistrictRatePercent/100))-0.55>0){
                Decimal effectiveRate = Math.min(schoolRate,(DistrictRatePercent/100))-0.55;           // 2014.08.19 J Caughie -  drc.District_Rate_Percent__c replaced
                Conc50RateSum = ((FullRateSum+ExtraFundsRateSum) * effectiveRate * 0.65).round();
            }
            //2014.08.19 J Caughie - new logic added for schools withunduplicated count based on a different District

            /*if(Math.min(schoolRate,(drc.District_Rate_Percent__c/100))-0.55>0){
                Decimal effectiveRate = Math.min(schoolRate,(drc.District_Rate_Percent__c/100))-0.55;           // 2014.08.19 J Caughie -  drc.District_Rate_Percent__c replaced
                Conc50RateSum = ((FullRateSum+ExtraFundsRateSum) * effectiveRate * 0.5).round();
            }*/
            FinancialCalcModel.addLog('Conc50RateSum - ' + Conc50RateSum);

            Decimal totalLCFF = FullRateSum + ExtraFundsRateSum + Supp20RateSum + Conc50RateSum;
            FinancialCalcModel.addLog('totalLCFF - ' + totalLCFF);

            Decimal GapRate = ((totalLCFF - BaseRateSum) * src.Gap_Percent__c / 100).round();
			FinancialCalcModel.addLog('GapRate - ' + GapRate);

			//Decimal totalFunding = BaseRateSum + GapRate;
            Decimal totalFunding = (GapRate > 0) ? (BaseRateSum + GapRate) : totalLCFF;                        //2015.09.01 J Caughie - Updated to exclude negative GAP values
			FinancialCalcModel.addLog('totalFunding - ' + totalFunding);

			Decimal totalPensec20DayADA = att.ADA_K_3_PENSEC_20_Day__c + att.ADA_4_6_PENSEC_20_Day__c + att.ADA_7_8_PENSEC_20_Day__c + att.ADA_9_12_PENSEC_20_Day__c + att.ADA_K_3_PENSEC_20_Day_nonClassroom__c + att.ADA_4_6_PENSEC_20_Day_nonClassroom__c + att.ADA_7_8_PENSEC_20_Day_nonClassroom__c + att.ADA_9_12_PENSEC_20_Day_nonClassroom__c;               //2016.09.27    J Caughie
            FinancialCalcModel.addLog('totalPensec20DayADA - ' + totalPensec20DayADA);

            Decimal EPAOffset = (totalPensec20DayADA * src.EPA_PENSEC_Rate__c).round();
			FinancialCalcModel.addLog('EPAOffset - ' + EPAOffset);

			Decimal annualInLieu = (totalPensec20DayADA * drc.In_Lieu_Rate__c).setScale(0);
            FinancialCalcModel.addLog('annualInLieu - ' + annualInLieu);

            Decimal annualGross = totalFunding - EPAOffset - annualInLieu - att.Actual_Initial_Payment__c/0.55;                             //2014.12.09 J Caughie - added to pro-rate Initial Payment
            FinancialCalcModel.addLog('annualGross - ' + annualGross);

            FinancialCalcModel.addLog('#################### END PENSEC Makeup Payment ####################');

            retVal = annualGross;
            return retVal;
        } catch (Exception e) {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,'CA PENSEC Makeup Payment Calculation failed. Please contact your Salesforce Administrator. (Error: ' + e.getMessage() + ')');
            ApexPages.addMessage(msg);
            return null;
        }
    }
}