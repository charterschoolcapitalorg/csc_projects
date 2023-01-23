({

	 editProp: function(component, event, helper) {    
         var evt = $A.get("e.force:editRecord");
            evt.setParams({
             "recordId": component.get("v.Property").Id,
           });
         evt.fire();
     },
    viewProp: function(component, event, helper) {    
        window.open("/lightning/r/Account/" + component.get("v.Property").Id+ "/view","_blank");

     },
	 close : function(component, event, helper) {
        var recid = component.get("v.propertyId");
        var fromObjectId = component.get("v.fromObjectId");
        window.location.href='/' + fromObjectId;
     },
    
	 doInit: function(component, event, helper) {
        console.log("doInit:  CreateFacilitiesObjects");
        var recid = component.get("v.propertyId");
        console.log("rec id: " + recid);
         if (!recid) {
             recid = component.get("v.recordId");
        	 console.log("rec id from prop page: " + recid);
         }
         
        var action = component.get("c.getProperty");
		action.setParams({"pId": recid});
		action.setCallback(this, function(actionResult) {
			var state = actionResult.getState();
			if (state == "SUCCESS") {
				var retVal = actionResult.getReturnValue();
				component.set("v.Property", retVal);
                console.log('Property: ' + component.get("v.Property"));
            }
        });
		$A.enqueueAction(action);
        
        //get Buildings
        action = component.get("c.getBuildings");
		action.setParams({"pId": recid});
		action.setCallback(this, function(actionResult) {
			var state = actionResult.getState();
			if (state == "SUCCESS") {
				var retVal = actionResult.getReturnValue();
				component.set("v.Buildings", retVal);
                console.log('Buildings: ' + component.get("v.Buildings"));
            }
        });
		$A.enqueueAction(action);
         
		//get Suites
        action = component.get("c.getSuites");
		action.setParams({"pId": recid});
		action.setCallback(this, function(actionResult) {
			var state = actionResult.getState();
			if (state == "SUCCESS") {
				var retVal = actionResult.getReturnValue();
				component.set("v.Suites", retVal);
                console.log('Suites: ' + component.get("v.Suites"));
            }
        });
		$A.enqueueAction(action);
        
         //get Leases
        action = component.get("c.getLeases");
		action.setParams({"pId": recid});
		action.setCallback(this, function(actionResult) {
			var state = actionResult.getState();
			if (state == "SUCCESS") {
				var retVal = actionResult.getReturnValue();
				component.set("v.Leases", retVal);
                console.log('Leases: ' + component.get("v.Leases"));
            }
        });
		$A.enqueueAction(action);
         
         //get Tenants
        action = component.get("c.getTenantsForActiveLeases");
		action.setParams({"pId": recid});
		action.setCallback(this, function(actionResult) {
			var state = actionResult.getState();
			if (state == "SUCCESS") {
				var retVal = actionResult.getReturnValue();
				component.set("v.Tenants", retVal);
                console.log('Tenants: ' + component.get("v.Tenants"));
            }
        });
		$A.enqueueAction(action);
         
         //get Lease Suites
        action = component.get("c.getLeaseSuites");
		action.setParams({"pId": recid});
		action.setCallback(this, function(actionResult) {
			var state = actionResult.getState();
			if (state == "SUCCESS") {
				var retVal = actionResult.getReturnValue();
				component.set("v.LeaseSuites", retVal);
                console.log('LeaseSuites: ' + component.get("v.LeaseSuites"));
            }
        });
		$A.enqueueAction(action);
         
         //get Parcels
        action = component.get("c.getParcels");
		action.setParams({"pId": recid});
		action.setCallback(this, function(actionResult) {
			var state = actionResult.getState();
			if (state == "SUCCESS") {
				var retVal = actionResult.getReturnValue();
				component.set("v.Parcels", retVal);
                console.log('Parcels: ' + component.get("v.Parcels"));
            }
        });
		$A.enqueueAction(action);
         
         //get Property Taxes
        action = component.get("c.getPropertyTaxes");
		action.setParams({"pId": recid});
		action.setCallback(this, function(actionResult) {
			var state = actionResult.getState();
			if (state == "SUCCESS") {
				var retVal = actionResult.getReturnValue();
                console.log('retVal PropTaxes = ' + retVal);
				component.set("v.PropTaxes", retVal);
                console.log('PropTaxes: ' + component.get("v.PropTaxes"));
            }
        });
		$A.enqueueAction(action);
        
         //get Lease COmpliances
        action = component.get("c.getLeaseCompliances");
		action.setParams({"pId": recid});
		action.setCallback(this, function(actionResult) {
			var state = actionResult.getState();
			if (state == "SUCCESS") {
				var retVal = actionResult.getReturnValue();
				component.set("v.LeaseCompliances", retVal);
                console.log('LeaseCompliances: ' + component.get("v.LeaseCompliances"));
            }
        });
		$A.enqueueAction(action);
         
        //get LeaseSchools
        action = component.get("c.getLeaseSchools");
		action.setParams({"pId": recid});
		action.setCallback(this, function(actionResult) {
			var state = actionResult.getState();
			if (state == "SUCCESS") {
				var retVal = actionResult.getReturnValue();
				component.set("v.LeaseSchools", retVal);
                console.log('LeaseSchools: ' + component.get("v.LeaseSchools"));
            }
        });
		$A.enqueueAction(action);
        
         //get RelatedContacts
        action = component.get("c.getRelatedContacts");
		action.setParams({"pId": recid});
		action.setCallback(this, function(actionResult) {
			var state = actionResult.getState();
			if (state == "SUCCESS") {
				var retVal = actionResult.getReturnValue();
				component.set("v.RelatedContacts", retVal);
                console.log('RelatedContacts: ' + component.get("v.RelatedContacts"));
            }
        });
		$A.enqueueAction(action);
         
         //get checklists
        action = component.get("c.getAssetMgmtChecklist");
		action.setCallback(this, function(actionResult) {
			var state = actionResult.getState();
			if (state == "SUCCESS") {
				var retVal = actionResult.getReturnValue();
				component.set("v.AssetChecklist", retVal);                
            }
        });
		$A.enqueueAction(action);
         
        action = component.get("c.getAquisitionsChecklist");
		action.setCallback(this, function(actionResult) {
			var state = actionResult.getState();
			if (state == "SUCCESS") {
				var retVal = actionResult.getReturnValue();
				component.set("v.AcqChecklist", retVal);                
            }
        });
		$A.enqueueAction(action);

        action = component.get("c.getFinancialsChecklist");
		action.setCallback(this, function(actionResult) {
			var state = actionResult.getState();
			if (state == "SUCCESS") {
				var retVal = actionResult.getReturnValue();
				component.set("v.FinChecklist", retVal);                
            }
        });
		$A.enqueueAction(action);
	},
    
    getAcq: function(component, event, helper) {
        var modalBody;
        var modalHeader;
        console.log('component.get("v.AcqChecklist"): ' + component.get("v.AcqChecklist"));
        $A.createComponents([ ["c:ModalText", {content: component.get("v.AcqChecklist")}] ],
               function(components, status) {
                   if (status === "SUCCESS") {
                       console.log('success');
                       modalBody = components[0];
                       component.find('overlayLib').showCustomModal({
                           header: modalHeader,
                           body: modalBody, 
                           showCloseButton: true,
                           closeCallback: function() {
                              
                           }
                       });
                   } else {
                       console.log('status: ' + status);
                   }                               
               });
    },
    
    getAsset: function(component, event, helper) {
        var modalBody;
        var modalHeader;
        $A.createComponents([ ["c:ModalText", {content: component.get("v.AssetChecklist")}] ],
               function(components, status) {
                   if (status === "SUCCESS") {
                       console.log('success');
                       modalBody = components[0];
                       component.find('overlayLib').showCustomModal({
                           showCloseButton: true,
                           header: modalHeader,
                           body: modalBody, 
                           closeCallback: function() {
                              
                           }
                       });
                   } else {
                       console.log('status: ' + status);
                   }                               
               });
        
    },
    
    getFinancials: function(component, event, helper) {
        var modalBody;
        var modalHeader;
        $A.createComponents([ ["c:ModalText", {content: component.get("v.FinChecklist")}] ],
               function(components, status) {
                   if (status === "SUCCESS") {
                       console.log('success');
                       modalBody = components[0];
                       component.find('overlayLib').showCustomModal({
                           showCloseButton: true,
                           header: modalHeader,
                           body: modalBody, 
                           closeCallback: function() {
                              
                           }
                       });
                   } else {
                       console.log('status: ' + status);
                   }                               
               });
        
    },
    
    
})