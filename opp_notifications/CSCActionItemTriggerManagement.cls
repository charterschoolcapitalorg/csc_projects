//
// (c) 2014 Appirio, Inc.
// Helper Class to handle all Action Item trigger events
//
// Test Class: CSCActionItemTriggerManagementTest
//
// 02 April 2014     Harshit Jain(JDC)       Original
// 03 Nov 2022       Krel Slava              email Sales Process recipients
// 29 Nov 2022       Krel Slava              FMR pipeline status

public with sharing class CSCActionItemTriggerManagement {

    private static Set<String> CLOSEED_STAUS = new Set<String>{'Completed','Cancelled','N/A'};
    private static Set<String> NOT_APPLICABLE_STAUS = new Set<String>{'Cancelled','N/A'};
    public static Boolean isActionTriggerTriggerRunning = false;
    static Map<String, String> withoutSpaceToFullName = new Map<String, String>();
      
  
    //Handle all event after insert and update
    public static void OnAfterInsertUpdate(Map<Id, CSC_Action_Item__c> newMap, Map<Id, CSC_Action_Item__c> oldMap) {
        updateOpportunityFields(newMap, OldMap);
        sendTimeBasedNotification(newMap, OldMap);
        emailCompletedSalesProcessRecipients(newMap, oldMap);
        createOngoingDiligence(newMap, oldMap);
    }
  
    public static void OnBeforeUpdate(Map<Id, CSC_Action_Item__c> newMap, Map<Id, CSC_Action_Item__c> oldMap){
        updateDueDate(newMap, oldMap);
    }
  
    //Update opportunity fields based on following criteria
    // Opportunity.Stage: On action item complition
    // Opportunity.Open_Items: On action item complition
    // Opportunity.Pipeline_Stage__c: On action item complition
    private static void updateOpportunityFields(Map<Id, CSC_Action_Item__c> newMap, Map<Id, CSC_Action_Item__c> oldMap) {
        Set<String> oppIdSet = new Set<String>();
    
        for(CSC_Action_Item__c item: newMap.values()) {
            if(Trigger.isInsert || (Trigger.isUpdate && String.isNotBlank(item.Opportunity_Id__c) && item.Status__c != oldMap.get(item.Id).Status__c)) {
                if(item.Opportunity_Id__c != null){//2015.06.03 J Caughie - non-selective query issue 
                    oppIdSet.add(item.Opportunity_Id__c);
                }
            }
        }
    
        if(oppIdSet.size() > 0) {
            validateOpportunityState(oppIdSet, oldMap);
            validateOpportunityPipelineStatus(oppIdSet);
        }
    }
  
    //sending opp notifications
    //cannot be replaced with a flow unless there is a loop element envolved
    private static void emailCompletedSalesProcessRecipients(Map<Id, CSC_Action_Item__c> newMap, Map<Id, CSC_Action_Item__c> oldMap) {
   
        //Standard template for email 
        Id templateID;
        for(EmailTemplate template: [SELECT id FROM EmailTemplate WHERE DeveloperName = 'CSC_Action_Item_Completed_Notification' LIMIT 1]) {
            templateId = template.Id;
        }

        //query Record Type Names
        Map<Id,RecordType> rtMap = new Map<Id,RecordType>([SELECT Id, DeveloperName FROM RecordType WHERE sObjectType = 'CSC_Action_Item__c']);

        //==================================================================
        //==================================================================
        Map<Id, Opportunity> superMap = new Map<Id, Opportunity>();
        Map<Id, CSC_Action_Item__c> aiMap = new Map<Id, CSC_Action_Item__c>();
        Set<Id> oppIds = new Set<Id>();
        for(CSC_Action_Item__c ai : [SELECT id, name, CSC_Action_List__c, Opportunity_Id__c FROM CSC_Action_Item__c WHERE id in : newMap.keySet()]) {
            aiMap.put(ai.id, ai);
            oppIds.add(ai.Opportunity_Id__c);
        }

        List <Opportunity> oppList = [SELECT id, name, 
                                        Financial_Review__r.Email, 
                                        Legal_Assistant__r.Email, 
                                        Paralegal__r.Email, 
                                        Owner.Email, 
                                        Facilities_Underwriting_Manager_FAUM__r.Email, 
                                        Paralegal_Facilities__r.Email,
                                        Attorney__r.Email,
                                        Deal_Specialist__r.Email
                                        FROM Opportunity WHERE Id IN : oppIds];

        for(Id aiFromMap : aiMap.keySet()){
            for(Opportunity opp : oppList) {
                if(opp.id == aiMap.get(aiFromMap).Opportunity_Id__c) {
                    superMap.put(aiMap.get(aiFromMap).id, opp);
                }
            }
        }

        //==================================================================
        //==================================================================

        //Loop over each triggering Item and generate an email for each. Use generic contact, "to" email list and template
        for(CSC_Action_Item__c item: newMap.values()) {
            Set<String> contactEmails = new Set<String>();

            //add extra condition to make sure AI has Opportunity populated
            if(item.Opportunity_Id__c != null) {

                if(item.Opportunity_Notifications__c != null && rtMap.get(item.RecordTypeId).DeveloperName.contains('Sales_Process') && item.Status__c == 'Completed' && 
                (Trigger.isInsert || (Trigger.isUpdate && oldMap.get(item.Id).Status__c != 'Completed'))) {

                    String financialAnalyst;
                    String legalAssistant;
                    string paralegal;
                    String oppOwner;
                    String fAUM;
                    String facilitiesParalegal;
                    String attorney;
                    String dealSpecialist;
                    String rEUnderwriter;

                    //==================================================================
                    //==================================================================
                    if(superMap.containsKey(item.id)){
                        financialAnalyst = superMap.get(item.id).Financial_Review__r.Email;
                        legalAssistant = superMap.get(item.id).Legal_Assistant__r.Email;
                        paralegal = superMap.get(item.id).Paralegal__r.Email;
                        oppOwner = superMap.get(item.id).Owner.Email;
                        fAUM = superMap.get(item.id).Facilities_Underwriting_Manager_FAUM__r.Email;
                        facilitiesParalegal = superMap.get(item.id).Paralegal_Facilities__r.Email;
                        attorney = superMap.get(item.id).Attorney__r.Email;
                        dealSpecialist = superMap.get(item.id).Deal_Specialist__r.Email;
                        rEUnderwriter = superMap.get(item.id).Facilities_Underwriting_Manager_FAUM__r.Email;
                    }
                    //==================================================================
                    //==================================================================
                    
                    if(item.Opportunity_Notifications__c.contains('Financial Analyst') && financialAnalyst != null) {
                        contactEmails.add(financialAnalyst);
                    }
                    if(item.Opportunity_Notifications__c.contains('Legal Assistant') && legalAssistant != null) {
                        contactEmails.add(legalAssistant);
                    }
                    if(item.Opportunity_Notifications__c.contains('Paralegal') && paralegal != null) {
                        contactEmails.add(paralegal);
                    }
                    if(item.Opportunity_Notifications__c.contains('Opportunity Owner') && oppOwner != null) {
                        contactEmails.add(oppOwner);
                    }
                    if(item.Opportunity_Notifications__c.contains('FAUM') && fAUM != null) {
                        contactEmails.add(fAUM);
                    }
                    if(item.Opportunity_Notifications__c.contains('Facilities Paralegal') && facilitiesParalegal != null) {
                        contactEmails.add(facilitiesParalegal);
                    }
                    if(item.Opportunity_Notifications__c.contains('Attorney') && attorney != null) {
                        contactEmails.add(attorney);
                    }
                    if(item.Opportunity_Notifications__c.contains('Deal Specialist') && dealSpecialist != null) {
                        contactEmails.add(dealSpecialist);
                    }
                    if(item.Opportunity_Notifications__c.contains('RE Underwriter') && rEUnderwriter != null) {
                        contactEmails.add(rEUnderwriter);
                    }
                    List<String> convertPicklistIntoList = item.Opportunity_Notifications__c.split(';');
                    for(String eachPickListItem : convertPicklistIntoList) {
                        List<Opp_Notifications_List__c> mcs = Opp_Notifications_List__c.getall().values();
                        for(Opp_Notifications_List__c itemFromCustomSetting : mcs) {
                            if(itemFromCustomSetting.name == eachPickListItem){
                                contactEmails.add(itemFromCustomSetting.email__c);
                            }
                        }
                    }

                    if(templateId != null && contactEmails.size() > 0) {
                        sendSingleEmailNotification(contactEmails, templateID, item.Id);
                    }
                }
            }
        }
    }

    private static void sendSingleEmailNotification(Set<String> contacts, Id templateId, Id record) {

        List<String> toAddresses = new List<String>();
        toAddresses.addAll(contacts);

        Id contactId = [SELECT id FROM Contact WHERE email <> null AND LastName = 'Caughie' LIMIT 1].Id;

        //Construct dummy message
        Messaging.SingleEmailMessage dummyMSG = new Messaging.SingleEmailMessage();
        dummyMSG.setTemplateId(templateId);
        dummyMSG.setTargetObjectId(contactId);
        dummyMSG.setWhatId(record);
        dummyMSG.setUseSignature(false);
        dummyMSG.setSaveAsActivity(false);

        // Send the emails in a transaction, then roll it back
        Savepoint sp = Database.setSavepoint();
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {dummyMSG});
        Database.rollback(sp);

        //Contruct & send the actual message
        Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
        msg.setToAddresses(toAddresses);
        msg.setPlainTextBody(dummyMSG.getPlainTextBody());
        msg.setSubject(dummyMSG.getSubject());
        msg.setUseSignature(false);
        msg.setSaveAsActivity(false);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {msg});      
  
    }
  
  
    private static void sendTimeBasedNotification(Map<Id, CSC_Action_Item__c> newMap, Map<Id, CSC_Action_Item__c> oldMap) {
      Set<Id> expiredItemIds = new Set<Id>();
  
      if(Trigger.oldMap != null) {
        for(CSC_Action_Item__c item : newMap.values()) {
          if(item.IsSendTimeBasedNotification__c && item.IsSendTimeBasedNotification__c != oldMap.get(item.Id).IsSendTimeBasedNotification__c) {
            expiredItemIds.add(item.Id);
          }
        }
      }
  
      if(expiredItemIds.size() > 0) {
  
        sendNotificationToKeyResources(expiredItemIds);
      }
    }
  
    private static void sendNotificationToKeyResources(Set<Id> expiredItemIds) {
      Id templateId;
      Id contactId = getContact();
      List<Messaging.SingleEmailMessage> lstMsgs = new List<Messaging.SingleEmailMessage>();
      List<CSC_Action_Item__c> itemsToBeUpdated = new List<CSC_Action_Item__c>();
  
      for(EmailTemplate template: [select id from EmailTemplate where DeveloperName='Action_Item_time_frame_expiry_notification']) {
        templateId = template.Id;
      }
  
      if(templateId != null && contactId != null) {
          Messaging.SingleEmailMessage msg;
          List<String> toAddress;
        for(CSC_Action_Item__c item : [Select CSC_Action_List__r.Opportunity__r.User__r.Email,
                                                CSC_Action_List__r.Opportunity__r.Paralegal__r.Email,
                                                CSC_Action_List__r.Opportunity__r.Financial_Review__r.Email,
                                                CSC_Action_List__r.Opportunity__r.Account_Owner__r.Email,
                                                IsAllowExpirationNotification__c, CSC_Action_List__r.Opportunity__r.Owner.Email, isSendTimeBasedNotification__c
                                          From  CSC_Action_Item__c c
                                          Where Id IN:expiredItemIds]) {
          toAddress = populateToAddresses(item);
  
          if(toAddress.size() > 0) {
            msg = new Messaging.SingleEmailMessage();
              msg.setTemplateId(templateId);
              msg.setTargetObjectId(contactId);
              msg.setWhatId(item.Id);
              msg.setToAddresses(toAddress);
              lstMsgs.add(msg);
              itemsToBeUpdated.add(new CSC_Action_Item__c(Id = item.Id, IsAllowExpirationNotification__c = false, isSendTimeBasedNotification__c = false));
          }
        }
      }
  
      if(itemsToBeUpdated.size() > 0) {
          Savepoint sp;
        try {
          sp = Database.setSavepoint();
          Messaging.sendEmail(lstMsgs);
          update itemsToBeUpdated;
          delete new Contact(Id = contactId);
          } catch(Exception e) {
            Database.rollback(sp);
          }
      }
  
    }
  
    private static List<String> populateToAddresses(CSC_Action_Item__c item) {
      List<String> toAddresses = new List<String>();
  
      if(item.CSC_Action_List__r.Opportunity__r.User__r.Email != null) {
        toAddresses.add(item.CSC_Action_List__r.Opportunity__r.User__r.Email);
      }
  
      if(item.CSC_Action_List__r.Opportunity__r.Paralegal__r.Email != null) {
        toAddresses.add(item.CSC_Action_List__r.Opportunity__r.Paralegal__r.Email);
      }
  
      if(item.CSC_Action_List__r.Opportunity__r.Financial_Review__r.Email != null) {
        toAddresses.add(item.CSC_Action_List__r.Opportunity__r.Financial_Review__r.Email);
      }
  
      if(item.CSC_Action_List__r.Opportunity__r.Account_Owner__r.Email != null) {
        toAddresses.add(item.CSC_Action_List__r.Opportunity__r.Account_Owner__r.Email);
      }
  
      if(item.CSC_Action_List__r.Opportunity__r.Owner.Email != null) {
        toAddresses.add(item.CSC_Action_List__r.Opportunity__r.Owner.Email);
      }
  
      return toAddresses;
    }
  
    private static Id getContact() {
        Contact con = new Contact();
        con.FirstName = 'Test';
        con.LastName = 'Contact';
        con.Email = 'no-reply@salesforce.com';
        insert con;

        return con.Id;
    }
  
    // find out opportunity pipeline stage and update it
    // method changed from private
    public static void validateOpportunityPipelineStatus(Set<String> opportunityIds) {
        
        Map<Opportunity, List<CSC_Action_Item__c>> oppItemMap = new Map<Opportunity, List<CSC_Action_Item__c>>();

        //this is what I need to work with
        List<OpportunityWrapper> facilitiesMilestoneItems = new List<OpportunityWrapper>();
        List<EMOpportunityWrapper> emMilestoneItems = new List<EMOpportunityWrapper>();

        //query opps
        Map<Id, Opportunity> opps = new Map<ID, Opportunity>([
            SELECT Id, 
            Name, 
            Pipeline_Stage__c, 
            CloseDate, 
            Due_Diligence_End_Date__c, 
            RecordType.DeveloperName 
            FROM Opportunity 
            WHERE Id IN : opportunityIds 
            AND (RecordType.DeveloperName = 'Facilities' OR RecordType.DeveloperName = 'Broker_Network' OR RecordType.DeveloperName = 'Enrollment_Marketing')]);
                
        //collect opp ids to query action item
        Set<Id> oppIds = opps.keySet();

        //list of action item names
        List<String> actionItemNames = new List<String>{
            'Approve Phase 1 Opportunity',
            'Verify Rent and/or Establish Property Valuation',
            'FC Pre-Approval Prepared and Presented',
            'Send LOI',
            'Sign LOI',
            'Deliver Lease Proposal (MOU)',
            'Receive Lease Proposal (MOU) Approval',
            'Sign PSA',
            'Sign Lease',
            'Present Opportunity and Receive Final FC Approval',
            'Waive Diligence',
            'Fund Acquisition',
            'Collect pre-qualification information',
            'Present Enrollment Marketing pitch deck to Prospect',
            'Approve Enrollment Marketing client for contracting',
            'Receive signed contract'};

        List<CSC_Action_Item__c> actionItemList = [
            SELECT id, 
            Name, 
            Action_Item_Name__c, 
            Opportunity_Id__c, 
            Status__c, 
            CSC_Action_List__r.Opportunity__r.CloseDate, 
            Status_Value__c  
            FROM CSC_Action_Item__c 
            WHERE CSC_Action_List__r.Opportunity__c IN :oppIds 
            AND Action_Item_Name__c IN :actionItemNames 
            ORDER BY CSC_Action_List__r.Opportunity__r.CloseDate ASC];

        for(CSC_Action_Item__c actionItem : actionItemList){
            if(oppItemMap.containsKey(opps.get(actionItem.Opportunity_Id__c))){
                (oppItemMap.get(opps.get(actionItem.Opportunity_Id__c))).add(actionItem);
            } else {
                oppItemMap.put(opps.get(actionItem.Opportunity_Id__c), 
                new List<CSC_Action_Item__c>{actionItem});
            }
        }

        for(Opportunity oppFromMap : oppItemMap.keySet()) {

            if(oppFromMap.RecordType.DeveloperName == 'Facilities' || oppFromMap.RecordType.DeveloperName == 'Broker_Network') {
                Map<String, List<CSC_Action_Item__c>> mapItem = new Map<String, List<CSC_Action_Item__c>>();
                mapItem.put('dealApproved', new List<CSC_Action_Item__c>());
                mapItem.put('preFC', new List<CSC_Action_Item__c>());
                mapItem.put('loiSent', new List<CSC_Action_Item__c>());
                mapItem.put('loiSigned', new List<CSC_Action_Item__c>());
                mapItem.put('mouSent', new List<CSC_Action_Item__c>());
                mapItem.put('mouSigned', new List<CSC_Action_Item__c>());
                mapItem.put('psaSigned', new List<CSC_Action_Item__c>());
                mapItem.put('leaseSigned', new List<CSC_Action_Item__c>());
                mapItem.put('finalFC', new List<CSC_Action_Item__c>());
                mapItem.put('diligenceWaived', new List<CSC_Action_Item__c>());
                mapItem.put('funded', new List<CSC_Action_Item__c>());
    
                for(CSC_Action_Item__c actionItemToDisplay : oppItemMap.get(oppFromMap)){
                    if(actionItemToDisplay.Action_Item_Name__c.containsIgnoreCase('Approve Phase 1 Opportunity') || actionItemToDisplay.Action_Item_Name__c.containsIgnoreCase('Verify Rent and/or Establish Property Valuation')){
                        mapItem.get('dealApproved').add(actionItemToDisplay);
                    } else if(actionItemToDisplay.Action_Item_Name__c.containsIgnoreCase('FC Pre-Approval Prepared and Presented')){
                        mapItem.get('preFC').add(actionItemToDisplay);
                    } else if(actionItemToDisplay.Action_Item_Name__c.containsIgnoreCase('Send LOI')){
                        mapItem.get('loiSent').add(actionItemToDisplay);
                    } else if(actionItemToDisplay.Action_Item_Name__c.containsIgnoreCase('Sign LOI')){
                        mapItem.get('loiSigned').add(actionItemToDisplay);
                    } else if(actionItemToDisplay.Action_Item_Name__c.containsIgnoreCase('Deliver Lease Proposal (MOU)')){
                        mapItem.get('mouSent').add(actionItemToDisplay);
                    } else if(actionItemToDisplay.Action_Item_Name__c.containsIgnoreCase('Receive Lease Proposal (MOU) Approval')){
                        mapItem.get('mouSigned').add(actionItemToDisplay);
                    } else if(actionItemToDisplay.Action_Item_Name__c.containsIgnoreCase('Sign PSA')){
                        mapItem.get('psaSigned').add(actionItemToDisplay);
                    } else if(actionItemToDisplay.Action_Item_Name__c.containsIgnoreCase('Sign Lease')){
                        mapItem.get('leaseSigned').add(actionItemToDisplay);
                    } else if(actionItemToDisplay.Action_Item_Name__c.containsIgnoreCase('Present Opportunity and Receive Final FC Approval')){
                        mapItem.get('finalFC').add(actionItemToDisplay);
                    } else if(actionItemToDisplay.Action_Item_Name__c.containsIgnoreCase('Waive Diligence')){
                        mapItem.get('diligenceWaived').add(actionItemToDisplay);
                    } else if(actionItemToDisplay.Action_Item_Name__c.containsIgnoreCase('Fund Acquisition')){
                        mapItem.get('funded').add(actionItemToDisplay);
                    } 
                }
    
                OpportunityWrapper opportunityWrapperItem = new OpportunityWrapper();
                opportunityWrapperItem.oppId = oppFromMap.Id;
                opportunityWrapperItem.oppName = oppFromMap.Name;
                opportunityWrapperItem.dealApproved = FacilitiesMilestoneReportCtrl.getStatusOptionOne(mapItem.get('dealApproved'));
                opportunityWrapperItem.preFC = FacilitiesMilestoneReportCtrl.getStatusOptionOne(mapItem.get('preFC')); 
                opportunityWrapperItem.loiSent = FacilitiesMilestoneReportCtrl.getStatusOptionOne(mapItem.get('loiSent'));
                opportunityWrapperItem.loiSigned = FacilitiesMilestoneReportCtrl.getStatusOptionOne(mapItem.get('loiSigned')); 
                opportunityWrapperItem.mouSent = FacilitiesMilestoneReportCtrl.getStatusOptionTwo(mapItem.get('mouSent'));
                opportunityWrapperItem.mouSigned = FacilitiesMilestoneReportCtrl.getStatusOptionTwo(mapItem.get('mouSigned'));
                opportunityWrapperItem.psaSigned = FacilitiesMilestoneReportCtrl.getStatusOptionOne(mapItem.get('psaSigned'));
                opportunityWrapperItem.leaseSigned = FacilitiesMilestoneReportCtrl.getStatusOptionThree(mapItem.get('leaseSigned'), oppFromMap.Due_Diligence_End_Date__c);
                opportunityWrapperItem.finalFC = FacilitiesMilestoneReportCtrl.getStatusOptionFour(mapItem.get('finalFC'), oppFromMap.Due_Diligence_End_Date__c);
                opportunityWrapperItem.diligenceWaived = FacilitiesMilestoneReportCtrl.getStatusOptionThree(mapItem.get('diligenceWaived'), oppFromMap.Due_Diligence_End_Date__c);
                opportunityWrapperItem.funded = FacilitiesMilestoneReportCtrl.getStatusOptionThree(mapItem.get('funded'), oppFromMap.CloseDate);
    
                facilitiesMilestoneItems.add(opportunityWrapperItem);
            }
            
            if(oppFromMap.RecordType.DeveloperName == 'Enrollment_Marketing') {

                Map<String, List<CSC_Action_Item__c>> mapItem = new Map<String, List<CSC_Action_Item__c>>();
                mapItem.put('preQualInfo', new List<CSC_Action_Item__c>());
                mapItem.put('pitchDeck', new List<CSC_Action_Item__c>());
                mapItem.put('approveContracting', new List<CSC_Action_Item__c>());
                mapItem.put('signedContract', new List<CSC_Action_Item__c>());
    
                for(CSC_Action_Item__c actionItemToDisplay : oppItemMap.get(oppFromMap)){
                    if(actionItemToDisplay.Action_Item_Name__c.containsIgnoreCase('Collect pre-qualification information')){
                        mapItem.get('preQualInfo').add(actionItemToDisplay);
                    } else if(actionItemToDisplay.Action_Item_Name__c.containsIgnoreCase('Present Enrollment Marketing pitch deck to Prospect')){
                        mapItem.get('pitchDeck').add(actionItemToDisplay);
                    } else if(actionItemToDisplay.Action_Item_Name__c.containsIgnoreCase('Approve Enrollment Marketing client for contracting')){
                        mapItem.get('approveContracting').add(actionItemToDisplay);
                    } else if(actionItemToDisplay.Action_Item_Name__c.containsIgnoreCase('Receive signed contract')){
                        mapItem.get('signedContract').add(actionItemToDisplay);
                    }
                }

                EMOpportunityWrapper opportunityWrapperItem = new EMOpportunityWrapper();
                opportunityWrapperItem.oppId = oppFromMap.Id;
                opportunityWrapperItem.oppName = oppFromMap.Name;
    
                opportunityWrapperItem.preQualInfo = EnrollmentMarketingMilestoneReportCtrl.getStatus(mapItem.get('preQualInfo'));
                opportunityWrapperItem.pitchDeck = EnrollmentMarketingMilestoneReportCtrl.getStatus(mapItem.get('pitchDeck')); 
                opportunityWrapperItem.approveContracting = EnrollmentMarketingMilestoneReportCtrl.getStatus(mapItem.get('approveContracting'));
                opportunityWrapperItem.signedContract = EnrollmentMarketingMilestoneReportCtrl.getStatus(mapItem.get('signedContract')); 
                
                emMilestoneItems.add(opportunityWrapperItem);
            }
        }

        // get stages for facilities
        if(!facilitiesMilestoneItems.isEmpty()) {
            List<Opportunity> oppToUpdateList = new List<Opportunity>();

            //assign pipeline stage
            for(OpportunityWrapper owItem : facilitiesMilestoneItems) {
                Opportunity oppToUpdate = [SELECT Id, Name, Pipeline_Stage__c FROM Opportunity WHERE Id = : owItem.oppId];
                //won opportunity
                if(owItem.funded == 'Completed') {
                    oppToUpdate.Pipeline_Stage__c = 'Won';
                } 
                //contracted opportunity
                else if(owItem.psaSigned == 'Completed' && owItem.funded != 'Completed') {
                    oppToUpdate.Pipeline_Stage__c = 'Contracted';
                } 
                //converted opportunity
                else if((owItem.loiSigned == 'Completed' || owItem.mouSigned == 'Completed') 
                    && owItem.psaSigned != 'Completed' && owItem.funded != 'Completed') {
                        oppToUpdate.Pipeline_Stage__c = 'Converted';
                } 
                //proposed opportunity
                else if((owItem.loiSent == 'Completed' || owItem.mouSent == 'Completed') 
                    && owItem.loiSigned != 'Completed' && owItem.mouSigned != 'Completed' 
                    && owItem.psaSigned != 'Completed' && owItem.funded != 'Completed') {
                        oppToUpdate.Pipeline_Stage__c = 'Proposed';
                } 
                //sourced opportunity
                else {
                    oppToUpdate.Pipeline_Stage__c = 'Sourced';
                }
                oppToUpdateList.add(oppToUpdate);
            }
    
            system.debug('### oppToUpdateList = ' + oppToUpdateList);

            // update facilities
            if(!oppToUpdateList.isEmpty()) {
                update oppToUpdateList;
            }
        }
        
        if(!emMilestoneItems.isEmpty()) {
            List<Opportunity> oppEMToUpdateList = new List<Opportunity>();

            for(EMOpportunityWrapper emOWItem : emMilestoneItems) {
                Opportunity oppToUpdate = [SELECT Id, Name, Pipeline_Stage__c FROM Opportunity WHERE Id = : emOWItem.oppId];
                //won opportunity (same as contracted)
                if(emOWItem.signedContract == 'Completed') {
                    oppToUpdate.Pipeline_Stage__c = 'Won';
                } 
                //Converted opportunity
                else if(emOWItem.approveContracting == 'Completed' && emOWItem.signedContract != 'Completed') {
                    oppToUpdate.Pipeline_Stage__c = 'Converted';
                } 
                //Proposed opportunity
                else if((emOWItem.pitchDeck == 'Completed') 
                    && emOWItem.approveContracting != 'Completed' && emOWItem.signedContract != 'Completed') {
                        oppToUpdate.Pipeline_Stage__c = 'Converted';
                } 
                //sourced opportunity
                else if((emOWItem.preQualInfo == 'Completed')
                    && emOWItem.pitchDeck != 'Completed' && emOWItem.approveContracting != 'Completed' && emOWItem.signedContract != 'Completed') {
                    
                        oppToUpdate.Pipeline_Stage__c = 'Sourced';
                }
                oppEMToUpdateList.add(oppToUpdate);
            }
            system.debug('### oppEMToUpdateList = ' + oppEMToUpdateList);

            // update facilities
            if(!oppEMToUpdateList.isEmpty()) {
                update oppEMToUpdateList;
            }
        }
    }

    // build a wrapper for facilities
    public class OpportunityWrapper{
        @AuraEnabled
        public String oppId {get;set;}
        @AuraEnabled
        public String oppName {get;set;}
        @AuraEnabled
        public String dealApproved {get;set;}
        @AuraEnabled
        public String preFC {get;set;}
        @AuraEnabled
        public String loiSent {get;set;}
        @AuraEnabled
        public String loiSigned {get;set;}
        @AuraEnabled
        public String mouSent {get;set;}
        @AuraEnabled
        public String mouSigned {get;set;}
        @AuraEnabled
        public String psaSigned {get;set;}
        @AuraEnabled
        public String leaseSigned {get;set;}
        @AuraEnabled
        public String finalFC {get;set;}
        @AuraEnabled
        public String diligenceWaived {get;set;}
        @AuraEnabled
        public String funded {get;set;}
    }

    // build a wrapper for enrollment marketing
    public class EMOpportunityWrapper{
        @AuraEnabled
        public String oppId {get;set;}
        @AuraEnabled
        public String oppName {get;set;}
        @AuraEnabled
        public String preQualInfo {get;set;}
        @AuraEnabled
        public String pitchDeck {get;set;}
        @AuraEnabled
        public String approveContracting {get;set;}
        @AuraEnabled
        public String signedContract {get;set;}
    }

    private static void validateOpportunityState(Set<String> opportunityIds, Map<Id, CSC_Action_Item__c> oldMap) {
        List<Opportunity> opportunitiesNeedsToBeUpdated = new List<Opportunity>();
        Map<Id, ActionItemWrapper> actionListToOpenItemMap = doActionItemCalculation(opportunityIds, oldMap);
        Map<String, Decimal> stageToProbabilityMap = getStageProbability();
    
        for(Opportunity opp: [SELECT StageName, 
                                (SELECT Id, Action_List_Name__c FROM CSC_Action_Lists__r Order by Action_List_Name__c)
                                FROM   Opportunity
                                WHERE  Id IN: opportunityIds]) {
            for(CSC_Action_List__c actionListRec : opp.CSC_Action_Lists__r) {
                if(actionListToOpenItemMap.containsKey(actionListRec.Id) ) {
                    //updated opportunity stage by action list name whose action items are open
                    if(actionListToOpenItemMap.get(actionListRec.Id).openItem > 0) {
                        if(Trigger.isUpdate) {
                            if(!opp.StageName.deleteWhitespace().equalsIgnoreCase(actionListRec.Action_List_Name__c.deleteWhitespace())) {
                                if(stageToProbabilityMap.get(opp.StageName.deleteWhitespace()) < stageToProbabilityMap.get(actionListRec.Action_List_Name__c.deleteWhitespace())) {
                                    //opp.stageName = actionListRec.Action_List_Name__c;
                                    opp.stageName = withoutSpaceToFullName.get(actionListRec.Action_List_Name__c.deleteWhitespace());
                                    opp.IsAllowStageUpdation__c = true;
                                    opp.Open_Items__c = actionListToOpenItemMap.get(actionListRec.Id).openItem + ' out of ' + actionListToOpenItemMap.get(actionListRec.Id).totalItem;
                                    opportunitiesNeedsToBeUpdated.add(opp);
                                    break;
                                } else if(actionListToOpenItemMap.get(actionListRec.Id).isOpened && actionListToOpenItemMap.get(actionListRec.Id).openItem == 1) {
                                    //opp.stageName = actionListRec.Action_List_Name__c;
                                    opp.stageName = withoutSpaceToFullName.get(actionListRec.Action_List_Name__c.deleteWhitespace());
                                    opp.IsAllowStageUpdation__c = true;
                                    opp.Open_Items__c = actionListToOpenItemMap.get(actionListRec.Id).openItem + ' out of ' + actionListToOpenItemMap.get(actionListRec.Id).totalItem;
                                    opportunitiesNeedsToBeUpdated.add(opp);
                                    break;
                                }
                            } else {
                                opp.Open_Items__c = actionListToOpenItemMap.get(actionListRec.Id).openItem + ' out of ' + actionListToOpenItemMap.get(actionListRec.Id).totalItem;
                                opportunitiesNeedsToBeUpdated.add(opp);
                                break;
                            }
                        } else {
                            opp = processOpportunity(opp, actionListRec);
                            opp.Open_Items__c = actionListToOpenItemMap.get(actionListRec.Id).openItem + ' out of ' + actionListToOpenItemMap.get(actionListRec.Id).totalItem;
                            opportunitiesNeedsToBeUpdated.add(opp);
                            break;
                        }
                    } else if(actionListRec.Id == opp.CSC_Action_Lists__r.get(opp.CSC_Action_Lists__r.size() - 1).Id) {
                        opp = processOpportunity(opp, actionListRec);
                        opp.Open_Items__c = actionListToOpenItemMap.get(actionListRec.Id).openItem + ' out of ' + actionListToOpenItemMap.get(actionListRec.Id).totalItem;
                        opportunitiesNeedsToBeUpdated.add(opp);
                        break;
                    }
            }
            // if All items are completed than udpate opportunity stage with last action list name
            else if(actionListRec.Id == opp.CSC_Action_Lists__r.get(opp.CSC_Action_Lists__r.size() - 1).Id) {
                opp = processOpportunity(opp, actionListRec);
                opp.Open_Items__c = '0 out of 0';
                opportunitiesNeedsToBeUpdated.add(opp);
            }
            }
        }
    
        if(opportunitiesNeedsToBeUpdated.size() > 0) {
            isActionTriggerTriggerRunning = true;
            update opportunitiesNeedsToBeUpdated;
        }
    }
  
    //Create a map with holds open and total items corresponding to action list
    private static Map<Id, ActionItemWrapper> doActionItemCalculation(set<String> opportunityIds, Map<Id, CSC_Action_Item__c> oldMap) {
      Map<Id, ActionItemWrapper> actionListToOpenItemMap = new Map<Id, ActionItemWrapper>();
      ActionItemWrapper itemWrapperObj;
      
      for(CSC_Action_Item__c item: [Select Status__c,  Opportunity_Id__c, CSC_Action_List__c,
                                           CSC_Action_List__r.Action_List_Name__c,
                                           CSC_Action_List__r.Opportunity__r.Id, CSC_Action_List__r.Opportunity__r.StageName
                                    From   CSC_Action_Item__c
                                    WHERE  Opportunity_Id__c IN: opportunityIds
                                    Order BY Opportunity_Id__c,CSC_Action_List__c]) {
        Integer openItemCount =  (!CLOSEED_STAUS.Contains(item.Status__c)) ? 1 : 0;
        Integer totalItemCount =  (NOT_APPLICABLE_STAUS.Contains(item.Status__c)) ? 0 : 1;
        if(!actionListToOpenItemMap.containsKey(item.CSC_Action_List__c)) {
          itemWrapperObj = new ActionItemWrapper();
          itemWrapperObj.openItem = openItemCount;
          itemWrapperObj.totalItem = totalItemCount;
          itemWrapperObj.isOpened = (oldMap != null && oldMap.containsKey(item.Id) && !CLOSEED_STAUS.contains(item.Status__c)) ? true : false;
          actionListToOpenItemMap.put(item.CSC_Action_List__c, itemWrapperObj);
        } else {
          itemWrapperObj = actionListToOpenItemMap.get(item.CSC_Action_List__c);
          itemWrapperObj.openItem += openItemCount;
          itemWrapperObj.totalItem += totalItemCount;
          itemWrapperObj.isOpened = (itemWrapperObj.isOpened || (oldMap != null && oldMap.containsKey(item.Id) && !CLOSEED_STAUS.contains(item.Status__c))) ? true : false;
        }
      }
      System.debug('actionListToOpenItemMap: ' + actionListToOpenItemMap);
      return actionListToOpenItemMap;
    }
  
  
    private static Opportunity processOpportunity(Opportunity opp, CSC_Action_List__c actionListRec) {
      if(!opp.StageName.deleteWhitespace().equalsIgnoreCase(actionListRec.Action_List_Name__c.deleteWhitespace())) {
          //opp.StageName = actionListRec.Action_List_Name__c;
          opp.stageName = withoutSpaceToFullName.get(actionListRec.Action_List_Name__c.deleteWhitespace());
          opp.IsAllowStageUpdation__c = true;
        }
        System.debug('returned opp ' + opp);
        return opp;
    }
  
    private static Map<String, Decimal> getStageProbability() {
      Map<String, Decimal> stageToProbabilityMap = new Map<String, Decimal>();
      for(OpportunityStage oppStage : [Select  SortOrder, MasterLabel, IsActive, DefaultProbability
                                       From    OpportunityStage
                                       Where   IsActive = true
                                       order by DefaultProbability ]) {
         stageToProbabilityMap.put(oppStage.MasterLabel.deleteWhitespace(), oppStage.DefaultProbability);
         withoutSpaceToFullName.put(oppStage.MasterLabel.deleteWhitespace(), oppStage.MasterLabel);
      }
      System.debug('stageToProbabilityMap ' + stageToProbabilityMap);
      return stageToProbabilityMap;
    }
  
    private static void updateDueDate(Map<Id, CSC_Action_Item__c> newMap, Map<Id, CSC_Action_Item__c> oldMap){
        for(CSC_Action_Item__c ai:newMap.values()){
            Boolean dateUpdate = (ai.Opp_Close_Date_Hidden__c != null);
            Boolean itemOpen = (ai.Item_Status__c == 'Open');
            Boolean businessDays = (ai.Business_Days_Due_Before_Close__c != null);
            Boolean alertsOn = (ai.Delay_Alert_On__c == true);
            Boolean salesProcessItem = (ai.RecordTypeId == RecordTypeUtils.CSCActionItemSalesProcess.Id);
            Boolean oppOpen = !(ai.Opp_Closed_HIDDEN_AI__c);

            if(dateUpdate && itemOpen && businessDays && alertsOn && salesProcessItem && oppOpen){
                ai.Item_Due_Date__c = DateUtilities.calculateStartDate(ai.Opp_Close_Date_Hidden__c, (Integer)ai.Business_Days_Due_Before_Close__c);
            }
        }
    }
  
    private static void createOngoingDiligence(Map<Id,CSC_Action_Item__c> newMap, Map<Id,CSC_Action_Item__c> oldMap) {
      List<CSC_Action_Item__c> changed = new List<CSC_Action_Item__c>();
  
      if (oldMap == null) {
        changed.addAll(newMap.values());
      } else {
        for (Id itemId: oldMap.keySet()) {
          CSC_Action_Item__c oldItem = oldMap.get(itemId);
          CSC_Action_Item__c newItem = newMap.get(itemId);
  
          if (
            oldItem.Template__c != newItem.Template__c ||
            oldItem.Generate_Client_Portal_Items__c != newItem.Generate_Client_Portal_Items__c ||
            oldItem.Action_Item_Mapping__c != newItem.Action_Item_Mapping__c ||
            oldItem.Next_Action_Date__c != newItem.Next_Action_Date__c ||
            oldItem.CP_Item_Due_Date__c != newItem.CP_Item_Due_Date__c
          ) {
            changed.add(newItem);
          }
        }
      }
  
      List<CSC_Action_Item__c> toProcess = new List<CSC_Action_Item__c>();
      for (CSC_Action_Item__c item: changed) {
        if (
          !item.Template__c &&
          item.Generate_Client_Portal_Items__c &&
          String.isNotBlank(item.Action_Item_Mapping__c) &&
          item.Next_Action_Date__c != null
        ) {
          toProcess.add(item);
        }
      }
  
      if (!toProcess.isEmpty()) {
        DiligenceUtils.createOngoingDiligence(new Map<Id,CSC_Action_Item__c>(toProcess).keySet());
      }
    }
  
    //Action Item calcualation wrapper
    private class ActionItemWrapper {
        private Integer openItem;
        private Integer totalItem;
        private Boolean isOpened;
    }
  
  }