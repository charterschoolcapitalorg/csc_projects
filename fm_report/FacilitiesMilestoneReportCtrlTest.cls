@isTest
public with sharing class FacilitiesMilestoneReportCtrlTest {
    
    @isTest
    public static void FacilitiesMilestoneReportCtrlTest_Sourced() {

        TestHelper.createCustomSettingToByPassTriggersAndRules('Account, Opportunity, CSC_Action_List__c, CSC_Action_Item__c');

        //create accounts
        //
        //
		//create account
		Account acct = new Account();
		acct.name = 'Test Acct';
		insert acct;



        //create opportunitise
        //
        //
        //create opportunity Tenant/School Sourced
        Opportunity oppTenant = new Opportunity();
        oppTenant.name = 'Test OppTenant';
        oppTenant.StageName = 'Stage 3 - Review';
        oppTenant.accountId = acct.id;
        oppTenant.CloseDate = System.today();
        oppTenant.Facilities_Channel__c = 'Tenant/School';
        oppTenant.Estimated_Project_Cost__c = 100;
        oppTenant.Latest_Update__c = 'dummy string here - latest update';
        oppTenant.Overview__c = 'dummy string here - overview';
        //testOppsToCreate.add(oppTenant);
        insert oppTenant;
        
        //create opportunity Broker
        Opportunity oppBroker = new Opportunity();
        oppBroker.name = 'Test oppBroker';
        oppBroker.StageName = 'Stage 3 - Review';
        oppBroker.accountId = acct.id;
        oppBroker.CloseDate = System.today();
        oppBroker.Facilities_Channel__c = 'Broker';
        oppBroker.Estimated_Project_Cost__c = 100;
        //testOppsToCreate.add(oppBroker);
        insert oppBroker;
        
        //create opportunity Developer
        Opportunity oppDeveloper = new Opportunity();
        oppDeveloper.name = 'Test oppDeveloper';
        oppDeveloper.StageName = 'Stage 3 - Review';
        oppDeveloper.accountId = acct.id;
        oppDeveloper.CloseDate = System.today();
        oppDeveloper.Facilities_Channel__c = 'Developer';
        oppDeveloper.Estimated_Project_Cost__c = 100;
        //testOppsToCreate.add(oppDeveloper);
        insert oppDeveloper;

        //create opportunity Owner
        Opportunity oppOwner = new Opportunity();
        oppOwner.name = 'Test oppOwner';
        oppOwner.StageName = 'Stage 3 - Review';
        oppOwner.accountId = acct.id;
        oppOwner.CloseDate = System.today();
        oppOwner.Facilities_Channel__c = 'Owner';
        oppOwner.Estimated_Project_Cost__c = 100;
        //testOppsToCreate.add(oppOwner);
        insert oppOwner;



        //create Action Lists
        //
        //
        //create Action Lists Tenant Sourced
        CSC_Action_List__c actionList = new CSC_Action_List__c();
        actionList.Action_List_Name__c = 'List Name';
        actionList.Account__c = acct.Id;
        actionList.Opportunity__c = oppTenant.Id;
        actionList.Library_Type__c = 'Underwriting';
        actionList.Status__c = 'New';
        actionList.Order__c = 1;
        actionList.Template__c = false;
        actionList.Opportunity_Record_Type__c = 'FOF';
        insert actionList;
        
        //create Action Lists Broker
        CSC_Action_List__c actionListBroker = new CSC_Action_List__c();
        actionListBroker.Action_List_Name__c = 'List Name Broker';
        actionListBroker.Account__c = acct.Id;
        actionListBroker.Opportunity__c = oppBroker.Id;
        actionListBroker.Library_Type__c = 'Underwriting';
        actionListBroker.Status__c = 'New';
        actionListBroker.Order__c = 1;
        actionListBroker.Template__c = false;
        actionListBroker.Opportunity_Record_Type__c = 'FOF';
        //testAListToCreate.add(actionListBroker);
        insert actionListBroker;
        
        //create Action Lists Developer
        CSC_Action_List__c actionListDeveloper = new CSC_Action_List__c();
        actionListDeveloper.Action_List_Name__c = 'List Name Developer';
        actionListDeveloper.Account__c = acct.Id;
        actionListDeveloper.Opportunity__c = oppDeveloper.Id;
        actionListDeveloper.Library_Type__c = 'Underwriting';
        actionListDeveloper.Status__c = 'New';
        actionListDeveloper.Order__c = 1;
        actionListDeveloper.Template__c = false;
        actionListDeveloper.Opportunity_Record_Type__c = 'FOF';
        //testAListToCreate.add(actionListDeveloper);
        insert actionListDeveloper;

        //create Action Lists Owner
        CSC_Action_List__c actionListOwner = new CSC_Action_List__c();
        actionListOwner.Action_List_Name__c = 'List Name Owner';
        actionListOwner.Account__c = acct.Id;
        actionListOwner.Opportunity__c = oppOwner.Id;
        actionListOwner.Library_Type__c = 'Underwriting';
        actionListOwner.Status__c = 'New';
        actionListOwner.Order__c = 1;
        actionListOwner.Template__c = false;
        actionListOwner.Opportunity_Record_Type__c = 'FOF';
        //testAListToCreate.add(actionListOwner);
        insert actionListOwner;




        //create Action Items
        //
        //
        //create Action Items Tenant
        List<CSC_Action_Item__c> itemsTenant = new List<CSC_Action_Item__c>();
        for(Integer i = 0; i < 11; i++){
            CSC_Action_Item__c item = CSCTestUtil.createActionItem(actionList.Id, i);
            switch on i{
                when 0 {
                    item.Action_Item_Name__c = 'Approve Phase 1 Opportunity';
                    item.Status__c = 'Completed';
                }
                when 1 {item.Action_Item_Name__c = 'FC Pre-Approval Prepared and Presented';}
                when 2 {item.Action_Item_Name__c = 'Deliver LOI to Seller';}
                when 3 {item.Action_Item_Name__c = 'Sign LOI';}
                when 4 {item.Action_Item_Name__c = 'Deliver Lease Proposal (MOU)';}
                when 5 {item.Action_Item_Name__c = 'Receive Lease Proposal (MOU) Approval';}
                when 6 {item.Action_Item_Name__c = 'Sign PSA';}
                when 7 {item.Action_Item_Name__c = 'Sign Lease';}
                when 8 {item.Action_Item_Name__c = 'Present Opportunity and Receive Final FC Approval';}
                when 9 {item.Action_Item_Name__c = 'Waive Diligence';}
                when else {item.Action_Item_Name__c = 'Fund Acquisition';}
            }
            itemsTenant.add(item);
        }
        insert itemsTenant;
        
        //create Action Items Broker
        List<CSC_Action_Item__c> itemsBroker = new List<CSC_Action_Item__c>();
        for(Integer i = 0; i < 11; i++){
            CSC_Action_Item__c item = CSCTestUtil.createActionItem(actionListBroker.Id, i);
            switch on i{
                when 0 {
                    item.Action_Item_Name__c = 'Approve Phase 1 Opportunity';
                    item.Status__c = 'Completed';
                }
                when 1 {item.Action_Item_Name__c = 'FC Pre-Approval Prepared and Presented';}
                when 2 {item.Action_Item_Name__c = 'Deliver LOI to Seller';}
                when 3 {item.Action_Item_Name__c = 'Sign LOI';}
                when 4 {item.Action_Item_Name__c = 'Deliver Lease Proposal (MOU)';}
                when 5 {item.Action_Item_Name__c = 'Receive Lease Proposal (MOU) Approval';}
                when 6 {item.Action_Item_Name__c = 'Sign PSA';}
                when 7 {item.Action_Item_Name__c = 'Sign Lease';}
                when 8 {item.Action_Item_Name__c = 'Present Opportunity and Receive Final FC Approval';}
                when 9 {item.Action_Item_Name__c = 'Waive Diligence';}
                when else {item.Action_Item_Name__c = 'Fund Acquisition';}
            }
            
            itemsBroker.add(item);
        }
        insert itemsBroker;
        
        //create Action Items Developer
        List<CSC_Action_Item__c> itemsDeveloper = new List<CSC_Action_Item__c>();
        for(Integer i = 0; i < 11; i++){
            CSC_Action_Item__c item = CSCTestUtil.createActionItem(actionListDeveloper.Id, i);
            switch on i{
                when 0 {
                    item.Action_Item_Name__c = 'Approve Phase 1 Opportunity';
                    item.Status__c = 'Completed';
                }
                when 1 {item.Action_Item_Name__c = 'FC Pre-Approval Prepared and Presented';}
                when 2 {item.Action_Item_Name__c = 'Deliver LOI to Seller';}
                when 3 {item.Action_Item_Name__c = 'Sign LOI';}
                when 4 {item.Action_Item_Name__c = 'Deliver Lease Proposal (MOU)';}
                when 5 {item.Action_Item_Name__c = 'Receive Lease Proposal (MOU) Approval';}
                when 6 {item.Action_Item_Name__c = 'Sign PSA';}
                when 7 {item.Action_Item_Name__c = 'Sign Lease';}
                when 8 {item.Action_Item_Name__c = 'Present Opportunity and Receive Final FC Approval';}
                when 9 {item.Action_Item_Name__c = 'Waive Diligence';}
                when else {item.Action_Item_Name__c = 'Fund Acquisition';}
            }
            
            itemsDeveloper.add(item);
        }
        insert itemsDeveloper;

        //create Action Items Owner
        List<CSC_Action_Item__c> itemsOwner = new List<CSC_Action_Item__c>();
        for(Integer i = 0; i < 11; i++){
            CSC_Action_Item__c item = CSCTestUtil.createActionItem(actionListOwner.Id, i);
            switch on i{
                when 0 {
                    item.Action_Item_Name__c = 'Approve Phase 1 Opportunity';
                    item.Status__c = 'Completed';
                }
                when 1 {item.Action_Item_Name__c = 'FC Pre-Approval Prepared and Presented';}
                when 2 {item.Action_Item_Name__c = 'Deliver LOI to Seller';}
                when 3 {item.Action_Item_Name__c = 'Sign LOI';}
                when 4 {item.Action_Item_Name__c = 'Deliver Lease Proposal (MOU)';}
                when 5 {item.Action_Item_Name__c = 'Receive Lease Proposal (MOU) Approval';}
                when 6 {item.Action_Item_Name__c = 'Sign PSA';}
                when 7 {item.Action_Item_Name__c = 'Sign Lease';}
                when 8 {item.Action_Item_Name__c = 'Present Opportunity and Receive Final FC Approval';}
                when 9 {item.Action_Item_Name__c = 'Waive Diligence';}
                when else {item.Action_Item_Name__c = 'Fund Acquisition';}
            }
            
            itemsOwner.add(item);
        }
        insert itemsOwner;

        Test.startTest();
        FacilitiesMilestoneReportCtrl.getFacilitiesMilestone();
        FacilitiesMilestoneReportCtrl controller = new FacilitiesMilestoneReportCtrl() ;
        Test.stopTest();
    }
    
    @isTest
    public static void FacilitiesMilestoneReportCtrlTest_Won() {

        TestHelper.createCustomSettingToByPassTriggersAndRules('Account, Opportunity, CSC_Action_List__c, CSC_Action_Item__c');

        //create accounts
        //
        //
		//create account
		Account acctWon = new Account();
		acctWon.name = 'Test Acct Won';
		insert acctWon;
        
        //create opportunity Tenant/School Won
        Opportunity oppTenantWon = new Opportunity();
        oppTenantWon.name = 'Test OppTenantWon';
        oppTenantWon.StageName = 'Stage 3 - Review';
        oppTenantWon.accountId = acctWon.id;
        oppTenantWon.CloseDate = System.today();
        oppTenantWon.Facilities_Channel__c = 'Tenant/School';
        oppTenantWon.Estimated_Project_Cost__c = 100;
        //testOppsToCreate.add(oppTenant);
        insert oppTenantWon;
        
        //create Action Lists Tenant Won
        CSC_Action_List__c actionListTenantWon = new CSC_Action_List__c();
        actionListTenantWon.Action_List_Name__c = 'List Name Tenant Won';
        actionListTenantWon.Account__c = acctWon.Id;
        actionListTenantWon.Opportunity__c = oppTenantWon.Id;
        actionListTenantWon.Library_Type__c = 'Underwriting';
        actionListTenantWon.Status__c = 'New';
        actionListTenantWon.Order__c = 1;
        actionListTenantWon.Template__c = false;
        actionListTenantWon.Opportunity_Record_Type__c = 'FOF';
        insert actionListTenantWon;
        
        //create Action Items Tenant Won
        List<CSC_Action_Item__c> itemsTenantWon = new List<CSC_Action_Item__c>();
        for(Integer i = 0; i < 11; i++){
            CSC_Action_Item__c item = CSCTestUtil.createActionItem(actionListTenantWon.Id, i);
            switch on i{
                when 0 {
                    item.Action_Item_Name__c = 'Approve Phase 1 Opportunity';
                    //item.Status__c = 'Completed';
                }
                when 1 {item.Action_Item_Name__c = 'FC Pre-Approval Prepared and Presented';}
                when 2 {item.Action_Item_Name__c = 'Deliver LOI to Seller';}
                when 3 {item.Action_Item_Name__c = 'Sign LOI';}
                when 4 {item.Action_Item_Name__c = 'Deliver Lease Proposal (MOU)';}
                when 5 {item.Action_Item_Name__c = 'Receive Lease Proposal (MOU) Approval';}
                when 6 {item.Action_Item_Name__c = 'Sign PSA';}
                when 7 {item.Action_Item_Name__c = 'Sign Lease';}
                when 8 {item.Action_Item_Name__c = 'Present Opportunity and Receive Final FC Approval';}
                when 9 {item.Action_Item_Name__c = 'Waive Diligence';}
                when else {
                    item.Action_Item_Name__c = 'Fund Acquisition';
                    item.Status__c = 'Completed';
                }
            }
            itemsTenantWon.add(item);
        }
        insert itemsTenantWon;
        
        Test.startTest();
        FacilitiesMilestoneReportCtrl.getFacilitiesMilestone();
        FacilitiesMilestoneReportCtrl controller = new FacilitiesMilestoneReportCtrl() ;
        Test.stopTest();
    }
}