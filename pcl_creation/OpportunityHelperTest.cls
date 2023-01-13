//
// (c) 2014 Appirio, Inc.
//
// A Test class for an opportunity trigger helper class
//
//  April 07,  2014     Harshit Jain       Original
//
@isTest
public class OpportunityHelperTest {
  private static Account testAccount;
  private static Opportunity opportunity;
  private static Contact mainContact;

  static testMethod void testActionListCloningOnOpportunity() {
    Test.startTest();
      createTestData();
      opportunity = CSCTestUtil.createOpportunity(testAccount.Id, 'Unit Test Opp', 'Stage 1 - Projected');
      insert opportunity;

      System.assertEquals(5, [Select Id From CSC_Action_List__c Where Opportunity__c =: opportunity.Id].size());

      CSCActionItemTriggerManagement.isActionTriggerTriggerRunning = false;
      //update opportunity stage
      opportunity.StageName = 'Stage 2 - Request';
      update opportunity;


      System.assertEquals('5 out of 5', [Select Id, Open_Items__c From Opportunity Where Id =: opportunity.Id].Open_Items__c);
    Test.stopTest();
  }

  static testMethod void testExpirationDateOnItem() {
  	Test.startTest();
      createTestData();
      opportunity = CSCTestUtil.createOpportunity(testAccount.Id, 'Unit Test Opp123', 'Stage 1 - Projected');
      insert opportunity;

      List<CSC_Action_Item__c> itemList = [Select Time_Frame_Expiration_Date__c, Opportunity__c,
													                        IsAllowExpirationNotification__c, CSC_Action_List__r.Action_List_Name__c
													                 From   CSC_Action_Item__c
													                 Where  Opportunity_Id__c != null
													                 AND    CSC_Action_List__r.Action_List_Name__c  = 'Stage 1 - Projected'];

      //Assert expiration date, Should not be null if time frame in business day provided
      System.assertNotEquals(null, itemList.get(0).Time_Frame_Expiration_Date__c);
      System.assertEquals(true, itemList.get(0).IsAllowExpirationNotification__c);
    Test.stopTest();
  }

  //2015.10.19 J Caughie - test before insert opportunity type update
  private static testMethod void testFacilitiesOpportunityInsert(){
      createTestData();
      Opportunity opp = CSCTestUtil.createOpportunity(testAccount.Id, 'Unit Test Opp123', 'Stage x - Projected');
      opp.Lead_Opportunity_Type__c = 'Facilities';
      Test.startTest();
      insert opp;
      Test.stopTest();
      Opportunity updatedOpp = ([Select Name, StageName FROM Opportunity WHERE id = :opp.id]);
      System.assertEquals('Stage 01 - Prospect', updatedOpp.StageName);
  }

  private static testMethod void testFOFOpportunityInsert(){
      createTestData();
      Opportunity opp = CSCTestUtil.createOpportunity(testAccount.Id, 'Unit Test Opp123', 'Stage x - Projected');
      opp.Lead_Opportunity_Type__c = 'FOF';
      Test.startTest();
      insert opp;
      Test.stopTest();
      Opportunity updatedOpp = ([Select Name, StageName FROM Opportunity WHERE id = :opp.id]);
      System.assertEquals('Stage 1 - Projected', updatedOpp.StageName);
  }

  private static testMethod void testInitialFundingOpportunityInsert(){
      createTestData();
      Opportunity opp = CSCTestUtil.createOpportunity(testAccount.Id, 'Unit Test Opp123', 'Stage x - Projected');
      opp.Lead_Opportunity_Type__c = 'Initial Funding';
      Test.startTest();
      insert opp;
      Test.stopTest();
      Opportunity updatedOpp = ([Select Name, StageName FROM Opportunity WHERE id = :opp.id]);
      System.assertEquals('Stage 1 - Prospect', updatedOpp.StageName);
  }

  private static testMethod void testBulkOpportunityInsert(){
      createTestData();
      List<Opportunity> listOpps = new List<Opportunity>();
      for(Integer i = 0; i<50; i++){
        Opportunity o = CSCTestUtil.createOpportunity(testAccount.Id, 'Opp - ' + i, 'Stage x - Projected');
        o.Lead_Opportunity_Type__c = 'Facilities';
        listOpps.add(o);
      }
      Test.startTest();
      insert listOpps;
      Test.stopTest();
      List<Opportunity> updatedOpps = new List<Opportunity>();
      updatedOpps = ([Select StageName FROM Opportunity]);
      //Test that all have been inserted
      System.assertEquals(50, updatedOpps.size());
      //Test a random insert to ensure the StageName has been updated
      System.debug((Integer)Math.floor(Math.random()*50));
      System.assertEquals('Stage 01 - Prospect', updatedOpps[(Integer)Math.floor(Math.random()*50)].StageName);
  }
  //2015.10.19 J Caughie - test before insert opportunity type update

  //2017.04.06 J Caughie - test opportunity signers
  private static testMethod void testOpportunitySignersInsert(){
    createTestData();
    Opportunity opp = new Opportunity();
    opp = CSCTestUtil.createOpportunity(testAccount.Id, 'Opp - Test', 'Stage x - Projected');
    Test.startTest();
    insert opp;
    Test.stopTest();
    Opportunity updatedOpp = [SELECT Signer_1__c, Signer_2__c, Signer_Manager_1__c, Signer_AP__c FROM Opportunity WHERE id = :opp.Id];
    System.assertEquals(null, updatedOpp.Signer_1__c);
    System.assertEquals(null, updatedOpp.Signer_2__c);
    System.assertEquals(null, updatedOpp.Signer_Manager_1__c);
    System.assertEquals(null, updatedOpp.Signer_AP__c);
  }
  
  private static testMethod void testOpportunityWhiteboard(){
    createTestData();
    Opportunity opp = new Opportunity();
    opp = CSCTestUtil.createOpportunity(testAccount.Id, 'Opp - Test', 'Stage x - Projected');
    insert opp;
    //move opportunity to Whiteboard
    opp.StageName = 'Stage 3 - Review';
    Test.startTest();
    update opp;
    Test.stopTest();
    Opportunity updatedOpp = [SELECT Signer_1__c, Signer_2_FN__c, Signer_Manager_1_FN__c, Signer_Manager_2_FN__c, Internal_Ref__c, Operating_State__c, Signer_AP__c FROM Opportunity WHERE id = :opp.Id];
    System.assertEquals(mainContact.Id, updatedOpp.Signer_1__c);
    System.assertEquals('Amanda Ripley', updatedOpp.Signer_2_FN__c);
    System.assertEquals('Ellen Ripley', updatedOpp.Signer_Manager_1_FN__c);
    System.assertEquals('Amanda Ripley', updatedOpp.Signer_Manager_2_FN__c);
    System.assertEquals(updatedOpp.Internal_Ref__c, updatedOpp.Operating_State__c + String.valueOf(Date.today().year()).right(2) + '-' + 1, 'Should be first AZ opportunity current year'); //only 1 opportunity for the test client
    System.assertEquals(null, updatedOpp.Signer_AP__c);
  }

  private static testMethod void testOpportunityWhiteboardAPSigner(){
    createTestData();
    Account cmo = new Account(name = 'Test CMO');
    cmo.Manager_s_COA__c = true;
    insert cmo;
    testAccount.CMO__c = cmo.Id;
    update testAccount;
    Contact cmoContact = new Contact(FirstName = 'Dennis', LastName = 'Parker', Account = cmo);
    insert cmoContact;
    Related_Contact__c rc = new Related_Contact__c(Contact__c = cmoContact.Id, Account__c = cmo.Id, Management_Authorized_Signer__c = true, Signatory__c = 'Management Signer 1');
    insert rc;
    Opportunity opp = new Opportunity();
    opp = CSCTestUtil.createOpportunity(testAccount.Id, 'Opp - Test', 'Stage x - Projected');
    insert opp;
    //move opportunity to Whiteboard
    opp.StageName = 'Stage 3 - Review';
    Test.startTest();
    update opp;
    Test.stopTest();
    Opportunity updatedOpp = [SELECT Signer_1__c, Signer_2_FN__c, Signer_Manager_1_FN__c, Signer_Manager_2_FN__c, Internal_Ref__c, Operating_State__c, Signer_AP__c FROM Opportunity WHERE id = :opp.Id];
    System.assertEquals(mainContact.Id, updatedOpp.Signer_1__c);
    System.assertEquals('Amanda Ripley', updatedOpp.Signer_2_FN__c);
    System.assertEquals('Ellen Ripley', updatedOpp.Signer_Manager_1_FN__c);
    System.assertEquals('Amanda Ripley', updatedOpp.Signer_Manager_2_FN__c);
    System.assertEquals(updatedOpp.Internal_Ref__c, updatedOpp.Operating_State__c + String.valueOf(Date.today().year()).right(2) + '-' + 1, 'Should be first AZ opportunity current year'); //only 1 opportunity for the test client
    System.assertEquals(cmoContact.Id, updatedOpp.Signer_AP__c);
  }
  //2017.04.06 J Caughie - test opportunity signers

    
  public static void createTestData() {
    //Custom Settings
    Action_List_Settings__c actionListSettings = new Action_List_Settings__c(
      SetupOwnerId = UserInfo.getOrganizationId(),
      Order_Threshold__c = 0
    );
    insert actionListSettings;

    BypassRulesandTriggers__c ProfileCustomSettings = new BypassRulesandTriggers__c (Trigger_Objects__c = 'Lead;Account;Contact;Opportunity;Applicant__c;Attachment;Charter_Term__c;CSC_Action_Item__c;CSC_Action_List__c;Opp_School__c;Related_Contact__c;RPA__c;Terms_Letter__c',
                                            Triggers_Disabled__c = false,
                                            Validation_Rules_Disabled__c = false,
                                            Workflow_Rules_Disabled__c = false);
    insert ProfileCustomSettings;

    State_Province__c state = TestHelper.createStateProvince('AZ', true);

    Account testCMO = CSCTestUtil.createAccount('Test CMO 1');
    insert testCMO;
    mainContact = new Contact(FirstName = 'Ellen', LastName = 'Ripley', Account = testCMO);
    insert mainContact;
    Related_Contact__c rcCMO = new Related_Contact__c(Account__c = testCMO.Id, Contact__c = mainContact.Id, Authorized_Signer__c = true);
    insert rcCMO;

    testAccount = CSCTestUtil.createAccount('Test Account 1');
    testAccount.Operating_State__c = state.Id;
    testAccount.CMO__c = testCMO.Id;
    insert testAccount;

    //2017.04.06 J Caughie - added contact for related contact tests
    Contact testContact2 = new Contact(FirstName = 'Newt', LastName = 'Ripley', Account = testAccount, Formal_Name__c = 'Amanda Ripley');
    insert testContact2;

    Related_Contact__c rc1 = new Related_Contact__c(Account__c = testAccount.Id, Contact__c = mainContact.Id, Authorized_Signer__c = true, Signatory__c = 'Signer 1');
    insert rc1;
    Related_Contact__c rc2 = new Related_Contact__c(Account__c = testAccount.Id, Contact__c = testContact2.Id, Authorized_Signer__c = true, Signatory__c = 'Signer 2');
    insert rc2;
    Related_Contact__c rc3 = new Related_Contact__c(Account__c = testAccount.Id, Contact__c = mainContact.Id, Management_Authorized_Signer__c = true, Signatory__c = 'Management Signer 1');
    insert rc3;
    Related_Contact__c rc4 = new Related_Contact__c(Account__c = testAccount.Id, Contact__c = testContact2.Id, Management_Authorized_Signer__c = true, Signatory__c = 'Management Signer 2');
    insert rc4;
    //2017.04.06 J Caughie

    //2015.10.19 J Caughie - added custom settings for insert test
    InitialStageName__c oppStageNames = new InitialStageName__c(
      Name = 'Standard',
      Facilities__c = 'Stage 01 - Prospect',
      FOF__c = 'Stage 1 - Projected',
      Initial_Funding__c = 'Stage 1 - Prospect'
    );
    insert oppStageNames;
    //2015.10.19 J Caughie - added custom settings for insert test      

    //Create Action List records
    CSC_Action_List__c actionList1 = CSCTestUtil.createActionList(testAccount.Id, 'Stage 1 - Projected' ,'Finance', 1, true, true);
    CSC_Action_List__c actionList2 = CSCTestUtil.createActionList(testAccount.Id, 'Stage 2 - Request' ,'Finance', 2, true, true);
    CSC_Action_List__c actionList3 = CSCTestUtil.createActionList(testAccount.Id, 'Stage 3 - Review' ,'Finance', 3, true, true);
    CSC_Action_List__c actionList4 = CSCTestUtil.createActionList(testAccount.Id, 'Stage 4 - Client Response' ,'Finance', 4, true, true);
    CSC_Action_List__c actionList5 = CSCTestUtil.createActionList(testAccount.Id, 'Stage 5 - FC Review' ,'Finance', 5, true, true);
    Flags.SkipActionListOrderResequencing = true;
    insert new List<CSC_Action_List__c> { actionList1, actionList2, actionList3, actionList4, actionList5 };
    Flags.reset();


    //create Action List Items
    CSC_Action_Item__c item1 = CSCTestUtil.createActionItem(actionList1.Id, 1);
    CSC_Action_Item__c item2 = CSCTestUtil.createActionItem(actionList1.Id, 2);
    CSC_Action_Item__c item3 = CSCTestUtil.createActionItem(actionList1.Id, 3);
    CSC_Action_Item__c item4 = CSCTestUtil.createActionItem(actionList1.Id, 4);
    CSC_Action_Item__c item5 = CSCTestUtil.createActionItem(actionList1.Id, 5);
    CSC_Action_Item__c item6 = CSCTestUtil.createActionItem(actionList2.Id, 1);
    CSC_Action_Item__c item7 = CSCTestUtil.createActionItem(actionList2.Id, 2);
    CSC_Action_Item__c item8 = CSCTestUtil.createActionItem(actionList3.Id, 1);
    CSC_Action_Item__c item9 = CSCTestUtil.createActionItem(actionList3.Id, 2);
    CSC_Action_Item__c item10 = CSCTestUtil.createActionItem(actionList3.Id, 3);
    CSC_Action_Item__c item11 = CSCTestUtil.createActionItem(actionList4.Id, 1);
    CSC_Action_Item__c item12 = CSCTestUtil.createActionItem(actionList4.Id, 2);
    CSC_Action_Item__c item13 = CSCTestUtil.createActionItem(actionList4.Id, 3);
    CSC_Action_Item__c item14 = CSCTestUtil.createActionItem(actionList5.Id, 1);
    CSC_Action_Item__c item15 = CSCTestUtil.createActionItem(actionList5.Id, 2);
    Flags.SkipActionItemOrderResequencing = true;
    insert new List<CSC_Action_Item__c> { item1, item2, item3, item4, item5,item6, item7, item8, item9, item10,item11, item12, item13, item14, item15 };
    Flags.reset();

  }

  @isTest 
  static void testPropOntoOpp(){
    Account junk = new Account(Name='test account 2');
    insert junk;
    opportunity = CSCTestUtil.createOpportunity(junk.Id, 'Unit Test Opp', 'Stage 1 - Projected');
    insert opportunity;
    Id propertyRTId = [SELECT Id FROM RecordType WHERE Name='Property'].Id;
    testAccount = new Account(Name='Test Accout 1',RecordTypeId = propertyRTId);
    testAccount.Opportunity_That_Created_the_Property__c = ''+opportunity.Id;

    Test.startTest();
    insert testAccount;
    Test.stopTest();

    System.debug(opportunity.Property__c);


  }
}