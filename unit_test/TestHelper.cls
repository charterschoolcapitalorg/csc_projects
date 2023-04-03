public class TestHelper{

    private static RecordType charterRt;
    private static RecordType schoolRt;
    private static Map<String,RecordType> recordTypeMap;
    private static Map<String, RecordType> receivableTypeMap;

    public static Map<String,RecordType> createRecordTypeMap(){
        List<RecordType> recordTypeList = [Select Id,Name,
                                                  DeveloperName
                                           From RecordType
                                           Where sObjectType = 'Account'
                                            and (DeveloperName = 'Charter_Holder'
                                             Or developerName = 'School'
                                             or developerName = 'Investor'
                                             or developerName = 'COE_District'
                                             or developerName = 'Property'
                                             or developerName = 'Business')];

        recordTypeMap = new Map<String,RecordType>();

        for(RecordType rt : recordTypeList){
            recordTypeMap.put(rt.developerName,rt);
        }

        return recordTypeMap;
    }

    //2017.03.22 J Caughie - Additional methods for loan testing
        public static Map<String,RecordType> createReceivableTypeMap(){
        List<RecordType> receivableTypeList = [Select Id,Name,
                                                  DeveloperName
                                           From RecordType
                                           Where sObjectType = 'Funded_Receivable__c'
                                            and (DeveloperName = 'Funded_Receivable'
                                             Or developerName = 'Loan')];

        receivableTypeMap = new Map<String,RecordType>();

        for(RecordType rt : receivableTypeList){
            receivableTypeMap.put(rt.developerName,rt);
        }

        return receivableTypeMap;
    }
    //2017.03.22 J Caughie - Additional methods for loan testing

    public static Map<String,RecordType> createRateCardRecordTypeMap(){
        List<RecordType> recordTypeList = [Select Id,Name
                                           From RecordType
                                           Where sObjectType = 'Rate_Card__c'];

        recordTypeMap = new Map<String,RecordType>();

        for(RecordType rt : recordTypeList){
            recordTypeMap.put(rt.Name,rt);
        }

        return recordTypeMap;
    }

    public static Map<String,RecordType> createAttendanceRecordTypeMap(){
        List<RecordType> recordTypeList = [Select Id,Name
                                           From RecordType
                                           Where sObjectType = 'School_Attendance__c'];

        recordTypeMap = new Map<String,RecordType>();

        for(RecordType rt : recordTypeList){
            recordTypeMap.put(rt.Name,rt);
        }

        return recordTypeMap;
    }

    public static void createSeedDataForTesting(){
        //Create Custom settings.
        Financial_Calc_Settings__c finCalc = Financial_Calc_Settings__c.getOrgDefaults();
        finCalc.NameSpacePrefix__c = '';
        upsert finCalc;

        //Initialize Record Type.
        Map<String,RecordType> rtMap = createRecordTypeMap();

        //Create State
        State_Province__c state = createStateProvince('TT',true);

        //Create Charter School.
        Account charterSch = createAccountForRecordType(rtMap.get('Charter_Holder').Id,'ABC Charter Holder');
        charterSch.Operating_State__c = state.Id;
        update charterSch;

        //Create COE/District.
        Account coeDist = createAccountForRecordType(rtMap.get('COE_District').Id,'ABC COE/District');
        coeDist.Operating_State__c = state.Id;
        update coeDist;

        //Create Opportunity.
        Opportunity opp = createOpportunity(charterSch,'ABC School Funding 2014');
        insert opp;

        //Create School
        Account school = createAccountForRecordType((rtMap.get('School')).Id,'ABC School 1');
        school.Charter_Holder__c = chartersch.Id;
        school.ParentId = chartersch.Id;
        school.Operating_State__c = state.Id;
        school.COE__c = coeDist.Id;
        school.School_District__c = coeDist.Id;
        update school;

        //Create Opportunity School.
        Opp_school__c oppSchool = createOppSchool(opp,school);
        system.debug('oppSchool - ' + oppSchool);

        //Create Payor
        Payor__c statePayor = createPayor('Test Payor');
        statePayor.State_Province__c = state.Id;
        update statePayor;

        //Create Receivable Types.
        Receivable_Type__c type1 = createReceivableType(statePayor,'Test Calc Receivable');

        //Create Calculations.
        Calculation__c c1 = createCalculation(type1,'calc_TestCalc');

        //Create Payout Dates for both calculations.
        createPayoutDate(50,c1,Date.newInstance(2099,6,1),'June');
        createPayoutDate(50,c1,Date.newInstance(2099,12,1),'December');
        createPayoutDate(100,c1,Date.newInstance(2099,10,1),'January');

        //School Attendance
        createSchoolAttendance(school);

        //Rate Card
        createRateCard(state.Id,null,true,true);
        createRateCard(null,coeDist.Id,true,true);
    }

    public static School_Attendance__c createSchoolAttendance(Account schAtt){
        School_Attendance__c attendance = new School_Attendance__c();
        attendance.School__c = schAtt.Id;
        attendance.Report_Date__c = date.today();
        attendance.Active__c = true;
        insert attendance;
        return attendance;
    }

    public static Payout_Date__c createPayoutDate(Integer percentVal,Calculation__c calc,Date payDate,String outName){
        Payout_Date__c pDate = new Payout_Date__c();
        pDate.Percent_Value_of_Receivable__c = percentVal;
        pDate.Calculation__c = calc.Id;
        pDate.Default_Payout_Date__c = payDate;
        pDate.Default_Distribution_Date__c = payDate;
        pDate.Output_Name__c = outName;
        pDate.Active__c = true;

        insert pDate;
        return pDate;
    }

    public static Payout_Date__c createPayoutDateNoInsert(Integer percentVal,Calculation__c calc,Date payDate,String outName){
        Payout_Date__c pDate = new Payout_Date__c();
        pDate.Percent_Value_of_Receivable__c = percentVal;
        pDate.Calculation__c = calc.Id;
        pDate.Default_Payout_Date__c = payDate;
        pDate.Default_Distribution_Date__c = payDate;
        pDate.Output_Name__c = outName;

        return pDate;
    }

    public static Calculation__c createCalculation(Receivable_Type__c rType , String apexClassName){
        Calculation__c calculation = new Calculation__c();
        calculation.Apex_Class_Name__c = apexClassName;
        calculation.Receivable_Type__c = rType.Id;

        insert calculation;
        return calculation;
    }

    public static Calculation__c createCalculationNoInsert(Receivable_Type__c rType , String apexClassName){
        Calculation__c calculation = new Calculation__c();
        calculation.Apex_Class_Name__c = apexClassName;
        calculation.Receivable_Type__c = rType.Id;
        return calculation;
    }

    public static Receivable_Type__c createReceivableType(Payor__c statePayor, String typeName){
        Receivable_Type__c rType = new Receivable_Type__c();
        rType.Name = typeName;
        rType.Payor__c = statePayor.Id;
        rType.Active__c = true;

        insert rType;
        return rType;
    }

    public static Payor__c createPayor(String payorName){
        Payor__c payor = new Payor__c();
        payor.Name = payorName;

        insert payor;
        return payor;
    }

    public static Opp_School__c createOppSchool(Opportunity opp, Account schAcc){
        Opp_School__c oppSch = new Opp_School__C();
        oppSch.Opportunity__c = opp.Id;
        oppSch.School__c = schAcc.Id;

        insert oppSch;
        return oppSch;
    }

    public static Opportunity createOpportunity(Account acc,String oppName){
        Opportunity opp = new Opportunity();
        opp.Name = oppName;
        opp.CloseDate = Date.today().addDays(20);
        opp.StageName = 'Prospecting';
        opp.AccountId = acc.ID;
        opp.RecordTypeId = RecordTypeUtils.OpportunityFOF.Id;                                            //2016.01.19 J Caughie - Added FOF record type
        //insert opp;
        return opp;
    }

    public static Account createAccountForRecordType(Id recordTypeId,String name){
        Account a = new Account();
        a.Name = name;
        a.RecordTypeId = recordTypeId;

        insert a;
        return a;
    }

    public static Account createAccountForRecordTypeNoInsert(Id recordTypeId,String name){
        Account a = new Account();
        a.Name = name;
        a.RecordTypeId = recordTypeId;

        return a;
    }

    public static Rate_Card__c createRateCard(String stateId, String coeDistrictId, boolean isActive, boolean isInsert){
        Rate_Card__c rateCard = new Rate_Card__c();
        rateCard.State_Province__c = stateId;
        rateCard.COE_District__c = coeDistrictId;
        rateCard.Active__c = isActive;
        if(isInsert){
            insert rateCard;
        }
        return rateCard;
    }

    public static State_Province__c createStateProvince(String name, boolean isInsert){
        State_Province__c state = new State_Province__c();
        state.Active__c = true;
        state.Name = name;
        state.State_Name__c = name;
        if(isInsert){
            insert state;
        }
        return state;
    }

    public static void createCalcClassData(String apexClassName,String attendanceRecordType, String stateRateCardRecordType, String distRateCardRecordType){
        //Initialize Record Type.
        Map<String,RecordType> rtMap = createRecordTypeMap();
        Map<String,RecordType> rateCardRTMap = createRateCardRecordTypeMap();
        Map<String,RecordType> attendanceRTMap = createAttendanceRecordTypeMap();

        //Create State
        State_Province__c state = createStateProvince('TT',true);

        //Create Charter School.
        Account charterSch = createAccountForRecordType(rtMap.get('Charter_Holder').Id,'ABC Charter Holder');
        charterSch.Operating_State__c = state.Id;
        update charterSch;

        //Create COE/District.
        Account coeDist = createAccountForRecordType(rtMap.get('COE_District').Id,'ABC COE/District');
        coeDist.Operating_State__c = state.Id;
        update coeDist;

        //Create Opportunity.
        Opportunity opp = createOpportunity(charterSch,'Test Oppty');
        insert opp;

        //Create School
        Account school = createAccountForRecordType((rtMap.get('School')).Id,'ABC School 1');
        school.Charter_Holder__c = chartersch.Id;
        school.ParentId = chartersch.Id;
        school.Operating_State__c = state.Id;
        school.COE__c = coeDist.Id;
        school.School_District__c = coeDist.Id;
        update school;

        //Create Opportunity School.
        Opp_school__c oppSchool = createOppSchool(opp,school);
        system.debug('oppSchool - ' + oppSchool);

        //Create Payor
        Payor__c statePayor = createPayor('Test Payor');
        statePayor.State_Province__c = state.Id;
        update statePayor;

        //Create Receivable Type.
        Receivable_Type__c type1 = createReceivableType(statePayor,'Test Calc Receivable This FY');
        type1.Fiscal_Year__c = '98-99';
        update type1;
        Receivable_Type__c type2 = createReceivableType(statePayor,'Test Calc Receivable Last FY');
        type2.Fiscal_Year__c = '97-98';
        update type2;
        Receivable_Type__c type3 = createReceivableType(statePayor,'Test Calc Receivable Next FY');
        type3.Fiscal_Year__c = '99-00';
        update type3;

        //Create Calculation.
        Calculation__c c1 = createCalculation(type1,apexClassName);
        Calculation__c c2 = createCalculation(type2,apexClassName);
        Calculation__c c3 = createCalculation(type3,apexClassName);

        //Create Payout Date
        createPayoutDate(100,c1,Date.newInstance(2098,10,1),'January');
        createPayoutDate(100,c2,Date.newInstance(2097,10,1),'January');
        createPayoutDate(100,c3,Date.newInstance(2099,10,1),'January');

        //School Attendance
        createFullSchoolAttendance(school,attendanceRTMap.get(attendanceRecordType).Id);

        //Regional attendance - J Caughie 2014.11.17
        List<School_Attendance__c> schAttList = [Select Id
                                From School_Attendance__c LIMIT 1];
        School_Attendance__c schAttLimit = new School_Attendance__c();
        schAttLimit = schAttList[0];
        createRegionalAttendance(coeDist.Id, schAttLimit);

        List<Regional_Attendance__c> regAttList = [Select Id, District__c, School_Attendance__c, Enrollment_Last_Feb__c
                                From Regional_Attendance__c];
        System.debug(regAttList);    
        //Regional Attendance - J Caughie 2014.11.17

        //Rate Card
        if(rateCardRTMap.get(stateRateCardRecordType) != null){
            createFullRateCard(state.Id,null,rateCardRTMap.get(stateRateCardRecordType).Id);
        }
        if(rateCardRTMap.get(distRateCardRecordType) != null){
            createFullRateCard(null,coeDist.Id,rateCardRTMap.get(distRateCardRecordType).Id);
        }
    }

    public static Rate_Card__c createFullRateCard(Id stateId, Id coeDistrictId, Id recordTypeId){
        Rate_Card__c rateCard = new Rate_Card__c();
        rateCard.State_Province__c = stateId;
        rateCard.COE_District__c = coeDistrictId;
        rateCard.Active__c = true;
        rateCard.RecordTypeId = recordTypeId;
        rateCard.Fiscal_Year__c = '98-99';

        //populate all fields that do not have a default value
        rateCard.Ortho_Impairment_Resource_Rate__c = 1.00;
        rateCard.X254_ESE_Level_4_9_12_PCF__c = 1.00;
        rateCard.X112_Basic_4_8_w_ESE_PCF__c = 1.00;
        rateCard.X111_K_3_ESE_Level_2_Rate__c = 1.00;
        rateCard.Full_Rate_9_12__c = 1.00;
        rateCard.Base_Rate_K_3__c = 1.00;
        rateCard.X113_Basic_9_12_w_ESE_PCF__c = 1.00;
        rateCard.X102_Basic_4_8_PCF__c = 1.00;
        rateCard.Emotionally_Disabled_Private_Rate__c = 1.00;
        rateCard.Lottery_Discretionary_Funds__c = 1.00;
        rateCard.Transport_Allocation_per_Base_Student__c = 1.00;
        rateCard.Full_Rate_4_6__c = 1.00;
        rateCard.X130_ESOL_PK_3_PCF__c = 1.00;
        rateCard.Holdback_This_FY__c = 1.00;
        rateCard.Supplemental_Academic_Instruction__c = 1.00;
        rateCard.Preschool_Severe_Delay_Rate__c = 1.00;
        rateCard.Sparsity_Supplement__c = 1.00;
        rateCard.X111_K_3_ESE_Level_1_Rate__c = 1.00;
        rateCard.X113_9_12_ESE_Level_1_Rate__c = 1.00;
        rateCard.Extra_Funds_Rate_4_6__c = 1.00;
        rateCard.Safe_Schools_Allocation__c = 1.00;
        rateCard.Multiple_Disabilities_SSI_Rate__c = 1.00;
        rateCard.MDR_AR_and_SMRR_Rate__c = 1.00;
        rateCard.Moderate_Mental_Retardation_Rate__c = 1.00;
        rateCard.Base_Student_Allocation__c = 1.00;
        rateCard.Transport_Allocation_per_ESE_Student__c = 1.00;
        rateCard.Declining_Enrollment_Supplement__c = 1.00;
        rateCard.Visual_Impairment_Rate__c = 1.00;
        rateCard.MDSC_ASC_and_SMRSC_Rate__c = 1.00;
        rateCard.Base_Rate_4_6__c = 1.00;
        rateCard.Gap_Percent__c = 1.00;
        rateCard.K_3_Reading_Rate__c = 1.00;
        rateCard.Total_Proration_to_Funds_Available__c = 1.00;
        rateCard.X255_ESE_Level_5_4_8_PCF__c = 1.00;
        rateCard.Full_Rate_7_8__c = 1.00;
        rateCard.Weighted_FTE__c = 1.00;
        rateCard.Teacher_Salary_Allocation__c = 1.00;
        rateCard.Prorated_Class_Size_Alloc_Factors_K_3__c = 1.00;
        rateCard.Unweighted_FTE__c = 1.00;
        rateCard.X255_ESE_Level_5_PK_3_PCF__c = 1.00;
        rateCard.Full_Rate_K_3__c = 1.00;
        rateCard.K_3_Rate__c = 1.00;
        rateCard.Discretionary_Tax_Compression__c = 1.00;
        rateCard.X112_4_8_ESE_Level_2_Rate__c = 1.00;
        rateCard.Instructional_Materials_Allocation__c = 1.00;
        rateCard.Additional_Assistance_K_8_Rate__c = 1.00;
        rateCard.X101_Basic_K_3_PCF__c = 1.00;
        rateCard.Spec_Ed_Rate__c = 1.00;
        rateCard.X300_Career_Education_9_12_PCF__c = 1.00;

        rateCard.Base_Rate_9_12__c = 1.00;
        rateCard.X130_ESOL_9_12_PCF__c = 1.00;
        rateCard.X111_K_3_ESE_Level_3_Rate__c = 1.00;
        rateCard.Ortho_Impairment_Self_Cont_Rate__c = 1.00;
        rateCard.X130_ESOL_4_8_PCF__c = 1.00;
        rateCard.X112_4_8_ESE_Level_3_Rate__c = 1.00;
        rateCard.Additional_Assistance_9_12_Rate__c = 1.00;
        rateCard.DD_ED_MIMR_SLD_SLI_OHI_Rate__c = 1.00;
        rateCard.Default_Additional_Assistance_Rate__c = 1.00;
        rateCard.X103_Basic_9_12_PCF__c = 1.00;
        rateCard.Extra_Funds_Rate_9_12__c = 1.00;
        rateCard.Extra_Funds_Rate_K_3__c = 1.00;
        rateCard.State_Funded_Discretionary_Contribution__c = 1.00;
        rateCard.X255_ESE_Level_5_9_12_PCF__c = 1.00;
        rateCard.Extra_Funds_Rate_7_8__c = 1.00;
        rateCard.X254_ESE_Level_4_4_8_PCF__c = 1.00;
        rateCard.Holdback_Last_FY__c = 1.00;
        rateCard.Base_Rate_7_8__c = 1.00;
        rateCard.X112_4_8_ESE_Level_1_Rate__c = 1.00;
        rateCard.Additional_Assistance_PSD_Rate__c = 1.00;
        rateCard.Prorated_Class_Size_Alloc_Factors_4_8__c = 1.00;
        rateCard.ELL_English_Learners_Rate__c = 1.00;
        rateCard.In_Lieu_Rate__c = 1.00;
        rateCard.Additional_Allocation__c = 1.00;
        rateCard.X113_9_12_ESE_Level_2_Rate__c = 1.00;
        rateCard.Hearing_Impairment_Rate__c = 1.00;
        rateCard.BSL_Base_Level_Rate__c = 1.00;
        rateCard.Total_Disc__c = 1.00;
        rateCard.EPA_Offset_Percent__c = 1.00;
        rateCard.X113_9_12_ESE_Level_3_Rate__c = 1.00;
        rateCard.District_Rate_Percent__c = 1.00;
        rateCard.District_Cost_Differential__c = 1.00;
        rateCard.X254_ESE_Level_4_PK_3_PCF__c = 1.00;
        rateCard.X111_Basic_K_3_w_ESE_PCF__c = 1.00;
        rateCard.Prorated_Class_Size_Alloc_Factors_9_12__c = 1.00;
        rateCard.SB740_Max_Rate_Per_ADA__c = 1.00;                                                                 //2014.11.21 J Caughie added for SB740 test
        rateCard.EPA_PENSEC_Rate__c = 1.00;
        rateCard.Total_Funds_Compression_Allocation__c = 1.00;
        rateCard.Declining_Enrollment_Supplement__c = 1.00;
        rateCard.Sparsity_Supplement__c =  1.0;
        rateCard.Reading_Allocation__c = 1.0;
        rateCard.Total_Disc__c = 1.0;
        rateCard.Total_Proration_to_Funds_Available__c = 1.0;
        rateCard.Lottery_Discretionary_Funds__c = 1.0;
        rateCard.Mental_Health_Assistance_Allocation__c = 1.0;


        insert rateCard;
        return rateCard;
    }

    public static School_Attendance__c createFullSchoolAttendance(Account schAtt, Id recordTypeId){
        School_Attendance__c attendance = new School_Attendance__c();
        attendance.School__c = schAtt.Id;
        attendance.Report_Date__c = date.today();
        attendance.Active__c = true;
        attendance.RecordTypeId = recordTypeId;
        attendance.Fiscal_Year__c = '98-99';

        //populate all fields that do not have a default value:
        attendance.Pupil_FTE__c = 1.00;
        attendance.Opportunity_Grant__c = 1.00;
        attendance.Facilities_Adjustment__c = 1.00;
        attendance.Reading_Allocation__c = 1.00;
        attendance.Student_Transportation_ESE_Riders__c = 1.00;
        attendance.Transportation__c = 1.00;
        attendance.Limited_English_Proficiency__c = 1.00;
        attendance.Total_ESE_Allocation__c = 1.00;
        attendance.Audit_Adjustments__c = 1.00;
        attendance.Attendance_Type__c = '11 - Test';
        attendance.Economic_Disadvantaged_Funding__c = 1.00;
        attendance.Prior_Year_Adjustments__c = 1.00;
        attendance.Food_Service_Allocation__c = 1.00;
        attendance.Targeted_Assistance__c = 1.00;
        attendance.Student_Transportation_All_Riders__c = 1.00;
        attendance.State_Teacher_Retirement__c = 1.00;
        attendance.School_Employee_Retirement__c = 1.00;
        attendance.Sponsor_Fee_Deduction__c = 1.00;
        attendance.Periods_Remaining__c = 1.00;
        attendance.Prior_Period_YTD_Total_State_Support__c = 1.00;
        attendance.Special_Education_Funding__c = 1.00;
        attendance.Paid_Year_to_Date__c = 1.00;
        attendance.JV44__c = 1.00;
        attendance.Actual_Payment_Net__c = 1.00;
        attendance.Career_Technical_Funding__c = 1.00;
        attendance.Report_Date__c = Date.newinstance(2014,6,20);
        attendance.ESC_Deduction__c = 1.00;
        attendance.FL_Teachers_Lead_Program_Stipend__c = 1.00;
        attendance.K_3_Literacy__c = 1.00;
        attendance.This_FY_October_Data_Included__c = true;
        attendance.This_FY_February_Data_Included__c = true;
        attendance.Last_FY_February_Data_Included__c = true;
        attendance.ADM_Last_FY__c = 1.00;
        attendance.ADM_This_FY__c = 1.00;
        attendance.Attest_Last_FY__c = 1.00;
        attendance.Attest_Next_FY__c = 1.00;
        attendance.Attest_This_FY__c = 1.00;
        attendance.Calendar_Year_Total_Last_FY__c = 1.00;
        attendance.Calendar_Year_Total_This_FY__c = 1.00;
        attendance.SB740_Grant_Amount__c = 1.00;                                                //2014.11.21 J Caughie - added for SB740 test
        attendance.Remaining_Payments__c = 1.00;                                                //2014.11.17 J Caughie - added for Regional Attendance tests
        attendance.Base_Floor_Rate__c = 1.00;                                                   //2015.07.08 J Caughie - added for PENSEC
        attendance.ADA_K_3_Initial_PENSEC__c = 1.00;
        attendance.ADA_4_6_Initial_PENSEC__c = 1.00;
        attendance.ADA_7_8_Initial_PENSEC__c = 1.00;
        attendance.ADA_9_12_Initial_PENSEC__c = 1.00;
        attendance.Unduplicated_Count__c = 1.00;
        attendance.Total_Students__c = 1.00;
        attendance.ADA_K_3__c = 1.00;                                                           //2015.10.09 J Caughie - added for test class coverage
        attendance.LCFF_Gap_Amount_Last_FY__c = 1.00;                                           //2015.10.09 J Caughie - added for test class coverage
        attendance.ADA_K_3_Last_Certified__c = 1.00;                                            //2015.10.09 J Caughie - added for test class coverage

        insert attendance;
        return attendance;
    }

    //2014.11.17 J Caughie - added for Regional Attendance
    public static Regional_Attendance__c createRegionalAttendance(Id district, School_Attendance__c schAttend){
        Regional_Attendance__c regAtt = new Regional_Attendance__c();
        regAtt.District__c = district;
        regAtt.School_Attendance__c = schAttend.Id;

        insert regAtt;
        return regAtt;
    }
    //2014.11.17 J Caughie - added for Regional Attendance

    //2014.11.17 J Caughie - added for Regional Attendance
    public static Regional_Attendance__c createRegionalAttendanceNoInsert(Id district, School_Attendance__c schAttend){
        Regional_Attendance__c regAtt = new Regional_Attendance__c();
        regAtt.District__c = district;
        regAtt.School_Attendance__c = schAttend.Id;
  
         return regAtt;
    }
    //2014.11.17 J Caughie - added for Regional Attendance

    /************************************************************
        05/19/2014 : Manisha Gupta : Added for test class update
    **************************************************************/
    public static void createCustomSettingToByPassTriggersAndRules(String objectsToBypass){
        BypassRulesandTriggers__c customSetting = new BypassRulesandTriggers__c();
        customSetting.Name = 'test Custom Setting';
        customSetting.SetupOwnerId = userInfo.getUserId();
        customSetting.Trigger_Objects__c = objectsToBypass;
        customSetting.Triggers_Disabled__c = true;                                          //2018.06.28 J Caughie changed false to true
        customSetting.Validation_Rules_Disabled__c = true;
        insert customSetting;
    }

    public static void createCustomSettingToSetPageSize(String Page){
        PaginationSettings__c pageSetting = PaginationSettings__c.getValues(Page);  
        pageSetting.PageSize__c = 6;
    }
    
    public static Account createAccountForIndustryType(String industry){
        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.Industry = industry;
        return acc;

    }

    public static Account createRPAAccount(Id charterHolderId){
        Account RPAAccount = new Account();
        RPAAccount.Name = 'Test Account';
        RPAAccount.Charter_Holder__c = charterHolderId;
        return RPAAccount;
    }

    public static Funding_Estimates__c createFundingEstimate(Id oppId){
        Funding_Estimates__c fundingEst = new Funding_Estimates__c();
          fundingEst.Opportunity__c = oppId;
          return fundingEst;
    }

    public static Funding_Estimate_Receivable__c createFundingEstimateReceivable(Id fundingEstId, Id oppSchoolId){
        return new Funding_Estimate_Receivable__c(Funding_Estimate__c = fundingEstId,
                                                    GRV_Amount__c = 100.00,
                                                    Opp_School__c = oppSchoolId,
                                                    Included_In_Estimate__c = true,
                                                    Purchase_Date__c = Date.today().addDays(20));               //2015.06.09 J Caughie - added for FE Purchase Date Rollup
    }

    public static Funded_Receivable__c createFundedReceivable(Id payoutId, decimal amount, Id accId, Id rpaId){
        return new Funded_Receivable__c(Source_Payout_Date_Record__c = payoutId, GRV_Amount__c = amount,
                                        FV_Amount__c = amount,
                                        Max_Deferred_Purchase_Price__c = amount,
                                        Upfront_Purchase_Price__c = amount,
                                        Charter_Holder__c = accId,
                                        RPA__c = rpaId,
                                        School__c = accId,
                                        purchase_date__c = date.today(),
                                        maturity_date__c = date.today() + 50);                                    //2014.11.13 J Caughie - added for validations on DrTx Workflow
    }

    public static Draw_Note__c createDrawNote(){
        return new Draw_Note__c(Borrow_Date__c = date.today().addDays(-60), Note_Rate__c = 10.00);
    }

    //2017.01.03 J Caughie
    public static Draw_Note__c createDrawNoteDetailed(Integer amountBorrowed, Account inv, State_Province__c state){
        return new Draw_Note__c(Borrow_Date__c = date.today().addDays(-60), Note_Rate__c = 10.00, Adjusted_Amount_Borrowed__c = amountBorrowed, Investor__c = inv.Id, Operating_State__c = state.Id, Status__c = 'Active');
    }
    //2017.01.03 J Caughie

    public static Draw_Entry__c createDrawEntry(Id DrawNoteId){
        Draw_Entry__c test_DrawEntry = new Draw_Entry__c (
            Draw_Note__c = DrawNoteId
        );
        return test_DrawEntry;
    }

    public static Draw_Note_TX__c createDrawNoteTx(Id DrawNoteId, Id fundedRecId, Decimal amountBorrowed){
        Draw_Note_TX__c test_DrawNoteTX =  new Draw_Note_TX__c (
            Funded_Receivable__c = fundedRecId,
            Draw_Note__c = DrawNoteId,
            Amount_Borrowed__c = amountBorrowed,
            FV_Amount_TX__c = amountBorrowed
        );

        return test_DrawNoteTX;
    }

    public static Draw_Rate__c createDrawRate(Id DrawNoteId, decimal intRate){
        Draw_Rate__c test_DrawRate = new Draw_Rate__c (
            Interest_Rate__c = intRate,
            Draw_Note__c = DrawNoteId
        );

        return test_DrawRate;
    }

    public static Funded_Receivable__c createFundedRec(Id AccountId, Id RPAId){
        Funded_Receivable__c test_FundedReceivable = new Funded_Receivable__c (
            Charter_Holder__c = AccountId,
            RPA__c = RPAId,
            School__c = AccountId,
            purchase_date__c = date.Today() - 50,
            maturity_date__c = date.Today() + 50,                                                                       //2014.11.13 J Caughie - added for validations on DrTx Workflow
            Name = 'test value'
        );

        return test_FundedReceivable;
    }

    public static Redemption__c createRedemption(Id AccountId){
        Redemption__c test_Redemption = new Redemption__c (
            School__c = AccountId,
            Amount_received__c = 10000.00,
            Date_paid__c = date.today(), // Rajeev Arya(Appirio India) - [06/27/2014] - I-119371 - Add DATE PAID override
            Date_Cleared__c = date.today() // Rajeev Arya(Appirio India) - [07/18/2014] - I-122095 - Issue related to Clear Date in Redemption and AllocationTrigger
        );

    return test_Redemption;
    }

    public static RPA_Redemption__c createRPARedemption(Id RPAId, ID RedemptionID){
        RPA_Redemption__c test_RPARedemption = new RPA_Redemption__c (
            RPA__c = RPAId,
            Redemption__c = RedemptionID,
            Program_Fee_Collected__c = 200
        );

    return test_RPARedemption;
    }

    public static State_Province__c createOperatingState(){
        State_Province__c test_state = new State_Province__c (
            Active__c = true,
            Name = 'test state'
        );

    return test_state;
    }

    public static Payment_Sub__c createPaymentSub(Id drawNoteId, Decimal amount){
        Payment_Sub__c test_PaymentSub = new Payment_Sub__c (
            Payment_Against__c = drawNoteId,
            Amount__c = amount
        );
        return test_PaymentSub;
    }

    public static Payment__c createPayment(Id drawNoteId, decimal amount, Id paymentSubId){
        Payment__c test_Payment = new Payment__c (
            Draw_Note__c = drawNoteId,
            Payment_Sub__c = paymentSubId,
            Payment_Amount__c = amount,
            Payment_Type__c = 'Ad Hoc'                                                                              //2015.08.07 J Caughie - Added for test logic
        );
        return test_Payment;
    }

    public static RPA__c createRPA(Id accId){
        RPA__c test_RPA = new RPA__c (
            Account__c = accId, 
            RPA_Date__c = Date.Today() + 2,
            Status__c = 'Active'
        );

        return test_RPA;
    }
    public static Terms_Letter__c createTermsLetter(ID accountId, ID rpaID){
        Terms_Letter__c test_Terms_Letter = new Terms_Letter__c(
            RPA__c = rpaID,
            Account__c = accountId,
            TL_Type__c = 'Original',
            TL_Date__c = Date.today(),
            Initial_Close_Date__c = Date.today(),
            Termination_Date__c = Date.today(),
            Status__c = 'Active',
            Library_Type__c = 'Underwriting',
            RPA_Face_Value__c = 45.00,
            RPA_Gross_Value__c = 43.00
        );
        return test_Terms_Letter;
    }
    public static Terms_Letter__c createDraftTermsLetter(ID accountId, ID rpaID){                                   //2015.06.17 J Caughie - Added to prevent TL -> PF Date test trigger
        Terms_Letter__c test_Terms_Letter = new Terms_Letter__c(
            RPA__c = rpaID,
            Account__c = accountId,
            TL_Type__c = 'Original',
            TL_Date__c = Date.today(),
            Initial_Close_Date__c = Date.today(),
            Termination_Date__c = Date.today(),
            Status__c = 'Draft',
            Library_Type__c = 'Underwriting',
            RPA_Face_Value__c = 45.00,
            RPA_Gross_Value__c = 43.00
        );
        return test_Terms_Letter;
    }
    public static Program_Fee__c createProgramFee (ID TermsLtrID){

        Program_Fee__c test_Prgm_Fee = new Program_Fee__c(
            Program_Fee__c = 456.00,
            Fee_Type__c = 'Fixed_Fee__c',
            Start_Date__c = date.Today().addDays(-2),
            End_Date__c = date.Today().addDays(2),
            Terms_Letter__c = TermsLtrID
        );
        return test_Prgm_Fee;
    }

    public static Rate_Card__c createRateCardForState(Id StateId){
        Rate_Card__c rateCard = new Rate_Card__c(
                            State_Province__c = StateId,
                            Fiscal_Year__c = '13-14'
                            );
        return rateCard;
    }

    public static Rate_Card__c createRateCardForDistrict(Id districtId){
        Rate_Card__c rateCard = new Rate_Card__c(
                            COE_District__c = districtId,
                            Fiscal_Year__c = '13-14'
                            );
        return rateCard;
    }

    public static State_Province__c createState(){
        State_Province__c state = new State_Province__c(
            Name = 'Test State'
        );

        return state;
    }
    
    public static Allocation__c createAllocation(ID ReceivableId, ID RedemptionId, Decimal Amount){
        Allocation__c alloc = new Allocation__c(
            Funded_Receivable__c = ReceivableId,
            Redemption__c = RedemptionId,
            Face_Amount_Applied__c = Amount
        );
        return alloc;
    }

    public static User createUser(String firstName, String lastName, String email, String alias, Id profileId) {
        return new User(
            FirstName = firstName,
            LastName = lastName,
            Alias = alias,
            CommunityNickname = alias,
            Email = email,
            Username = email,
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US',
            EmailEncodingKey = 'ISO-8859-1',
            ProfileId = profileId,
            Paralegal__c = true
        );
    }

}