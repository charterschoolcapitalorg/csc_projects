({
    getPCLType : function(component, event){   
        var action = component.get("c.getPCLType");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {               
                component.set("v.CSCActionItemSalesRecordType", response.getReturnValue());
            }            
        });
        $A.enqueueAction(action);  
	},
	getCharterALAcctType : function(component, event){   
        var action = component.get("c.getCharterALAcctType");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {               
                component.set("v.CharterAcctRecordType", response.getReturnValue());
            }            
        });
        $A.enqueueAction(action);  
	},
    
    getSchoolALAcctType : function(component, event){   
        var action = component.get("c.getSchoolALAcctType");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {               
                component.set("v.SchoolAcctRecordType", response.getReturnValue());
            }            
        });
        $A.enqueueAction(action);  
	},
    
    showToast : function(title, message, duration, key, type, mode) {
        var toastEvent = $A.get("e.force:showToast");
        if(! toastEvent){
            confirm(title + ': ' + message);
            return;
        }
        toastEvent.setParams({
            title : title,
            message: message,
            duration: duration,
            key: key,
            type: type,
            mode: mode
        });
        toastEvent.fire();
    },

    saveChildren: function(children, status) {
        try {
            if (children) {
                if (children.length) {
                    for (var i = 0; i < children.length; i++) {
                        children[i].save(status);
                    }
                } else {
                    children.save(status);
                }
            }
        } catch(e) { }
    }
})