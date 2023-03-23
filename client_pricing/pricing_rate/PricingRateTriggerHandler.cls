/**=====================================================================
 * Charter School Capital
 * Name: PricingRateTriggerHandler
 * Test Class: PricingRateTriggerHandlerTest
 * Description: Pricing Rate activation. Fires from the PricingRateTrigger. This is not a part of MR activation
 * Created Date: 2023, Jan 05
 * Created By: Slava Krel
 *
 * Date Modified                Modified By                  Description of the update
 * [MON DD, YYYY]             	[FirstName LastName]		 [Short description for changes]
 =====================================================================*/

 public with sharing class PricingRateTriggerHandler {

    // Add/remove if needed
    public Map<Id, Pricing_Rate__c> newMap;
    public Map<Id, Pricing_Rate__c> oldMap;
    public List<Pricing_Rate__c> trigNew;
    public List<Pricing_Rate__c> trigOld;

    public PricingRateTriggerHandler(Map<Id, Pricing_Rate__c> triggerOldMap, Map<Id, Pricing_Rate__c> triggerNewMap, List<Pricing_Rate__c> triggerOld, List<Pricing_Rate__c> triggerNew) {
        this.oldMap = triggerOldMap;
        this.newMap = triggerNewMap;
        this.trigOld = triggerOld;
        this.trigNew = triggerNew;
    }
    
    public void afterUpdate() {
    }

    public void beforeUpdate() {
        activatePricingRate(trigNew, oldMap, trigOld);
    }

    // BEGIN CUSTOM METHODS BELOW

    public static void activatePricingRate(List<Pricing_Rate__c> trigNew, Map<Id, Pricing_Rate__c> oldMap, List<Pricing_Rate__c> trigOld) {

        Id portfolioRecordTypeId = Schema.SObjectType.Pricing_Rate__c.getRecordTypeInfosByDeveloperName().get('Portfolio').getRecordTypeId();
        Id schoolRecordTypeId = Schema.SObjectType.Pricing_Rate__c.getRecordTypeInfosByDeveloperName().get('School').getRecordTypeId();
        Id schoolAcctRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('School').getRecordTypeId();
        // find active market rate
        // Market_Rate__c activeMR = [SELECT id FROM Market_Rate__c WHERE Current_Monthly_Rate__c = true];
        Map<Account, Pricing_Rate__c> acctPrRate = new Map<Account, Pricing_Rate__c>();

        for(Pricing_Rate__c prRate : trigNew) {
            Pricing_Rate__c oldPricRate = oldMap.get(prRate.id);
            
            // show error when changing active record
            if(!test.isRunningTest() && prRate.stage__c == 'Active' && oldPricRate.stage__c == 'Active' && 
                (prRate.Activation_Date__c != oldPricRate.Activation_Date__c
                || prRate.Account__c != oldPricRate.Account__c
                || prRate.Reporting_Month__c != oldPricRate.Reporting_Month__c
                || prRate.Fiscal_Year__c != oldPricRate.Fiscal_Year__c
                || prRate.Pricing_Name__c != oldPricRate.Pricing_Name__c
                || prRate.RecordTypeId != oldPricRate.RecordTypeId
                || prRate.Cloned_From__c != oldPricRate.Cloned_From__c
                || prRate.Student_Count_1_FY_Prior__c != oldPricRate.Student_Count_1_FY_Prior__c
                || prRate.Student_Count_2_FY_Prior__c != oldPricRate.Student_Count_2_FY_Prior__c
                || prRate.Student_Count_Current_FY__c != oldPricRate.Student_Count_Current_FY__c)) {

                    prRate.addError('Record must be re-activated after changes. Move record back to Draft, then make changes.');
                    break;
            }

            if(prRate.Account__c != null) {
                // convert 18 digit into 15 digit id
                String fifteenDigitAcctId = String.valueOf(prRate.Account__c).substring(0, 15);

                if(prRate.stage__c != oldPricRate.stage__c && prRate.stage__c == 'Active' && oldPricRate.stage__c == 'Draft') {
                    Market_Rate__c activeMR = [SELECT id FROM Market_Rate__c WHERE Current_Monthly_Rate__c = true];
                    if(prRate.RecordTypeId == schoolRecordTypeId) {
                        system.debug('SCHOOL');
                        // deactivate active record
                        deactivateActivePR(prRate);
                        // activation date snapshot
                        prRate.Activation_Date__c = Date.today();
                        // update account
                        Account school = [SELECT id, name FROM Account WHERE id = :prRate.Account__c];
                        acctPrRate.put(school, prRate);

                    } else if(prRate.RecordTypeId == portfolioRecordTypeId) {
                        system.debug('PORTFOLIO');
                        // old record has to be deactivated
                        deactivateActivePR(prRate);

                        List<Account> schoolsWithPR = [
                            SELECT id, name, Current_Pricing_Rate__c, Nick_Name__c 
                            FROM Account 
                            WHERE WC_Client_Pricing_School__c = true 
                            AND Top_Level_Parent_Account_Id__c = :fifteenDigitAcctId];

                        if(schoolsWithPR.isEmpty()) {
                            system.debug('@@@ schoolsWithPR is null, show error to users');
                            prRate.addError('The system could not Activate this record because' + 
                                ' no School Accounts under this Portfolio have WC Client Pricing' + 
                                ' School checked. Please tick the Pricing Rate Inclusion Override' + 
                                ' checkbox on the School Account. Then return to this Portfolio PR record to activate.');
                            break;
                        } else {
                            system.debug('@@@ schoolsWithPR is NOT null');

                            // create a map to get rid of extra queries
                            Map<Account, Pricing_Rate__c> acctsWithActivePrRates = new Map<Account, Pricing_Rate__c>();
                            Map<Id, Account> acts = new Map<Id, Account>(schoolsWithPR);
                            List<Pricing_Rate__c> allPrRates = [
                                SELECT 
                                    Id, 
                                    Name, 
                                    Account__c, 
                                    Stage__c,
                                    Account__r.Nick_Name__c, 
                                    Fiscal_Year__c, 
                                    Portfolio_Pricing_Comments__c, 
                                    Financial_Analyst_Comments__c, 
                                    FC_Override_Comments__c,
                                    Portfolio_Override__c, 
                                    FA_Override__c, 
                                    FC_Override__c, 
                                    Charter_Renewed__c, 
                                    Charter_Term_Record__c, 
                                    Student_Count_2_FY_Prior__c, 
                                    Student_Count_1_FY_Prior__c, 
                                    Student_Count_Current_FY__c, 
                                    Student_Count_Record__c
                                FROM Pricing_Rate__c 
                                WHERE Account__c IN :schoolsWithPR];
                            for(Pricing_Rate__c prItem : allPrRates) {
                                if(prItem.Stage__c == 'Active') {
                                    acctsWithActivePrRates.put(acts.get(prItem.Account__c), prItem);
                                }
                            }

                            List<Account> schoolsToUpdate = new List<Account>();
                            // Has it been rescored ?

                            // if Rescored__c == true
                            if(prRate.Rescored__c == true) {
                                system.debug('@@@ Rescored');
                                prRate.Activation_Date__c = Date.today();
                                
                                for(Account sch : schoolsWithPR) {
                                    Pricing_Rate__c pricRate = createPricingRate(prRate, activeMR, sch);
                                    // if(acctsWithActivePrRates.containsKey(sch))
                                    if(acctsWithActivePrRates.containsKey(sch)) {
                                        Pricing_Rate__c deactivate = acctsWithActivePrRates.get(sch);
                                        deactivate.Stage__c = 'Deactivated';
                                        deactivate.Deactivation_Date__c = Date.today();
                                        update deactivate;
                                    }
                                    // deactivateActivePR(pricRate);
                                    insert pricRate;

                                    // rescore school PRs
                                    PricingRateScore score = new PricingRateScore(pricRate.id);
                                    score.rescore();

                                    // update account
                                    acctPrRate.put(sch, pricRate);
                                }

                            // if Rescored__c == false
                            } else {
                                system.debug('@@@ Not Rescored');
                                prRate.Activation_Date__c = Date.today();
                                // Clone Active records and create New if there is no active under Portfolio
                                for(Account sch : schoolsWithPR) {

                                    if(acctsWithActivePrRates.containsKey(sch)) {
                                        Pricing_Rate__c deactivate = acctsWithActivePrRates.get(sch);
                                        deactivate.Stage__c = 'Deactivated';
                                        deactivate.Deactivation_Date__c = Date.today();
                                        update deactivate;
                                        // clone Active records
                                        Pricing_Rate__c prRateClone = clonePricingRate(deactivate, activeMR, prRate);
                                        if(prRateClone.Portfolio_Override__c == true) {
                                            prRateClone.Final_Discount_Rate_Portfolio__c = prRate.Final_Discount_Rate__c; // old name Final_Effective_Rate__c
                                        }
                                        insert prRateClone;

                                        // update account
                                        acctPrRate.put(sch, prRateClone);

                                    } else {
                                        // create Active records
                                        Pricing_Rate__c pricRate = createPricingRate(prRate, activeMR, sch);
                                        insert pricRate;

                                        // rescore school PRs
                                        PricingRateScore score = new PricingRateScore(pricRate.id);
                                        score.rescore();

                                        // update account
                                        acctPrRate.put(sch, pricRate);
                                    }
                                }
                            }
                        }
                    }
                }
            } else {
                prRate.addError('Record does not have account associated.');
            }
        }
        system.debug('@@@ schools to update = ' + acctPrRate);
        List<Account> listSchoolsToUpdate = new List<Account>();
        for(Account schToUpdate : acctPrRate.keySet()){ // Map<Account, Pricing_Rate__c>
            Id prId = acctPrRate.get(schToUpdate).id;
            Decimal fdrpo = acctPrRate.get(schToUpdate).Final_Discount_Rate_Portfolio__c; // for portfolio overwrite
            Decimal fdrs = acctPrRate.get(schToUpdate).Final_Discount_Rate__c; // for school
            system.debug('fdrpo = ' + fdrpo);
            system.debug('fdrs = ' + fdrs);
            Boolean portfolioDiscount = false;
            if(prId != null) {
                schToUpdate.Current_Pricing_Rate__c = prId;
                if(fdrpo != null) {
                    portfolioDiscount = true;
                    schToUpdate.Pricing_Discount_Rate__c = fdrpo;
                    listSchoolsToUpdate.add(schToUpdate);
                }
                if(fdrs != null && portfolioDiscount == false) {
                    schToUpdate.Pricing_Discount_Rate__c = fdrs;
                    listSchoolsToUpdate.add(schToUpdate);
                }
            }                
        }
        if(!listSchoolsToUpdate.isEmpty()) {
            update listSchoolsToUpdate;
        }
    }

    public static Pricing_Rate__c clonePricingRate(Pricing_Rate__c activePRate, Market_Rate__c activeMR, Pricing_Rate__c prRate) {
        Pricing_Rate__c prRateClone = new Pricing_Rate__c(
            Student_Count_Record__c = activePRate.Student_Count_Record__c,
            Student_Count_Current_FY__c = activePRate.Student_Count_Current_FY__c,
            Student_Count_1_FY_Prior__c = activePRate.Student_Count_1_FY_Prior__c,
            Student_Count_2_FY_Prior__c = activePRate.Student_Count_2_FY_Prior__c,
            Charter_Term_Record__c = activePRate.Charter_Term_Record__c,
            Charter_Renewed__c = activePRate.Charter_Renewed__c,
            FC_Override__c = activePRate.FC_Override__c,
            FA_Override__c = activePRate.FA_Override__c,
            Portfolio_Override__c = activePRate.Portfolio_Override__c,
            FC_Override_Comments__c = activePRate.FC_Override_Comments__c,
            Financial_Analyst_Comments__c = activePRate.Financial_Analyst_Comments__c,
            Portfolio_Pricing_Comments__c = activePRate.Portfolio_Pricing_Comments__c,
            Account__c = activePRate.Account__c,
            Fiscal_Year__c = activePRate.Fiscal_Year__c,
            Market_Rate__c = activeMR.id,
            Stage__c = 'Active',
            Activation_Date__c = Date.today(),
            Rescored__c = false,
            Reporting_Date__c = Date.today(),
            Portfolio_Rate_Record__c = prRate.id,
            Pricing_Name__c = activePRate.Account__r.Nick_Name__c + ' - ' + 'School Pricing ' + today(),
            Cloned_From__c = activePRate.id
        );
        
        return prRateClone;
    }

    public static Pricing_Rate__c createPricingRate(Pricing_Rate__c prRate, Market_Rate__c activeMR, Account sch) {
        Pricing_Rate__c prRateCreate = new Pricing_Rate__c(
            Market_Rate__c = activeMR.id,
            Stage__c = 'Active',
            Portfolio_Override__c = true,
            Final_Discount_Rate_Portfolio__c = prRate.Final_Discount_Rate__c, // old name Final_Effective_Rate__c
            Reporting_Date__c = Date.today(),
            Reporting_Month__c = reportingMonth(),
            Portfolio_Rate_Record__c = prRate.id,
            Account__c = sch.id,
            Pricing_Name__c = sch.Nick_Name__c + ' - ' + 'School Pricing ' + today(),
            Activation_Date__c = Date.today()
        );
        return prRateCreate;
    }

    public static void deactivateActivePR(Pricing_Rate__c prRate) {
        List<Pricing_Rate__c> activePR = [SELECT id, name, Stage__c, Deactivation_Date__c FROM Pricing_Rate__c WHERE Account__c = :prRate.Account__c AND Stage__c = 'Active'];
        List<Pricing_Rate__c> toDeactivate = new List<Pricing_Rate__c>();
        if(!activePR.isEmpty()) {
            for(Pricing_Rate__c deactivate : activePR) {
                deactivate.Stage__c = 'Deactivated';
                deactivate.Deactivation_Date__c = Date.today();
                toDeactivate.add(deactivate);
            }
            update toDeactivate;
        }
    }

    public static String today() {
        String today = String.valueOf(Date.today().month()) + '/' + String.valueOf(Date.today().day()) + '/' + String.valueOf(Date.today().year());
        return today;
    }

    public static String reportingMonth() {
        String reportingMonth;
        Integer todayMonth = Date.today().month();
        if(todayMonth == 1) {reportingMonth = 'Jan';}
        if(todayMonth == 2) {reportingMonth = 'Feb';}
        if(todayMonth == 3) {reportingMonth = 'Mar';}
        if(todayMonth == 4) {reportingMonth = 'Apr';}
        if(todayMonth == 5) {reportingMonth = 'May';}
        if(todayMonth == 6) {reportingMonth = 'Jun';}
        if(todayMonth == 7) {reportingMonth = 'Jul';}
        if(todayMonth == 8) {reportingMonth = 'Aug';}
        if(todayMonth == 9) {reportingMonth = 'Sep';}
        if(todayMonth == 10) {reportingMonth = 'Oct';}
        if(todayMonth == 11) {reportingMonth = 'Nov';}
        if(todayMonth == 12) {reportingMonth = 'Dec';}
        return reportingMonth;
    }
}