//
// (c) 2014 Appirio, Inc.
//
// Test Class for FinancialCalcController.
//
//  9 Jun, 2014 Aditi Bhardwaj original.
//
//
@isTest
private class FinancialCalcControllerTest {
	static Opportunity opp;
	static List<Funding_Estimate_Receivable__c> listReceivable;
	static Funding_Estimates__c fundingEst;


	// A Method which create test data
	private static void createTestData(){

		TestHelper.createCustomSettingToByPassTriggersAndRules('Account, RPA__c, Opportunity, Funding_Estimate_Receivable__c, Funding_Estimates__c, '+
																	'Opp_School__c');


		Financial_Calc_Settings__c finCalc = Financial_Calc_Settings__c.getOrgDefaults();
        finCalc.NameSpacePrefix__c = '';
        upsert finCalc;

        //Initialize Record Type.
         Map<String,RecordType> rtMap = TestHelper.createRecordTypeMap();

		//Create Charter School.
        Account acc = TestHelper.createAccountForRecordType(rtMap.get('Charter_Holder').Id,'ABC Charter Holder');

		Account RPAAccount = TestHelper.createRPAAccount(acc.Id);
		insert RPAAccount;




		RPA__c rpa = new RPA__c();
		rpa.Account__c = RPAAccount.Id;
		insert rpa;

		opp = TestHelper.createOpportunity(acc, 'Test Opp');
		insert Opp;



		fundingEst = TestHelper.createFundingEstimate(opp.Id);
		insert fundingEst;

		State_Province__c state =  TestHelper.createStateProvince('California', true);
		Rate_Card__c rateCard1 = TestHelper.createRateCard(state.Id, null , true, true);


		Rate_Card__c rateCard2 = TestHelper.createRateCard(null, RPAAccount.Id , true, true);


		//Create School
        Account school = TestHelper.createAccountForRecordType((rtMap.get('School')).Id,'ABC School 1');
		school.Operating_State__c = state.Id;
		school.School_District__c = RPAAccount.Id;
		school.COE__c = RPAAccount.Id;
		school.ParentId = acc.Id;
		update school;

		Opp_School__c oppSchool = testHelper.createOppSchool(opp, school);

		system.debug('------Opp School--------' + oppSchool);

		//Create Payor
  	    Payor__c statePayor = testHelper.createPayor('California');
        statePayor.State_Province__c = state.Id;
        update statePayor;

		//Create Receivable Types.
	    Receivable_Type__c type1 = testHelper.createReceivableType(statePayor,'CA-EPA');
	    type1.Active__c = true;
	    type1.Fiscal_Year__c = '10-11';
	    update type1;

		//Create Calculations.
  		Calculation__c c1 = testHelper.createCalculation(type1,'calc_OH_13_14');

        List<RecordType> recordTypeList = [Select Id,Name,
                                                  DeveloperName
                                           From RecordType
                                           Where sObjectType = 'School_Attendance__c'
                                            and Name = 'Ohio' LIMIT 1];

        //School Attendance
        School_Attendance__c schAttnd = TestHelper.createSchoolAttendance(school);
        schAttnd.RecordTypeId = recordTypeList.get(0).Id;
        schAttnd.Active__c = true;
        schAttnd.Opportunity_Grant__c = 1000;
        schAttnd.Targeted_Assistance__c = 1000;
        schAttnd.K_3_Literacy__c = 0;
        schAttnd.Economic_Disadvantaged_Funding__c = 0;
        schAttnd.Limited_English_Proficiency__c = 10;
        schAttnd.Special_Education_Funding__c = 10;
        schAttnd.Career_Technical_Funding__c = 10;
        schAttnd.Transportation__c = 1000;
        schAttnd.Fiscal_Year__c = '13-14';
        schAttnd.Prior_Period_YTD_Total_State_Support__c = 1000;
        schAttnd.Attendance_Type__c = '12 - June';
        schAttnd.Actual_Payment_Net__c = 0;
        schAttnd.Facilities_Adjustment__c = 0;
        schAttnd.ESC_Deduction__c = 0;
        schAttnd.State_Teacher_Retirement__c = 0;
        schAttnd.School_Employee_Retirement__c = 0;
        schAttnd.Audit_Adjustments__c = 0;
        schAttnd.Sponsor_Fee_Deduction__c = 0;
        schAttnd.JV44__c = 0;
        update schAttnd;

  		//Create Payout Dates for both calculations.
  		Payout_Date__c   payout  = testHelper.createPayoutDate(50,c1, System.today() + 2, 'Test Payout Date');


		listReceivable = new list<Funding_Estimate_Receivable__c>();
		listReceivable.add(TestHelper.createFundingEstimateReceivable(fundingEst.Id, oppSchool.Id));
		insert listReceivable;

		Funded_Receivable__c fundedReceivable = TestHelper.createFundedReceivable( payout.Id, 2, school.Id,  rpa.Id);
		insert fundedReceivable;



	}

    // A test method for financialCalcController
    static testMethod void financialCalcControllerTest() {
	   	Test.StartTest();
			createTestData();
		    ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(opp);
		    FinancialCalcController fCalc = new FinancialCalcController(stdController);

		    // verify constructor
		    System.AssertNotEquals(fCalc.oppty, null);


		    // Verify PrepareMap Method
		    System.assertNotEquals(fCalc.receivableToInsert, null);

		    // Verify ProcessMap Method
		    //System.assertEquals(fCalc.receivableToInsert.size(), 1);

		    fCalc.saveReceivables();
		    fCalc.applyAmortization();

		    PageReference pageRef = fCalc.cancel();

		    System.assertNotEquals(pageRef, null);

		    // 06/20/2014 : Manisha Gupta : Update to increase code coverage
		    FinancialCalcModel calModel = new FinancialCalcModel();
			FinancialCalcController.sortList(listReceivable, 'Name', 'asc');
		    FinancialCalcController.sortList(listReceivable, 'Name', 'desc');

	    Test.stopTest();

    }
}