/**=====================================================================
 * Charter School Capital
 * Name: PropertyTax
 * Test Class: PropertyTaxTest
 * Description: property tax status, batch to clone existing property tax records
 * Created Date: [Sep 22, 2022]
 * Created By: [Slava Krel] 
 *
 * Date Modified                Modified By                  Description of the update
 * [MON DD, YYYY]             	[FirstName LastName]		 [Short description for changes]
 *  Dec 09, 2022                 Slava Krel                   Add due date to the cloned record
 =====================================================================*/
 global class PropertyTax implements  Database.Batchable<SObject> {

    global Database.QueryLocator start(Database.BatchableContext BC) {
        Date today = Date.today();
        return Database.getQueryLocator([SELECT Id, 
                                                Name, 
                                                Property_Tax_Status__c, 
                                                Parcel__c, 
                                                Parcel__r.Current_Tax_Year__c,
                                                Property__c, 
                                                Tax_Year_Number__c, 
                                                Next_record_trigger_days__c,
                                                Action_Item_Mapping__c,
                                                X1st_Tax_Due_Date__c,
                                                Next_record_trigger_date_field__c,
                                                CY_or_FY__c,
                                                Non_School_Occupied__c,
                                                RecordTypeId
                                            FROM Property_Tax__c 
                                            WHERE Property_Tax_Status__c = 'Finalized' 
                                        ]);
    }

    global void execute(Database.BatchableContext BC, List<Property_tax__c> propertyTaxes) {
        
        Date today = Date.today();
        List<Property_tax__c> propertyTaxRecordsToInsert = new List<Property_tax__c>();
        
        if(!propertyTaxes.isEmpty()) {
            for(Property_Tax__c propTax : propertyTaxes) {
                
                //check Tax_Year_Match
                if(propTax.Parcel__r.Current_Tax_Year__c != null && propTax.Parcel__r.Current_Tax_Year__c == propTax.Tax_Year_Number__c) {
                    propTax.Tax_Year_Match__c = true;
                }
                
                //create/clone new prop tax record
                if(propTax.Next_record_trigger_date_field__c == today) {

                    Integer nextYearNumber = Integer.valueOf(propTax.Tax_Year_Number__c) + 1;

                    Property_Tax__c createPTRecord = new Property_Tax__c();
                    createPTRecord.Property_Tax_Status__c = 'Draft';
                    createPTRecord.Parcel__c = propTax.Parcel__c;
                    createPTRecord.Property__c = propTax.Property__c;
                    createPTRecord.Tax_Year_Number__c = String.valueOf(nextYearNumber);
                    createPTRecord.Next_record_trigger_days__c = propTax.Next_record_trigger_days__c;
                    createPTRecord.Action_Item_Mapping__c = propTax.Action_Item_Mapping__c;
                    createPTRecord.CY_or_FY__c = propTax.CY_or_FY__c;

                    // set due date
                    if(propTax.X1st_Tax_Due_Date__c != null) {
                        Integer ddDay = propTax.X1st_Tax_Due_Date__c.day();
                        Integer ddMonth = propTax.X1st_Tax_Due_Date__c.month();
                        Integer ddYear = propTax.X1st_Tax_Due_Date__c.year() + 1;
                        createPTRecord.X1st_Tax_Due_Date__c = date.newInstance(ddYear, ddMonth, ddDay);
                    }
    
                    // add to the list
                    propertyTaxRecordsToInsert.add(createPTRecord);
                }
            }
        }
        
        //insert property tax record
        if(!propertyTaxRecordsToInsert.isEmpty()) {
            insert propertyTaxRecordsToInsert;
        }
    }

    global void finish(Database.BatchableContext BC) {
    }

}