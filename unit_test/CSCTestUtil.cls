//
// (c) 2014 Appirio, Inc.
// Helper Class to provide support for test data creation
//
//
// 04 April 2014     Harshit Jain(JDC)       Original
public with sharing class CSCTestUtil {

    public static Account createAccount(String name) {
      Account account = new Account();
      account.Name = name;
      account.Catch_All__c = true;
    return account;
    }

    public static Opportunity createOpportunity(Id accountId, String name, String StageName) {
      Opportunity opportunity = new Opportunity();
      opportunity.Name = name;
      opportunity.CloseDate = System.today();
      opportunity.StageName = StageName;
      opportunity.AccountId = accountId;
      opportunity.RecordTypeId = RecordTypeUtils.OpportunityFOF.Id;
      return opportunity;
    }

    public static CSC_Action_List__c createActionList(Id accountId, String listName, String libType, Integer ord, Boolean template, Boolean fof ) {
      CSC_Action_List__c actionList = new CSC_Action_List__c();
      actionList.Action_List_Name__c = listName;
      actionList.Account__c = accountId;
      actionList.Library_Type__c = libType;
      actionList.Status__c = 'New';
      actionList.Order__c = ord;
      actionList.Template__c = template;
      actionList.Opportunity_Record_Type__c = 'FOF';
      return actionList;
    }

    public static CSC_Action_List__c createSPActionList(Id accountId, Id oppId, String listName, String libType, Integer ord, Boolean template, Boolean fof ) {
      CSC_Action_List__c actionList = new CSC_Action_List__c();
      actionList.Action_List_Name__c = listName;
      actionList.Account__c = accountId;
      actionList.Opportunity__c = oppId;
      actionList.Library_Type__c = libType;
      actionList.Status__c = 'New';
      actionList.Order__c = ord;
      actionList.Template__c = template;
      actionList.Opportunity_Record_Type__c = 'FOF';
      return actionList;
    }

    public static CSC_Action_Item__c createActionItem(Id actionListId, Integer ord) {
      CSC_Action_Item__c actionItem = new CSC_Action_Item__c();
      actionItem.CSC_Action_List__c = actionListId;
      actionItem.Status__c = 'New';
      actionItem.Order__c = ord;
      actionItem.Time_Frame_In_Business_Days__c = 2;
      actionItem.Opportunity_Notifications__c = '';                                                     //2015.05.12 Added for existing class test
      actionItem.Opp_Close_Date_Hidden__c = Date.newInstance(2018, 07, 05);
      actionItem.Delay_Alert_On__c = true;
      actionItem.Opp_Closed_HIDDEN_AI__c = false;
      actionItem.Business_Days_Due_Before_Close__c = 1;
      actionItem.RecordTypeId = RecordTypeUtils.CSCActionItemSalesProcess.Id;
      return actionItem;
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