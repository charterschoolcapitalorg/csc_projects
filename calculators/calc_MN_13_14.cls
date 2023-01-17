public class calc_MN_13_14 implements FinancialCalculatorAPI{
    
    public Decimal computeReceivable(){
    	try {
	    	if(!FinancialCalcModel.currentProcessHasStateRateCard){
	    		ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,'MN Calculation Failed. No Active State Rate Card found. Please contact your Salesforce Administrator.');
	            ApexPages.addMessage(msg);
	            return null;
	    	} else {
	    		if(FinancialCalcModel.currentProcessingStateRateCard.Record_Type_Text__c != 'Minnesota State'){
	    			ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,'MN Calculation failed. School\'s State\'s Active Rate Card not of type "Minnesota State". Please contact your Salesforce Administrator.');
		            ApexPages.addMessage(msg);
		            return null;
	    		}
	    	}
	    	if(FinancialCalcModel.currentProcessingSchAttendance.Record_Type_Text__c != 'Minnesota'){
    			ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,'MN Calculation failed. School\'s Active Attendance record not of type "Minnesota". Please contact your Salesforce Administrator.');
	            ApexPages.addMessage(msg);
	            return null;
    		}
	        Decimal retVal;
	        School_Attendance__c att = FinancialCalcModel.currentProcessingSchAttendance;
	    	Rate_Card__c src = FinancialCalcModel.currentProcessingStateRateCard;
	    	Receivable_Type__c rt = FinancialCalcModel.currentProcessingReceivableType;
	    	/*#########################################################################################################
	        ############################################### MN Calc ###################################################
	        #########################################################################################################*/

	        Decimal calTotal = 0;
	        Decimal thisADM = 0;
	        Decimal thisAttest = 0;
	        
	        if(Integer.valueOf(rt.Fiscal_Year__c.left(2)) > Integer.valueOf(att.Fiscal_Year__c.left(2))){
	        	calTotal = att.Calendar_Year_Total_This_FY__c;
	        	thisADM = att.ADM_This_FY__c;
	        	thisAttest = att.Attest_Next_FY__c;
	        	if(calTotal <= 0 || thisADM <= 0){
	        		ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,'MN Calculation failed. This FY Calendar Total and This FY ADM required to calculate future FY receivables.');
	            	ApexPages.addMessage(msg);
	            	return null;
	        	}
	        }else if(Integer.valueOf(rt.Fiscal_Year__c.left(2)) == Integer.valueOf(att.Fiscal_Year__c.left(2))){
	        	calTotal = att.Calendar_Year_Total_This_FY__c;
	        	thisADM = att.ADM_This_FY__c;
	        	thisAttest = att.Attest_This_FY__c;
	        	if(calTotal <= 0 || thisADM <= 0){
	        		ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,'MN Calculation failed. This FY Calendar Total and This FY ADM required to calculate this FY receivables.');
	            	ApexPages.addMessage(msg);
	            	return null;
	        	}
	        }else{
	        	calTotal = att.Calendar_Year_Total_Last_FY__c;
	        	thisADM = att.ADM_Last_FY__c;
	        	thisAttest = att.Attest_Last_FY__c;
	        	if(calTotal <= 0 || thisADM <= 0){
	        		ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,'MN Calculation failed. Last FY Calendar Total and Last FY ADM required to calculate previous FY receivables.');
	            	ApexPages.addMessage(msg);
	            	return null;
	        	}
	        }
	        FinancialCalcModel.addLog('calTotal = ' + calTotal);
	        FinancialCalcModel.addLog('thisADM = ' + thisADM);
	        FinancialCalcModel.addLog('thisAttest = ' + thisAttest);

	        Decimal thisHoldback = 0;
	        if(Integer.valueOf(rt.Fiscal_Year__c.left(2)) >= Integer.valueOf(src.Fiscal_Year__c.left(2))){
	        	thisHoldback = src.Holdback_This_FY__c;//If receivable FY is >= rate card FY, use This FY Rate
        	}else{
        		thisHoldback = src.Holdback_Last_FY__c;//Otherwise use Last FY Rate
        	}
        	FinancialCalcModel.addLog('thisHoldback = ' + thisHoldback);

        	Decimal attestAdjustmentFactor = 1;//Default is 100% (1)
        	If(thisAttest > 0){//If there is an attest value, calculate new factor
        		If(thisAttest/thisADM < 1){//If factor is <1, use it, otherwise keeping default of 100%
        			attestAdjustmentFactor = (thisAttest/thisADM);
        		}
        	}
        	FinancialCalcModel.addLog('attestAdjustmentFactor = ' + attestAdjustmentFactor);

        	Decimal adjustedAnnualRevenue = (calTotal * attestAdjustmentFactor).round();
        	FinancialCalcModel.addLog('adjustedAnnualRevenue = ' + adjustedAnnualRevenue);

        	Decimal fiscalYearAnnualRev = (adjustedAnnualRevenue/(1 - (thisHoldback/100))).round();
        	FinancialCalcModel.addLog('fiscalYearAnnualRev = ' + fiscalYearAnnualRev);

        	retVal = fiscalYearAnnualRev;
	        return retVal;
	    } catch (Exception e) {
	    	ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,'MN Calculation failed. Please contact your Salesforce Administrator. (Error: ' + e.getMessage() + ')');
            ApexPages.addMessage(msg);
            return null;
		}
    }
}