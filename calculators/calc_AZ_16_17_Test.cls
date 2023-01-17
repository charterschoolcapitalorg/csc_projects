@isTest
private class calc_AZ_16_17_Test {
    private static Opportunity oppty;
    
    @isTest static void test_method_base_Attendance() {
        TestHelper.createCustomSettingToByPassTriggersAndRules('Account, RPA__c, Opportunity, Funding_Estimate_Receivable__c, Funding_Estimates__c, '+
                                                                    'Opp_School__c');
        //createCalcClassData(Apex Class Name, Attendance Record Type, State Rate Card Record Type, District Rate Card Record Type)
        TestHelper.createCalcClassData('calc_AZ_16_17', 'Arizona', 'Arizona', null);
        //get created opportunity in testhelper.
        oppty = [Select Id,Name from Opportunity where Name = 'Test Oppty' limit 1];
        Test.startTest();
        FinancialCalcController con = new FinancialCalcController(new ApexPages.StandardController(oppty));
        Test.stopTest();
        System.assert(con != null, 'Receivable value not generated');
    }

    //Test try/catch block on calculator class
    @isTest static void test_method_StateRateCard() {

        calc_AZ_16_17 az = new calc_AZ_16_17();
		Test.startTest();
		az.computeReceivable();
		Test.stopTest();

		List<Apexpages.Message> msgs = ApexPages.getMessages();
		Boolean messageAssert = false;
		for(Apexpages.Message msg:msgs){
		    if (msg.getDetail().contains('Arizona Calculation failed. No Active State Rate Card found. Please contact your Salesforce Administrator.')) messageAssert = true;
		}
		System.assert(messageAssert);
    }

    @isTest static void test_method_LOW_Attendance() {
        TestHelper.createCustomSettingToByPassTriggersAndRules('Account, RPA__c, Opportunity, Funding_Estimate_Receivable__c, Funding_Estimates__c, '+
                                                                    'Opp_School__c');
        //createCalcClassData(Apex Class Name, Attendance Record Type, State Rate Card Record Type, District Rate Card Record Type)
        TestHelper.createCalcClassData('calc_AZ_16_17', 'Arizona', 'Arizona', null);
        //get created opportunity in testhelper.
        oppty = [Select Id,Name from Opportunity where Name = 'Test Oppty' limit 1];
        School_Attendance__c sa = [Select id, Student_Count_K_8_AOI_Full__c, Student_Count_9_12_AOI_Full__c, Increase_for_200_Days_of_Instruction__c, Adjst_to_Additional_Assistance_Next_FY__c FROM School_Attendance__c];
        sa.Student_Count_K_8_AOI_Full__c = 401;
        sa.Student_Count_9_12_AOI_Full__c = 401;
        sa.Increase_for_200_Days_of_Instruction__c = true;
        sa.Adjst_to_Additional_Assistance_Next_FY__c = 500;
        update sa;
        Test.startTest();
        FinancialCalcController con = new FinancialCalcController(new ApexPages.StandardController(oppty));
        Test.stopTest();
        System.assert(con != null, 'Receivable value not generated');
    }

    @isTest static void test_method_MID_Attendance() {
        TestHelper.createCustomSettingToByPassTriggersAndRules('Account, RPA__c, Opportunity, Funding_Estimate_Receivable__c, Funding_Estimates__c, '+
                                                                    'Opp_School__c');
        //createCalcClassData(Apex Class Name, Attendance Record Type, State Rate Card Record Type, District Rate Card Record Type)
        TestHelper.createCalcClassData('calc_AZ_16_17', 'Arizona', 'Arizona', null);
        //get created opportunity in testhelper.
        oppty = [Select Id,Name from Opportunity where Name = 'Test Oppty' limit 1];
        School_Attendance__c sa = [Select id, Student_Count_K_8_AOI_Full__c, Student_Count_9_12_AOI_Full__c, Adjustment_to_Additional_Assistance__c FROM School_Attendance__c];
        sa.Student_Count_K_8_AOI_Full__c = 501;
        sa.Student_Count_9_12_AOI_Full__c = 501;
        sa.Adjustment_to_Additional_Assistance__c = 500;
        update sa;
        Test.startTest();
        FinancialCalcController con = new FinancialCalcController(new ApexPages.StandardController(oppty));
        Test.stopTest();
        System.assert(con != null, 'Receivable value not generated');
    }

    @isTest static void test_method_HIGH_Attendance() {
        TestHelper.createCustomSettingToByPassTriggersAndRules('Account, RPA__c, Opportunity, Funding_Estimate_Receivable__c, Funding_Estimates__c, '+
                                                                    'Opp_School__c');
        //createCalcClassData(Apex Class Name, Attendance Record Type, State Rate Card Record Type, District Rate Card Record Type)
        TestHelper.createCalcClassData('calc_AZ_16_17', 'Arizona', 'Arizona', null);
        //get created opportunity in testhelper.
        oppty = [Select Id,Name from Opportunity where Name = 'Test Oppty' limit 1];
        School_Attendance__c sa = [Select id, Student_Count_K_8_AOI_Full__c, Student_Count_9_12_AOI_Full__c FROM School_Attendance__c];
        sa.Student_Count_K_8_AOI_Full__c = 1001;
        sa.Student_Count_9_12_AOI_Full__c = 1001;
        update sa;
        Test.startTest();
        FinancialCalcController con = new FinancialCalcController(new ApexPages.StandardController(oppty));
        Test.stopTest();
        System.assert(con != null, 'Receivable value not generated');
    }

    @isTest static void test_method_Try_Error() {
        TestHelper.createCustomSettingToByPassTriggersAndRules('Account, RPA__c, Opportunity, Funding_Estimate_Receivable__c, Funding_Estimates__c, '+
                                                                    'Opp_School__c');
        //createCalcClassData(Apex Class Name, Attendance Record Type, State Rate Card Record Type, District Rate Card Record Type)
        TestHelper.createCalcClassData('calc_AZ_16_17', 'Arizona', 'Arizona', null);
        //get created opportunity in testhelper.
        oppty = [Select Id,Name from Opportunity where Name = 'Test Oppty' limit 1];
        School_Attendance__c sa = [Select id, Student_Count_K_8_AOI_Full__c, Student_Count_9_12_AOI_Full__c, Increase_for_200_Days_of_Instruction__c, Adjst_to_Additional_Assistance_Next_FY__c FROM School_Attendance__c];
        sa.Student_Count_K_8_AOI_Full__c = null;
        sa.Student_Count_9_12_AOI_Full__c = 401;
        sa.Increase_for_200_Days_of_Instruction__c = true;
        sa.Adjst_to_Additional_Assistance_Next_FY__c = 500;
        update sa;

        Test.startTest();
        FinancialCalcController con = new FinancialCalcController(new ApexPages.StandardController(oppty));
        Test.stopTest();
        
        List<Apexpages.Message> msgs = ApexPages.getMessages();
        Boolean messageAssert = false;
        for(Apexpages.Message msg:msgs){
		    if (msg.getDetail().contains('Arizona Calculation failed. Please contact your Salesforce Administrator.')) messageAssert = true;
		}

		System.assert(con != null, 'Receivable value not generated');
		System.assert(messageAssert);
    }

}