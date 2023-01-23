({
	editTax: function(component, event, helper) {

        var evt = $A.get("e.force:editRecord");
        evt.setParams({
         "recordId": component.get("v.PropTax").Id,
       });
        evt.fire();
    
    },
    viewTax: function(component, event, helper) {    
        window.open("/lightning/r/Property_Tax__c/" + component.get("v.PropTax").Id+ "/view","_blank");

     },
})