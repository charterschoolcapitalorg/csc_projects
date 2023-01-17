@isTest
private class calc_FL_Apr2_June2_13_14_Test {
	private static Opportunity oppty;
    
    @isTest static void test_method_one() {
        TestHelper.createCustomSettingToByPassTriggersAndRules('Account, RPA__c, Opportunity, Funding_Estimate_Receivable__c, Funding_Estimates__c, '+
                                                                    'Opp_School__c');
        //createCalcClassData(Apex Class Name, Attendance Record Type, State Rate Card Record Type, District Rate Card Record Type)
        TestHelper.createCalcClassData('calc_FL_Apr2_June2_13_14', 'Florida', 'Florida State', 'Florida District');
        //get created opportunity in testhelper.
        oppty = [Select Id,Name from Opportunity where Name = 'Test Oppty' limit 1];
        Test.startTest();
        FinancialCalcController con = new FinancialCalcController(new ApexPages.StandardController(oppty));
        Test.stopTest();
    }
}