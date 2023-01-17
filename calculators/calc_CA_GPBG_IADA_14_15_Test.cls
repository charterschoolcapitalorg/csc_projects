@isTest
private class calc_CA_GPBG_IADA_14_15_Test{
  private static Opportunity oppty;
  private static School_Attendance__c att;
    
    @isTest static void test_method_one() {
        TestHelper.createCustomSettingToByPassTriggersAndRules('Account, RPA__c, Opportunity, Funding_Estimate_Receivable__c, Funding_Estimates__c, '+
                                                                    'Opp_School__c');
        //createCalcClassData(Apex Class Name, Attendance Record Type, State Rate Card Record Type, District Rate Card Record Type)
        TestHelper.createCalcClassData('calc_CA_GPBG_IADA_P1_14_15', 'California', 'California State', 'California District');
        //get created opportunity in testhelper.
        oppty = [Select Id,Name from Opportunity where Name = 'Test Oppty' limit 1];
        att = [Select Id,Name from School_Attendance__c limit 1];
        att.ADA_K_3__c = 1;
        att.IADA_K_3_Period_1__c = 2;
        att.Number_of_instructional_days_Period_1__c = 30;
        att.Total_Instructional_Days__c = 100;
        att.Total_Students__c = 1;
        update att;
        Test.startTest();
        FinancialCalcController con = new FinancialCalcController(new ApexPages.StandardController(oppty));
        Test.stopTest();
    }
    
    @isTest static void test_method_two() {
        TestHelper.createCustomSettingToByPassTriggersAndRules('Account, RPA__c, Opportunity, Funding_Estimate_Receivable__c, Funding_Estimates__c, '+
                                                                    'Opp_School__c');
        //createCalcClassData(Apex Class Name, Attendance Record Type, State Rate Card Record Type, District Rate Card Record Type)
        TestHelper.createCalcClassData('calc_CA_GPBG_IADA_P2_14_15', 'California', 'California State', 'California District');
        //get created opportunity in testhelper.
        oppty = [Select Id,Name from Opportunity where Name = 'Test Oppty' limit 1];
        att = [Select Id,Name from School_Attendance__c limit 1];
        att.ADA_K_3__c = 1;
        att.IADA_K_3_Period_2__c = 2;
        att.Number_of_instructional_days_Period_2__c = 30;
        att.Total_Instructional_Days__c = 100;
        att.Total_Students__c = 1;
        update att;
        Test.startTest();
        FinancialCalcController con = new FinancialCalcController(new ApexPages.StandardController(oppty));
        Test.stopTest();
    }
    
    @isTest static void test_method_three() {
        TestHelper.createCustomSettingToByPassTriggersAndRules('Account, RPA__c, Opportunity, Funding_Estimate_Receivable__c, Funding_Estimates__c, '+
                                                                    'Opp_School__c');
        //createCalcClassData(Apex Class Name, Attendance Record Type, State Rate Card Record Type, District Rate Card Record Type)
        TestHelper.createCalcClassData('calc_CA_GPBG_IADA_P3_14_15', 'California', 'California State', 'California District');
        //get created opportunity in testhelper.
        oppty = [Select Id,Name from Opportunity where Name = 'Test Oppty' limit 1];
        att = [Select Id,Name from School_Attendance__c limit 1];
        att.ADA_K_3__c = 1;
        att.IADA_K_3_Period_3__c = 2;
        att.Number_of_instructional_days_Period_3__c = 30;
        att.Total_Instructional_Days__c = 100;
        att.Total_Students__c = 1;
        update att;
        Test.startTest();
        FinancialCalcController con = new FinancialCalcController(new ApexPages.StandardController(oppty));
        Test.stopTest();
    }
    
    @isTest static void test_method_four() {
        TestHelper.createCustomSettingToByPassTriggersAndRules('Account, RPA__c, Opportunity, Funding_Estimate_Receivable__c, Funding_Estimates__c, '+
                                                                    'Opp_School__c');
        //createCalcClassData(Apex Class Name, Attendance Record Type, State Rate Card Record Type, District Rate Card Record Type)
        TestHelper.createCalcClassData('calc_CA_GPBG_IADA_P4_14_15', 'California', 'California State', 'California District');
        //get created opportunity in testhelper.
        oppty = [Select Id,Name from Opportunity where Name = 'Test Oppty' limit 1];
        att = [Select Id,Name from School_Attendance__c limit 1];
        att.ADA_K_3__c = 1;
        att.IADA_K_3_Period_4__c = 2;
        att.Number_of_instructional_days_Period_4__c = 30;
        att.Total_Instructional_Days__c = 100;
        att.Total_Students__c = 1;
        update att;
        Test.startTest();
        FinancialCalcController con = new FinancialCalcController(new ApexPages.StandardController(oppty));
        Test.stopTest();
    }
    
    @isTest static void test_method_five() {
        TestHelper.createCustomSettingToByPassTriggersAndRules('Account, RPA__c, Opportunity, Funding_Estimate_Receivable__c, Funding_Estimates__c, '+
                                                                    'Opp_School__c');
        //createCalcClassData(Apex Class Name, Attendance Record Type, State Rate Card Record Type, District Rate Card Record Type)
        TestHelper.createCalcClassData('calc_CA_GPBG_IADA_P5_14_15', 'California', 'California State', 'California District');
        //get created opportunity in testhelper.
        oppty = [Select Id,Name from Opportunity where Name = 'Test Oppty' limit 1];
        att = [Select Id,Name from School_Attendance__c limit 1];
        att.ADA_K_3__c = 1;
        att.IADA_K_3_Period_5__c = 2;
        att.Number_of_instructional_days_Period_5__c = 30;
        att.Total_Instructional_Days__c = 100;
        att.Total_Students__c = 1;
        update att;
        Test.startTest();
        FinancialCalcController con = new FinancialCalcController(new ApexPages.StandardController(oppty));
        Test.stopTest();
    }
    
    @isTest static void test_method_six() {
        TestHelper.createCustomSettingToByPassTriggersAndRules('Account, RPA__c, Opportunity, Funding_Estimate_Receivable__c, Funding_Estimates__c, '+
                                                                    'Opp_School__c');
        //createCalcClassData(Apex Class Name, Attendance Record Type, State Rate Card Record Type, District Rate Card Record Type)
        TestHelper.createCalcClassData('calc_CA_GPBG_IADA_P6_14_15', 'California', 'California State', 'California District');
        //get created opportunity in testhelper.
        oppty = [Select Id,Name from Opportunity where Name = 'Test Oppty' limit 1];
        att = [Select Id,Name from School_Attendance__c limit 1];
        att.ADA_K_3__c = 1;
        att.IADA_K_3_Period_6__c = 2;
        att.Number_of_instructional_days_Period_6__c = 30;
        att.Total_Instructional_Days__c = 100;
        att.Total_Students__c = 1;
        update att;
        Test.startTest();
        FinancialCalcController con = new FinancialCalcController(new ApexPages.StandardController(oppty));
        Test.stopTest();
    }
}