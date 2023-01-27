//
// (c) 2014 Appirio, Inc.
// Action Item trigger for after events
//
//
// 03 April 2014     Harshit Jain(JDC)       Original
trigger CSCActionItemTrigger on CSC_Action_Item__c (after insert, after update) {

    /*[04/03/14] - T-268092 - RA - This custom setting is used to conditionally control for which users/profile or the entire org
      the triggers, validation rules and workflow rules fire*/
    BypassRulesandTriggers__c ProfileCustomSettings = BypassRulesandTriggers__c.getInstance();
    // 05/06/2014 : Manisha Gupta : Add null check (T-276525)
    if(ProfileCustomSettings.Trigger_Objects__c == null){
        ProfileCustomSettings.Trigger_Objects__c = '';
    }
    if(ProfileCustomSettings.Triggers_Disabled__c == null){
        ProfileCustomSettings.Triggers_Disabled__c = false;
    }
    
    if(!(ProfileCustomSettings.Trigger_Objects__c.toLowerCase().contains('csc_action_item__c') && ProfileCustomSettings.Triggers_Disabled__c)){
    /*[04/03/14] - T-268092 - RA - This custom setting is used to conditionally control for which users/profile or the entire org
      the triggers, validation rules and workflow rules fire*/

  		if(Trigger.isAfter) {

    		if(Trigger.isInsert || Trigger.isUpdate) {
       			CSCActionItemTriggerManagement.OnAfterInsertUpdate(trigger.newMap, trigger.oldMap);
    		}
    	}
  	}
}