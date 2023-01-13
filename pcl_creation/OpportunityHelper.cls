//
// (c) 2014 Appirio, Inc.
// Helper Class to handle all Oppurtunity trigger events
//
//
// 01 April 2014     Abhishek Pareek(JDC)       Original
public without sharing class OpportunityHelper {
    private static BusinessHours bHours;
    private static Long hoursPerDay;
    private static Map<String, Id> oppNameToId = new Map<String, Id>(RecordTypeUtils.getsObjectRecordMap('Opportunity'));
    
    private static boolean createdActionItems = false;
    private static boolean updatedItems = false;
    
    public static boolean createdPQFOrmsAndItems = false;
    
    static {
        for(BusinessHours bHour: [Select Id, Name, IsDefault, IsActive, MondayStartTime, MondayEndTime From BusinessHours Where IsDefault = true And IsActive = true]) {
          bHours = bHour;
          hoursPerDay = (bHour.MondayEndTime.hour() - bHour.MondayStartTime.hour())*3600000;
        }
    }

    public void onAfterInsert( Map<Id,Opportunity> newOppMap){
        if (!createdActionItems) {
            addActionListToOpportunities(newOppMap);
            createdActionItems = true;
        }
        updateExpirationDateOnItems(newOppMap, null);
    }
    public static Id facMgmtGrp;
    static {
      try {
        
      CollaborationGroup g =  [SELECT Id,Name From CollaborationGroup WHERE CollaborationType='Public' and Name = 'FAM - Facilities Asset Management Team'];
      facMgmtGrp = g.Id;
      
      } catch (Exception e) {}
    }
    public static Id legalGrp;
    static {
      try {
        
      CollaborationGroup g =  [SELECT Id,Name From CollaborationGroup WHERE CollaborationType='Public' and 
                               Name = 'UW - Underwriting Team'];
      legalGrp = g.Id;
      
      } catch (Exception e) {}
    }
    public static Id acctGrp;
    static {
      try {
        
      CollaborationGroup g =  [SELECT Id,Name From CollaborationGroup WHERE CollaborationType='Public' 
                               and Name = 'AM - Account Management Team'];
      acctGrp = g.Id;
      
      } catch (Exception e) {}
    }
       
    private ConnectApi.FeedItemInput postFeedElement(Id lcId ) {
        
        ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
        ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
        ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();
        ConnectApi.TextSegmentInput blankCharSegmentInput = new ConnectApi.TextSegmentInput();
        messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
        blankCharSegmentInput.text = ' ';
        
        ConnectApi.MentionSegmentInput mentionSegmentInput = new ConnectApi.MentionSegmentInput();
        mentionSegmentInput.id = facMgmtGrp;
        messageBodyInput.messageSegments.add(mentionSegmentInput);
        messageBodyInput.messageSegments.add(blankCharSegmentInput);
        
        ConnectApi.MentionSegmentInput mentionSegmentInput2 = new ConnectApi.MentionSegmentInput();
        mentionSegmentInput2.id = legalGrp;
        messageBodyInput.messageSegments.add(mentionSegmentInput2);
        messageBodyInput.messageSegments.add(blankCharSegmentInput);
        
        ConnectApi.MentionSegmentInput mentionSegmentInput3 = new ConnectApi.MentionSegmentInput();
        mentionSegmentInput3.id = acctGrp;
        messageBodyInput.messageSegments.add(mentionSegmentInput3);
        messageBodyInput.messageSegments.add(blankCharSegmentInput);
            
        textSegmentInput.text = '\r\n A Property has been linked to this Opportunity';
        messageBodyInput.messageSegments.add(textSegmentInput);
        feedItemInput.body = messageBodyInput;
        feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
        feedItemInput.subjectId = lcId+'';
        System.debug('****posting feed for group id : ' + facMgmtGrp);
        return feedItemInput;
            
    }
    
    public void onAfterUpdate(Map<Id,Opportunity> newOppMap, Map<Id,Opportunity> oldOppMap){
        System.debug('in onAfterUpdate in Opportunity Helper');
        
        if (!updatedItems) {
            updateOpenItemField(newOppMap, oldOppMap);
            updateExpirationDateOnItems(newOppMap, oldOppMap);
            updatedItems = true;
        }
        
        //RE - MOLINGER-009/04/19
        // WHen an Opp is tied to a Property - post a Chatter feed to Legal, Accounting and FAM teams (chatter groups) on the Opportunity 
        Set<Id> oppsForFeed = new Set<Id>();
        for (Opportunity o : newOppMap.values()) { 
            if (o.property__c!=null && oldOppMap.get(o.Id).Property__c==null) {
                oppsForFeed.add(o.Id);
            }    
        }
        List<ConnectApi.FeedItemInput> feedItemsForInsert = new List<ConnectApi.FeedItemInput>();
        for (Id i : oppsForFeed) {
            feedItemsForInsert.add(postFeedElement(i));    
        }
        
        for ( ConnectApi.FeedItemInput feedItem : feedItemsForInsert) {
           if (!Test.isrunningtest()) ConnectApi.FeedElement feedElement = ConnectApi.ChatterFeeds.postFeedElement(Network.getNetworkId(), feedItem);    
        }
        
        //RE - MOLINGER-009/04/19
        //When Opp is moved to Closed Lost, Updates Status on realted Porperty objects to On Hold
        Set<Id> pIds = new Set<Id>();
        for (Opportunity o : newOppMap.values()) { 
            if (o.property__c!=null && o.IsClosed && o.IsLost__c && 
                (!oldOppMap.get(o.Id).isClosed)) {
                pIds.add(o.property__c);
            }    
        }
        
        if (pIds.size()>0) {
            List<Account> props = CreateFacilitiesObjectsCtrl.getProperties(pIds);
            for (Account a : props) {
                a.Property_Status__c = 'On Hold';
            }
            update props;
            
            List<Tenant__c> tt = CreateFacilitiesObjectsCtrl.getTenants(pIds);
            if (tt!=null) {
                for (Tenant__c t : tt) {
                    t.Property_Status__c = 'On Hold';
                }
                update tt;
            }
        }
        
        
        //RE MOlinger-4/09/2019-CLient Portal Role AUtomation
        /*System.debug('doing client portal automation');
        Set<Id> acctIds = new Set<Id>();
        for (Opportunity o : newOppMap.values()) { 
            if (o.Diligence_Completed_FIN__c != null && o.Diligence_Completed_UW__c != null && o.AM_has_Reviewed_FE__c!=null) {
                if ((o.Diligence_Completed_FIN__c != oldOppMap.get(o.Id).Diligence_Completed_FIN__c && oldOppMap.get(o.Id).Diligence_Completed_FIN__c==null) ||
                    (o.Diligence_Completed_UW__c != oldOppMap.get(o.Id).Diligence_Completed_UW__c && oldOppMap.get(o.Id).Diligence_Completed_UW__c==null) ||
                    (o.AM_has_Reviewed_FE__c != oldOppMap.get(o.Id).AM_has_Reviewed_FE__c && oldOppMap.get(o.Id).AM_has_Reviewed_FE__c==null)
                ) {
                        
                    //look at Related Contacts from Opp and create Client Portal Roles if Client_Portal_User_Role__c is filled in
                    acctIds.add(o.AccountId);
                }
            }
        }*/

        //2019.10.03 J Caughie - removed AM review - case 00001577
        System.debug('doing client portal automation');
        Set<Id> acctIds = new Set<Id>();
        for (Opportunity o : newOppMap.values()) { 
            if (o.Diligence_Completed_FIN__c != null && o.Diligence_Completed_UW__c != null) {
                if ((o.Diligence_Completed_FIN__c != oldOppMap.get(o.Id).Diligence_Completed_FIN__c && oldOppMap.get(o.Id).Diligence_Completed_FIN__c==null) ||
                    (o.Diligence_Completed_UW__c != oldOppMap.get(o.Id).Diligence_Completed_UW__c && oldOppMap.get(o.Id).Diligence_Completed_UW__c==null)
                ) {
                        
                    //look at Related Contacts from Opp and create Client Portal Roles if Client_Portal_User_Role__c is filled in
                    acctIds.add(o.AccountId);
                }
            }
        }





            
        System.debug('for acct ids: ' + acctIds);
        if (acctids.size()>0) {
                if (OpportunityStatics.didClientPortalAutomation()) {
                    
                    List<Send_Community_Invite_Controller.ConWrapper> conswrapper = new List<Send_Community_Invite_Controller.ConWrapper>(); 
                    //Send_Community_Invite_Controller.consWrapper conswrapper = new Send_Community_Invite_Controller.consWrapper(); 
                    List<Account> accts = [Select Id, (Select Id,Contact__r.Name, Contact__c, Client_Portal_User_Role__c from Legal_Contacts__r where Client_Portal_User_Role__c!=null) from Account where ID IN:acctids];
                    Set<Id> conIds = new Set<Id>();
                    
                    for (Account a : accts) {
                        if (a.Legal_Contacts__r!=null && a.Legal_Contacts__r.size()>0) {
                            for (Related_Contact__c rc : a.Legal_Contacts__r) {
                                conIds.add(rc.Contact__c);
                            }
                        }
                    }
                    
                    Map<Id,Contact> cons = new Map<Id,Contact>([Select Id, AccountId, Email, Name, FirstName, LastName from Contact where ID IN:conIDs]);
                    for (Account a : accts) {
                        if (a.Legal_Contacts__r!=null && a.Legal_Contacts__r.size()>0) {
                            for (Related_Contact__c rc : a.Legal_Contacts__r) {
                                Send_Community_Invite_Controller.ConWrapper c = new Send_Community_Invite_Controller.ConWrapper(cons.get(rc.contact__c));
                                c.selected = true;
                                c.conName = rc.Contact__r.Name;
                                c.role = rc.Client_Portal_User_Role__c;
                                conswrapper.add(c);
                                System.debug('***** adding contact for role creation: ' + c);
                            }
                        }
                    }
                    System.debug('***** conswrapper: ' + conswrapper);
                       
                    //Opportunity opp = new Opportunity();
                    for (Opportunity o : newOppMap.values()) { 
                        if (conswrapper.size()>0) {
                            Send_Community_Invite_Controller ctrl = new Send_Community_Invite_Controller(new ApexPages.StandardController(o));
                            //Send_Community_Invite_Controller ctrl = new Send_Community_Invite_Controller();           
                            ctrl.consWrapper = conswrapper;
                            
                            List<Id> insertedUserIds = ctrl.createCommunityUsers(false);
                            if (insertedUserIds==null||insertedUserIds.size()==0) { 
                                
                            } else {
                                //add Contact Role for this Opp is doesnt exist
                                Map<Id,STring> conRoleMap = new Map<Id,String>();
                                for (Send_Community_Invite_Controller.ConWrapper c : consWrapper) {
                                    if (c.selected) {
                                        conRoleMap.put(c.con.Id, c.Role);
                                    }
                                }
                                ctrl.createContactRoles(conRoleMap);
                            }
                        }
                    }
                }
        }
    }

    //2017.04.06 J Caughie
    public void onBeforeUpdate(Map<Id,Opportunity> newOppMap, Map<Id,Opportunity> oldOppMap){
        updateWhiteboardOpps(newOppMap, oldOppMap);
    }
    //2017.04.06 J Caughie

    //2014.12.18 J Caughie - Added Method to allow re-use of code for opportunity button
    public static void addOppsManually(Map<Id,Opportunity> newOppMap){
        addActionListToOpportunities(newOppMap);    
    }

    //2015.10.19 J Caughie - Update Opportunity type before insert based on selection on lead layout page
    public static void onBeforeInsert(){
        updateOpportunityType(Trigger.new);
        
    }

  //Add appropriate action list and action items to opportunity based on their record types
    private static void addActionListToOpportunities(Map<Id, Opportunity> newOppMap) {
        Map<String, List<CSC_Action_List__c>> allActionListsMap = retrieveActionLists();
        Map<Id, String> oppRTMap = retrieveOppRecordTypeMap();
        Map<Id, List<CSC_Action_Item__c>> actionListToItemMap = new Map<Id, List<CSC_Action_Item__c>>();
        List<CSC_Action_List__c> actionListToBeInserted = new List<CSC_Action_List__c>();
        List<CSC_Action_Item__c> actionItemsToBeInserted = new List<CSC_Action_Item__c>();

        if(allActionListsMap.size() > 0) {
            for(Opportunity opp: newOppMap.values()) {
                if(opp.RecordTypeId != null 
                    && oppRTMap.containsKey(opp.RecordTypeId) 
                    && allActionListsMap.containsKey(oppRTMap.get(opp.RecordTypeId))) {
                    
                        for(CSC_Action_List__c origList : allActionListsMap.get(oppRTMap.get(opp.RecordTypeId))) {
                            //Make a copy of Action List template and attach it to Opportunity based on record type
                            CSC_Action_List__c newList = origList.clone(false, true, false, false);
                            newList.Source_List__c = origList.Id;
                            newList.Account__c = opp.AccountId;
                            newList.Opportunity__c = opp.Id;
                            newList.Status__c = 'New';
                            newList.Template__c = false;
                            actionListToItemMap.put(origList.Id, origList.CSC_Action_Items__r);
                            actionListToBeInserted.add(newList);
                        }
                }
            }
        }

        //Insert Action list
        if(actionListToBeInserted.size() > 0) {
            Flags.SkipActionListOrderResequencing = true;
            try {
                insert actionListToBeInserted;
            } finally {
                //Flags.SkipActionListOrderResequencing = false;
            }
        }

        for(CSC_Action_List__c origList : actionListToBeInserted) {
            if(actionListToItemMap.containsKey(origList.Source_List__c)) {
                for(CSC_Action_Item__c origItem : actionListToItemMap.get(origList.Source_List__c)) {
                    //Make a copy of Action Item template and attach it to action list that already attached to opportunity
                    CSC_Action_Item__c newItem = origItem.clone(false, true, false, false);
                    newItem.CSC_Action_List__c = origList.Id;
                    actionItemsToBeInserted.add(newItem);
                }
            }
        }

        //Insert Action Items
        if(actionItemsToBeInserted.size() > 0) {
            Flags.SkipActionItemOrderResequencing = true;
            try {
                insert actionItemsToBeInserted;
            } finally {
                Flags.SkipActionItemOrderResequencing = false;
            }
        }
    }

    private static void updateOpenItemField(Map<Id, Opportunity> newOppMap, Map<Id, Opportunity> oldOppMap) {
      Map<Id, String> opportunityStageMap = new Map<Id, String>();

      if(!CSCActionItemTriggerManagement.isActionTriggerTriggerRunning) {
        for(Opportunity opp: newOppMap.values()) {
            if(opp.StageName != oldOppMap.get(opp.Id).StageName) {
              opportunityStageMap.put(opp.Id, opp.StageName.deleteWhitespace());
            }
          }

          if(opportunityStageMap.size() > 0) {
            doOpentItemFieldCalculation(opportunityStageMap, newOppMap);
          }

      }
    }

    private static void updateExpirationDateOnItems(Map<Id, Opportunity> newOppMap, Map<Id, Opportunity> oldOppMap) {
      Set<Id> OpportunityIds = new Set<Id>();

      for(Opportunity opp: newOppMap.values()) {
          if(Trigger.isInsert || (Trigger.isUpdate && opp.StageName != oldOppMap.get(opp.Id).StageName)) {
            OpportunityIds.add(opp.Id);
          }
      }

      if(OpportunityIds.size() > 0) {
        doPopulateExpirationDateOnItem(OpportunityIds, newOppMap);
      }
    }

    private static void doPopulateExpirationDateOnItem(Set<Id> opportunityIds, Map<Id, Opportunity> newOppMap)  {
      Map<String, CSC_Action_List__c> actionListMap = new Map<String, CSC_Action_List__c>();
      List<CSC_Action_Item__c> itemsToBeUpdate = new List<CSC_Action_Item__c>();

      for(CSC_Action_List__c listRec: [SELECT ID, Opportunity__c, Action_List_Name__c,Num_Open_Items__c,Num_Items__c,
                                              (Select Id, Name, Time_Frame_In_Business_Days__c, Time_Frame_Expiration_Date__c From CSC_Action_Items__r)
                                        FROM   CSC_Action_List__c
                                        WHERE  Opportunity__c IN: opportunityIds]) {
         actionListMap.put(listRec.Opportunity__c+'~'+listRec.Action_List_Name__c.deleteWhitespace(), listRec);
       }

       for(Id oppId : opportunityIds) {
         if(actionListMap.containsKey(oppId+'~'+newOppMap.get(oppId).StageName.deleteWhitespace())) {
           for(CSC_Action_Item__c item : actionListMap.get(oppId+'~'+newOppMap.get(oppId).StageName.deleteWhitespace()).CSC_Action_Items__r) {
             if(item.Time_Frame_In_Business_Days__c != null && item.Time_Frame_In_Business_Days__c > 0 && bHours != null) {
               itemsToBeUpdate.add(new CSC_Action_Item__c(Id = item.Id, Time_Frame_Expiration_Date__c = BusinessHours.add(bHours.Id, BusinessHours.nextStartDate(bHours.Id,DateTime.now()), hoursPerDay), IsAllowExpirationNotification__c = true));
             }
           }
         }
       }

       if(itemsToBeUpdate.size() > 0) {
         update itemsToBeUpdate;
       }
    }

    private static void doOpentItemFieldCalculation(Map<Id, String> opportunityStageMap, Map<Id, Opportunity> oppMap) {
       Map<String, CSC_Action_List__c> actionListMap = new Map<String, CSC_Action_List__c>();
       List<Opportunity> opportunitiesToBeUdpated = new List<Opportunity>();
       for(CSC_Action_List__c listRec: [SELECT ID, Opportunity__c, Action_List_Name__c,Num_Open_Items__c,Num_Items__c
                                        FROM   CSC_Action_List__c
                                        WHERE  Opportunity__c IN: opportunityStageMap.keyset()]) {
         actionListMap.put(listRec.Opportunity__c+'~'+listRec.Action_List_Name__c.deleteWhitespace(), listRec);
       }

       for(ID oppId : opportunityStageMap.KeySet()) {
         if(actionListMap.ContainsKey(oppId+'~'+opportunityStageMap.get(oppId))) {
             CSC_Action_List__c listRec = actionListMap.get(oppId+'~'+opportunityStageMap.get(oppId));
             String openItemValue = listRec.Num_Open_Items__c + ' out of ' + listRec.Num_Items__c;
             if(!openItemValue.equalsIgnoreCase(oppMap.get(oppId).Open_Items__c)) {
               opportunitiesToBeUdpated.add(new Opportunity(Id = oppId, Open_Items__c = openItemValue));
             }
         }
       }

       if(opportunitiesToBeUdpated.size() > 0) {
         update opportunitiesToBeUdpated;
       }

    }

    private static Map<Id, String> retrieveOppRecordTypeMap(){
        Map<Id, String> oppRTMap = new Map<Id, String>();
        for(RecordType rt : [Select Id, Name, DeveloperName, BusinessProcessId From RecordType where SobjectType='Opportunity']) {
          oppRTMap.put(rt.Id, rt.Name.toLowerCase());
        }
        return oppRTMap;
    }

    private static Map<String,List<CSC_Action_List__c>> retrieveActionLists(){
        Map<String,List<CSC_Action_List__c>> allActionListsMap = new Map<String,List<CSC_Action_List__c>>();

        for(CSC_Action_List__c cscActionListObj : [SELECT View__c, Template__c, Status__c, Source_List__c,
            Sort_Order__c, RecordTypeId, Order__c, Order_Status__c, Opportunity__c,Opportunity_Record_Type__c,
            Opportunity_Id__c, Num_Open_Items__c, Num_Items__c, Num_Completed_Items__c,
            Name, Library_Type__c, Id, CH_Account_ID__c,
            Action_List__c, Action_List_Name__c, Account__c, Account_Paralegal__c,
            Account_Id__c, 
            (SELECT Id, Action_Item_Mapping__c, Name, RecordTypeId, Order__c, Received_Date__c,Time_Frame_In_Business_Days__c,
            Next_Action_Date__c, Review_Date__c, Status__c, Expiration_Date__c, Comments__c,Time_Frame_Expiration_Date__c,
            CSC_Action_List__c, CSC_Action_List__r.Action_List_Name__c, Sort_Order__c, Web_Link__c, Related_Action_Item__c,
            Contact__c, Action_Item_Name__c, View_Attach__c, Attach__c, Account__c, Edit__c,
            Library_Type__c, Account_Id__c, UCC_Draft_Language__c, Num_Attachments__c,
            Opportunity__c, Date_Requested__c, Order_Status__c, Opportunity_Id__c,
            Assigned_To__c, My_Assigned_Item__c, View__c, Department__c, Date_Completed__c,
            definition__c, Opportunity_Notifications__c, Dependencies__c, Delay_Alert_On__c, Business_Days_Due_Before_Close__c,
            BD_Green_Level_Accelerated__c, BD_Green_Level_Standard__c, BD_Red_Level_Accelerated__c, BD_Red_Level_Standard__c, Milestone_Sort_Order__c 
            FROM CSC_Action_Items__r)
            FROM CSC_Action_List__c
            WHERE Template__c = true]){

                if(String.isNotBlank(cscActionListObj.Opportunity_Record_Type__c)) {
                    if(!allActionListsMap.ContainsKey(cscActionListObj.Opportunity_Record_Type__c.toLowerCase())) {
                        allActionListsMap.put(cscActionListObj.Opportunity_Record_Type__c.toLowerCase(), new List<CSC_Action_List__c>());
                    }
                    allActionListsMap.get(cscActionListObj.Opportunity_Record_Type__c.toLowerCase()).add(cscActionListObj);
                }
            }
        return allActionListsMap;
    }

    //2015.10.19 J Caughie - method to update opportunity with correct opportunity type before insert
    private static void updateOpportunityType(List<Opportunity> newOpps){

      // Map<String, Id> oppNameToId = new Map<String, Id>(RecordTypeUtils.getsObjectRecordMap('Opportunity'));

      if(newOpps == null){ newOpps = Trigger.new; }
      for(Opportunity o : newOpps){
        if(o.Lead_Opportunity_Type__c != null){
            String stage;
            if(o.Lead_Opportunity_Type__c == 'Facilities') {
                  stage = InitialStageName__c.getInstance ('Standard').Facilities__c;
              } else if(o.Lead_Opportunity_Type__c == 'FOF') {
                  stage = InitialStageName__c.getInstance ('Standard').FOF__c;
              } else if(o.Lead_Opportunity_Type__c == 'Initial Funding') {
                  stage = InitialStageName__c.getInstance ('Standard').Initial_Funding__c;
              } else if(o.Lead_Opportunity_Type__c == 'Loan') {
                  stage = InitialStageName__c.getInstance ('Standard').Loan__c;
              } else if(o.Lead_Opportunity_Type__c == 'LOI') {
                  stage = InitialStageName__c.getInstance ('Standard').LOI__c;
              } else if(o.Lead_Opportunity_Type__c == 'Energy') {
                  stage = InitialStageName__c.getInstance ('Standard').Energy__c;
              } else if(o.Lead_Opportunity_Type__c == 'Medicaid') {
                  stage = InitialStageName__c.getInstance ('Standard').Medicaid__c;
              } else if(o.Lead_Opportunity_Type__c == 'Enrollment Marketing') {
                  stage = InitialStageName__c.getInstance ('Standard').Enrollment_Marketing__c;
              } else if(o.Lead_Opportunity_Type__c == '5DF') {
                  stage = InitialStageName__c.getInstance ('Standard').X5DF__c;
              }
           
            if (o.Lead_Opportunity_Type__c.contains(' ')) {
                o.RecordTypeId = oppNameToId.get(o.Lead_Opportunity_Type__c.replace(' ', '_'));
                System.debug('****new rec type string: ' + o.Lead_Opportunity_Type__c.replace(' ', '_'));  
            } else {
                o.RecordTypeId = oppNameToId.get(o.Lead_Opportunity_Type__c);   
            }
             System.debug('****Setting opp record type to: ' + o.RecordTypeId);          
            o.StageName = stage;
        }
      }
    }
    //2015.10.19 J Caughie - method to update opportunity with correct opportunity type before insert

    //2017.04.06 J Caughie - update WB opps
    private static void updateWhiteboardOpps(Map<Id, Opportunity> oppNewMap, Map<Id, Opportunity> oppOldMap){
        //Opp accounts
        Set<Id> oppAccounts = new Set<Id>();

        //list of opportunities to update
        List<Opportunity> oppsToUpdate = new List<Opportunity>();
        for(Opportunity o : oppNewMap.values()){
          if (o.Whiteboard_Opportunity_WC__c == True && oppOldMap.get(o.id).Whiteboard_Opportunity_WC__c == False && oppOldMap.get(o.id).IsWon != True){
            oppsToUpdate.add(o);
            oppAccounts.add(o.AccountId);
            o.DocuSign_Transaction__c = !o.DocuSign_Client__c;
          }
        }
        System.debug('opp accounts: ' + oppAccounts);
        if(!oppsToUpdate.isEmpty()){
            updateOpportunitySigners(oppsToUpdate, oppAccounts);
            updateOpportunityManagementSigners(oppsToUpdate, oppAccounts);
            updateOpportunityManager(oppsToUpdate, oppAccounts);
            updateOpportunityInternalReference(oppsToUpdate, oppAccounts);
            updateOpportunityManagersManager(oppsToUpdate, oppAccounts);
        }
    }


    //method to update Signer 1 & 2 on opportunity once it hits whiteboard
    private static void updateOpportunitySigners(List<Opportunity> oppsToUpdate, Set<Id> oppAccounts){
        //list of signers
        Map<Id, Related_Contact__c> oppSigner_1 = new Map<Id, Related_Contact__c>();
        Map<Id, Related_Contact__c> oppSigner_2 = new Map<Id, Related_Contact__c>();
        for(Account a : [Select Id, (Select Contact__c, Title__c, Signatory__c From Legal_Contacts__r Where Signatory__c IN ('Signer 1', 'Signer 2') AND Inactive__c = False ) From Account a Where a.id in : oppAccounts]){
          for(Related_Contact__c rc : a.Legal_Contacts__r){
            if(rc.Signatory__c == 'Signer 1'){
                oppSigner_1.put(a.Id, rc);
              } else {
                oppSigner_2.put(a.Id, rc);
              }
          }
        }
        System.debug('Signers 1: ' + oppSigner_1);

        //update opportunities
        for(Opportunity o : oppsToUpdate){
          if(oppSigner_1.containsKey(o.AccountId)){
            o.Signer_1__c = oppSigner_1.get(o.AccountId).Contact__c; 
            o.Title_1__c = oppSigner_1.get(o.AccountId).Title__c;
          }
          if(oppSigner_2.containsKey(o.AccountId)){
            o.Signer_2__c = oppSigner_2.get(o.AccountId).Contact__c;
            o.Title_2__c = oppSigner_2.get(o.AccountId).Title__c;
          }
        }
    }

    private static void updateOpportunityManagementSigners(List<Opportunity> oppsToUpdate, Set<Id> oppAccounts){
        //list of signers
        Map<Id, Related_Contact__c> oppManagementSigner_1 = new Map<Id, Related_Contact__c>();
        Map<Id, Related_Contact__c> oppManagementSigner_2 = new Map<Id, Related_Contact__c>();
        for(Account a : [Select Id, (Select Contact__c, Title__c, Signatory__c From Legal_Contacts__r Where Signatory__c IN ('Management Signer 1', 'Management Signer 2') AND Inactive__c = False ) From Account a Where a.id in : oppAccounts]){
          for(Related_Contact__c rc : a.Legal_Contacts__r){
            if(rc.Signatory__c == 'Management Signer 1'){
                oppManagementSigner_1.put(a.Id, rc);
              } else {
                oppManagementSigner_2.put(a.Id, rc);
              }
          }
        }
        System.debug('Management Signer 1: ' + oppManagementSigner_1);

        //update opportunities
        for(Opportunity o : oppsToUpdate){
          if(oppManagementSigner_1.containsKey(o.AccountId)){
            o.Signer_Manager_1__c = oppManagementSigner_1.get(o.AccountId).Contact__c; 
            o.Title_Manager_1__c = oppManagementSigner_1.get(o.AccountId).Title__c;
          }
          if(oppManagementSigner_2.containsKey(o.AccountId)){
            o.Signer_Manager_2__c = oppManagementSigner_2.get(o.AccountId).Contact__c;
            o.Title_Manager_2__c = oppManagementSigner_2.get(o.AccountId).Title__c;
          }
        }
    }


    //method to update opportunity manager
    private static void updateOpportunityManager(List<Opportunity> oppsToUpdate, Set<Id> oppAccounts){

        //Map of CMO Ids to CMO accounts
        Map<Id, Id> charterIdToCMO = new Map<Id, Id>();
        Set<Id> accountCMOs = new Set<Id>();
        for(Account a : [SELECT ParentId FROM Account WHERE Id IN : oppAccounts]){
          charterIdToCMO.put(a.Id, a.ParentId);
        }
        System.debug('accId to CMOid' + charterIdToCMO);

        //update opportunities
        for(Opportunity o : oppsToUpdate){
            o.Manager__c = charterIdToCMO.get(o.AccountId);
        }
    }

    //update opportunity with manager's Certificate of Acknowledgement
    private static void updateOpportunityManagersManager(List<Opportunity> oppsToUpdate, Set<Id> oppAccounts){

        Map<Id, Related_Contact__c> charterToManagersSigner = new Map<Id, Related_Contact__c>();
        Map<Id, Id> charterToCMOid = new Map<Id, Id>();
        List<Id> cmoManager = new List<Id>();
        List<Related_Contact__c> rcs = new List<Related_Contact__c>();

        //List of CMO's managers for opportunity accounts
        List<Account> coaAccounts = [SELECT CMO__c FROM Account WHERE id in :oppAccounts AND CMO__r.Manager_s_COA__c = True];
        List<Id> cmoManagersId = new List<Id>();
        if (!coaAccounts.isEmpty()){
            for(Account a : coaAccounts){
                cmoManagersId.add(a.CMO__c);
            }

            //find related contacts for the CMO's manager for the opportunity account
            if (!cmoManagersId.isEmpty()){
                rcs = [SELECT Account__c, Contact__c, Title__c From Related_Contact__c Where Management_Authorized_Signer__c = True AND Signatory__c = 'Management Signer 1' AND Inactive__c = False AND Account__r.Id in :cmoManagersId];
            }
            System.debug('rcs: ' + rcs);

            //loop through accounts and find related contact if any - add to map
            if(!rcs.isEmpty()){
                    for (Account a : coaAccounts){
                        for (Related_Contact__c rc : rcs){
                            if (a.CMO__c == rc.Account__c){
                                charterToManagersSigner.put(a.Id, rc);
                            }
                        }
                    }
                //}
                System.debug('charter to manager: ' + charterToManagersSigner);

                //update existing opportunity signer ap/other
                for (Opportunity o : oppsToUpdate){
                    o.Signer_AP__c = charterToManagersSigner.get(o.AccountId).Contact__c;
                    o.Title_AP__c = charterToManagersSigner.get(o.AccountId).Title__c;
                }
            }
        }
    }

    private static void updateOpportunityInternalReference(List<Opportunity> oppsToUpdate, Set<Id> oppAccounts){

      //Method counts the number of won Working Capital opportunities this year then adds 1 to it to create an internal reference

      //Map of account Id to aggregate result count
      Map<Id, AggregateResult> accIdToCount = new Map<Id, AggregateResult>([SELECT AccountId Id, Count(Id) Total FROM Opportunity WHERE AccountId in :oppAccounts AND IsWon = True AND CloseDate = This_Year AND (RecordType.DeveloperName = 'FOF' OR RecordType.DeveloperName = 'Initial_Funding' OR RecordType.DeveloperName = 'Loan' OR RecordType.DeveloperName = 'X5DF') GROUP BY AccountId]);
      System.debug('Acc to Aggregate Result: ' + accIdToCount);

      //update opportunities
      for(Opportunity o : oppsToUpdate){
          o.Internal_Ref__c = (String.IsEmpty(o.State__c) ? 'XX' : o.State__c) + String.valueOf(Date.today().year()).right(2) + '-';
          o.Internal_Ref__c += (accIdToCount.containsKey(o.AccountId) ? (Integer)accIdToCount.get(o.AccountId).get('Total') : 0) + 1;
      }      
    }

    //2017.04.06 J Caughie


}