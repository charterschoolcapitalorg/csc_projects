@isTest
private class calc_CA_PENSEC_Initial_Payment_16_17_Tst{
  private static Opportunity oppty;
    
    @isTest static void test_method_one() {
        TestHelper.createCustomSettingToByPassTriggersAndRules('Account, RPA__c, Opportunity, Funding_Estimate_Receivable__c, Funding_Estimates__c, '+
                                                                    'Opp_School__c');
        //createCalcClassData(Apex Class Name, Attendance Record Type, State Rate Card Record Type, District Rate Card Record Type)
        TestHelper.createCalcClassData('calc_CA_PENSEC_Initial_Payment_16_17', 'California', 'California State', 'California District');
        //get created opportunity in testhelper.
        oppty = [Select Id,Name from Opportunity where Name = 'Test Oppty' limit 1];
        Test.startTest();
        FinancialCalcController con = new FinancialCalcController(new ApexPages.StandardController(oppty));
        Test.stopTest();
        System.debug('con: ' + con);
    }

    //Test try/catch block on calculator class
    @isTest static void test_method_catch() {

        calc_CA_PENSEC_Initial_Payment_16_17 ca = new calc_CA_PENSEC_Initial_Payment_16_17();
		Test.startTest();
		ca.computeReceivable();
		Test.stopTest();

		List<Apexpages.Message> msgs = ApexPages.getMessages();
		Boolean messageAssert = false;
		for(Apexpages.Message msg:msgs){
		    if (msg.getDetail().contains('CA PENSEC Initial Payment Calculation failed. Please contact your Salesforce Administrator.')) messageAssert = true;
		}
		System.assert(messageAssert);
    }

    //Test 
    @isTest static void test_method_State() {
        TestHelper.createCustomSettingToByPassTriggersAndRules('Account, RPA__c, Opportunity, Funding_Estimate_Receivable__c, Funding_Estimates__c, '+
                                                                    'Opp_School__c');
        //createCalcClassData(Apex Class Name, Attendance Record Type, State Rate Card Record Type, District Rate Card Record Type)
        TestHelper.createCalcClassData('calc_CA_PENSEC_Initial_Payment_16_17', 'California', 'California States', 'California District');
        //get created opportunity in testhelper.
        oppty = [Select Id,Name from Opportunity where Name = 'Test Oppty' limit 1];
        Test.startTest();
        FinancialCalcController con = new FinancialCalcController(new ApexPages.StandardController(oppty));
        Test.stopTest();

		List<Apexpages.Message> msgs = ApexPages.getMessages();
		Boolean messageAssert = false;
		for(Apexpages.Message msg:msgs){
		    if (msg.getDetail().contains('CA PENSEC Initial Payment Calculation Failed. No Active State Rate Card found. Please contact your Salesforce Administrator.')) messageAssert = true;
			//System.debug(msg);
		}
		System.assert(messageAssert);

    }

    @isTest static void test_method_District() {
        TestHelper.createCustomSettingToByPassTriggersAndRules('Account, RPA__c, Opportunity, Funding_Estimate_Receivable__c, Funding_Estimates__c, '+
                                                                    'Opp_School__c');
        //createCalcClassData(Apex Class Name, Attendance Record Type, State Rate Card Record Type, District Rate Card Record Type)
        TestHelper.createCalcClassData('calc_CA_PENSEC_Initial_Payment_16_17', 'California', 'California State', 'California Districts');
        //get created opportunity in testhelper.
        oppty = [Select Id,Name from Opportunity where Name = 'Test Oppty' limit 1];
        Test.startTest();
        FinancialCalcController con = new FinancialCalcController(new ApexPages.StandardController(oppty));
        Test.stopTest();

		List<Apexpages.Message> msgs = ApexPages.getMessages();
		Boolean messageAssert = false;
		for(Apexpages.Message msg:msgs){
		    if (msg.getDetail().contains('CA PENSEC Initial Payment Calculation Failed. No Active District Rate Card found. Please contact your Salesforce Administrator.')) messageAssert = true;
			//System.debug(msg);
		}
		System.assert(messageAssert);


    }

}