public class calc_IN_Dec implements FinancialCalculatorAPI{
    
    public Decimal computeReceivable(){
    	try{
	    	if(!FinancialCalcModel.currentProcessHasStateRateCard){
	    		ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,'Indiana Dec Calculation Failed. No Active State Rate Card found. Please contact your Salesforce Administrator.');
	            ApexPages.addMessage(msg);
	            return null;
	    	} else {
	    		if(FinancialCalcModel.currentProcessingStateRateCard.Record_Type_Text__c != 'Indiana State'){
	    			ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,'Indiana Dec Calculation failed. School\'s Operating State Active Rate Card not of type "Indiana State". Please contact your Salesforce Administrator.');
		            ApexPages.addMessage(msg);
		            return null;
	    		}
	    	}
	    	if(FinancialCalcModel.currentProcessingSchAttendance.Record_Type_Text__c != 'Indiana'){
    			ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,'Indiana Dec Calculation failed. School\'s Active Attendance record not of type "Indiana". Please contact your Salesforce Administrator.');
	            ApexPages.addMessage(msg);
	            return null;
    		}

	        Decimal retVal;
	        School_Attendance__c att = FinancialCalcModel.currentProcessingSchAttendance;
	    	Rate_Card__c src = FinancialCalcModel.currentProcessingStateRateCard;
	    	Receivable_Type__c rt = FinancialCalcModel.currentProcessingReceivableType;
	        /*#########################################################################################################
	        ########################################## Tuition Support ################################################
	        #########################################################################################################*/
	        FinancialCalcModel.addLog('######################## Tuition Support - Dec ########################');

	        //Year Calculation
	        Boolean thisYear = !(Integer.valueOf(rt.Fiscal_Year__c.left(2)) > Integer.valueOf(att.Fiscal_Year__c.left(2)));
	        FinancialCalcModel.addLog('This Year: ' + thisYear);

	        Decimal baseADM = 0.0;
	        //If receivables are for "future" years then use February ADM
	        if(thisYear){
	        	baseADM = (6 * att.September_ADM__c - 4 * att.May_ADM__c) / 2.0;
	        } else {
	        	baseADM = att.February_ADM__c;
	        }
	        FinancialCalcModel.addLog('Base: ' + baseADM.setScale(2));

	        //Tuition Support
	        Decimal tuitionSupport = (src.Base_Tuition_Support__c * baseADM / 12.0);
	        tuitionSupport *= att.Virtual_Charter__c ? (src.Virtual_Charter_Rate__c / 100.0 ) : 1;
	        FinancialCalcModel.addLog('Tuition Support: ' + tuitionSupport.setScale(2));

	        //Honors Grant
	        Decimal honorsGrant = 0.0;
	        if(thisYear){
			        honorsGrant += (6 * att.Honors_non_SNAP_Current__c - 5 * att.Honors_non_SNAP_Prior__c) * src.Honors_non_SNAP__c;
			        honorsGrant += (6 * att.CORE_40_non_SNAP_Current__c - 5 * att.Core_40_non_SNAP_Prior__c) * src.Core_40_non_SNAP__c;
			        honorsGrant += (6 * att.Honors_SNAP_Current__c - 5 * att.Honors_SNAP_Prior__c) * src.Honors_SNAP__c;
			        honorsGrant += (6 * att.CORE_40_SNAP_Current__c - 5 * att.CORE_40_SNAP_Prior__c) * src.Core_40_SNAP__c;
	        	} else {
			        honorsGrant += att.Honors_non_SNAP_Current__c * src.Honors_non_SNAP__c;
			        honorsGrant += att.Core_40_non_SNAP_Current__c * src.Core_40_non_SNAP__c;
			        honorsGrant += att.Honors_SNAP_Current__c * src.Honors_SNAP__c;
			        honorsGrant += att.CORE_40_SNAP_Current__c * src.Core_40_SNAP__c;
	        	}
	        honorsGrant /= 12.0;
	        FinancialCalcModel.addLog('Honors: ' + honorsGrant.setScale(2));

	        //Special Education Grant
	        Decimal specialEdGrant = 0.0;
	        if(thisYear){
			        specialEdGrant += att.Severe_Prior__c * src.SEG_Severe__c;
			        specialEdGrant += att.Mild_Moderate_Prior__c * src.SEG_Mild_Moderate__c;
			        specialEdGrant += att.Communication_and_Homebound_Prior__c * src.SEG_Communication_and_Homebound__c;
			        specialEdGrant += att.Preschool_Prior__c * src.SEG_Preschool__c;
	        	} else {
					specialEdGrant += att.Severe_Current__c * src.SEG_Severe__c;
			        specialEdGrant += att.Mild_Moderate_Current__c * src.SEG_Mild_Moderate__c;
			        specialEdGrant += att.Communication_and_Homebound_Current__c * src.SEG_Communication_and_Homebound__c;
			        specialEdGrant += att.Preschool_Current__c * src.SEG_Preschool__c;
	        	}
	        specialEdGrant /= 12.0;
	        FinancialCalcModel.addLog('SpecEd: ' + specialEdGrant.setScale(2));

	        //Vocational Education Grant
	        Decimal vocationalEdGrant = 0.0;
	        if(thisYear){
        			vocationalEdGrant += (6 * att.Total_Annual_Amount_Current__c - 5 * att.Total_Annual_Amount_Prior__c) / 12.0;
	        	} else {
	        		vocationalEdGrant += att.Total_Annual_Amount_Current__c / 12.0;
	        	} 
	        FinancialCalcModel.addLog('Vocational: ' + vocationalEdGrant.setScale(2));

	        //Complexity Grant
	        Decimal complexityGrant = 0.0;
	        complexityGrant += ((baseADM * src.Complexity_Grant__c) * att.Complexity_Grant__c / 100.0);
	        complexityGrant /= 12.0;
	        FinancialCalcModel.addLog('Complexity: ' + complexityGrant.setScale(2));

	        //Annualized Value
	        retVal = (tuitionSupport + honorsGrant + specialEdGrant + vocationalEdGrant + complexityGrant) * 12.0;
	        
	        return retVal;
        } catch (Exception e) {
	    	ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,'Indiana Dec Calculation failed. Please contact your Salesforce Administrator. (Error: ' + e.getMessage() + ')');
            ApexPages.addMessage(msg);
            return null;
		}
    }
}