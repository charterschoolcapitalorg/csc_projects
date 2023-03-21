/**=====================================================================
 * Charter School Capital
 * Name: MarketRateTriggerHandler
 * Test Class: MarketRateTriggerHandlerTest
 * Description: See MarketRateEvents trigger. Fires when Market rate gets activated.
 * Created Date: 2023, Feb 05
 * Created By: Slava Krel
 *
 * Date Modified                Modified By                  Description of the update
 * [MON DD, YYYY]             	[FirstName LastName]		 [Short description for changes]
 =====================================================================*/

 public with sharing class MarketRateTriggerHandler {
    
    // Add/remove if needed
    public Map<Id, Market_Rate__c> newMap;
    public Map<Id, Market_Rate__c> oldMap;
    public List<Market_Rate__c> trigNew;
    public List<Market_Rate__c> trigOld;

    public MarketRateTriggerHandler(Map<Id, Market_Rate__c> triggerOldMap, Map<Id, Market_Rate__c> triggerNewMap, List<Market_Rate__c> triggerOld, List<Market_Rate__c> triggerNew) {
        this.oldMap = triggerOldMap;
        this.newMap = triggerNewMap;
        this.trigOld = triggerOld;
        this.trigNew = triggerNew;
    }
    
    public void afterUpdate() {
    }

    public void beforeUpdate() {
        activateMarketRate(trigNew, oldMap);
    }

    // BEGIN CUSTOM METHODS BELOW

    public static void activateMarketRate(List<Market_Rate__c> trigNew, Map<Id, Market_Rate__c> oldMap) {

        Id marRateLockedRecordTypeId = Schema.SObjectType.Market_Rate__c.getRecordTypeInfosByDeveloperName().get('Market_Rate_Locked').getRecordTypeId();
        Id marRateRecordTypeId = Schema.SObjectType.Market_Rate__c.getRecordTypeInfosByDeveloperName().get('Market_Rate').getRecordTypeId();
        Id portfolioRecordTypeId = Schema.SObjectType.Pricing_Rate__c.getRecordTypeInfosByDeveloperName().get('Portfolio').getRecordTypeId();
        Id schoolRecordTypeId = Schema.SObjectType.Pricing_Rate__c.getRecordTypeInfosByDeveloperName().get('School').getRecordTypeId();
        Id chRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Charter_Holder').getRecordTypeId();
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Business').getRecordTypeId();

        List<Pricing_Rate__c> upsertPricRateList = new List<Pricing_Rate__c>();
        Map<Account, Pricing_Rate__c> schoolsWithNewPr = new Map<Account, Pricing_Rate__c>();
        Map<Pricing_Rate__c, Pricing_Rate__c> prSchoolsWithNewPr = new Map<Pricing_Rate__c, Pricing_Rate__c>();
        List<Account> schoolsToUpdate = new List<Account>();
        List<Pricing_Rate__c> prSchoolsUpdate = new List<Pricing_Rate__c>();
        Map<Pricing_Rate__c, Account> pricRateSchoolToRescore = new Map<Pricing_Rate__c, Account>();
        Map<Pricing_Rate__c, Account> pricRatePortfolioToRescore = new Map<Pricing_Rate__c, Account>();
        Map<Account, List<Account>> acctAccts = new Map<Account, List<Account>>();
        Map<Id, Account> part = new Map<Id, Account>();
        Map<Account, Account> partOfPortfolio = new Map<Account, Account>();
        Map<Id, Account> notPart = new Map<Id, Account>();
        Map<Account, Pricing_Rate__c> acctIdandActivePR = new Map<Account, Pricing_Rate__c>();
        Map<Pricing_Rate__c, Id> activePRandAcctId = new Map<Pricing_Rate__c, Id>();
        Set<Id> doneAcct = new Set<Id>();
        Set<Id> donePrRate = new Set<Id>();

        Map<Id, Account> acctMap = new Map<Id, Account>([SELECT Id, Name, Nick_Name__c, Current_Pricing_Rate__c, Top_Level_Parent_Account_Id__c, WC_Client_Pricing_School__c, Pricing_Discount_Rate__c FROM Account WHERE WC_Client_Pricing_School__c = true]);
        Map<Id, Account> allAccounts = new Map<Id, Account>([SELECT Id, Name, Nick_Name__c, Current_Pricing_Rate__c, Top_Level_Parent_Account_Id__c, ParentId, RecordTypeId, WC_Client_Pricing_School__c FROM Account WHERE RecordTypeId = :chRecordTypeId OR RecordTypeId = :businessRecordTypeId]); 

        for(Market_Rate__c marRate : trigNew) {
            Market_Rate__c oldMarlRate = oldMap.get(marRate.id);
            if(marRate.stage__c != oldMarlRate.stage__c && marRate.stage__c == 'Active' && oldMarlRate.stage__c == 'Draft') {

                // confirm MR active only one
                List<Market_Rate__c> activeMarRateList = [SELECT id, RecordTypeId FROM Market_Rate__c WHERE Current_Monthly_Rate__c = true AND id != :marRate.id];
                if(activeMarRateList?.size() == 1 || activeMarRateList?.size() == 0) {
                    // deactivate the active MR
                    if(activeMarRateList?.size() == 1) {
                        for(Market_Rate__c mrToDeactivate : activeMarRateList) {
                            mrToDeactivate.Deactivation_Date__c = Date.today();
                            mrToDeactivate.Current_Monthly_Rate__c = false;
                            mrToDeactivate.Stage__c = 'Deactivated';
                            mrToDeactivate.RecordTypeId = marRateRecordTypeId;
                            update mrToDeactivate;
                        }
                    }
                    
                    // activate current MR record
                    marRate.Activation_Date__c = Date.today();
                    marRate.Current_Monthly_Rate__c = true;
                    marRate.RecordTypeId = marRateLockedRecordTypeId;
            
                    List<Pricing_Rate__c> prRateList = getPricingRates();

                    for(Pricing_Rate__c prRate : prRateList) {
                        if(prRate.recordtypeid == schoolRecordTypeId && prRate.Account__c != null && prRate.Stage__c == 'Active') activePRandAcctId.put(prRate, prRate.Account__c);
                    }

                    // build Map<Account, List<Account>>
                    for(Id accnt : acctMap.keySet()){
                        Id eighteenDigit = acctMap.get(accnt).Top_Level_Parent_Account_Id__c;
                        if(acctAccts.containsKey(allAccounts.get(eighteenDigit))) {
                            acctAccts.get(allAccounts.get(eighteenDigit)).add(acctMap.get(accnt));
                        } else {
                            acctAccts.put(allAccounts.get(eighteenDigit), new List<Account>{acctMap.get(accnt)});
                        }
                    }

                    // build part and notPart maps
                    for(Account item : acctAccts.keySet()) {
                        if(acctAccts.get(item) != null) {
                            if(acctAccts.get(item)?.size() > 1) {
                                List<Account> subItemList = new List<Account>();
                                for(Account subItem : acctAccts.get(item)) {
                                    if(subItem.WC_Client_Pricing_School__c == true) {
                                        subItemList.add(subItem);
                                    }
                                }
                                if(!subItemList.isEmpty() && subItemList != null) {
                                    if(subItemList.size() == 1) {
                                        notPart.put(subItemList[0].id, subItemList[0]);
                                    }
                                    // build a Map<Account, Account> where keySet is a school
                                    if(subItemList.size() > 1) {
                                        for(Account acctInPortf : subItemList) {
                                            partOfPortfolio.put(acctInPortf, item); // Map<Account, Account>
                                        }
                                    }
                                }
                            }
                            if(acctAccts.get(item)?.size() == 1) {
                                for(Account subItem : acctAccts.get(item)) {
                                    notPart.put(subItem.id, subItem);
                                }
                            }
                        }
                    }

                    for(Pricing_Rate__c ap : activePRandAcctId.keySet()) {
                        if(notPart.containsKey(activePRandAcctId.get(ap))) {
                            acctIdandActivePR.put(notPart.get(activePRandAcctId.get(ap)), ap);
                        }
                    }

                    for(Id schoolId : acctMap.keySet()) {
                        Account school = acctMap.get(schoolId);
                        Pricing_Rate__c pricRate;

                        // not part of portfolio
                        if(acctIdandActivePR.containsKey(school)) { // Map<Account, Pricing_Rate__c>
                            Pricing_Rate__c deactivatePR = acctIdandActivePR.get(school);
                            deactivatePR.Stage__c = 'Deactivated';
                            deactivatePR.Deactivation_Date__c = Date.today();
                            upsertPricRateList.add(deactivatePR);

                            String nick = getNick(school);
                            pricRate = clonePricingRate(deactivatePR, marRate, 'School', schoolRecordTypeId, school, nick);
                            upsertPricRateList.add(pricRate);
                            schoolsWithNewPr.put(school, pricRate);
                        }

                        // part of portfolio partOfPortfolio Map<Account, Account>
                        if(partOfPortfolio.containsKey(school)) {
                            if(!doneAcct.contains(school.id)) {
                                Id eighteenDigit = school.Top_Level_Parent_Account_Id__c; 
                                Pricing_Rate__c portfPr;

                                for(Pricing_Rate__c portfPrItem : prRateList) {
                                    if(portfPrItem.Account__c == eighteenDigit && portfPrItem.Stage__c == 'Active') {
                                        portfPr = portfPrItem;
                                    }
                                }
                                
                                if(portfPr != null) {
                                    if(!donePrRate.contains(portfPr.id)) {
                                        // portfolio
                                        // deactivate
                                        portfPr.Stage__c = 'Deactivated';
                                        portfPr.Deactivation_Date__c = Date.today();
                                        update portfPr;
                                        donePrRate.add(portfPr.id);
                                        // find related account
                                        Account topAccount = allAccounts.get(portfPr.Account__c);
                                        String nick = getNick(topAccount);
                                        // clone
                                        pricRate = clonePricingRate(portfPr, marRate, 'Portfolio', portfolioRecordTypeId, topAccount, nick);
                                        insert pricRate;
                                        donePrRate.add(pricRate.id);
    
                                        // schools
                                        List<Pricing_Rate__c> subSchoolList = new List<Pricing_Rate__c>();
                                        for(Pricing_Rate__c subSchool : prRateList) {
                                            if(subSchool.Portfolio_Rate_Record__c == portfPr.id && subSchool.Stage__c == 'Active') {
                                                subSchoolList.add(subSchool);
                                            }
                                        }
                                        if(!subSchoolList.isEmpty()) {
                                            for(Pricing_Rate__c schPrUnderPortf : subSchoolList) {
                                                Account subSchool = acctMap.get(schPrUnderPortf.Account__c);
                                                if(subSchool != null) {                                                        
                                                    schPrUnderPortf.Stage__c = 'Deactivated';
                                                    schPrUnderPortf.Deactivation_Date__c = Date.today();
                                                    upsertPricRateList.add(schPrUnderPortf);

                                                    String nickSub = getNick(subSchool);
                                                    Pricing_Rate__c subPricRate;
                                                    subPricRate = clonePricingRate(schPrUnderPortf, marRate, 'School', schoolRecordTypeId, subSchool, nickSub);

                                                    subPricRate.Portfolio_Rate_Record__c = pricRate.id;
                                                    upsertPricRateList.add(subPricRate);
                                                    schoolsWithNewPr.put(subSchool, subPricRate);
                                                    doneAcct.add(subSchool.id);
                                                } 
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                } else {
                    marRate.addError('There is more than one active Market Rate record in the system.');
                }
            }    
        }

        // PART II
        // upsert PRs and update schools
        if(!upsertPricRateList.isEmpty()) {
            upsert upsertPricRateList;

            schoolsToUpdate = updateSchools(schoolsWithNewPr);
            update schoolsToUpdate;
        }
    }

    public static String getNick(Account acctRecord) {
        String nickString;
        if(acctRecord.Nick_Name__c != null) {
            nickString = acctRecord.Nick_Name__c;
        } else {
            nickString = acctRecord.Name;
        }
        return nickString;
    }

    public static List<Pricing_Rate__c> getPricingRates() {
        List<Pricing_Rate__c> allPricingRates = [
            SELECT 
                id, 
                name,
                recordtypeid, 
                RecordType.DeveloperName,
                Portfolio_Rate_Record__c, 
                Account__c, 
                Account__r.Top_Level_Parent_Account_Id__c, 
                Deactivation_Date__c, 
                Final_Discount_Rate__c, 
                Stage__c, 
                Student_Count_Record__c, 
                Student_Count_Current_FY__c, 
                Student_Count_1_FY_Prior__c, 
                Student_Count_2_FY_Prior__c,
                Discount_Rate_FC_Override__c,
                Discount_Rate_FA_Override__c,
                Final_Discount_Rate_Portfolio__c,
                Charter_Renewed__c,
                Fiscal_Year__c,
                Cloned_From__c,
                Charter_Term_Record__c,
                FC_Override_Comments__c,
                Financial_Analyst_Comments__c,
                Portfolio_Pricing_Comments__c,
                FC_Override__c,
                FA_Override__c,
                Portfolio_Override__c
            FROM Pricing_Rate__c]; 
        return allPricingRates;
    }

    public static List<Account> updateSchools(Map<Account, Pricing_Rate__c> schoolsWithNewPr) {
        List<Account> schoolList = new List<Account>();

        // make a set of pr ids
        Set<Id> newPrIds = new Set<Id>();
        for(Account schl : schoolsWithNewPr.keySet()) {
            newPrIds.add(schoolsWithNewPr.get(schl).id);
        }

        Map<Id, Pricing_Rate__c> newPRs = new Map<Id, Pricing_Rate__c>([SELECT Id, Name, Final_Discount_Rate__c, Final_Discount_Rate_Portfolio__c, Portfolio_Rate_Record__c, Portfolio_Override__c FROM Pricing_Rate__c WHERE Id IN :newPrIds]);

        for(Account schUpd : schoolsWithNewPr.keySet()) {
            Id prId = schoolsWithNewPr.get(schUpd).id;
            Pricing_Rate__c newPricRate = newPRs.get(prId);
            Decimal fdrs = newPricRate.Final_Discount_Rate__c; 
            system.debug('@@@ school = ' + schUpd);
            system.debug('@@@ pricing rate = ' + newPricRate);
            system.debug('@@@ fdrs = ' + fdrs);
            if(prId != null) {
                schUpd.Current_Pricing_Rate__c = prId;
                if(fdrs != null) {
                    schUpd.Pricing_Discount_Rate__c = fdrs;
                }
                schoolList.add(schUpd);
            }
        }
        return schoolList;
    }

    public static Pricing_Rate__c clonePricingRate(Pricing_Rate__c prRate, Market_Rate__c marRate, String index, Id recordtype, Account acct, String nickName) {
        Pricing_Rate__c prRateCreate = new Pricing_Rate__c(
            Market_Rate__c = marRate.id,
            Stage__c = 'Active',
            Discount_Rate_FC_Override__c = prRate.Discount_Rate_FC_Override__c,
            Discount_Rate_FA_Override__c = prRate.Discount_Rate_FA_Override__c,
            Final_Discount_Rate_Portfolio__c = prRate.Final_Discount_Rate_Portfolio__c,
            Reporting_Date__c = Date.today(),
            Reporting_Month__c = PricingRateTriggerHandler.reportingMonth(),
            Account__c = prRate.Account__c,
            Pricing_Name__c = nickName + ' - ' + index + ' Pricing ' + PricingRateTriggerHandler.today(),
            Activation_Date__c = Date.today(),
            Student_Count_Record__c = prRate.Student_Count_Record__c,
            Student_Count_Current_FY__c = prRate.Student_Count_Current_FY__c,
            Student_Count_1_FY_Prior__c = prRate.Student_Count_1_FY_Prior__c,
            Student_Count_2_FY_Prior__c = prRate.Student_Count_2_FY_Prior__c,
            RecordTypeId = recordtype,
            Charter_Renewed__c = prRate.Charter_Renewed__c,
            Fiscal_Year__c = prRate.Fiscal_Year__c,
            Cloned_From__c = prRate.id,
            Charter_Term_Record__c = prRate.Charter_Term_Record__c,
            FC_Override_Comments__c = prRate.FC_Override_Comments__c,
            Financial_Analyst_Comments__c = prRate.Financial_Analyst_Comments__c,
            Portfolio_Pricing_Comments__c = prRate.Portfolio_Pricing_Comments__c,
            FC_Override__c = prRate.FC_Override__c,
            FA_Override__c = prRate.FA_Override__c,
            Portfolio_Override__c = prRate.Portfolio_Override__c
        );
        return prRateCreate;
    }

}