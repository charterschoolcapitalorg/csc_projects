/*=====================================================================
 * Charter School Capital, Inc
 * Name: calc_CA_EPA_Q4_14_15
 * Description: Q4 EPA Calculations
 * Created Date: [12/05/2015]
 * Created By: [John Caughie]
 *
 * Date Modified                Modified By                  Description of the update
 * [MON DD, YYYY]               [FirstName LastName]         [Short description for changes]
 * Dec 05, 2014                 John Caughie                 Added for Q4 EPA Calculations
 * Sep 27, 2016                 John Caughie                 Added logic for Classroom based calculations
 =====================================================================*/

public class calc_CA_EPA_Q4_14_15 implements FinancialCalculatorAPI{
    
    public Decimal computeReceivable(){
        try {
            if(!FinancialCalcModel.currentProcessHasDistRateCard){
                ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,'CA EPA Q4 Calculation Failed. No Active District Rate Card found. Please contact your Salesforce Administrator.');
                ApexPages.addMessage(msg);
                return null;
            } else {
                if(FinancialCalcModel.currentProcessingDistRateCard.Record_Type_Text__c != 'California District'){
                    ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,'CA EPA Q4 Calculation failed. School\'s District Active Rate Card not of type "California District". Please contact your Salesforce Administrator.');
                    ApexPages.addMessage(msg);
                    return null;
                }
            }
            if(!FinancialCalcModel.currentProcessHasStateRateCard){
                ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,'CA EPA Q4 Calculation Failed. No Active State Rate Card found. Please contact your Salesforce Administrator.');
                ApexPages.addMessage(msg);
                return null;
            } else {
                if(FinancialCalcModel.currentProcessingStateRateCard.Record_Type_Text__c != 'California State'){
                    ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,'CA EPA Q4 Calculation failed. School\'s State Active Rate Card not of type "California State". Please contact your Salesforce Administrator.');
                    ApexPages.addMessage(msg);
                    return null;
                }
            }
            if(FinancialCalcModel.currentProcessingSchAttendance.Record_Type_Text__c != 'California'){
                ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,'CA EPA Q4 Calculation failed. School\'s Active Attendance record not of type "California". Please contact your Salesforce Administrator.');
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
            ############################################## EPA Calc ###################################################
            #########################################################################################################*/
            FinancialCalcModel.addLog('#################### START EPA Q4 ####################');

            Decimal totalADA = att.ADA_K_3__c + att.ADA_4_6__c + att.ADA_7_8__c + att.ADA_9_12__c + att.ADA_K_3_nonClassroom__c + att.ADA_4_6_nonClassroom__c + att.ADA_7_8_nonClassroom__c + att.ADA_9_12_nonClassroom__c;                     //2016.09.27    J Caughie
            System.debug('ada' + totalADA);
            if(totalADA <= 0){
                return null;
            }

            /*Decimal BaseRateK3 = att.ADA_K_3__c * src.Base_Rate_K_3__c;
            Decimal BaseRate46 = att.ADA_4_6__c * src.Base_Rate_4_6__c;
            Decimal BaseRate78 = att.ADA_7_8__c * src.Base_Rate_7_8__c;
            Decimal BaseRate912 = att.ADA_9_12__c * src.Base_Rate_9_12__c;
            Decimal BaseRateSum = (BaseRateK3 + BaseRate46 + BaseRate78 + BaseRate912).round();
            FinancialCalcModel.addLog('BaseRateSum - ' + BaseRateSum);*/

            System.debug('att ' + att.Base_Floor_Rate__c);

            Decimal BaseRateSum = totalADA * att.Base_Floor_Rate__c;    // Based on change by SH - J Caughie 7/21/14

            Decimal totalADALastFY = att.ADA_K_3_Last_FY__c + att.ADA_4_6_Last_FY__c + att.ADA_7_8_Last_FY__c + att.ADA_9_12_Last_FY__c;
            Decimal categoricalsRate = 1;
            if(totalADALastFY > 0){
                categoricalsRate = totalADA/totalADALastFY;
            }
            FinancialCalcModel.addLog('categoricalsRate - ' + categoricalsRate);
            Decimal lastFYCategoricals = ((att.CBG_EIA_Last_FY__c * categoricalsRate) + att.Other_Last_FY__c).round();
            FinancialCalcModel.addLog('lastFYCategoricals - ' + lastFYCategoricals);
            //Decimal certifiedRate = totalADA/(att.ADA_K_3_Last_Certified__c + att.ADA_4_6_Last_Certified__c + att.ADA_7_8_Last_Certified__c + att.ADA_9_12_Last_Certified__c).setScale(2);           //2014.12.05 J Caughie - added as per SH
            //Decimal adjustedGapForGrowth = (att.LCFF_Gap_Amount_Last_FY__c * certifiedRate).setScale(2);                               //2014.12.05 J Caughie - added as per SH
            Decimal adjustedGapForGrowth = att.LCFF_Gap_Amount_Last_FY__c;                                                               //2015.03.16 J Caughie - adjusted as per SH
            FinancialCalcModel.addLog('Adj Gap amount - ' + adjustedGapForGrowth);
            Decimal totalBase = BaseRateSum + lastFYCategoricals + adjustedGapForGrowth;
            FinancialCalcModel.addLog('totalBase - ' + totalBase);
            
            Decimal FullRateK3 = (att.ADA_K_3__c + att.ADA_K_3_nonClassroom__c) * src.Full_Rate_K_3__c;                                         //2016.09.27  J Caughie
            Decimal FullRate46 = (att.ADA_4_6__c + att.ADA_4_6_nonClassroom__c) * src.Full_Rate_4_6__c;                                         //2016.09.27  J Caughie
            Decimal FullRate78 = (att.ADA_7_8__c + att.ADA_7_8_nonClassroom__c) * src.Full_Rate_7_8__c;                                         //2016.09.27  J Caughie
            Decimal FullRate912 = (att.ADA_9_12__c + att.ADA_9_12_nonClassroom__c) * src.Full_Rate_9_12__c;                                     //2016.09.27  J Caughie
            Decimal FullRateSum = (FullRateK3 + FullRate46 + FullRate78 + FullRate912).round();
            FinancialCalcModel.addLog('FullRateSum - ' + FullRateSum);

            Decimal ExtraFundsRateK3 = (att.ADA_K_3__c + att.ADA_K_3_nonClassroom__c) * src.Extra_Funds_Rate_K_3__c;                            //2016.09.27  J Caughie
            Decimal ExtraFundsRate46 = (att.ADA_4_6__c + att.ADA_4_6_nonClassroom__c) * src.Extra_Funds_Rate_4_6__c;                            //2016.09.27  J Caughie
            Decimal ExtraFundsRate78 = (att.ADA_7_8__c + att.ADA_7_8_nonClassroom__c) * src.Extra_Funds_Rate_7_8__c;                            //2016.09.27  J Caughie
            Decimal ExtraFundsRate912 = (att.ADA_9_12__c + att.ADA_9_12_nonClassroom__c) * src.Extra_Funds_Rate_9_12__c;                         //2016.09.27  J Caughie
            Decimal ExtraFundsRateSum = (ExtraFundsRateK3 + ExtraFundsRate46 + ExtraFundsRate78 + ExtraFundsRate912).round();
            FinancialCalcModel.addLog('ExtraFundsRateSum - ' + ExtraFundsRateSum);

            if(att.Total_Students__c==0){   // removed || att.Unduplicated_Count__c==0 from IF test - J Caughie 2014.07.02
                ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,'CA EPA Calculation failed. Total Students cannot be ZERO. Please contact your Salesforce Administrator.');
                ApexPages.addMessage(msg);
                return null;
            }
            Decimal schoolRate = (att.Unduplicated_Count__c/att.Total_Students__c).setScale(4);
            FinancialCalcModel.addLog('schoolRate - ' + schoolRate);
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

            Decimal GapRate = ((totalLCFF - totalBase) * src.Gap_Percent__c / 100).round();
            FinancialCalcModel.addLog('GapRate - ' + GapRate);

            Decimal totalFunding = (GapRate > 0) ? (totalBase + GapRate) : totalLCFF;                        //2015.09.01 J Caughie - Updated to exclude negative GAP values
            FinancialCalcModel.addLog('totalFunding - ' + totalFunding);

            Decimal EPAOffset = 0;

            /*
            // added as per SH email re new schools EPA Rate - J Caughie 2014.07.23
            if (att.Reduced_EPA_School__c == true){
                    EPAOffset = src.EPA_PENSEC_Rate__c * totalADA;
                } else {
                    EPAOffset = (BaseRateSum * src.EPA_Offset_Percent__c / 100).round();  // updated as per SH template - J Caughie 2014.07.23 //2015.10.08 EPA Reduction on School level
                }
            FinancialCalcModel.addLog('EPA Offset - ' + EPAOffset);
            FinancialCalcModel.addLog('EPA Prior Year Adj - ' + att.EPA_Prior_Year_Adjustments__c);
            EPAOffset += att.EPA_Prior_Year_Adjustments__c;                                             //2015.03.16 J Caughie - added prior year EPA adjustments
            
            // 2015.09.02 J Caughie - Added to adj EPA as per SH/MP
            if(((totalADA * drc.In_Lieu_Rate__c).setScale(0) + EPAOffset) > BaseRateSum){
                EPAOffset = Math.max(0.0, (BaseRateSum - (totalADA * drc.In_Lieu_Rate__c).setScale(0)));
            }
            // 2015.09.02 J Caughie - Added to adj EPA as per SH/MP
            */

            Decimal annualInLieu = (totalADA * drc.In_Lieu_Rate__c).setScale(0);
            FinancialCalcModel.addLog('annualInLieu - ' + annualInLieu);

            //2017.11.20 J Caughie - EPA adjustments
            if (att.Reduced_EPA_School__c == true){
                    EPAOffset = src.EPA_PENSEC_Rate__c * totalADA;
                } else {
                    Decimal epaMinimum = totalADA * src.EPA_PENSEC_Rate__c;
                    Decimal epaEntitlementCap = BaseRateSum - annualInLieu;
                    Decimal epaProportinateShare = BaseRateSum * src.EPA_Offset_Percent__c / 100.00;
                    EPAOffset = (epaMinimum > epaEntitlementCap) ? epaMinimum : Math.min(epaEntitlementCap, epaProportinateShare);
                }
            FinancialCalcModel.addLog('EPAOffset - ' + EPAOffset);
            //2017.11.20 J Caughie - EPA adjustments

            FinancialCalcModel.addLog('EPA Prior Year Adj - ' + att.EPA_Prior_Year_Adjustments__c);
            EPAOffset += att.EPA_Prior_Year_Adjustments__c;                                             //2015.03.16 J Caughie - added prior year EPA adjustments
            FinancialCalcModel.addLog('EPA Offset - ' + EPAOffset);

            //EPAOffset = EPAOffset * 0.25;                                     //2014.12.05 J Caughie - Added for Q4 EPA Calculations
            FinancialCalcModel.addLog('EPA True up factor - ' + src.True_up_Factor__c);                        

            //Adjust for negative Q3
            if (EPAOffset * src.True_up_Factor__c / 100 < att.EPA_Paid__c){
                EPAOffset = EPAOffset - att.EPA_Paid__c;
            } else {
                EPAOffset = EPAOffset * (100 - src.True_up_Factor__c) / 100;    //2015.03.16 J Caughie - added flexible True-up rate to State Rate Card 
            }
            //Adjust for negative Q3

            FinancialCalcModel.addLog('EPAOffset - ' + EPAOffset);                                //2016.01.19 J Caughie - removed and updated EPA notation

            FinancialCalcModel.addLog('#################### END EPA ####################');

            retVal = EPAOffset;
            return retVal;
        } catch (Exception e) {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,'CA EPA Q4 Calculation failed. Please contact your Salesforce Administrator. (Error: ' + e.getMessage() + ')');
            ApexPages.addMessage(msg);
            return null;
        }
    }
}