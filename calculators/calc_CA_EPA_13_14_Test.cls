@isTest
private class calc_CA_EPA_13_14_Test{
  private static Opportunity oppty;
  private static School_Attendance__c att;												//2015.03.30 J Caughie - added for test coverage
    
    @isTest static void test_method_one() {
        TestHelper.createCustomSettingToByPassTriggersAndRules('Account, RPA__c, Opportunity, Funding_Estimate_Receivable__c, Funding_Estimates__c, '+
                                                                    'Opp_School__c');
        //createCalcClassData(Apex Class Name, Attendance Record Type, State Rate Card Record Type, District Rate Card Record Type)
		TestHelper.createCalcClassData('calc_CA_EPA_13_14', 'California', 'California State', 'California District');
		//get created opportunity in testhelper.
        oppty = [Select Id,Name from Opportunity where Name = 'Test Oppty' limit 1];
        att = [Select Id,Name from School_Attendance__c limit 1];						//2015.03.30 J Caughie - added for test coverage
        att.ADA_K_3__c = 1;																//2015.03.30 J Caughie - added for test coverage
        update att;                                                                     //2015.03.30 J Caughie - added for test coverage
        Test.startTest();
        FinancialCalcController con = new FinancialCalcController(new ApexPages.StandardController(oppty));
        Test.stopTest();
    }
}