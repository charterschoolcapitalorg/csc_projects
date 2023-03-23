/**=====================================================================
 * Charter School Capital
 * Name: PricingRateTrigger
 * Test Class: PricingRateTriggerHandlerTest
 * Description: 
 * Created Date: 2023, Jan 05
 * Created By: Slava Krel
 *
 * Date Modified                Modified By                  Description of the update
 * [MON DD, YYYY]             	[FirstName LastName]		 [Short description for changes]
 =====================================================================*/
// TODO: create re-usable runonce method 
trigger PricingRateTrigger on Pricing_Rate__c (before update, after update) {
    if (trigger.isBefore) { 
        if (trigger.isUpdate) {
            if (CreateBoxFoldersStatic.runonce()) {
                PricingRateTriggerHandler handler = new PricingRateTriggerHandler(trigger.oldMap, trigger.newMap, trigger.old, trigger.new);
                handler.beforeUpdate();
            }
        }
    }
    // if (trigger.isAfter) { 
    //     if (trigger.isUpdate) {
    //         if (CreateBoxFoldersStatic.runonce()) {
    //             PricingRateTriggerHandler handler = new PricingRateTriggerHandler(trigger.oldMap, trigger.newMap, trigger.old, trigger.new);
    //             handler.afterUpdate();
    //         }
    //     }
    // }
}