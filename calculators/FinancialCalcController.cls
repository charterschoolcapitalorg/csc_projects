public with sharing class FinancialCalcController {
    public Opportunity oppty{get;set;}
    public List<Funding_Estimate_Receivable__c> receivableToInsert{get;set;}
    public boolean hasAttendance = TRUE;
    public decimal startingIPF {get; set;}
    public Integer ipfDuration {get; set;}
    public boolean disableButtons {get;set;}
    public Id startingPayDate {get; set;}

    //Interface variable to hold dynamic instances of class. Framework uses dynamica polymorphism here.
    private FinancialCalculatorAPI calcApiImpl;

    /**
    * Map holds list of all School Payors for a particular School. Id is School_Payor__c.School__c & data is list of related payors.
    */
    //public Map<Id,List<School_Payor__c>> schoolPayorMap;

    public Map<Id,List<Payor__c>> stateProvPayorMap;

    public Map<Id,List<Payor__c>> coeDistPayorMap;

    /**
    * Map holds list of School_Attendance related to particular School. Id is School_Attendance__c.School__c & value is list of related School_attendace.
    */
    public Map<Id,List<School_Attendance__c>> schoolAttendanceMap;

    /*
    * Map holding list of Regional_Attendance__c records related to a particular school. Id is Regional_Attendance__c.School_ID__c and Regional_Attendance__c
    */

    public Map<Id,List<Regional_Attendance__c>> schRegAttendanceMap;                        //2014.11.17 J Caughie

    /**
    * Map holds list of Rate Cards related to particular Payor. Id is Rate_Card__c.Payor__c & value is list of related Rate_Card.
    */
    public Map<Id,List<Rate_Card__c>> stateRateCardMap;
    public Map<Id,List<Rate_Card__c>> distRateCardMap;
    public Map<Id,List<Rate_Card__c>> coeRateCardMap;

    /**
    * Map holds list of receivable types related to a single payor. ID is Payor__c from Receivable_Type__c & value is list of related receivable types.
    */
    public Map<Id,List<Receivable_Type__c>> receivableTypeMap;

    /*
    * Map holds list of Calculation we need to perform for each Receivable Type.
    * Id is Calculation__r.Receivable_Type__c & value is list of related calculations.
    */
    public Map<Id,List<Calculation__c>> calculationsMap;

    /**
    * Map holds list of Payout dates for each calculation. Id is calculation id & value is list of related payout dates.
    * Note: In case of multiple payout dates for single calculation, framework performs calculation only once & then multiply it by payout Date %.
    */
    public Map<Id,List<Payout_Date__c>> payoutDateMap;


    /*
    * Map holds list of Alternate District Rate Cards where the School's unduplicated rate is based on a District that is not their regular District.
    */

    public Map<Id,List<Funded_Receivable__c>> deductableFRMap;

    public Map<Id,Set<Id>> fundedRecMap;

    private Date currentDate;
    //private List<School_Payor__c> schoolPayors;
    Private List<Payor__c> coeDistPayorList;
    Private List<Payor__c> statePayorList;
    private List<Opp_School__c> schoolList;
    public List<Funding_Estimate_Receivable__c> origReceivableToInsert{get;set;}
    public List<selectOption> amortOptions{get;set;}

    public FinancialCalcController(ApexPages.StandardController controller) {

        //get Opportunity Record & other needed fields.
        oppty = [Select Id,Name,
                        CloseDate,
                        AccountId,
                        RPA__c,
                        Terms_Letter__c,
                        Account.RecordTypeId,
                        Account.Default_Initial_Purchase_Factor__c,
                        Account.Default_Maturity_Buffer__c,
                        Account.Default_Discount_Rate__c,
                        Account.Operating_State__r.Name,
                        RPA__r.Default_Transaction_Fee__c,
                        Account.Default_Target_Effective_Rate__c
                 From Opportunity
                 Where Id =: controller.getRecord().Id];

        //set Current date.
        disableButtons = true;
        currentDate = Date.today();
        startingIPF = 0.00;
        ipfDuration = 0;
        //Set Existing receivables avaialable for this opportunity. Used to delete when user clicks on Save Receivable button.
        //setExistingReceivable();

        //Prepare all maps.
        prepareMaps();

        //Process & Comput Receivables.
        processMaps();

    }//end Constructor.

    /**
    * Method sets existing receivable records into system to a list.
    */
    /*private void setExistingReceivable(){
        existedReceivableForOpp = [Select Id,Name,
                                          Expected_Pay_Date__c,
                                          Opp_School__r.School__r.Name,
                                          Opp_school__r.School__c,
                                          Opp_School__c,
                                          GRV_Amount__c
                                   From Receivable__c
                                   Where Opportunity__c =: oppty.Id];
    }//end setExistingReceivable.*/

    /**
    * prepare all maps defined above & popluate them accordingly.
    *
    * These maps are important part of implementation as it avoids requerying DB for particular record.
    *
    * For ex: schoolAttendance map allows us to get all related school attendace records without requerying them for each school,
    *         also it helps to get exact related attendace records for a school in squence we need.
    */
    private void prepareMaps(){
        //Initialize all maps.
        schoolAttendanceMap = new Map<Id,List<School_Attendance__c>>();
        schRegAttendanceMap = new Map<Id, List<Regional_Attendance__c>>();                                        //2014.11.17 J Caughie - Regional Attendance
        stateRateCardMap = new Map<Id,List<Rate_Card__c>>();
        distRateCardMap = new Map<Id,List<Rate_Card__c>>();
        coeRateCardMap = new Map<Id,List<Rate_Card__c>>();
        //schoolPayorMap = new Map<Id,List<School_Payor__c>>();
        stateProvPayorMap = new Map<Id,List<Payor__c>>();
        coeDistPayorMap = new Map<Id,List<Payor__c>>();
        receivableTypeMap = new Map<Id,List<Receivable_Type__c>>();
        calculationsMap = new Map<Id,List<Calculation__c>>();
        payoutDateMap = new Map<Id,List<Payout_Date__c>>();
        fundedRecMap = new Map<Id,Set<Id>>();
        receivableToInsert = new List<Funding_Estimate_Receivable__c>();
        origReceivableToInsert = new List<Funding_Estimate_Receivable__c>();

        //Initialize wrapper object list for existing & future receivables.
        amortOptions = new List<selectOption>();

        /**
        * These sets are used to bulkify SOQL.
        * Framework fetch all records needed from sObject & then arrange ( put ) then into different maps as necessary to avoid requery.
        */
        Set<Id> schoolIds = new set<Id>();
        Set<Id> payorIds = new Set<Id>();
        Set<Id> receivableIds = new Set<Id>();
        Set<Id> calcIds = new Set<Id>();
        Set<Id> payoutIds = new Set<Id>();
        Set<Id> stateIds = new Set<Id>();
        Set<Id> districtIds = new Set<Id>();
        Set<Id> countyIds = new Set<Id>();
        List<Account> payorsNeededList = new List<Account>();
        List<School_Attendance__c> altAttDistrictNeededList = new List<School_Attendance__c>();                  //2014.08.19 J Caughie
        List<Funded_Receivable__c> purchasedRecs = new List<Funded_Receivable__c>();
        List<Regional_Attendance__c> regionalAttDistNeededList = new List<Regional_Attendance__c>();               //2014.11.17 J Caughie - Regional Attendance

        //get list of Opp_School__c related to opportunity.
        schoolList = [Select Id,Name,
                               School__c,
                               School__r.Name,
                               School__r.RecordTypeId,
                               School__r.Operating_State__c,
                               School__r.School_District__c,
                               School__r.COE__c
                          From Opp_School__c
                          Where Opportunity__c =: oppty.Id
                            and School__r.ParentId =: oppty.AccountId];
        system.debug('------Opp School--------' + schoolList);
        //prepate Set of Ids for bulkify.
        for(Opp_School__c school : schoolList){
            schoolIds.add(school.School__c);
        }

        purchasedRecs = [Select Id,School__c,
                                    Source_Payout_Date_Record__c
                                From Funded_Receivable__c
                                Where School__c in :schoolIds
                                And Source_Payout_Date_Record__c != null];

        if(!purchasedRecs.isEmpty()){
          Map<Id,Set<Id>> retVal = new Map<Id,Set<Id>>();
          Set<Id> valueSet;

          for(SObject sObj : purchasedRecs){
              valueSet = retVal.get((Id)sObj.get('School__c'));

              if(valueSet != null){
                  valueSet.add((Id)sObj.get('Source_Payout_Date_Record__c'));
              }else{
                  valueSet = new Set<Id>();
                  valueSet.add((Id)sObj.get('Source_Payout_Date_Record__c'));
              }
              retVal.put((Id)sObj.get('School__c'),valueSet);
          }
          fundedRecMap = retVal;
        }

        payorsNeededList = [Select Id,
                                    Name,
                                    Operating_State__c,
                                    School_District__c,
                                    COE__c
                                From Account
                                Where ID in :schoolIds];

        if(!payorsNeededList.isEmpty()){
          stateIds = CalcUtil.getIdSet(payorsNeededList,'Operating_State__c');
          districtIds = CalcUtil.getIdSet(payorsNeededList,'School_District__c');
          countyIds = CalcUtil.getIdSet(payorsNeededList,'COE__c');
        }

        //2014.08.19 J Caughie - new logic added for schools with unduplicated count based on a different District
        //prepare a list of all att records with Alternate School Districts
        altAttDistrictNeededList = [Select  School__c,
                                            Alternative_District__c                                    
                                    From School_Attendance__c
                                    Where School__c in :schoolIds
                                    and Alternative_District__c != null];

        if(!altAttDistrictNeededList.isEmpty()){
          districtIds.addAll(CalcUtil.getIdSet(altAttDistrictNeededList,'Alternative_District__c'));
          system.debug('All Districts: '+ districtIds);
        }
        //system.debug('Att list ' + altAttDistrictNeededList);
        //2014.08.19 J Caughie - new logic added for schools with unduplicated count based on a different District

        //2014.11.17 J Caughie - query to obtain list of additional Districts required when multi-region attendance is used
        regionalAttDistNeededList = [Select  School_Attendance__r.School__c,
                                            District__c                                    
                                    From Regional_Attendance__c
                                    Where School_Attendance__r.School__c in :schoolIds
                                    And School_Attendance__r.Active__c = TRUE];

        if(!regionalAttDistNeededList.isEmpty()){
          districtIds.addAll(CalcUtil.getIdSet(regionalAttDistNeededList,'District__c'));
          system.debug('All Districts: '+ districtIds);
        }
        //2014.11.17 J Caughie - query to obtain list of additional Districts required when multi-region attendance is used

        //get all payors identified by state/coe/district
        coeDistPayorList = [select Id, Name,
                          COE_District__c,
                          State_Province__c
                      From Payor__c
                      Where COE_District__c in :countyIds
                      OR COE_District__c in :districtIds];

        statePayorList = [select Id, Name,
                          COE_District__c,
                          State_Province__c
                      From Payor__c
                      Where State_Province__c in :stateIds];

        if(coeDistPayorList!=null && !coeDistPayorList.isEmpty()){
          coeDistPayorMap = CalcUtil.getIdRelatedMap(coeDistPayorList,'COE_District__c');
          payorIds.addAll(CalcUtil.getIdSet(coeDistPayorList,'Id'));
        }

        if(statePayorList!=null && !statePayorList.isEmpty()){
          stateProvPayorMap = CalcUtil.getIdRelatedMap(statePayorList,'State_Province__c');
          payorIds.addAll(CalcUtil.getIdSet(statePayorList,'Id'));
        }



        String stateRateCardQuery = new selectall('Rate_Card__c').soql +
          ' Where State_Province__c IN :stateIds' +
          ' and Active__c=TRUE';
        List<Rate_Card__c> stateRateCards = Database.query(stateRateCardQuery);

        if(!stateRateCards.isEmpty()){
           //prepare map as described above.
           stateRateCardMap = CalcUtil.getIdRelatedMap(stateRateCards,'State_Province__c');
        }

        String coeRateCardQuery = new selectall('Rate_Card__c').soql +
          ' Where COE_District__c IN :countyIds' +
          ' and Active__c=TRUE';
        List<Rate_Card__c> coeRateCards = Database.query(coeRateCardQuery);

        if(!coeRateCards.isEmpty()){
           //prepare map as described above.
           coeRateCardMap = CalcUtil.getIdRelatedMap(coeRateCards,'COE_District__c');
        }

        String distRateCardQuery = new selectall('Rate_Card__c').soql +
          ' Where COE_District__c IN :districtIds' +
          ' and Active__c=TRUE';
        List<Rate_Card__c> distRateCards = Database.query(distRateCardQuery);

        if(!distRateCards.isEmpty()){
           //prepare map as described above.
           distRateCardMap = CalcUtil.getIdRelatedMap(distRateCards,'COE_District__c');
        }


        //get all school payors for all schools.
        /*schoolPayors = [Select Id,Name,
                              School__c,
                              Payor__c,
                              Payor__r.Name
                       From School_Payor__c
                       Where School__c in: schoolIds];*/
       /**
       * Create Map for School Payors with School Id as key & List of payors as its value,
       * So, we can get list of payors at any point of time, without requerying them using school Id.
       */
       /*if(!schoolPayors.isEmpty()){
           //prepare set for later use in soql
           payorIds = CalcUtil.getIdSet(schoolPayors,'Payor__c');

           //prepare map as described above.
           schoolPayorMap = CalcUtil.getIdRelatedMap(schoolPayors,'School__c');
       }*/

       //get list of school attendance for all schools.
       /*List<School_Attendance__c> schAttendance = [Select Id,Name,
                                                         school__c,
                                                         school__r.Name
                                                  From School_Attendance__c
                                                  Where School__c in: schoolIds
                                                    and Active__c=TRUE];*/

       String schAttendanceQuery = new selectall('School_Attendance__c').soql +
          ' Where School__c IN :schoolIds' +
          ' and Active__c=TRUE';
       List<School_Attendance__c> schAttendance = Database.query(schAttendanceQuery);

       /**
       * Create map for School Attendance, with School Id as a key & List of attendance object as value.
       * we will use this map to get attendace (Actual_ADA__c) value at any point of time using school Id without requeying it.
       */
       if(!schAttendance.isEmpty()){
           //prepare map as described above.
           schoolAttendanceMap = CalcUtil.getIdRelatedMap(schAttendance,'School__c');
       }

       List<Receivable_Type__c> receivableTypes = [Select Id,Name,
                                                          Payor__c,
                                                          Fiscal_Year__c
                                                   From Receivable_Type__c
                                                   Where Payor__c in: payorIds
                                                   and Active__c = TRUE];

      
       //2014.11.17 J Caughie - Get a list of Regional Attendance records needed & create a map of School_id to List<Regional Attendance Record>
       String schRegionalAttQuery = new selectall('Regional_Attendance__c').soql +
          ' Where School_Attendance__r.School__c IN :schoolIds' +
          ' and School_Attendance__r.Active__c = TRUE';
       List<Regional_Attendance__c> schRegAttendance = Database.query(schRegionalAttQuery);
       System.debug(schRegAttendance);


       if(!schRegAttendance.isEmpty()){
         schRegAttendanceMap = CalcUtil.getIdRelatedMap(schRegAttendance,'School_ID__c');
       }
       system.debug(schRegAttendanceMap);
       //2014.11.17 J Caughie - Get a list of Regional Attendance records needed


       /**
       * Create map for receivable Type, with Payor Id as a key & List of receivables from that payor as value.
       * we will use this map to get list of payors using payor Id at any point of time, so we do not have to re-query.
       */

       if(!receivableTypes.isEmpty()){
           //prepare set for later use in soql
           receivableIds = CalcUtil.getIdSet(receivableTypes,'Id');

            //prepare map as described above.
           receivableTypeMap = CalcUtil.getIdRelatedMap(receivableTypes,'Payor__c');
       }

       //get all calculations present for filtered receivables.
       List<Calculation__c> calculations = [Select Id,Name,
                                                   Receivable_Type__c,
                                                   Apex_Class_Name__c
                                            From Calculation__c
                                            Where Receivable_Type__c in: receivableIds];

       if(!receivableTypes.isEmpty()){
            //prepare set for later use in soql
           calcIds = CalcUtil.getIdSet(calculations,'Id');

           //prepare map as described above.
           calculationsMap = CalcUtil.getIdRelatedMap(calculations,'Receivable_Type__c');
       }

       //get all payout dates in future ( greater than today ).
       //2015.08.19 J Caughie - FV Loan Deduction
       List<Payout_Date__c> payoutDates = [Select Id,Name,
                                                  Percent_Value_of_Receivable__c,
                                                  Calculation__c,
                                                  Default_Payout_Date__c,
                                                  Output_Name__c,
                                                  Receivable_Full_Name__c,
                                                  FV_Deduction__c
                                           From Payout_Date__c
                                           Where Default_Payout_Date__c >: currentDate
                                           And Active__c=TRUE];

        if(!payoutDates.isEmpty()){
           //prepare map as described above.
           payoutIds = CalcUtil.getIdSet(payoutDates,'Id');
           payoutDateMap = CalcUtil.getIdRelatedMap(payoutDates ,'Calculation__c');
        }

        List<Funded_Receivable__c> deductableFRs = [Select Id,Name,
                                                            FV_Amount__c,
                                                            GRV_Amount__c,
                                                            Source_Payout_Date_Record__r.Deduct_from_Payout_Date__c,
                                                            School__c
                                                    From Funded_Receivable__c
                                                    Where Source_Payout_Date_Record__r.Deduct_from_Payout_Date__c in: payoutIds
                                                    And School__c in: schoolIds];

        if(!deductableFRs.isEmpty()){
          Map<Id,List<SObject>> retVal = new Map<Id,List<SObject>>();
          List<SObject> valueList;
          
          for(SObject sObj : deductableFRs){
              valueList = retVal.get((Id)sObj.getSObject('Source_Payout_Date_Record__r').get('Deduct_from_Payout_Date__c'));
              
              if(valueList != null){
                  valueList.add(sObj);
              }else{
                  valueList = new List<SObject>();
                  valueList.add(sObj);
              }
              
              retVal.put((Id)sObj.getSObject('Source_Payout_Date_Record__r').get('Deduct_from_Payout_Date__c'),valueList);
          }
          deductableFRMap = retVal;
        }
    }//end prepareMaps.

    /**
    * Method calculates future receivables for each related school for each receivable type using each related calculation for multiple future payout dates.
    *
    * Method gives final output expected by this framework.
    *
    * Method uses Factory design pattern to get apex class instance (dynamica). Dynamic polymorphism is used.
    */
    public void processMaps(){
        if(schoolList == null || schoolList.isEmpty()){
          ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,'No Opp Schools found on Opportunity. Please add at least one Opp School before generating receivables.');
          ApexPages.addMessage(msg);
          return;
        }
        if(oppty.RPA__c == null || oppty.Terms_Letter__c == null){
          ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,'No RPA/Terms Letter assigned on Opportunity. Please assign both an RPA and a Terms Letter before continuing.');
          ApexPages.addMessage(msg);
        }
        if(receivableTypeMap == null || receivableTypeMap.isEmpty()){
          ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,'No Receivable Types found for included Opp Schools\' Payors. Please contact your Salesforce Administrator.');
          ApexPages.addMessage(msg);
          return;
        }
        if(payoutDateMap == null || payoutDateMap.isEmpty()){
          ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,'No Future/Active Payout Dates found for included Opp Schools\' Payors. Please contact your Salesforce Administrator.');
          ApexPages.addMessage(msg);
          return;
        }
        //process each school.
        for(Opp_School__c oppSchool : schoolList){

            //Set current processing opp school, so it can be accessed by Apex Classes who are going to perform actual calculation for receivable amount.
            FinancialCalcModel.currentProcessingOppSchool = oppSchool;

            //List<School_Payor__c> payorsForSchool = (List<School_Payor__c>)schoolPayorMap.get(oppSchool.School__c);
            FinancialCalcModel.currentProcessHasStateRateCard = false;
            FinancialCalcModel.currentProcessHasCOERateCard = false;
            FinancialCalcModel.currentProcessHasDistRateCard = false;
            FinancialCalcModel.currentProcessHasAltDistRateCard = false;                      //2014.08.19 J Caughie - used to get Unduplicated Count District
            FinancialCalcModel.currentProcessHasRegionalAttRec = false;                       //2014.11.17 J Caughie

            //2014.11.17 J Caughie - preparation of maps/list for calc access
            //Map 1 - Dist ID & Regional Attend Record, Map 2 - Dist ID & District Rate Cards
            if(schRegAttendanceMap.get(oppSchool.School__r.Id) != null){
              FinancialCalcModel.currentProcessingRegAttMap = CalcUtil.getIdRelatedMap(schRegAttendanceMap.get(oppSchool.School__r.Id), 'District__c');
              FinancialCalcModel.currentProcessHasRegionalAttRec = true;
              FinancialCalcModel.currentProcessingRegRateCardMap = distRateCardMap;
            }
            system.debug('school id ' + oppSchool.School__r.Id);
            //2014.11.17 J Caughie - preparation of maps/list for calc access

            Set<Payor__c> payorsForSchool2 = new Set<Payor__c>();
            If (oppSchool.School__r.Operating_State__c != null){
              if (stateProvPayorMap.get(oppSchool.School__r.Operating_State__c) != null){
                payorsForSchool2.addAll((List<Payor__c>)stateProvPayorMap.get(oppSchool.School__r.Operating_State__c));
              }
              If (stateRateCardMap.get(oppSchool.School__r.Operating_State__c) != null){
                FinancialCalcModel.currentProcessingStateRateCard = stateRateCardMap.get(oppSchool.School__r.Operating_State__c)[0];
                FinancialCalcModel.currentProcessHasStateRateCard = true;
              }
            }
            If (oppSchool.School__r.COE__c != null){
              if(coeDistPayorMap.get(oppSchool.School__r.COE__c) != null){
                payorsForSchool2.addAll((List<Payor__c>)coeDistPayorMap.get(oppSchool.School__r.COE__c));
              }
              If (coeRateCardMap.get(oppSchool.School__r.COE__c) != null){
                FinancialCalcModel.currentProcessingCOERateCard = coeRateCardMap.get(oppSchool.School__r.COE__c)[0];
                FinancialCalcModel.currentProcessHasCOERateCard = true;
              }
            }
            If (oppSchool.School__r.School_District__c != null){
              if(coeDistPayorMap.get(oppSchool.School__r.School_District__c) != null){
                payorsForSchool2.addAll((List<Payor__c>)coeDistPayorMap.get(oppSchool.School__r.School_District__c));
              }
              If (distRateCardMap.get(oppSchool.School__r.School_District__c) != null){
                FinancialCalcModel.currentProcessingDistRateCard = distRateCardMap.get(oppSchool.School__r.School_District__c)[0];
                FinancialCalcModel.currentProcessHasDistRateCard = true;
              }
            }

            List<School_Attendance__c> schAttendanceList = new List<School_Attendance__c>();

            If (schoolAttendanceMap.get(oppSchool.School__c) != null){
              schAttendanceList = schoolAttendanceMap.get(oppSchool.School__c);
              //system.debug('sch attend list' + schAttendanceList[0].Alternative_District__c);
              FinancialCalcModel.currentProcessingSchAttendance = schAttendanceList[0];
              
              //2014.08.19 J Caughie - new logic added for schools with unduplicated count based on a different District
                if(schAttendanceList[0].Alternative_District__c != null){
                  Id altDist = schAttendanceList[0].Alternative_District__c;
                  FinancialCalcModel.currentProcessingAltDistRateCard = distRateCardMap.get(altDist)[0];
                  FinancialCalcModel.currentProcessHasAltDistRateCard = TRUE;
                  //system.debug('alt dist' + altDist);
                  //system.debug(altDistRateCardMap.get(altDist)[0]);
                  //system.debug(FinancialCalcModel.currentProcessingAltDistRateCard);
                }
              //2014.08.19 J Caughie - new logic added for schools with unduplicated count based on a different District                
            
            } else {
              ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,'No Active School Attendance Record Found for School: ' + oppSchool.School__r.Name);
              ApexPages.addMessage(msg);
              return;
            }

            School_Attendance__c att = FinancialCalcModel.currentProcessingSchAttendance;
            Rate_Card__c src = FinancialCalcModel.currentProcessingStateRateCard;
            Rate_Card__c drc = FinancialCalcModel.currentProcessingDistRateCard;
            Rate_Card__c crc = FinancialCalcModel.currentProcessingCOERateCard;

            Rate_Card__c altdrc = FinancialCalcModel.currentProcessingAltDistRateCard;                  //2014.08.19 J Caughie added for schools with Unduplicated outwith standard District

            String attendanceAudit = getAttendanceAudit(att);

            //process list of attendance related to current processing school.
            //for(School_Attendance__c sAttendance : schAttendanceList){

                //set current processing attendance.
                //FinancialCalcModel.currentProcessingSchAttendance = sAttendance;

                if(payorsForSchool2 != null && !payorsForSchool2.isEmpty()){

                    //Process all payors for a school for this attendance.
                    for(Payor__c payor : payorsForSchool2){

                        //set current processing School payor.
                        FinancialCalcModel.currentProcessingPayor = payor;
                        List<Receivable_Type__c> receivablesForPayor = receivableTypeMap.get(payor.Id);

                        List<Rate_Card__c> rateCardList = new List<Rate_Card__c>();

                        /*If (rateCardMap.get(payor.Id) != null){
                          rateCardList = rateCardMap.get(payor.Id);
                          FinancialCalcModel.currentProcessingRateCard = rateCardList[0];
                          FinancialCalcModel.currentProcessHasRateCard = TRUE;
                        } else {
                          FinancialCalcModel.currentProcessHasRateCard = FALSE;
                          ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.INFO,'No Active Rate Card Found for Payor: ' + payor.Name);
                          ApexPages.addMessage(msg);
                        }*/

                        if(receivablesForPayor != null && !receivablesForPayor.isEmpty()){

                            // process all receivables types for related payor.
                            for(Receivable_Type__c receivable : receivablesForPayor){

                                //set current processing receivable type.
                                FinancialCalcModel.currentProcessingReceivableType = receivable;
                                List<Calculation__c> calcsRelatedToReceivable = calculationsMap.get(receivable.Id);

                                if(calcsRelatedToReceivable != null
                                    && !calcsRelatedToReceivable.isEmpty()){

                                    //process all related calculations for each receivable.
                                    for(Calculation__c calculation : calcsRelatedToReceivable){

                                        //set current processing calculation.
                                        FinancialCalcModel.currentProcessingCalculation = calculation;

                                        //Perform calculation at once here, So we can use them for multiple following dates..
                                        calcApiImpl = FinancialCalcAPIFactory.getApi(calculation.Apex_Class_Name__c);
                                        FinancialCalcModel.currentDebugLog = 'Apex Class Name = ' + calculation.Apex_Class_Name__c;
                                        if (calcApiImpl != null){
                                          Decimal computedAmount = calcApiImpl.computeReceivable();

                                          if(computedAmount != null){
                                            //get payout Dates related to this calculation.
                                            FinancialCalcModel.addLog('Computed Full Amount = ' + computedAmount);
                                            List<Payout_Date__c> payDates = payoutDateMap.get(calculation.Id);

                                            if(payDates != null
                                                && !payDates.isEmpty()){

                                                for(Payout_Date__c pDate : payDates){

                                                    /**
                                                    * Create Receivable record for each future payout date.
                                                    * pre-computed value by apex class is multilied for each payout date for payout % value.
                                                    */
                                                    Funding_Estimate_Receivable__c aRecToCreate = new Funding_Estimate_Receivable__c();

                                                    try{
                                                        Decimal deductAmount = 0;
                                                        if(deductableFRMap != null){
                                                          List<Funded_Receivable__c> deductableFRs = deductableFRMap.get(pDate.Id);
                                                          //Calculate amount to deduct from GRV due to previous purchases (IADA)
                                                          if(deductableFRs != null && !deductableFRs.isEmpty()){
                                                            for(Funded_Receivable__c fr : deductableFRs){
                                                              if(fr.School__c == oppSchool.School__c){
                                                                deductAmount = deductAmount + fr.GRV_Amount__c;
                                                              }
                                                            }
                                                          }
                                                        }
                                                        System.debug('b4 ' + deductAmount);
                                                        Decimal grvAmount = (((pDate.Percent_Value_of_receivable__c / 100 ) * computedAmount).round())-deductAmount;
                                                        System.debug('after ' + grvAmount);
                                                        aRecToCreate.Opp_School__r = oppSchool;
                                                        aRecToCreate.Calculator_Audit_Log__c = FinancialCalcModel.currentDebugLog;
                                                        aRecToCreate.Attendance_Audit_Log__c = attendanceAudit;
                                                        aRecToCreate.Opp_School__c = oppSchool.Id;
                                                        aRecToCreate.Expected_Pay_Date__c = pDate.Default_Payout_Date__c;
                                                        aRecToCreate.Source_Payout_Date_Record__c = pdate.Id;
                                                        If(src != null){
                                                          aRecToCreate.Source_State_Rate_Card__c = src.Id;
                                                        }
                                                        If(drc != null){
                                                          aRecToCreate.Source_District_Rate_Card__c = drc.Id;
                                                        }
                                                        If(crc != null){
                                                          aRecToCreate.Source_COE_Rate_Card__c = crc.Id;
                                                        }
                                                        If(att != null){
                                                          aRecToCreate.Source_School_Attendance_Record__c = att.Id;
                                                        }
                                                        //######################################## SET DEFAULT IPF VALUE ########################################
                                                        if(oppty.Account.Default_Initial_Purchase_Factor__c != null){
                                                          if(oppty.Account.Operating_State__r.Name == 'OH'){
                                                            Decimal sponFeeMod = 0;
                                                            If(att.Deduct_for_Sponsor_Fee__c==TRUE){
                                                              sponFeeMod = -0.03;
                                                            }
                                                            Decimal auditAdjustment = att.Audit_Adjustments__c > 0 ? 0 : att.Audit_Adjustments__c;          //2014.11.13 J Caughie excluded Audit Adjustment when positive
                                                            Decimal riskValue = (((att.State_Teacher_Retirement__c + att.School_Employee_Retirement__c + auditAdjustment + att.Sponsor_Fee_Deduction__c + att.JV44__c)/grvAmount)+sponFeeMod+1);  //2015.01.12 J Caughie - added as per SH
                                                            system.debug('riskValue = ' + riskValue);
                                                            aRecToCreate.Initial_Purchase_Factor__c = (riskValue * oppty.Account.Default_Initial_Purchase_Factor__c).setScale(2);
                                                          } else if (oppty.Account.Operating_State__r.Name == 'FL') {            // Added for Florida 2014.07.06 as per SH - J Caughie

                                                              Decimal sumFTE = FinancialCalcModel.currentFLsumFTE;
                                                              Decimal adminFee = 1;
                                                              if (sumFTE > 250){
                                                                adminFee = (250/sumFTE);
                                                              }
                                                              Decimal districtFees = (adminFee * 0.05 * grvAmount).setScale(2);
                                                              if (att.Fees_override__c == true) {
                                                                districtFees = att.Administrative_Fees__c;
                                                              }

                                                              Decimal totalOtherDeductions = -(att.Prior_Year_Adjustments__c - districtFees);
                                                              Decimal riskValue = (grvAmount - totalOtherDeductions)/grvAmount;
                                                              aRecToCreate.Initial_Purchase_Factor__c = (riskValue * oppty.Account.Default_Initial_Purchase_Factor__c).setScale(2);   
                                                              
                                                              System.debug('riskValue = ' + riskValue);
                                                              System.debug('districtFees = ' + districtFees);
                                                              System.debug('totalOtherDeductions = ' + totalOtherDeductions);


                                                            }else{
                                                            aRecToCreate.Initial_Purchase_Factor__c = oppty.Account.Default_Initial_Purchase_Factor__c;
                                                          }
                                                        } else {
                                                          aRecToCreate.Initial_Purchase_Factor__c = 0.0;
                                                        }
                                                        //#######################################################################################################
                                                        if(oppty.Account.Default_Maturity_Buffer__c != null){
                                                          aRecToCreate.Maturity_Buffer__c = oppty.Account.Default_Maturity_Buffer__c;
                                                        } else {
                                                          aRecToCreate.Maturity_Buffer__c = 0;
                                                        }
                                                        aRecToCreate.Purchase_Date__c = oppty.CloseDate;

                                                        if(fundedRecMap.get(oppSchool.School__r.Id) != null){
                                                          aRecToCreate.Already_Purchased__c = fundedRecMap.get(oppSchool.School__r.Id).contains(pdate.Id);
                                                        }
                                                        aRecToCreate.Receivable_Type_Name_for_Sorting__c = receivable.Name;

                                                        //Receivable Name
                                                        aRecToCreate.Name = pDate.Receivable_Full_Name__c;

                                                        //2015.08.19 J Caughie - FV Adjustment
                                                        if(pDate.FV_Deduction__c){
                                                          aRecToCreate.FV_Deductions__c = att.Monthly_CDE_Loan_Repayment__c;
                                                        } else {
                                                          aRecToCreate.FV_Deductions__c = 0;
                                                        }
                                                        //2015.08.19 J Caughie - FV Adjustment

                                                        aRecToCreate.GRV_Amount__c = grvAmount;

                                                        receivableToInsert.add(aRecToCreate);
                                                    }Catch(Exception e){
                                                        ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.WARNING,e.getMessage()+
                                                                                                      'Please check  '+calculation.Name+' record.');
                                                        ApexPages.addMessage(msg);
                                                    }
                                                }
                                            }
                                          }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            //}
        }

        //form Visualforce table display.
        formReceivableDisplay();
    }//end processMaps

    /**
    * Method which builds table to display on visualforce page.
    */
    private void formReceivableDisplay(){
        Set<Id> inList = new Set<Id>();
        if(!receivableToInsert.isEmpty()){
          sortList(receivableToInsert,'Name','asc');
          sortList(receivableToInsert,'Expected_Pay_Date__c','asc');
          sortList(receivableToInsert,'Receivable_Type_Name_for_Sorting__c','asc');
          sortList(receivableToInsert,'Opp_School__c','asc');
        }
        for(Funding_Estimate_Receivable__c rec : receivableToInsert){
            disableButtons = false;

            if(!inList.contains(rec.Source_Payout_Date_Record__c)){
              inList.add(rec.Source_Payout_Date_Record__c);
              amortOptions.add(new selectOption(rec.Source_Payout_Date_Record__c,rec.Name));
            }

        }
        origReceivableToInsert = receivableToInsert.deepClone();
    }//end formReceivableDisplay.

    public void applyAmortization(){
      if(!receivableToInsert.isEmpty()){
        try{
          receivableToInsert.clear();
          receivableToInsert = origReceivableToInsert.deepClone();
          Boolean isAmort = false;
          Integer count = 0;
          Integer recsLeft = 0;
          Decimal lastIPF = 0.00;
          Id currentSchool = null;
          Decimal rateIPF = startingIPF/ipfDuration;
          for(Funding_Estimate_Receivable__c rec : receivableToInsert){
            if(currentSchool != rec.Opp_School__c){
              currentSchool = rec.Opp_School__c;
              lastIPF = startingIPF;
              recsLeft = ipfDuration;
              isAmort = false;
            }
            if(rec.Source_Payout_Date_Record__c == startingPayDate){
              isAmort = true;
            }
            if(isAmort && recsLeft > 0){
              Decimal newIPF = lastIPF - rateIPF;
              if(newIPF<0){
                newIPF = 0;
              }
              rec.Initial_Purchase_Factor__c = newIPF;
              lastIPF = newIPF;
              recsLeft = recsLeft - 1;
            }
            /*if(count==0){
              rec.Initial_Purchase_Factor__c = startingIPF;
              lastIPF = startingIPF;
              count = count + 1;
            } else {
              rec.Initial_Purchase_Factor__c = lastIPF - ipfAdjustment;
              lastIPF = lastIPF - ipfAdjustment;
              if(count>2){
                rec.Purchase_Date__c = rec.Expected_Pay_Date__c-90;
              }
              count = count + 1;
            }*/
          }
        } catch (Exception e) {
          ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,'Amortization Calc Error - Check Inputted Values');
          ApexPages.addMessage(msg);
        }
      }
    }

    /**
    * Method performs all Dmls with exception handling.
    * Method is called when User clicks on Save Receivable.
    */
    public PageReference saveReceivables(){
        List<Funding_Estimate_Receivable__c> receivableList = new List<Funding_Estimate_Receivable__c>();
        SavePoint sp = Database.setSavePoint();
        Funding_Estimates__c newFundingEstimate = new Funding_Estimates__c(Opportunity__c = oppty.Id,
                                                                            Discount__c = oppty.Account.Default_Discount_Rate__c,
                                                                            Transaction_Fee__c = oppty.RPA__r.Default_Transaction_Fee__c,
                                                                            Target_Effective_Rate__c = oppty.Account.Default_Target_Effective_Rate__c);
        try{
            insert newFundingEstimate;
            //form list of Future receivables selected to save.
            for(Funding_Estimate_Receivable__c recToInsert : receivableToInsert){
                recToInsert.Funding_Estimate__c = newFundingEstimate.Id;
                recToInsert.Discount_Rate__c = oppty.Account.Default_Discount_Rate__c;
            }

            //upsert receivables in bulk.
            upsert receivableToInsert;

        }catch(Exception e){
            Database.rollBack(sp);
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage());
            ApexPages.addMessage(msg);
            return null;
        }

        return new PageReference('/apex/FundingEstimateCalculator?id='+newFundingEstimate.Id);
    }//end SaveReceivables.

    public PageReference cancel(){
        return new PageReference('/'+oppty.Id);
    }//end SaveReceivables.

    //method to sort the result list
    public static void sortList(List<Sobject> items, String sortField, String order){
       List<Sobject> resultList = new List<Sobject>();
        //Create a map that can be used for sorting
       Map<object, List<Sobject>> objectMap = new Map<object, List<Sobject>>();

       for(Sobject ob : items){
                if(objectMap.get(ob.get(sortField)) == null){  // For non Sobject use obj.ProperyName
                    objectMap.put(ob.get(sortField), new List<Sobject>());
                }
                objectMap.get(ob.get(sortField)).add(ob);
        }
        //Sort the keys
        List<object> keys = new List<object>(objectMap.keySet());
        keys.sort();

        for(object key : keys){
            resultList.addAll(objectMap.get(key));
        }

        //Apply the sorted values to the source list
        items.clear();
        if(order.toLowerCase() == 'asc'){
            for(Sobject ob : resultList){
                items.add(ob);
            }
        }else if(order.toLowerCase() == 'desc'){
            for(integer i = resultList.size()-1; i >= 0; i--){
                items.add(resultList[i]);
            }
        }
    }

    public String getAttendanceAudit(School_Attendance__c thisAtt){
      String strAttAudit = '';

      //get all fields from School Attendance that we want to audit
      Map<String, Schema.DescribeFieldResult> attFieldsToTrack = new Map<String, Schema.DescribeFieldResult>();
      Map<String, Schema.SObjectField> allAttFieldsMap = Schema.SObjectType.School_Attendance__c.fields.getMap();
      for (Schema.SObjectField attField : allAttFieldsMap.values()) {
          Schema.DescribeFieldResult describeResult = attField.getDescribe();
          //choose which fields to track depending on the field type
          if (describeResult.getType() == Schema.DisplayType.Boolean ||
              describeResult.getType() == Schema.DisplayType.Combobox ||
              describeResult.getType() == Schema.DisplayType.Currency ||
              describeResult.getType() == Schema.DisplayType.Date ||
              describeResult.getType() == Schema.DisplayType.DateTime ||
              describeResult.getType() == Schema.DisplayType.Double ||
              describeResult.getType() == Schema.DisplayType.Email ||
              describeResult.getType() == Schema.DisplayType.Integer ||
              describeResult.getType() == Schema.DisplayType.MultiPicklist ||
              describeResult.getType() == Schema.DisplayType.Percent ||
              describeResult.getType() == Schema.DisplayType.Phone ||
              describeResult.getType() == Schema.DisplayType.Picklist ||
              describeResult.getType() == Schema.DisplayType.String ||
              describeResult.getType() == Schema.DisplayType.TextArea ||
              describeResult.getType() == Schema.DisplayType.Time ||
              describeResult.getType() == Schema.DisplayType.URL) 
          {
              //don't add standard fields that are not necessary
              if (describeResult.getName() != 'CreatedDate' &&
                  describeResult.getName() != 'LastModifiedDate' &&
                  describeResult.getName() != 'SystemModstamp' &&
                  describeResult.getName() != 'LastReferencedDate' &&
                  describeResult.getName() != 'LastViewedDate' &&
                  describeResult.getName() != 'Name' &&
                  //only add fields that are visible to the current user
                  describeResult.isAccessible() &&
                  //do not add formula fields
                  !describeResult.isCalculated()
                  )
              {
                  attFieldsToTrack.put(describeResult.getName(), describeResult);
              }
          }
      }
      //build audit string from relevant fields
      String[] auditList = new List<String>();
      for (Schema.DescribeFieldResult fieldDescribe : attFieldsToTrack.values()) {
        if(thisAtt.get(fieldDescribe.getName()) != null && thisAtt.get(fieldDescribe.getName()) != 0 && thisAtt.get(fieldDescribe.getName()) != false){
          String thisFieldLabel = fieldDescribe.getLabel();
          String thisFieldValue = String.valueOf(thisAtt.get(fieldDescribe.getName()));
          auditList.add(thisFieldLabel + ' - ' + thisFieldValue);
        }
      }
      auditList.sort();
      for(String thisAudit : auditList){
        strAttAudit = strAttAudit + thisAudit + '\r\n';
      }

      return strAttAudit;
    }


}//end main class.