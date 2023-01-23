({
	init : function(component, event, helper) {
	  	
      	var iId = component.get("v.recordId");
      	console.log('init of AcceptClientPortalItem');
        
        //get Related Action Items for Charter
      	var action = component.get("c.getCharterACLItems");
        action.setParams({"iId" : iId});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {   
                component.set("v.aclCharterItems", response.getReturnValue());
                var count = 0;
                for (var i=0; i<response.getReturnValue().length; i++) {
                    count++;
                }
                component.set("v.numACLCharterItems", count);
                
            } else {
                var message = 'There has been an error getting the intake item';
                helper.showToast('Error', message, '4000', 'info_alt', 'error', 'dismissible'); 
            }
        });        
        $A.enqueueAction(action); 
		
        //get Related Action Items for Schools
      	var action = component.get("c.getSchoolACLItems");
        action.setParams({"iId" : iId});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {   
                component.set("v.aclSchoolItems", response.getReturnValue());
                var count = 0;
                for (var i=0; i<response.getReturnValue().length; i++) {
                    count++;
                }
                component.set("v.numACLSChoolItems", count);
                
            } else {
                var message = 'There has been an error getting the intake item';
                helper.showToast('Error', message, '4000', 'info_alt', 'error', 'dismissible'); 
            }
        });        
        $A.enqueueAction(action); 
        
        //get Related Action Items for PCL
      	action = component.get("c.getPCLItems");
        action.setParams({"iId" : iId});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {   
                component.set("v.pclItems", response.getReturnValue());
                //console.log('pclItems: ' + response.getReturnValue());
                var count = 0;
                for (var i=0; i<response.getReturnValue().length; i++) {
                    count++;
                }
                component.set("v.numPCLItems", count);
                //console.log('numPCLItems: ' + count);
                
            } else {
                var message = 'There has been an error getting the intake item';
                helper.showToast('Error', message, '4000', 'info_alt', 'error', 'dismissible'); 
            }
        });        
        $A.enqueueAction(action); 
        
        //get Client Portal Item
        action = component.get("c.getIntakeItem");
        action.setParams({"iId" : iId});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {  
                component.set("v.intakeItem", response.getReturnValue());
            } else {
                var message = 'There has been an error getting the intake item';
                helper.showToast('Error', message, '4000', 'info_alt', 'error', 'dismissible'); 
            }
        });
        
        $A.enqueueAction(action); 

         //get Lease Compliance Items
         action = component.get("c.getLeaseComplianceItem");
         action.setParams({"iiId" : iId});
         //console.log('*** iiId = ' + iId);
         action.setCallback(this, function(response) {
             var state = response.getState();
             if (state === "SUCCESS") {  
                 component.set("v.leaseComplianceItems", response.getReturnValue());
                 component.set("v.numLeaseComplianceItems", response.getReturnValue().length);
                 //check if leaseComplianceItems come in
                 var leaseComplianceItemsCheck = response.getReturnValue();
                 //console.log('*** leaseComplianceItemsCheck = ' + leaseComplianceItemsCheck);
             } else {
                 var message = 'There has been an error getting the lease compliance item';
                 helper.showToast('Error', message, '4000', 'info_alt', 'error', 'dismissible'); 
             }
         });
         
         $A.enqueueAction(action);

         //get Property Tax items
         action = component.get("c.getPropertyTaxItem");
         action.setParams({"iiId" : iId});
         action.setCallback(this, function(response) {
             var state = response.getState();
             if (state === "SUCCESS") {  
                 component.set("v.propertyTaxItems", response.getReturnValue());
                 component.set("v.numPropertyTaxItems", response.getReturnValue().length);
                 //console.log('@@@ ' + JSON.stringify(response.getReturnValue()));
             } else {
                 var message = 'There has been an error getting the property tax item';
                 helper.showToast('Error', message, '4000', 'info_alt', 'error', 'dismissible'); 
             }
         });
         
         $A.enqueueAction(action);
         //get Property Tax items
		
        helper.getPCLType(component, event);
        helper.getCharterALAcctType(component, event);
        helper.getSchoolALAcctType(component, event);
		
        
        
    },
    
    close : function(component, event, helper) {
        
        var intakeItem = component.get("v.intakeItem");
        
        var theme = component.get("v.theme");
        console.log('theme: ' + theme);
        if (theme === 'Theme3') {
            window.location.href='/' + intakeItem.Id;
        } else {
            window.location.href='/' + intakeItem.Id;
            /*var navEvt = $A.get("e.force:navigateToSObject");
            console.log('navEvt: ' + navEvt);
            navEvt.setParams({
              "recordId": intakeItem.Id,
			  "slideDevName": "detail"              
            });
            navEvt.fire();*/
        }
    },
    
    saveNoItems : function(component, event, helper) {
        var action = component.get("c.saveNoActionItems");
        var iId = component.get("v.recordId");
        action.setParams({"iId" : iId});
        console.log('iId: ' + iId);
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {   
                var theme = component.get("v.theme");
                if (theme === 'Theme3') {
                    window.location.href='/' + iId;
                } else {
                    var navEvt = $A.get("e.force:navigateToSObject");
                    console.log('navEvt: ' + navEvt);
                    navEvt.setParams({
                      "recordId": iId,
                      "slideDevName": "detail"              
                    });
                    navEvt.fire();
                }
            } else {
                var message = 'There has been an error saving the intake item';
                helper.showToast('Error', message, '4000', 'info_alt', 'error', 'dismissible'); 
            }
        });
        
        $A.enqueueAction(action); 
    	
    },
    
    save : function(component, event, helper) {
        var status = '';
        //console.log('@@@ = ' + JSON.stringify(component.find("oppschchild")));

        helper.saveChildren(component.find("charterchild"), status);
        helper.saveChildren(component.find("oppschchild"), status);
        helper.saveChildren(component.find("pclchild"), status);
        helper.saveChildren(component.find("lcchild"), status);
        helper.saveChildren(component.find("ptchild"), status);
    },
})