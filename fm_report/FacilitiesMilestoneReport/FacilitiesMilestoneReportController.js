({
	doInit: function(component, event, helper) {
		console.log('calling doinit...');
        let action = component.get("c.getFacilitiesMilestone");
        action.setCallback(this, function(response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                let items = response.getReturnValue();
                component.set("v.filteredOpportunities", items);
                component.set("v.originalOpportunities", items);
                component.set("v.today", Date.now());
                component.set("v.ShowSpinner", false);

                let returnUsers = helper.getUserList(component, items);
                component.set("v.userList", returnUsers);
                //console.log('userList = ' + returnUsers);

                let returnStates = helper.getStateList(component, items);
                component.set("v.stateList", returnStates);
                
                //total records
                let returnTotalRecordCount = helper.totalRecordCount(component, items);
                component.set("v.totalRecord", returnTotalRecordCount);

                //total estimated cost 
                let returnTotalPurchasePrice = helper.totalPurchasePrice(component, items);
                component.set("v.totalPurPr", returnTotalPurchasePrice);
                
                //total deal approved
                let returnTotalDealApprovedCount = helper.totalDealApproved(component, items);
                component.set("v.totalDealApprovedRecord", returnTotalDealApprovedCount);
                let returnTotalDollarDealApproved = helper.totalDollarDealApproved(component, items);
                component.set("v.totalDollarDealApproved", returnTotalDollarDealApproved);
                
                //total pre fc
                let returnTotalPreFcCount = helper.totalPreFc(component, items);
                component.set("v.totalPreFcRecord", returnTotalPreFcCount);
                let returnTotalDollarPreFc = helper.totalDollarPreFc(component, items);
                component.set("v.totalDollarPreFc", returnTotalDollarPreFc);
                
                //total LOI Sent
                let returnTotalLOISentCount = helper.totalLOISent(component, items);
                component.set("v.totalLOISentRecord", returnTotalLOISentCount);
                let returnTotalDollarLOISent = helper.totalDollarLOISent(component, items);
                component.set("v.totalDollarLOISent", returnTotalDollarLOISent);
                
                //total LOI Signed
                let returnTotalLOISignedCount = helper.totalLOISigned(component, items);
                component.set("v.totalLOISigned", returnTotalLOISignedCount);
                let returnTotalDollarLOISigned = helper.totalDollarLOISigned(component, items);
                component.set("v.totalDollarLOISigned", returnTotalDollarLOISigned);
                
                //total MOU Sent
                let returnTotalMOUSentCount = helper.totalMOUSent(component, items);
                component.set("v.totalMOUSent", returnTotalMOUSentCount);
                let returnTotalDollarMOUSent = helper.totalDollarMOUSent(component, items);
                component.set("v.totalDollarMOUSent", returnTotalDollarMOUSent);
                
                //total MOU Signed
                let returnTotalMOUSignedCount = helper.totalMOUSigned(component, items);
                component.set("v.totalMOUSigned", returnTotalMOUSignedCount);
                let returnTotalDollarMOUSigned = helper.totalDollarMOUSigned(component, items);
                component.set("v.totalDollarMOUSigned", returnTotalDollarMOUSigned);
                
                //total PSA Signed
                let returnTotalPSASignedCount = helper.totalPSASigned(component, items);
                component.set("v.totalPSASigned", returnTotalPSASignedCount);
                let returnTotalDollarPSASigned = helper.totalDollarPSASigned(component, items);
                component.set("v.totalDollarPSASigned", returnTotalDollarPSASigned);
                
                //total Lease Signed
                let returnTotalLeaseSignedCount = helper.totalLeaseSigned(component, items);
                component.set("v.totalLeaseSigned", returnTotalLeaseSignedCount);
                let returnTotalDollarLeaseSigned = helper.totalDollarLeaseSigned(component, items);
                component.set("v.totalDollarLeaseSigned", returnTotalDollarLeaseSigned);
                
                //total Final FC
                let returnTotalFinalFcCount = helper.totalFinalFc(component, items);
                component.set("v.totalFinalFc", returnTotalFinalFcCount);
                let returnTotalDollarFinalFc = helper.totalDollarFinalFc(component, items);
                component.set("v.totalDollarFinalFc", returnTotalDollarFinalFc);
                
                //total Diligence Waived
                let returnTotalDiligenceWaivedCount = helper.totalDiligenceWaived(component, items);
                component.set("v.totalDiligenceWaived", returnTotalDiligenceWaivedCount);
                let returnTotalDollarDiligenceWaived = helper.totalDollarDiligenceWaived(component, items);
                component.set("v.totalDollarDiligenceWaived", returnTotalDollarDiligenceWaived);
                
                //total Funded
                let returnTotalFundedCount = helper.totalFunded(component, items);
                component.set("v.totalFunded", returnTotalFundedCount);
                let returnTotalDollarFunded = helper.totalDollarFunded(component, items);
                component.set("v.totalDollarFunded", returnTotalDollarFunded);
            }
        });
        $A.enqueueAction(action);
    },

    handleSort: function(component, event, helper) {
        let sortField = component.get('v.sortField'),
        sortDirection = component.get('v.sortDirection'),
        clickedField = event.currentTarget.dataset.sortfield;
        console.log('sort clicked');
        
        if (sortField === clickedField && sortDirection === 'ASC') {
            sortDirection = 'DESC';
        }else{
            sortDirection = 'ASC';
        }

        let data = component.get('v.filteredOpportunities');
        var cloneData = data.slice(0);
        console.log('*** clickedField = ' + clickedField);

        if (clickedField === 'estimatedCost' || clickedField === 'capRate') {
            if (sortDirection == "ASC") {
                cloneData.sort(function (a, b) {
                    return a[clickedField] - b[clickedField]
                });
            } else {
                cloneData.sort(function (a, b) {
                    return b[clickedField] - a[clickedField]
                });
            }
        } else {
            if (sortDirection == "ASC") {
                cloneData.sort(function (a, b) {
                    return (a[clickedField] || "|||").toUpperCase().localeCompare((b[clickedField] || "|||").toUpperCase())
                });
            } else {
                cloneData.sort(function (a, b) {
                    return (b[clickedField] || "!!!").toUpperCase().localeCompare((a[clickedField] || "!!!").toUpperCase())
                });
            }
        }

        console.log('cloneData after sort = '+ JSON.stringify(cloneData));

        component.set('v.filteredOpportunities', cloneData);
        component.set('v.sortField', clickedField);
        component.set('v.sortDirection', sortDirection);
    },

    //handle filtering
    handleSearch: function(cmp, event, helper){
        let selectedState = cmp.get("v.state");
        let selectedUser = cmp.get("v.user");
        let selectedStartDate = cmp.get("v.startDate");
        let selectedEndDate = cmp.get("v.endDate");

        let opptCount = 0;

        if(selectedState !== undefined || 
            selectedUser !== undefined || 
            selectedStartDate !== null || 
            selectedEndDate !== null) {

            let filteredOpps = helper.filterOpps(cmp.get("v.originalOpportunities"), 
                                                selectedUser, 
                                                selectedState, 
                                                selectedStartDate, 
                                                selectedEndDate);
            cmp.set("v.filteredOpportunities", filteredOpps);

            //find the amount of opps on screen after filters applied
            for (let oppt of filteredOpps) {
                if (oppt !== null) { 
                    opptCount = opptCount + 1; 
                }
            }
            console.log('opptCount = ' + opptCount);
        } else {
            this.showError(component, event, helper);
        }
    },

    handleRefresh: function(component, event, helper){
        component.set("v.ShowSpinner", true);
        //set filters back to undefined
        component.set("v.user", undefined);
        component.set("v.state", undefined);
        component.set("v.startDate", undefined);
        component.set("v.endDate", undefined);
        var init = component.get('c.doInit');
        $A.enqueueAction(init);
    },

    //show help window
    openHelp: function(component, event, helper) {
        component.set("v.openHelp",true);
        console.log('show error');
    },

    closeHelp: function(component, event, helper) {
        component.set("v.openHelp",false);
    },

    handleCheckbox: function(cmp, event, helper) {
        console.log('@@@ value = ' + event.getParam('value'));
    }

})