/**=====================================================================
 * Charter School Capital
 * Name: PropertyTaxTrigger
 * Test Class: PropertyTaxHandlerTest
 * Description: Property tax status
 * Created Date: Oct 2022
 * Created By: Slava Krel 
 *
 * Date Modified                Modified By                  Description of the update
 * [MON DD, YYYY]             	[FirstName LastName]		 [Short description for changes]
 =====================================================================*/


trigger PropertyTaxTrigger on Property_Tax__c (after update) {
    if (trigger.isAfter) { 
        if (trigger.isUpdate) {
            PropertyTaxHandler handler = new PropertyTaxHandler(trigger.oldMap, trigger.newMap, trigger.old, trigger.new);
            handler.afterUpdate();
        }
    }
}