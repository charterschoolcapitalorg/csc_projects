({
    init: function (component, event, helper) {
        component.set("v.cssStyle", "<style>.slds-brand-band_medium {background-color: yellow; background: rgb(255, 255, 255) !important;}</style>");
        
        var size = window.innerWidth - 40;
        console.log('maxscreensize: ' + size);
        component.set("v.maxscreensize",size);
        
        var recid = component.get("v.recordId");
        component.set("v.Spinner", true); 
    
        var action = component.get("c.getAccountName");
        action.setParams({"acctId" : recid});
        action.setCallback(this, function(response){
            var state = response.getState();
            console.log('getAccountName response ' + state + ' - ' + response.getReturnValue());
            if (state === "SUCCESS") {
                    var resp = response.getReturnValue();
                        component.set("v.accountname", resp);
                        component.set("v.accId", recid);
                    
            }
        });
        $A.enqueueAction(action);
        
        console.log('getAccounts');
        action = component.get("c.getAccounts2");
        action.setParams({"acctId" : recid});
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var accts = response.getReturnValue();
                component.set("v.accounts", accts);       
            }
        });
        $A.enqueueAction(action);
        
        action = component.get("c.getCurrFQ");
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                component.set("v.enddatefq", result);
                component.set("v.startdatefq", result);
            }
        });
        $A.enqueueAction(action);
        
        action = component.get("c.getCurrFY");
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                component.set("v.enddatefy", result);
                var startfy = parseInt(result, 10) - 2;
                component.set("v.startdatefy", startfy+'');
            }
        });
        $A.enqueueAction(action);
        
        
        var acctid = component.get('v.acctfilter');
        if (acctid==null || acctid=='') acctid = recid;
        
        action = component.get("c.getData");
        action.setParams({"acctId" : acctid, 
                          "isDefault": "True",
                          "type" : component.get('v.typefilter'), 
                          "auditstatus" : component.get('v.auditfilter'), 
                          "stDtfq" : component.get('v.startdatefq'), 
                          "endDtfq" : component.get('v.enddatefq'),
                          "stDtfy" : component.get('v.startdatefy'), 
                          "endDtfy" : component.get('v.enddatefy')});
        
        action.setCallback(this, function(response){
            
          component.set("v.Spinner", false); 
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.data", response.getReturnValue());
                component.set("v.columns", response.getReturnValue()[0].columns);
                console.log('columns size ' + response.getReturnValue()[0].screensize);
                component.set("v.screensize", response.getReturnValue()[0].screensize);
                component.set("v.columnwrappers", response.getReturnValue()[0].columnobjects);
            }
        });
        $A.enqueueAction(action);
        
        action = component.get("c.getFiscalYears");
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                component.set("v.fiscalyears", result);
            }
        });
        $A.enqueueAction(action);
        
        /*action = component.get("c.getReportId");
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                component.set("v.reportid", result);
            }
        });
        $A.enqueueAction(action);
        */
        
    },
  
    close : function(component, event, helper) {
        console.log('close');
        console.log(component.get("v.recordId"));
        window.location.href='/' + component.get("v.recordId");
    },
    
    viewFiles : function (component, event, helper){ 
        var idx = event.target.id;
        component.set("v.showfileid", idx);
    },
  
    formPress: function(component, event, helper) {
        if (event.keyCode === 27) {
            var idx = event.target.id;
            component.set("v.showfileid", '');
        }
    },
    
    getAccounts : function(component, event, helper) {
  
    },
  
    exportData : function(component, event, helper){
        var recid = component.get("v.recordId");
        var audited = (component.get('v.auditfilter') == 'All' ? 'Audited,Unaudited' : 
             (component.get('v.auditfilter') == 'Audited' ? 'Audited' : 'Unaudited'));
        
        var columns = component.get('v.columns');
        var fyFqs = '';
        for (var i=0; i<columns.length; i++) {
            fyFqs = fyFqs+columns[i]+',';     
        } 
        
        var type = (component.get('v.typefilter')=='All' 
             ? 'Quarterly,Annual' : component.get('v.typefilter'));
        
        var acct = component.get('v.accountname');
        //00O21000000QpRPEA0
        var win = window.open('/lightning/r/Report/' + component.get('v.reportid')+ '/view?fv0=' + acct + 
             '&fv1=' +  type + '&fv2=' + fyFqs + '&fv3=' + audited , '_blank');
      win.focus();
    },
  
    exportCongaReport : function(component, event, helper){
        /*
        sample
        /apex/APXTConga4__Conga_Composer?serverUrl={!API.Partner_Server_URL_370}&id=a2P210000003AJgEAM&TemplateId=a0H21000008FK2HEAW&queryId=[fins]a1421000004i6OtAAI?pv0=0010g00001bAZWnAAO~pv1='Annual'|'Quarterly'~pv2=true|false~pv3='3Q18'|'4Q18'|'2018'|'1Q19'|'2Q19'|'3Q19'|'4Q19'|'2019'|'1Q20'|'2Q20'|'3Q20'|'2020'
        */
        // let recid = component.get("v.recordId");
        let recid = component.get('v.acctfilter') || component.get("v.accId");
        let congaAddr = '/apex/APXTConga4__Conga_Composer?serverUrl={!API.Partner_Server_URL_370}';
        let congaId = '&id=' + recid;
        //let queryId = '&queryId=[fins]a1421000004i6OtAAI'; //TEMP FOR SANDBOX
        let queryId = '&queryId=[fins]a140g00000AXpQWAA1'; //PRODUCTION
        //let templateId = '&TemplateId=a0H21000008FK2HEAW'; //TEMP FOR SANDBOX
        let templateId = '&TemplateId=a0H0g00000OwyGuEAJ'; //PRODUCTION
        let cParams = '&DS7=13'; //background mode
        //let cParams = '&DS7=0'; //debug available
        let acctid = component.get('v.acctfilter') || component.get("v.accId");
        console.log('acctid: ' + acctid);
        let audited = (component.get('v.auditfilter') == 'All' ? 'true|false' : 
            (component.get('v.auditfilter') == 'Audited' ? 'true' : 'false'));
        // let type = (component.get('v.typefilter')=='All' ? '\'Quarterly\'|\'Annual\'' : 
        //     (component.get('v.typefilter') == 'Quarterly' ? '\'Quarterly\'' : '\'Annual\''));
        let type = '';
        switch (component.get('v.typefilter')) {
            case 'Quarterly':
                type = '\'Quarterly\'';
                break;
            case 'Annual':
                type = '\'Annual\'';
                break;
            case 'Monthly':
                type = '\'Monthly\'';
                break;
            case 'Monthly/Annual':
                type = '\'Monthly\'|\'Annual\'';
                break;
            default:
                type = '\'Quarterly\'|\'Annual\'';
                break;
        }
  
        let columns = component.get('v.columns');
        let fyFqs = '';
        if(type.includes('Monthly')){
            fyFqs = '\'20' + component.get('v.enddatefy') + '\'';
        } else {
            for (let i=0; i<columns.length; i++) {
                fyFqs += '\'' + columns[i] + '\'' + '|';
            }
            fyFqs = fyFqs.substring(0, fyFqs.length - 1);
        }
  
        let params = '?pv0=' + acctid + '~pv1=' + type + '~pv2=' + audited + '~pv3=' + fyFqs;
        let loc = congaAddr + congaId + templateId + cParams + queryId + params;
        //let loc = congaAddr + congaId + templateId + queryId + params;
  
        console.log('conga address: ' + loc);
        let win = window.open(loc);
        //loc.focus();
    },
    
    openItem : function(component, event, helper){
        var idx = event.target.id;
        // var win = window.open('/' + idx, '_blank');
        var width = window.innerWidth - 40;
        console.log('width: ' + width);
        var height =  window.screen.availHeight - 40;
        console.log('height: ' + height);
        var win = window.open('/' + idx,  '_blank', 'toolbar=0,location=0,menubar=0');
        //var win = window.open('/' + idx,  'windowName', "height="+height+ ",width=" + width);
       
      win.focus();
    },
    
    resetFilters : function(component, event, helper) {
        location.reload();
        /*
    component.set('v.auditfilter', 'All');
        component.set('v.typefilter', 'Quarterly/Annual');
        component.set('v.startdatefq', 'All');
        component.set('v.enddatefq', 'All');
        component.set('v.startdatefy', 'All');
        component.set('v.enddatefy', 'All');
        var recid = component.get("v.recordId");
        var acctid = component.get('v.acctfilter');
        if (acctid==null || acctid=='') acctid = recid;
        
        component.set("v.Spinner", true); 
        
        var action = component.get("c.getData");
            action.setParams({"acctId" : acctid, 
                              "isDefault": "False",
                              "type" : component.get('v.typefilter'), 
                              "auditstatus" : component.get('v.auditfilter'), 
                              "stDtfq" : component.get('v.startdatefq'), 
                              "endDtfq" : component.get('v.enddatefq'),
                              "stDtfy" : component.get('v.startdatefy'), 
                              "endDtfy" : component.get('v.enddatefy')});
            
            action.setCallback(this, function(response){
                component.set("v.Spinner", false); 
                var state = response.getState();
                if (state === "SUCCESS") {
                    component.set("v.data", response.getReturnValue());
                    component.set("v.columns", response.getReturnValue()[0].columns);
                    component.set("v.columnwrappers", response.getReturnValue()[0].columnobjects);
                    console.log('columns size ' + response.getReturnValue()[0].screensize);
                  component.set("v.screensize", response.getReturnValue()[0].screensize);
                }
            });
            $A.enqueueAction(action);
        */
        //var a = component.get('c.init');
        //$A.enqueueAction(a);
    },
  
    applyFilters : function(component, event, helper) { 
        component.set("v.Spinner", true); 
        
        var recid = component.get("v.recordId");
        var acctid = component.get('v.acctfilter');
        if ((component.get('v.typefilter')=='Monthly' || component.get('v.typefilter')=='Monthly/Annual') && component.get('v.enddatefy') == 'All') {
            alert ('You must specify a Fiscal Year');
            component.set("v.Spinner", false);
            return;
        }

        if ((component.get('v.typefilter')=='Quarterly' || component.get('v.typefilter')=='Quarterly/Annual') &&
            (component.get('v.startdatefq')=='All' || component.get('v.startdatefy')=='All' || component.get('v.enddatefq')=='All' || component.get('v.enddatefy')=='All')
           ) {
                alert ('You must specify both Fiscal Year and Fiscal Quarter');
                component.set("v.Spinner", false);
        } else {
            if (acctid==null || acctid=='') acctid = recid;
            var action = component.get("c.getAccountName");
            action.setParams({"acctId" : acctid});
            // console.log('acctId: ' + acctid);
            action.setCallback(this, function(response){
                var state = response.getState();
                
                if (state === "SUCCESS") {
                    var resp = response.getReturnValue();
                    component.set("v.accountname", resp);
                    component.set("v.accId", recid);
                }
            });
            $A.enqueueAction(action);
                
            action = component.get("c.getData");
            action.setParams({"acctId" : acctid, 
                              "isDefault": "False",
                              "type" : component.get('v.typefilter'), 
                              "auditstatus" : component.get('v.auditfilter'), 
                              "stDtfq" : component.get('v.startdatefq'), 
                              "endDtfq" : component.get('v.enddatefq'),
                              "stDtfy" : component.get('v.startdatefy'), 
                              "endDtfy" : component.get('v.enddatefy')});
            
            action.setCallback(this, function(response){
                console.log('hideSpinner'); 
                component.set("v.Spinner", false); 
                var state = response.getState();
                if (state === "SUCCESS") {
                    component.set("v.data", response.getReturnValue());
                    console.log('@@@ data = ' + JSON.stringify(response.getReturnValue()));
                    component.set("v.columns", response.getReturnValue()[0].columns);
                    component.set("v.columnwrappers", response.getReturnValue()[0].columnobjects);
                    console.log('columns size ' + response.getReturnValue()[0].screensize);
                    component.set("v.screensize", response.getReturnValue()[0].screensize);
                    component.set("v.viewType", component.get('v.typefilter'));
                }
            });
            $A.enqueueAction(action);
        } 
    },
    
    showSpinner: function(component, event, helper) {
        component.set("v.Spinner", true); 
    },
    
    // this function automatic call by aura:doneWaiting event 
    hideSpinner : function(component,event,helper){  
       component.set("v.Spinner", false);
    },
  
    afterRender : function( component, helper ) {
       
    },

    addVarianceComments: function(component) {
        component.set("v.showBudgetComments", true);
    },
    
    changeState : function(component, event, helper) {
        component.set('v.showBudgetComments',!component.get('v.showBudgetComments'));
    },
    
    handleToast : function(component, event, helper) {
        var fireToast = component.get('v.recordSaved');
        console.log('fireToast== '+fireToast);
        if(fireToast){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title : 'Success',
                message: 'The record has been updated successfully.',
                duration:' 5000',
                type: 'success',
                mode: 'pester'
            });
            toastEvent.fire();
            console.log('fireToast3 in loop == '+fireToast);
            component.set("v.showBudgetComments", false);
        }
    }
    
  });