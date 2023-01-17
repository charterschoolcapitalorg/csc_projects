@isTest
private class calc_CA_SB740_FinalApportionment_Test{
  private static Opportunity oppty;
  private static School_Attendance__c att;
    
    @isTest static void test_method_one() {
        TestHelper.createCustomSettingToByPassTriggersAndRules('Account, RPA__c, Opportunity, Funding_Estimate_Receivable__c, Funding_Estimates__c, '+
                                                                    'Opp_School__c');
        //createCalcClassData(Apex Class Name, Attendance Record Type, State Rate Card Record Type, District Rate Card Record Type)
        TestHelper.createCalcClassData('calc_CA_SB740_FinalApportionment', 'California', 'California State', 'California District');
        //get created opportunity in testhelper.
        oppty = [Select Id,Name from Opportunity where Name = 'Test Oppty' limit 1];
        att = [Select Id,Name, SB740_Grant_Amount__c, SB740_Paid__c from School_Attendance__c limit 1];                     //2015.03.30 J Caughie - added for test coverage
        att.SB740_Grant_Amount__c = 1;                                                                                      //2015.03.30 J Caughie - added for test coverage
        att.SB740_Paid__c = 1;
        att.Fiscal_Year__c = '98-99';
        update att;

        Test.startTest();
        FinancialCalcController con = new FinancialCalcController(new ApexPages.StandardController(oppty));
        Test.stopTest();
    }
}