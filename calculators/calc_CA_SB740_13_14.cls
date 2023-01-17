public class calc_CA_SB740_13_14 implements FinancialCalculatorAPI{
	
	public Decimal computeReceivable(){
		try {
			if(!FinancialCalcModel.currentProcessHasStateRateCard){
				ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,'CA SB740 Calculation Failed. No Active State Rate Card found. Please contact your Salesforce Administrator.');
				ApexPages.addMessage(msg);
				return null;
			} else {
				if(FinancialCalcModel.currentProcessingStateRateCard.Record_Type_Text__c != 'California State'){
					ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,'CA SB740 Calculation failed. School\'s State Active Rate Card not of type "California State". Please contact your Salesforce Administrator.');
					ApexPages.addMessage(msg);
					return null;
				}
			}
			if(FinancialCalcModel.currentProcessingSchAttendance.Record_Type_Text__c != 'California'){
				ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,'CA SB740 Calculation failed. School\'s Active Attendance record not of type "California". Please contact your Salesforce Administrator.');
				ApexPages.addMessage(msg);
				return null;
			}
			Decimal retVal;
			School_Attendance__c att = FinancialCalcModel.currentProcessingSchAttendance;
			Rate_Card__c src = FinancialCalcModel.currentProcessingStateRateCard;
			Receivable_Type__c rt = FinancialCalcModel.currentProcessingReceivableType;
			/*#########################################################################################################
			############################################ SB740 Calc ###################################################
			#########################################################################################################*/
			FinancialCalcModel.addLog('#################### START SB740 Apportionments ####################');

			/*if(att.SB740_Grant_Amount__c == 0){
				return null;
			}

			Decimal x75percentGrant = (att.SB740_Grant_Amount__c * 0.75).round();

			Decimal totalADA = att.ADA_K_3__c + att.ADA_4_6__c + att.ADA_7_8__c + att.ADA_9_12__c;

			Decimal sb740limit = (totalADA * src.SB740_Max_Rate_Per_ADA__c).round();

			Decimal sb740payment = Math.min(x75percentGrant, sb740limit);
			FinancialCalcModel.addLog('sb740payment - ' + sb740payment);

			FinancialCalcModel.addLog('#################### END SB740 ####################');

			retVal = sb740payment;
			return retVal;*/

			// 2014.11.20 J Caughie - added logic to allow calculations for next year based on last year

			if (att.SB740_Grant_Amount__c > 0 && ((Integer.valueOf(rt.Fiscal_Year__c.left(2)) == Integer.valueOf(att.Fiscal_Year__c.left(2)) && att.SB740_Paid__c == 0)
					|| (Integer.valueOf(rt.Fiscal_Year__c.left(2)) == (1 + Integer.valueOf(att.Fiscal_Year__c.left(2)))))) {
							Decimal x75percentGrant = (att.SB740_Grant_Amount__c * 0.75).round();
							Decimal totalADA = att.ADA_K_3__c + att.ADA_4_6__c + att.ADA_7_8__c + att.ADA_9_12__c;
							Decimal sb740limit = (totalADA * src.SB740_Max_Rate_Per_ADA__c).round();
							Decimal sb740payment = Math.min(x75percentGrant, sb740limit);
							FinancialCalcModel.addLog('sb740payment - ' + sb740payment);
							FinancialCalcModel.addLog('#################### END SB740 ####################');
							retVal = sb740payment;
							return retVal;
			} else {
                return null;
            }
		} catch (Exception e) {
			ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,'CA SB740 Calculation failed. Please contact your Salesforce Administrator. (Error: ' + e.getMessage() + ')');
			ApexPages.addMessage(msg);
			return null;
		}
	}
}