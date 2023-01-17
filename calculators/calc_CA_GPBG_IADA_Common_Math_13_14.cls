public class calc_CA_GPBG_IADA_Common_Math_13_14 {
	public static Decimal getGPBG_IADA(Decimal diffK3, Decimal diff46, Decimal diff78, Decimal diff912, Decimal currentADA) {
		//Declare calc model objects
		School_Attendance__c att = FinancialCalcModel.currentProcessingSchAttendance;
        Rate_Card__c src = FinancialCalcModel.currentProcessingStateRateCard;
        Rate_Card__c drc = FinancialCalcModel.currentProcessingDistRateCard;
        Receivable_Type__c rt = FinancialCalcModel.currentProcessingReceivableType;

        Decimal diffADAtotal = diffK3 + diff46 + diff78 + diff912;

        //Calculate result
	    Decimal BaseRateK3 = diffK3 * src.Base_Rate_K_3__c;
        Decimal BaseRate46 = diff46 * src.Base_Rate_4_6__c;
        Decimal BaseRate78 = diff78 * src.Base_Rate_7_8__c;
        Decimal BaseRate912 = diff912 * src.Base_Rate_9_12__c;
        Decimal BaseRateSum = (BaseRateK3 + BaseRate46 + BaseRate78 + BaseRate912).round();
        FinancialCalcModel.addLog('BaseRateSum - ' + BaseRateSum);

        Decimal totalADALastFY = att.ADA_K_3_Last_FY__c + att.ADA_4_6_Last_FY__c + att.ADA_7_8_Last_FY__c + att.ADA_9_12_Last_FY__c;
        Decimal categoricalsRate = 1;
        if(totalADALastFY > 0){
            categoricalsRate = currentADA/totalADALastFY;
        }
        FinancialCalcModel.addLog('categoricalsRate - ' + categoricalsRate);
        Decimal lastFYCategoricals = ((att.CBG_EIA_Last_FY__c * categoricalsRate) + att.Other_Last_FY__c).round();
        FinancialCalcModel.addLog('lastFYCategoricals - ' + lastFYCategoricals);
        Decimal totalBase = BaseRateSum + lastFYCategoricals + att.LCFF_Gap_Amount_Last_FY__c;
        FinancialCalcModel.addLog('totalBase - ' + totalBase);

        Decimal FullRateK3 = diffK3 * src.Full_Rate_K_3__c;
        Decimal FullRate46 = diff46 * src.Full_Rate_4_6__c;
        Decimal FullRate78 = diff78 * src.Full_Rate_7_8__c;
        Decimal FullRate912 = diff912 * src.Full_Rate_9_12__c;
        Decimal FullRateSum = (FullRateK3 + FullRate46 + FullRate78 + FullRate912).round();
        FinancialCalcModel.addLog('FullRateSum - ' + FullRateSum);

        Decimal ExtraFundsRateK3 = diffK3 * src.Extra_Funds_Rate_K_3__c;
        Decimal ExtraFundsRate46 = diff46 * src.Extra_Funds_Rate_4_6__c;
        Decimal ExtraFundsRate78 = diff78 * src.Extra_Funds_Rate_7_8__c;
        Decimal ExtraFundsRate912 = diff912 * src.Extra_Funds_Rate_9_12__c;
        Decimal ExtraFundsRateSum = (ExtraFundsRateK3 + ExtraFundsRate46 + ExtraFundsRate78 + ExtraFundsRate912).round();
        FinancialCalcModel.addLog('ExtraFundsRateSum - ' + ExtraFundsRateSum);

        if(att.Total_Students__c==0){
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,'CA GPBG IADA Calculation failed. Total Students cannot be ZERO. Please contact your Salesforce Administrator.');
            ApexPages.addMessage(msg);
            return null;
        }
        Decimal schoolRate = (att.Unduplicated_Count__c/att.Total_Students__c).setScale(4);
        FinancialCalcModel.addLog('schoolRate - ' + schoolRate);
        Decimal Supp20RateSum = ((FullRateSum+ExtraFundsRateSum) * 0.2 * schoolRate).round();
        FinancialCalcModel.addLog('Supp20RateSum - ' + Supp20RateSum);

        Decimal Conc50RateSum = 0;
        if(Math.min(schoolRate,(drc.District_Rate_Percent__c/100))-0.55>0){
            Decimal effectiveRate = Math.min(schoolRate,(drc.District_Rate_Percent__c/100))-0.55;
            Conc50RateSum = ((FullRateSum+ExtraFundsRateSum) * effectiveRate * 0.5).round();
        }
        FinancialCalcModel.addLog('Conc50RateSum - ' + Conc50RateSum);

        Decimal totalLCFF = FullRateSum + ExtraFundsRateSum + Supp20RateSum + Conc50RateSum;
        FinancialCalcModel.addLog('totalLCFF - ' + totalLCFF);

        Decimal GapRate = ((totalLCFF - totalBase) * src.Gap_Percent__c / 100).round();
        FinancialCalcModel.addLog('GapRate - ' + GapRate);

        Decimal totalFunding = totalBase + GapRate;
        FinancialCalcModel.addLog('totalFunding - ' + totalFunding);

        Decimal EPAOffset = (totalFunding * src.EPA_Offset_Percent__c / 100).round();
        FinancialCalcModel.addLog('EPAOffset - ' + EPAOffset);

        Decimal annualInLieu = (diffADAtotal * drc.In_Lieu_Rate__c).setScale(0);
        FinancialCalcModel.addLog('annualInLieu - ' + annualInLieu);

        Decimal annualGPBG = totalFunding - EPAOffset - annualInLieu;
        FinancialCalcModel.addLog('annualGPBG - ' + annualGPBG);

        return annualGPBG;
	}
}