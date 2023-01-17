/*
// 2014.11.17 J Caughie - Louisiana Calculator Class
*/

public class calc_LA_14_15 implements FinancialCalculatorAPI{

	public Decimal computeReceivable(){
		try {
			if(FinancialCalcModel.currentProcessHasRegionalAttRec != true){
				ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,'Louisiana Calculation Failed. No Regional Attendance records. Please contact your Salesforce Administrator.');
				ApexPages.addMessage(msg);
				return null;
			} /*else {
				if(FinancialCalcModel.currentProcessHasStateRateCard){
					ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,'Louisiana Calculation failed. No active State Rate Card found. Please contact your Salesforce Administrator.');
					ApexPages.addMessage(msg);
					return null;
				}
			}*/

			Decimal retVal;
			Decimal totalAnnualRevAdjusted = 0;

			School_Attendance__c att = FinancialCalcModel.currentProcessingSchAttendance;
			//System.debug('att ' + att);

			Map<Id, List<Regional_Attendance__c>> regAttMap = new Map<Id, List<Regional_Attendance__c>>();
			regAttMap = FinancialCalcModel.currentProcessingRegAttMap;
			//System.debug('regAttMap ' + regAttMap);

			Map<Id, List<Rate_Card__c>> regRateCardMap = new Map<Id, List<Rate_Card__c>>();
			regRateCardMap = FinancialCalcModel.currentProcessingRegRateCardMap;
			//System.debug('regRateCardMap ' + regRateCardMap);

			Set<Id> regAttDists = new Set<Id>();
			regAttDists = regAttMap.keySet();
			//System.debug('set ' + regAttDists);

			/*#########################################################################################################
			############################################## LA Calculations ############################################
			#########################################################################################################*/
			FinancialCalcModel.addLog('######################## MFP Calcs ########################');

			// Loop through the Regional Attendance Records and calculate the value of each, accumulating the total 
			try {
				for (Id regDistId : regAttDists){
							Regional_Attendance__c currentRegAtt = regAttMap.get(regDistId)[0];
							System.debug(currentRegAtt);
							Rate_Card__c currentRegRateCard = regRateCardMap.get(regDistId)[0];
							System.debug(currentRegRateCard);
							System.debug('Attendance: ' + currentRegAtt.Enrollment_Last_Feb__c + ' ' + currentRegAtt.Enrollment_This_Oct__c + ' ' +currentRegAtt.Enrollment_This_Feb__c);
							System.debug('Rates: ' + currentRegRateCard.State_Rate__c + ' ' + currentRegRateCard.Local_Revenue__c);			
						if (att.Total_This_Feb__c > 0){
							totalAnnualRevAdjusted += (currentRegAtt.Enrollment_This_Feb__c + currentRegAtt.Enrollment_This_Oct__c) / 2 *
									(currentRegRateCard.State_Rate__c + currentRegRateCard.Local_Revenue__c);
						} else {
							totalAnnualRevAdjusted += (currentRegAtt.Enrollment_Last_Feb__c) *
									(currentRegRateCard.State_Rate__c + currentRegRateCard.Local_Revenue__c);
						}
						System.debug('inter' + totalAnnualRevAdjusted);
					}
				} catch (Exception e) {
					ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,'Louisiana Calculation failed, check rate cards for attendance Districts. Please contact your Salesforce Administrator. (Error: ' + e.getMessage() + ')');
					ApexPages.addMessage(msg);
					return null;
				}
			//System.debug('totalAnnualRevAdjusted ' + totalAnnualRevAdjusted);
			FinancialCalcModel.addLog('totalAnnualRevAdjusted ' + totalAnnualRevAdjusted);

			// Calculate LADOE fees at 0.25% rate
			Decimal adminLADOE = (0.25/100) * totalAnnualRevAdjusted;
			FinancialCalcModel.addLog('adminLADOE ' + adminLADOE.setScale(2));
			//System.debug('adminLADOE ' + adminLADOE.setScale(2));

			// Deduct LADOE fees and Attendance Record adjustments
			Decimal totalAnnualFunding = totalAnnualRevAdjusted + att.Audit_Adjustments__c + att.Level_4_Adj__c - adminLADOE;
			FinancialCalcModel.addLog('totalAnnualFunding ' + totalAnnualFunding.setScale(2));
			//System.debug('totalAnnualFunding ' + totalAnnualFunding.setScale(2));
			
			// Deduct amount already paid this YTD to get remainder for the year
			Decimal remainderYear = totalAnnualFunding - att.Paid_Year_to_Date__c;
			FinancialCalcModel.addLog('remainderYear ' + remainderYear.setScale(2));
			//System.debug('remainderYear ' + remainderYear.setScale(2));

			// Re-calculate total for the year based on the months remaining
			Decimal monthlyPayments = remainderYear / att.Remaining_Payments__c;
			FinancialCalcModel.addLog('monthlyPayments ' + monthlyPayments.setScale(2));
			//System.debug('monthlyPayments ' + monthlyPayments.setScale(2));	  
			
			retVal = monthlyPayments * 12;
			FinancialCalcModel.addLog('annualized total ' + retVal.setScale(2));
			
			return retVal.setScale(2);

		} catch (Exception e) {
			ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,'Louisiana Calculation failed. Please contact your Salesforce Administrator. (Error: ' + e.getMessage() + ')');
			ApexPages.addMessage(msg);
			return null;
		}
	}
}