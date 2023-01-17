/**=====================================================================
 * Charter School Capital
 * Name: FacilitiesMilestoneReportCtrl
 * Test Class: FacilitiesMilestoneReportCtrlTest
 * Description: Facilities Milestone Report
 * Created Date: August 2022
 * Created By: Slava Krel 
 *
 * Date Modified                Modified By                  Description of the update
 * [MON DD, YYYY]             	[FirstName LastName]		 [Short description for changes]
 *  Aug 31, 2022				Slava Krel				     Add Action Item 
 *  Oct 30, 2022                Slava Krel                   Pipeline funtionality
 *  Dec 12, 2022                Slava Krel                   Phase 2
 *  Dec 16, 2022                Slava Krel                   Add Student Count Field to FMR export
 =====================================================================*/

public class FacilitiesMilestoneReportCtrl {

    public List<OppByChannelWrapper> oppChannel {get;set;}
    public List<OppByPipelineStageWrapper> oppPipelineStage {get;set;}

    // phase 2
    public List<OppByChannelWrapper> oppTenantPipeline {get;set;}
    public List<OppByChannelWrapper> oppBrokerPipeline {get;set;}
    public List<OppByChannelWrapper> oppDeveloperPipeline {get;set;}
    public List<OppByChannelWrapper> oppOwnerPipeline {get;set;}
    
    public List<OpportunityWrapper> oppsAll {get;set;}
    public List<OpportunityWrapper> oppsToExport {get;set;}

    public FacilitiesMilestoneReportCtrl(){
        oppsAll = getFacilitiesMilestone();
        oppsToExport = getOppsForExport(oppsAll);
        oppChannel = getOppChannels(oppsToExport);
        oppPipelineStage = getOppPipelineStage(oppsToExport);

        // phase 2
        oppTenantPipeline = getTenantPipeline();
        oppBrokerPipeline = getBrokerPipeline();
        oppDeveloperPipeline = getDeveloperPipeline();
        oppOwnerPipeline = getOwnerPipeline();
    }

    // query all opps for the pipeline phase 2
    // phase 2
    // ======================================================
    // public static List<Opportunity> getOpportunityList() {
    //     List<Opportunity> getOpps = [
    //         SELECT id,
    //         Name, 
    //         CloseDate,
    //         Date_Submitted__c, 
    //         RecordType.DeveloperName,
    //         Facilities_Channel__c,
    //         createddate, 
    //         Estimated_Project_Cost__c,
    //         recordtypeid,
    //         Pipeline_Stage__c
    //         FROM Opportunity 
    //         WHERE (RecordType.DeveloperName = 'Facilities' OR RecordType.DeveloperName = 'Broker_Network')
    //         ORDER BY CloseDate ASC];

    //     return getOpps;
    // }

    @AuraEnabled
    public static List<OppByChannelWrapper> getTenantPipeline() {

        List<OpportunityWrapper> oppList = getFacilitiesMilestone();

        List<OppByChannelWrapper> tenantList = new List<OppByChannelWrapper>();

        List<OppByChannelWrapper> tenantListOpen = new List<OppByChannelWrapper>();
        List<OppByChannelWrapper> tenantListClosedWon = new List<OppByChannelWrapper>();
        List<OppByChannelWrapper> tenantListClosedLost = new List<OppByChannelWrapper>();

        if(!oppList.isEmpty()){
            for(OpportunityWrapper opp : oppList) {
                //OppByChannelWrapper tenant = new OppByChannelWrapper();
                if(opp.isClosed != false) {
                    tenant.testLine = 'Open';

                } else {
                    if(opp.StageName == 'Stage 5 - Funded (Closed Won)' || opp.StageName == 'Stage 5 - Closed Won') {
                        tenant.testLine = 'Closed Won';
                    }
                    if(opp.StageName == 'Closed Lost') {
                        tenant.testLine = 'Closed Won';
                    }
                }
            }
        }
        OppByChannelWrapper tenant = new OppByChannelWrapper();
        tenant.testLine = 'Open';
        tenant.wonOppCount = 0;
        tenant.contractedOppCount = 0;
        tenant.convertedOppCount = 0;
        tenant.proposedOppCount = 0;
        tenant.sourcedOppCount = 0;
        tenant.wonOppAmount = 0;
        tenant.contractedOppAmount = 0;
        tenant.convertedOppAmount = 0;
        tenant.proposedOppAmount = 0;
        tenant.sourcedOppAmount = 0;

        tenantList.add(tenant);

        return tenantList;
    }

    @AuraEnabled
    public static List<OppByChannelWrapper> getBrokerPipeline() {

        List<OpportunityWrapper> oppList = getFacilitiesMilestone();

        List<OppByChannelWrapper> brokerList = new List<OppByChannelWrapper>();
        OppByChannelWrapper broker = new OppByChannelWrapper();
        broker.testLine = 'Closed Won';
        broker.wonOppCount = 1;
        broker.contractedOppCount = 1;
        broker.convertedOppCount = 1;
        broker.proposedOppCount = 1;
        broker.sourcedOppCount = 1;
        broker.wonOppAmount = 1;
        broker.contractedOppAmount = 1;
        broker.convertedOppAmount = 1;
        broker.proposedOppAmount = 1;
        broker.sourcedOppAmount = 1;

        brokerList.add(broker);
        
        return brokerList;
    }

    @AuraEnabled
    public static List<OppByChannelWrapper> getDeveloperPipeline() {

        List<OpportunityWrapper> oppList = getFacilitiesMilestone();

        List<OppByChannelWrapper> developerList = new List<OppByChannelWrapper>();
        OppByChannelWrapper developer = new OppByChannelWrapper();
        developer.testLine = 'Closed Lost';
        developer.wonOppCount = 2;
        developer.contractedOppCount = 2;
        developer.convertedOppCount = 2;
        developer.proposedOppCount = 2;
        developer.sourcedOppCount = 2;
        developer.wonOppAmount = 2;
        developer.contractedOppAmount = 2;
        developer.convertedOppAmount = 2;
        developer.proposedOppAmount = 2;
        developer.sourcedOppAmount = 2;

        developerList.add(developer);
        
        return developerList;
    }

    @AuraEnabled
    public static List<OppByChannelWrapper> getOwnerPipeline() {

        List<OpportunityWrapper> oppList = getFacilitiesMilestone();

        List<OppByChannelWrapper> ownerList = new List<OppByChannelWrapper>();
        OppByChannelWrapper owner = new OppByChannelWrapper();
        owner.testLine = 'Total';
        owner.wonOppCount = 3;
        owner.contractedOppCount = 3;
        owner.convertedOppCount = 3;
        owner.proposedOppCount = 3;
        owner.sourcedOppCount = 3;
        owner.wonOppAmount = 3;
        owner.contractedOppAmount = 3;
        owner.convertedOppAmount = 3;
        owner.proposedOppAmount = 3;
        owner.sourcedOppAmount = 3;

        ownerList.add(owner);
        
        return ownerList;
    }

    // ===================================================


    
    
    @AuraEnabled
    public static List<OpportunityWrapper> getFacilitiesMilestone() {
        
        Map<Opportunity, List<CSC_Action_Item__c>> oppItemMap = new Map<Opportunity, List<CSC_Action_Item__c>>();

        //this is what gets displayed
        List<OpportunityWrapper> opportunityToDisplay = new List<OpportunityWrapper>();

        //query opps that are certain record type and not closed
        Map<Id, Opportunity> opps = 
        new Map<ID, Opportunity>([SELECT Id, 
                                            Account.Name, 
                                            Name, 
                                            StageName,
                                            CloseDate, 
                                            State__c, 
                                            NET_Amount_Requested__c, 
                                            Owner.LastName, 
                                            Paralegal__r.LastName, 
                                            Financial_Review__r.LastName, 
                                            Legal_Assistant__r.User_Fullname__c, 
                                            Paralegal__r.User_Fullname__c, 
                                            Financial_Review__r.User_Fullname__c, 
                                            Owner.User_Fullname__c, 
                                            Client_Portal_Testing_Opp__c, 
                                            RecordType.Name, 
                                            Receivables_Purchased__c, 
                                            Date_Submitted__c, 
                                            RecordType.DeveloperName,
                                            Due_Diligence_End_Date__c,
                                            Facilities_Channel__c,
                                            Purchase_Price__c,
                                            Deal_Specialist__r.LastName,
                                            Deal_Specialist__r.User_Fullname__c,
                                            isClosed,
                                            createddate, 
                                            Lease_Cap_Rate__c,
                                            Estimated_Project_Cost__c,
                                            recordtypeid,
                                            Attorney__c,
                                            Attorney__r.LastName,
                                            Attorney__r.User_Fullname__c,
                                            Facilities_Underwriting_Manager_FAUM__c,
                                            Facilities_Underwriting_Manager_FAUM__r.LastName,
                                            Facilities_Underwriting_Manager_FAUM__r.User_Fullname__c,
                                            Account_Owner__c,
                                            Account_Owner__r.LastName,
                                            Account_Owner__r.User_Fullname__c,
                                            Financial_Consultant__c,
                                            Financial_Consultant__r.LastName,
                                            Financial_Consultant__r.User_Fullname__c,
                                            Pipeline_Stage__c,
                                            Overview__c,
                                            Latest_Update__c,
                                            Current_Enrollment_Number__c
                                            FROM Opportunity 
                                            WHERE (RecordType.DeveloperName = 'Facilities' OR RecordType.DeveloperName = 'Broker_Network')
                                            //AND isClosed = false 
                                            ORDER BY CloseDate ASC]);
                            
        
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
            'Fund Acquisition'};

        List<CSC_Action_Item__c> actionItemList = [SELECT id, 
                                                            Name, 
                                                            Action_Item_Name__c, 
                                                            Opportunity_Id__c, 
                                                            Status__c, 
                                                            Assigned_To__r.Name, 
                                                            Date_Completed__c, 
                                                            CSC_Action_List__r.Opportunity__r.CloseDate, 
                                                            Status_Value__c  
                                                            FROM CSC_Action_Item__c 
                                                            WHERE CSC_Action_List__r.Opportunity__c IN :oppIds 
                                                            AND Action_Item_Name__c IN :actionItemNames 
                                                            ORDER BY CSC_Action_List__r.Opportunity__r.CloseDate asc];
                
        for(CSC_Action_Item__c actionItem : actionItemList){
            if(oppItemMap.containsKey(opps.get(actionItem.Opportunity_Id__c))){
                (oppItemMap.get(opps.get(actionItem.Opportunity_Id__c))).add(actionItem);
            } else {
                oppItemMap.put(opps.get(actionItem.Opportunity_Id__c), 
                new List<CSC_Action_Item__c>{actionItem});
            }
        }

        for(Opportunity oppFromMap : oppItemMap.keySet()) {
            
            OpportunityWrapper opportunityWrapperItem = new OpportunityWrapper();
            opportunityWrapperItem.oppId = oppFromMap.Id;
            opportunityWrapperItem.opp = oppFromMap;
            opportunityWrapperItem.oppName = oppFromMap.Name;
            opportunityWrapperItem.closeDate = oppFromMap.CloseDate;
            opportunityWrapperItem.diligenceEnd = oppFromMap.Due_Diligence_End_Date__c;
            opportunityWrapperItem.oppChannel = oppFromMap.Facilities_Channel__c;
            opportunityWrapperItem.state = oppFromMap.State__c;
            opportunityWrapperItem.oppOwner = oppFromMap.Owner.LastName;
            opportunityWrapperItem.dealSpecialist = oppFromMap.Deal_Specialist__r.LastName;
            opportunityWrapperItem.estimatedCost = oppFromMap.Estimated_Project_Cost__c;
            opportunityWrapperItem.capRate = oppFromMap.Lease_Cap_Rate__c;
            opportunityWrapperItem.oppPipelineStage = oppFromMap.Pipeline_Stage__c;
            opportunityWrapperItem.currEnrollment = oppFromMap.Current_Enrollment_Number__c;
            if(oppFromMap.Latest_Update__c != null) {
                string removeAllEmptyStrings = oppFromMap.Latest_Update__c.replace('\n', ' ');
                string stringToReturn = removeAllEmptyStrings.replace('\r', ' ');
                opportunityWrapperItem.oppLatestUpdate = stringToReturn;
            }
            if (oppFromMap.Overview__c != null) {
                string removeAllEmptyStrings = oppFromMap.Overview__c.replaceAll('\n', '');
                string stringToReturnOverview = removeAllEmptyStrings.replace('\r', '');
                opportunityWrapperItem.oppOverview = stringToReturnOverview;
            }

            DateTime dt = oppFromMap.createddate;
            Date oppCreatedDate = dt.date();
            opportunityWrapperItem.createdDate = oppCreatedDate;

            opportunityWrapperItem.businessDaysToClose = 
                DateUtilities.calculateBusinessDays(Date.today(), oppFromMap.CloseDate);
            
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
            
            opportunityWrapperItem.dealApproved = getStatusOptionOne(mapItem.get('dealApproved'));
            opportunityWrapperItem.preFC = getStatusOptionOne(mapItem.get('preFC')); 
            opportunityWrapperItem.loiSent = getStatusOptionOne(mapItem.get('loiSent'));
            opportunityWrapperItem.loiSigned = getStatusOptionOne(mapItem.get('loiSigned')); 
            opportunityWrapperItem.mouSent = getStatusOptionTwo(mapItem.get('mouSent'));
            opportunityWrapperItem.mouSigned = getStatusOptionTwo(mapItem.get('mouSigned'));
            opportunityWrapperItem.psaSigned = getStatusOptionOne(mapItem.get('psaSigned'));
            opportunityWrapperItem.leaseSigned = getStatusOptionThree(mapItem.get('leaseSigned'), oppFromMap.Due_Diligence_End_Date__c);
            opportunityWrapperItem.finalFC = getStatusOptionFour(mapItem.get('finalFC'), oppFromMap.Due_Diligence_End_Date__c);
            opportunityWrapperItem.diligenceWaived = getStatusOptionThree(mapItem.get('diligenceWaived'), oppFromMap.Due_Diligence_End_Date__c);
            opportunityWrapperItem.funded = getStatusOptionThree(mapItem.get('funded'), oppFromMap.CloseDate);

            opportunityToDisplay.add(opportunityWrapperItem);
        }
        return opportunityToDisplay;
    }

    public static List<OpportunityWrapper> getOppsForExport(List<OpportunityWrapper> scope) {
        List<OpportunityWrapper> oppsToExport = new List<OpportunityWrapper>();
        if(!scope.isEmpty()) {
            for(OpportunityWrapper opp : scope) {
                if(opp.isClosed != false) {
                    oppsToExport.add(opp);
                }
            }
        }
        return oppsToExport;
    }

    public static List<OppByChannelWrapper> getOppChannels(List<OpportunityWrapper> opportunityToDisplay) {
        List<OppByChannelWrapper> oppChannelList = new List<OppByChannelWrapper>();
        List<OpportunityWrapper> tenantOpportunities = new List<OpportunityWrapper>();
        List<OpportunityWrapper> brokerOpportunities = new List<OpportunityWrapper>();
        List<OpportunityWrapper> developerOpportunities = new List<OpportunityWrapper>();
        List<OpportunityWrapper> ownerOpportunities = new List<OpportunityWrapper>();

        if(!opportunityToDisplay.isEmpty()){
            for(OpportunityWrapper opp : opportunityToDisplay){
                if(opp.oppChannel == 'Tenant/School') {
                    tenantOpportunities.add(opp);
                } else if(opp.oppChannel == 'Broker') {
                    brokerOpportunities.add(opp);
                } else if(opp.oppChannel == 'Developer') {
                    developerOpportunities.add(opp);
                } else if(opp.oppChannel == 'Owner') {
                    ownerOpportunities.add(opp);
                }
            }
        }
        //tenant opportunities
        if(!tenantOpportunities.isEmpty()) {
            OppByChannelWrapper singleOppChannel = new OppByChannelWrapper();
            singleOppChannel.opportunityChannel = 'Tenant';
            //count
            Integer countWon = 0;
            Integer countContracted = 0;
            Integer countConverted = 0;
            Integer countProposed = 0;
            Integer countSourced = 0;
            //amount
            Decimal amountWon = 0;
            Decimal amountContracted = 0;
            Decimal amountConverted = 0;
            Decimal amountProposed = 0;
            Decimal amountSourced = 0;
            for(OpportunityWrapper tenant : tenantOpportunities) {

                if(tenant.funded == 'Completed') {
                    countWon = countWon + 1;
                    if(tenant.estimatedCost != null) {
                        amountWon = amountWon + tenant.estimatedCost;
                    }
                } else if(tenant.psaSigned == 'Completed' && tenant.funded != 'Completed') {
                    countContracted = countContracted + 1;
                    if(tenant.estimatedCost != null) {
                        amountContracted = amountContracted + tenant.estimatedCost;
                    }
                } else if((tenant.loiSigned == 'Completed' || tenant.mouSigned == 'Completed') 
                    && tenant.psaSigned != 'Completed' && tenant.funded != 'Completed') {
                    
                        countConverted = countConverted + 1;
                        if(tenant.estimatedCost != null) {
                            amountConverted = amountConverted + tenant.estimatedCost;
                        }
                } else if((tenant.loiSent == 'Completed' || tenant.mouSent == 'Completed') 
                    && tenant.loiSigned != 'Completed' && tenant.mouSigned != 'Completed' 
                    && tenant.psaSigned != 'Completed' && tenant.funded != 'Completed') {
                    
                        countProposed = countProposed + 1;
                        if(tenant.estimatedCost != null) {
                            amountProposed = amountProposed + tenant.estimatedCost;
                        }
                } else {
                    countSourced = countSourced + 1;
                        if(tenant.estimatedCost != null) {
                            amountSourced = amountSourced + tenant.estimatedCost;
                        }
                }
            }
            singleOppChannel.sourcedOppAmount = amountSourced;
            singleOppChannel.proposedOppAmount = amountProposed;
            singleOppChannel.convertedOppAmount = amountConverted;
            singleOppChannel.contractedOppAmount = amountContracted;
            singleOppChannel.wonOppAmount = amountWon;
            singleOppChannel.sourcedOppCount = countSourced;
            singleOppChannel.proposedOppCount = countProposed;
            singleOppChannel.convertedOppCount = countConverted;
            singleOppChannel.contractedOppCount = countContracted;
            singleOppChannel.wonOppCount = countWon;

            oppChannelList.add(singleOppChannel);
        }
        //broker opportunities
        if(!brokerOpportunities.isEmpty()) {
            OppByChannelWrapper singleOppChannel = new OppByChannelWrapper();
            singleOppChannel.opportunityChannel = 'Broker';
            Integer countWon = 0;
            Integer countContracted = 0;
            Integer countConverted = 0;
            Integer countProposed = 0;
            Integer countSourced = 0;
            //amount
            Decimal amountWon = 0;
            Decimal amountContracted = 0;
            Decimal amountConverted = 0;
            Decimal amountProposed = 0;
            Decimal amountSourced = 0;
            for(OpportunityWrapper broker : brokerOpportunities) {

                if(broker.funded == 'Completed') {
                    countWon = countWon + 1;
                    if(broker.estimatedCost != null) {
                        amountWon = amountWon + broker.estimatedCost;
                    }
                } else if(broker.psaSigned == 'Completed' && broker.funded != 'Completed') {
                    countContracted = countContracted + 1;
                    if(broker.estimatedCost != null) {
                        amountContracted = amountContracted + broker.estimatedCost;
                    }
                } else if((broker.loiSigned == 'Completed' || broker.mouSigned == 'Completed') 
                    && broker.psaSigned != 'Completed' && broker.funded != 'Completed') {
                    
                        countConverted = countConverted + 1;
                        if(broker.estimatedCost != null) {
                            amountConverted = amountConverted + broker.estimatedCost;
                        }
                } else if((broker.loiSent == 'Completed' || broker.mouSent == 'Completed') 
                    && broker.loiSigned != 'Completed' && broker.mouSigned != 'Completed' 
                    && broker.psaSigned != 'Completed' && broker.funded != 'Completed') {
                    
                        countProposed = countProposed + 1;
                        if(broker.estimatedCost != null) {
                            amountProposed = amountProposed + broker.estimatedCost;
                        }
                } else {
                    countSourced = countSourced + 1;
                        if(broker.estimatedCost != null) {
                            amountSourced = amountSourced + broker.estimatedCost;
                        }
                }

            }
            singleOppChannel.sourcedOppAmount = amountSourced;
            singleOppChannel.proposedOppAmount = amountProposed;
            singleOppChannel.convertedOppAmount = amountConverted;
            singleOppChannel.contractedOppAmount = amountContracted;
            singleOppChannel.wonOppAmount = amountWon;
            singleOppChannel.sourcedOppCount = countSourced;
            singleOppChannel.proposedOppCount = countProposed;
            singleOppChannel.convertedOppCount = countConverted;
            singleOppChannel.contractedOppCount = countContracted;
            singleOppChannel.wonOppCount = countWon;
            oppChannelList.add(singleOppChannel);
        }
        //developer opportunities
        if(!developerOpportunities.isEmpty()) {
            OppByChannelWrapper singleOppChannel = new OppByChannelWrapper();
            singleOppChannel.opportunityChannel = 'Developer';
            Integer countWon = 0;
            Integer countContracted = 0;
            Integer countConverted = 0;
            Integer countProposed = 0;
            Integer countSourced = 0;
            //amount
            Decimal amountWon = 0;
            Decimal amountContracted = 0;
            Decimal amountConverted = 0;
            Decimal amountProposed = 0;
            Decimal amountSourced = 0;
            for(OpportunityWrapper developer : developerOpportunities) {

                if(developer.funded == 'Completed') {
                    countWon = countWon + 1;
                    if(developer.estimatedCost != null) {
                        amountWon = amountWon + developer.estimatedCost;
                    }
                } else if(developer.psaSigned == 'Completed' && developer.funded != 'Completed') {
                    countContracted = countContracted + 1;
                    if(developer.estimatedCost != null) {
                        amountContracted = amountContracted + developer.estimatedCost;
                    }
                } else if((developer.loiSigned == 'Completed' || developer.mouSigned == 'Completed') 
                    && developer.psaSigned != 'Completed' && developer.funded != 'Completed') {
                    
                        countConverted = countConverted + 1;
                        if(developer.estimatedCost != null) {
                            amountConverted = amountConverted + developer.estimatedCost;
                        }
                } else if((developer.loiSent == 'Completed' || developer.mouSent == 'Completed') 
                    && developer.loiSigned != 'Completed' && developer.mouSigned != 'Completed' 
                    && developer.psaSigned != 'Completed' && developer.funded != 'Completed') {
                    
                        countProposed = countProposed + 1;
                        if(developer.estimatedCost != null) {
                            amountProposed = amountProposed + developer.estimatedCost;
                        }
                } else {
                    countSourced = countSourced + 1;
                        if(developer.estimatedCost != null) {
                            amountSourced = amountSourced + developer.estimatedCost;
                        }
                }

            }
            singleOppChannel.sourcedOppAmount = amountSourced;
            singleOppChannel.proposedOppAmount = amountProposed;
            singleOppChannel.convertedOppAmount = amountConverted;
            singleOppChannel.contractedOppAmount = amountContracted;
            singleOppChannel.wonOppAmount = amountWon;
            singleOppChannel.sourcedOppCount = countSourced;
            singleOppChannel.proposedOppCount = countProposed;
            singleOppChannel.convertedOppCount = countConverted;
            singleOppChannel.contractedOppCount = countContracted;
            singleOppChannel.wonOppCount = countWon;
            oppChannelList.add(singleOppChannel);
        }
        //owner opportunities
        if(!ownerOpportunities.isEmpty()) {
            OppByChannelWrapper singleOppChannel = new OppByChannelWrapper();
            singleOppChannel.opportunityChannel = 'Owner';
            Integer countWon = 0;
            Integer countContracted = 0;
            Integer countConverted = 0;
            Integer countProposed = 0;
            Integer countSourced = 0;
            //amount
            Decimal amountWon = 0;
            Decimal amountContracted = 0;
            Decimal amountConverted = 0;
            Decimal amountProposed = 0;
            Decimal amountSourced = 0;
            for(OpportunityWrapper owner : ownerOpportunities) {

                if(owner.funded == 'Completed') {
                    countWon = countWon + 1;
                    if(owner.estimatedCost != null) {
                        amountWon = amountWon + owner.estimatedCost;
                    }
                } else if(owner.psaSigned == 'Completed' && owner.funded != 'Completed') {
                    countContracted = countContracted + 1;
                    if(owner.estimatedCost != null) {
                        amountContracted = amountContracted + owner.estimatedCost;
                    }
                } else if((owner.loiSigned == 'Completed' || owner.mouSigned == 'Completed') 
                    && owner.psaSigned != 'Completed' && owner.funded != 'Completed') {
                    
                        countConverted = countConverted + 1;
                        if(owner.estimatedCost != null) {
                            amountConverted = amountConverted + owner.estimatedCost;
                        }
                } else if((owner.loiSent == 'Completed' || owner.mouSent == 'Completed') 
                    && owner.loiSigned != 'Completed' && owner.mouSigned != 'Completed' 
                    && owner.psaSigned != 'Completed' && owner.funded != 'Completed') {
                    
                        countProposed = countProposed + 1;
                        if(owner.estimatedCost != null) {
                            amountProposed = amountProposed + owner.estimatedCost;
                        }
                } else {
                    countSourced = countSourced + 1;
                        if(owner.estimatedCost != null) {
                            amountSourced = amountSourced + owner.estimatedCost;
                        }
                }

            }
            singleOppChannel.sourcedOppAmount = amountSourced;
            singleOppChannel.proposedOppAmount = amountProposed;
            singleOppChannel.convertedOppAmount = amountConverted;
            singleOppChannel.contractedOppAmount = amountContracted;
            singleOppChannel.wonOppAmount = amountWon;
            singleOppChannel.sourcedOppCount = countSourced;
            singleOppChannel.proposedOppCount = countProposed;
            singleOppChannel.convertedOppCount = countConverted;
            singleOppChannel.contractedOppCount = countContracted;
            singleOppChannel.wonOppCount = countWon;
            oppChannelList.add(singleOppChannel);
        }

        return oppChannelList;
    }

    public class OppByChannelWrapper{
        public String opportunityChannel {get;set;}
        public Integer wonOppCount {get;set;}
        public Integer contractedOppCount {get;set;}
        public Integer convertedOppCount {get;set;}
        public Integer proposedOppCount {get;set;}
        public Integer sourcedOppCount {get;set;}
        public Decimal wonOppAmount {get;set;}
        public Decimal contractedOppAmount {get;set;}
        public Decimal convertedOppAmount {get;set;}
        public Decimal proposedOppAmount {get;set;}
        public Decimal sourcedOppAmount {get;set;}
        public String testLine {get;set;}
    }

    public static List<OppByPipelineStageWrapper> getOppPipelineStage(List<OpportunityWrapper> opportunityToDisplay) {
        
        List<OppByPipelineStageWrapper> oppPipelineStageList = new List<OppByPipelineStageWrapper>();
        
        //get ids to update opportunities
        List<Id> oppWonIds = new List<Id>();
        List<Id> oppContractedIds = new List<Id>();
        List<Id> oppConvertedIds = new List<Id>();
        List<Id> oppProposedIds = new List<Id>();
        List<Id> oppSourcedIds = new List<Id>();

        List<OpportunityWrapper> oppWon = new List<OpportunityWrapper>();
        List<OpportunityWrapper> oppContracted = new List<OpportunityWrapper>();
        List<OpportunityWrapper> oppConverted = new List<OpportunityWrapper>();
        List<OpportunityWrapper> oppPropesed = new List<OpportunityWrapper>();
        List<OpportunityWrapper> oppSourced = new List<OpportunityWrapper>();

        OppByPipelineStageWrapper oppPipelineStage = new OppByPipelineStageWrapper();
        oppPipelineStage.oppPipelineStageTotal = 'TOTAL';
        
        if(!opportunityToDisplay.isEmpty()){
            for(OpportunityWrapper oppStage : opportunityToDisplay) {
                if(oppStage.oppChannel != null) {
                    if(oppStage.oppChannel != 'Influencer') {
                        if(oppStage.funded == 'Completed') {
                            oppWon.add(oppStage);
                        } else if(oppStage.psaSigned == 'Completed' && oppStage.funded != 'Completed') {
                            oppContracted.add(oppStage);
                        } else if((oppStage.loiSigned == 'Completed' || oppStage.mouSigned == 'Completed') 
                            && oppStage.psaSigned != 'Completed' && oppStage.funded != 'Completed') {
                            
                                oppConverted.add(oppStage);
                        } else if((oppStage.loiSent == 'Completed' || oppStage.mouSent == 'Completed') 
                            && oppStage.loiSigned != 'Completed' && oppStage.mouSigned != 'Completed' 
                            && oppStage.psaSigned != 'Completed' && oppStage.funded != 'Completed') {
                            
                                oppPropesed.add(oppStage);
                        } else {oppSourced.add(oppStage);}
                    }
                }
            }
        }
        if(!oppWon.isEmpty()) {
            Integer oppWonCount = 0;
            Decimal oppWonAmount = 0;
            for(OpportunityWrapper won : oppWon) {
                oppWonCount = oppWonCount + 1;
                oppWonIds.add(won.oppId);
                if(won.estimatedCost != null) {
                    oppWonAmount = oppWonAmount + won.estimatedCost;
                }
            }
            oppPipelineStage.wonOppCount = oppWonCount;
            oppPipelineStage.wonOppAmount = oppWonAmount;
        }
        if(!oppContracted.isEmpty()) {
            Integer oppContractedCount = 0;
            Decimal oppContractedAmount = 0;
            for(OpportunityWrapper contracted : oppContracted) {
                oppContractedCount = oppContractedCount + 1;
                oppContractedIds.add(contracted.oppId);
                if(contracted.estimatedCost != null) {
                    oppContractedAmount = oppContractedAmount + contracted.estimatedCost;
                }
            }
            oppPipelineStage.contractedOppAmount = oppContractedAmount;
            oppPipelineStage.contractedOppCount = oppContractedCount;
        }
        if(!oppConverted.isEmpty()) {
            Integer oppConvertedCount = 0;
            Decimal oppConvertedAmount = 0;
            for(OpportunityWrapper converted : oppConverted) {
                oppConvertedCount = oppConvertedCount + 1;
                oppConvertedIds.add(converted.oppId);
                if(converted.estimatedCost != null) {
                    oppConvertedAmount = oppConvertedAmount + converted.estimatedCost;
                }
            }
            oppPipelineStage.convertedOppAmount = oppConvertedAmount;
            oppPipelineStage.convertedOppCount = oppConvertedCount;
        }
        if(!oppPropesed.isEmpty()) {
            Integer oppPropesedCount = 0;
            Decimal oppPropesednAmount = 0;
            for(OpportunityWrapper proposed : oppPropesed) {
                oppPropesedCount = oppPropesedCount + 1;
                oppProposedIds.add(proposed.oppId);
                if(proposed.estimatedCost != null) {
                    oppPropesednAmount = oppPropesednAmount + proposed.estimatedCost;
                }
            }
            oppPipelineStage.proposedOppAmount = oppPropesednAmount;
            oppPipelineStage.proposedOppCount = oppPropesedCount;
        }
        if(!oppSourced.isEmpty()) {
            Integer oppSourcedCount = 0;
            Decimal oppSourcedAmount = 0;
            for(OpportunityWrapper sourced : oppSourced) {
                oppSourcedCount = oppSourcedCount + 1;
                oppSourcedIds.add(sourced.oppId);
                if(sourced.estimatedCost != null) {
                    oppSourcedAmount = oppSourcedAmount + sourced.estimatedCost;
                }
            }
            oppPipelineStage.sourcedOppAmount = oppSourcedAmount;
            oppPipelineStage.sourcedOppCount = oppSourcedCount;
        }
        oppPipelineStageList.add(oppPipelineStage);
        return oppPipelineStageList;
    }

    public class OppByPipelineStageWrapper{
        public String oppPipelineStageTotal {get;set;}
        public Integer wonOppCount {get;set;}
        public Integer contractedOppCount {get;set;}
        public Integer convertedOppCount {get;set;}
        public Integer proposedOppCount {get;set;}
        public Integer sourcedOppCount {get;set;}
        public Decimal wonOppAmount {get;set;}
        public Decimal contractedOppAmount {get;set;}
        public Decimal convertedOppAmount {get;set;}
        public Decimal proposedOppAmount {get;set;}
        public Decimal sourcedOppAmount {get;set;}
    }

    //green or blank
    public static string getStatusOptionOne(List<CSC_Action_Item__c> items){
        String status = '';
        
        for(CSC_Action_Item__c item : items) {
            if(item.Status__c == 'Completed') {
                status = 'Completed';
            } else {status = 'Blank';}
        }
        return status;
    }

    //green, NA or blank
    public static string getStatusOptionTwo(List<CSC_Action_Item__c> items){
        String status = '';
        for(CSC_Action_Item__c item : items) {
            if(item.Status__c == 'Completed') {
                status = 'Completed';
            } else if (item.Status__c == 'N/A') {
                status = 'NA';
            } else {
                status = 'Blank';
            }
        }
        return status;
    }

    //only for lease signed -- green, red, NA or blank
    public static string getStatusOptionThree(List<CSC_Action_Item__c> items, Date ddend){
        String status = '';
        Date todayDate = Date.today();
        for(CSC_Action_Item__c item : items) {
            if (item.Status__c == 'Completed') {
                if (todayDate > ddend) {
                    status = 'Incomplete';
                } else {
                    status = 'Completed';
                }
            } else if (item.Status__c == 'N/A') {
                if (todayDate > ddend) {
                    status = 'Incomplete';
                } else {
                    status = 'Completed';
                }
            } else {
                status = 'Blank';
            }
        }
        return status;
    }

    //green, red or blank
    public static string getStatusOptionFour(List<CSC_Action_Item__c> items, Date ddend){
        String status = '';
        Date todayDate = Date.today();
        if (ddend != null) {
            Integer dayDifference = todayDate.daysBetween(ddend);
            for(CSC_Action_Item__c item : items) {
                if (item.Status__c == 'Completed') {
                    status = 'Completed';
                } else if (item.Status__c != 'Completed' && dayDifference < 7) {
                    status = 'Incomplete';
                } else {
                    status = 'Blank';
                }
            }
        } else {
            status = 'Blank';
        }
        return status;
    }

    //green, red or blank
    public static string getStatusOptionFive(List<CSC_Action_Item__c> items, Date closeDate){
        String status = '';
        Date todayDate = Date.today();
        if (closeDate != null) {
            Integer dayDifference = todayDate.daysBetween(closeDate);
            for(CSC_Action_Item__c item : items) {
                if (item.Status__c == 'Completed') {
                    status = 'Completed';
                } else if (item.Status__c != 'Completed' && dayDifference < 2) {
                    status = 'Incomplete';
                } else {
                    status = 'Blank';
                }
            }
        } else {
            status = 'Blank';
        }
        return status;
    }

    public class OpportunityWrapper{
        @AuraEnabled
        public String oppId {get;set;}
        @AuraEnabled
        public Opportunity opp {get;set;}
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
        @AuraEnabled
        public Integer businessDaysToClose {get;set;}
        @AuraEnabled
        public Date createdDate {get;set;}
        @AuraEnabled
        public String oppName {get;set;}
        @AuraEnabled
        public Date closeDate {get;set;}
        @AuraEnabled
        public Date diligenceEnd {get;set;}
        @AuraEnabled
        public String oppChannel {get;set;}
        @AuraEnabled
        public String state {get;set;}
        @AuraEnabled
        public String oppOwner {get;set;}
        @AuraEnabled
        public String dealSpecialist {get;set;}
        @AuraEnabled
        public Decimal estimatedCost {get;set;}
        @AuraEnabled
        public Decimal capRate {get;set;}
        @AuraEnabled
        public String oppPipelineStage {get;set;}
        @AuraEnabled
        public String oppLatestUpdate {get;set;}
        @AuraEnabled
        public String oppOverview {get;set;}
        @AuraEnabled
        public Decimal currEnrollment {get;set;}
    }

}