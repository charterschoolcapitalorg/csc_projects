/**=====================================================================
 * Charter School Capital
 * Name: PropertyTaxHandler
 * Test Class: PropertyTaxHandlerTest
 * Description: Property tax status
 * Created Date: Oct 2022
 * Created By: Slava Krel 
 *
 * Date Modified                Modified By                  Description of the update
 * [MON DD, YYYY]             	[FirstName LastName]		 [Short description for changes]
 =====================================================================*/


public with sharing class PropertyTaxHandler {
    
    private Map<Id, Property_Tax__c> newMap;
    private Map<Id, Property_Tax__c> oldMap;
    private List<Property_Tax__c> trigNew;
    private List<Property_Tax__c> trigOld;

    //Constructor
    public PropertyTaxHandler(Map<Id, Property_Tax__c> triggerOldMap,Map<Id, Property_Tax__c> triggerNewMap,List<Property_Tax__c> triggerOld,List<Property_Tax__c> triggerNew) {
        this.oldMap = triggerOldMap;
        this.newMap = triggerNewMap;
        this.trigOld = triggerOld;
        this.trigNew = triggerNew;
    }
    public void afterUpdate() {
        actionItemUpdate(oldMap, trigNew);
    }

    // BEGIN CUSTOM METHODS BELOW

    public static void actionItemUpdate(Map<Id, Property_Tax__c> oldMap, List<Property_Tax__c> trigNew) {
        //system.debug('@@@ prop tax record = ' + trigNew);
        List<CSC_Action_Item__c> aiToUpdate = new List<CSC_Action_Item__c>();
        for(Property_Tax__c propTax : trigNew) {
            Property_Tax__c oldPropTax = oldMap.get(propTax.id);
            //it should only work if status changed from Draft to Active
            if(propTax.Property_Tax_Status__c != oldPropTax.Property_Tax_Status__c 
            && propTax.Property_Tax_Status__c == 'Active'
            && (oldPropTax.Property_Tax_Status__c == 'Draft' || oldPropTax.Property_Tax_Status__c == 'In Review')) {

                if(propTax.Non_School_Occupied__c == false) {
                    Lease__c lease = [SELECT id, name FROM lease__c WHERE recordtype.developername = 'Facilities_Asset_Leases' AND property__c =: propTax.Property__c LIMIT 1];
                    Lease_School__c leaseSchool;
                    try {
                        leaseSchool = [SELECT id, name, Account_School__r.ParentId, Account_School__c FROM Lease_School__c WHERE lease__c =:lease.id LIMIT 1];
                    } catch(QueryException e) {
                        //propTax.addError('School does not have lease school.');
                    }

                    Id accountId;
                    if(leaseSchool == null) {
                        propTax.addError('Non-Occupied School is unchecked AND there is no Active Lease with a Lease School. Only taxes for school-occupied properties are managed in the Client Portal. Please either update the Non-Occupied School checkbox or add a Lease School to the active Lease in order to move record into Active.');
                    } else {
                        if(leaseSchool.Account_School__r.ParentId != null) {
                            accountId = leaseSchool.Account_School__r.ParentId;
                        } else if(leaseSchool.Account_School__c != null) {
                            accountId = leaseSchool.Account_School__c;
                        }
                    }
                        
                    List<CSC_Action_Item__c> actionItems = [SELECT Id, 
                                                            Next_Action_Date__c,
                                                            CP_Item_Due_Date__c
                                                            FROM CSC_Action_Item__c 
                                                            WHERE Action_Item_Mapping__c = 'Property Taxes'
                                                            AND CSC_Action_List__r.Account__r.Charter_Holder__c =: accountId];
                    
                    system.debug('@@@ actionItems = ' + actionItems);

                    if(!actionItems.isEmpty()) {
                        for(CSC_Action_Item__c ai : actionItems) {
                            ai.CP_Item_Due_Date__c = propTax.X1st_Tax_Due_Date__c;
                            ai.Next_Action_Date__c = date.today();
                            aiToUpdate.add(ai);
                        } 
                    }

                    if(!aiToUpdate.isEmpty()) {
                        update aiToUpdate;
                    }
                }
            }
        }
    }
}