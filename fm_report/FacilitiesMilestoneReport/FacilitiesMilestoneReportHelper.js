({
	totalRecordCount : function(cmp, opps) {
		let recordCount = 0;
		for (let index = 0; index < opps.length; index++) {
			recordCount = recordCount + 1;
		}
		return recordCount;
	},

	totalPurchasePrice : function(cmp, opps) {
		let purchasePrice = 0;
		for (let index = 0; index < opps.length; index++) {
			if(opps[index].opp.Estimated_Project_Cost__c !== undefined) {
				purchasePrice = purchasePrice + 
				opps[index].opp.Estimated_Project_Cost__c;
			}
		}
		return purchasePrice;
	},

	getUserList : function(cmp, opps) {
		let users = new Set();
		for (let index = 0; index < opps.length; index++) {
			users.add(opps[index].opp.Owner.User_Fullname__c);
			//check to see user on each reacord before adding to array
			if(opps[index].opp.Deal_Specialist__c !== undefined){
				users.add(opps[index].opp.Deal_Specialist__r.User_Fullname__c);
			}
			if(opps[index].opp.Financial_Review__c !== undefined){
				users.add(opps[index].opp.Financial_Review__r.User_Fullname__c);
			}
			if(opps[index].opp.Paralegal__c !== undefined){
				users.add(opps[index].opp.Paralegal__r.User_Fullname__c);
			}
			if(opps[index].opp.Attorney__c !== undefined){
				users.add(opps[index].opp.Attorney__r.User_Fullname__c);
			}
			if(opps[index].opp.Facilities_Underwriting_Manager_FAUM__c !== undefined){
				users.add(opps[index].opp.Facilities_Underwriting_Manager_FAUM__r.User_Fullname__c);
			}
			if(opps[index].opp.Account_Owner__c !== undefined){
				users.add(opps[index].opp.Account_Owner__r.User_Fullname__c);
			}
		}
		//conver set to array and sort alphabetically
		let userArray = Array.from(users);
		userArray.sort();
		//convert to key/value pair for picklist
		let userList = [];
		userList.push(
			{
				value: "All Users",
				label: "All Users"
			}
		);
		for (let item of userArray){
			userList.push(
				{
					value: item,
					label: item
				}
			)
		};
		return userList;
	},

	getStateList : function(cmp, opps) {
		let stateList = [];
		stateList.push(
			{value: "All States",label: "All States"},
			//{value: "AL",label: "AL"},
			//{value: "AK",label: "AK"},
			{value: "AZ",label: "AZ"},
			//{value: "AR",label: "AR"},
			{value: "DC",label: "DC"},
			{value: "CA",label: "CA"},
			{value: "CO",label: "CO"},
			//{value: "CT",label: "CT"},
			//{value: "DE",label: "DE"},
			{value: "FL",label: "FL"},
			{value: "GA",label: "GA"},
			//{value: "HI",label: "HI"},
			//{value: "ID",label: "ID"},
			{value: "IL",label: "IL"},
			//{value: "IN",label: "IN"},
			//{value: "IA",label: "IA"},
			//{value: "KS",label: "KS"},
			//{value: "KY",label: "KY"},
			{value: "LA",label: "LA"},
			//{value: "ME",label: "ME"},
			{value: "MD",label: "MD"},
			//{value: "MA",label: "MA"},
			{value: "MI",label: "MI"},
			{value: "MN",label: "MN"},
			//{value: "MS",label: "MS"},
			//{value: "MO",label: "MO"},
			//{value: "MT",label: "MT"},
			//{value: "NE",label: "NE"},
			//{value: "NV",label: "NV"},
			//{value: "NH",label: "NH"},
			//{value: "NJ",label: "NJ"},
			//{value: "NM",label: "NM"},
			{value: "NY",label: "NY"},
			{value: "NC",label: "NC"},
			//{value: "ND",label: "ND"},
			{value: "OH",label: "OH"},
			//{value: "OK",label: "OK"},
			//{value: "OR",label: "OR"},
			{value: "PA",label: "PA"},
			//{value: "RI",label: "RI"},
			//{value: "SC",label: "SC"},
			//{value: "SD",label: "SD"},
			{value: "TN",label: "TN"},
			//{value: "TX",label: "TX"},
			{value: "UT",label: "UT"}
			//{value: "VT",label: "VT"},
			//{value: "VA",label: "VA"},
			//{value: "WA",label: "WA"},
			//{value: "WV",label: "WV"},
			//{value: "WI",label: "WI"},
			//{value: "WY",label: "WY"}
		);
		return stateList;
	},

	//filter opportunities
	filterOpps: function(opps, userName, state, startDate, endDate){
		let updatedArray = [];
		if(userName === 'All Users' && state === 'All States'){
			updatedArray = opps;
		} else {
			for (let opp of opps){
				if(this.userInOpp(opp, userName, state, startDate, endDate)){
					updatedArray.push(opp);
				}
			};
		}
		return updatedArray;
	},

	userInOpp: function(opp, userName, state, startDate, endDate){

		//set dealSpecialist, paralegal, and financialReview
		let dealSpecialist = true
		let paralegal = true
		let financialReview = true
		let attorney = true
		let facUW = true
		let accountOwner = true
		let dealSource = true
		if(opp.opp.Deal_Specialist__c === null || opp.opp.Deal_Specialist__c === undefined){
			dealSpecialist = false
		}
		if(opp.opp.Paralegal__c === null || opp.opp.Paralegal__c === undefined){
			paralegal = false
		}
		if(opp.opp.Financial_Review__c === null || opp.opp.Financial_Review__c === undefined){
			financialReview = false
		}
		if(opp.opp.Attorney__c === null || opp.opp.Attorney__c === undefined){
			attorney = false
		}
		if(opp.opp.Facilities_Underwriting_Manager_FAUM__c === null || opp.opp.Facilities_Underwriting_Manager_FAUM__c === undefined){
			facUW = false
		}
		if(opp.opp.Account_Owner__c === null || opp.opp.Account_Owner__c === undefined){
			accountOwner = false
		}
		if(opp.opp.Financial_Consultant__c === null || opp.opp.Financial_Consultant__c === undefined){
			dealSource = false
		}

		let recordFound = false;

		if(userName !== undefined || state !== undefined) {
			//when all dealSpecialist, paralegal, and financialReview = true
			if(dealSpecialist === true && paralegal === true && financialReview === true) {
				//when user is not null
				if(opp.opp.Owner.User_Fullname__c === userName || 
					opp.opp.Deal_Specialist__r.User_Fullname__c === userName || 
					opp.opp.Paralegal__r.User_Fullname__c === userName || 
					opp.opp.Financial_Review__r.User_Fullname__c === userName){
					if(opp.opp.STATE__c === state){
						recordFound = true;
					} else if(state === undefined) {
						recordFound = true;
					} else if(state === 'All States') {
						recordFound = true;
					}
				//when state is not null	
				} else if(opp.opp.STATE__c === state) {
					if(opp.opp.Owner.User_Fullname__c === userName) {
						recordFound = true;
					} else if(userName === undefined) {
						recordFound = true;
					} else if(userName === 'All Users') {
						recordFound = true;
					}
				}
			} else if(dealSpecialist === false && paralegal === true && financialReview === true) {
				//when user is not null
				if(opp.opp.Owner.User_Fullname__c === userName || 
					opp.opp.Paralegal__r.User_Fullname__c === userName || 
					opp.opp.Financial_Review__r.User_Fullname__c === userName){
					if(opp.opp.STATE__c === state){
						recordFound = true;
					} else if(state === undefined) {
						recordFound = true;
					} else if(state === 'All States') {
						recordFound = true;
					}
				//when state is not null	
				} else if(opp.opp.STATE__c === state) {
					if(opp.opp.Owner.User_Fullname__c === userName) {
						recordFound = true;
					} else if(userName === undefined) {
						recordFound = true;
					} else if(userName === 'All Users') {
						recordFound = true;
					}
				}
			} else if(dealSpecialist === true && paralegal === false && financialReview === true){
				
				//when user is not null
				if(opp.opp.Owner.User_Fullname__c === userName || 
					opp.opp.Deal_Specialist__r.User_Fullname__c === userName || 
					opp.opp.Financial_Review__r.User_Fullname__c === userName){
					if(opp.opp.STATE__c === state){
						recordFound = true;
					} else if(state === undefined) {
						recordFound = true;
					} else if(state === 'All States') {
						recordFound = true;
					}
				//when state is not null	
				} else if(opp.opp.STATE__c === state) {
					if(opp.opp.Owner.User_Fullname__c === userName) {
						recordFound = true;
					} else if(userName === undefined) {
						recordFound = true;
					} else if(userName === 'All Users') {
						recordFound = true;
					}
				}
			} else if(dealSpecialist === true && paralegal === true && financialReview === false) {
				//when user is not null
				if(opp.opp.Owner.User_Fullname__c === userName || 
					opp.opp.Deal_Specialist__r.User_Fullname__c === userName || 
					opp.opp.Paralegal__r.User_Fullname__c === userName){
					if(opp.opp.STATE__c === state){
						recordFound = true;
					} else if(state === undefined) {
						recordFound = true;
					} else if(state === 'All States') {
						recordFound = true;
					}
				//when state is not null	
				} else if(opp.opp.STATE__c === state) {
					if(opp.opp.Owner.User_Fullname__c === userName) {
						recordFound = true;
					} else if(userName === undefined) {
						recordFound = true;
					} else if(userName === 'All Users') {
						recordFound = true;
					}
				}
			} else if(dealSpecialist === true && paralegal === false && financialReview === false) {
				//when user is not null
				if(opp.opp.Owner.User_Fullname__c === userName || 
					opp.opp.Deal_Specialist__r.User_Fullname__c === userName){
					if(opp.opp.STATE__c === state){
						recordFound = true;
					} else if(state === undefined) {
						recordFound = true;
					} else if(state === 'All States') {
						recordFound = true;
					}
				//when state is not null	
				} else if(opp.opp.STATE__c === state) {
					if(opp.opp.Owner.User_Fullname__c === userName) {
						recordFound = true;
					} else if(userName === undefined) {
						recordFound = true;
					} else if(userName === 'All Users') {
						recordFound = true;
					}
				}
			} else {
				//when user is not null
				if(opp.opp.Owner.User_Fullname__c === userName ){
					if(opp.opp.STATE__c === state){
						recordFound = true;
					} else if(state === undefined) {
						recordFound = true;
					} else if(state === 'All States') {
						recordFound = true;
					}
				//when state is not null	
				} else if(opp.opp.STATE__c === state) {
					if(opp.opp.Owner.User_Fullname__c === userName) {
						recordFound = true;
					} else if(userName === undefined) {
						recordFound = true;
					} else if(userName === 'All Users') {
						recordFound = true;
					}
				}
			}
			if (attorney === true) {
				if(opp.opp.Attorney__r.User_Fullname__c === userName){
					if(opp.opp.STATE__c === state){
						recordFound = true;
					} else if(state === undefined) {
						recordFound = true;
					} else if(state === 'All States') {
						recordFound = true;
					}
				}
			}
			if (facUW === true) {
				if(opp.opp.Facilities_Underwriting_Manager_FAUM__r.User_Fullname__c === userName){
					if(opp.opp.STATE__c === state){
						recordFound = true;
					} else if(state === undefined) {
						recordFound = true;
					} else if(state === 'All States') {
						recordFound = true;
					}
				}
			}
			if (accountOwner === true) {
				if(opp.opp.Account_Owner__r.User_Fullname__c === userName){
					if(opp.opp.STATE__c === state){
						recordFound = true;
					} else if(state === undefined) {
						recordFound = true;
					} else if(state === 'All States') {
						recordFound = true;
					}
				}
			}
			if (dealSource === true) {
				if(opp.opp.Financial_Consultant__r.User_Fullname__c === userName){
					if(opp.opp.STATE__c === state){
						recordFound = true;
					} else if(state === undefined) {
						recordFound = true;
					} else if(state === 'All States') {
						recordFound = true;
					}
				}
			}
		}

		//when dates are not null	
		if((userName === undefined && state === undefined) && (startDate !== null || endDate !== null)) {
			if(opp.opp.CloseDate > startDate) { 
				if(opp.opp.CloseDate < endDate) {
					recordFound = true;
				} else if(endDate === null) {
					recordFound = true;
				}
			} else if(opp.opp.CloseDate < endDate) { 
				if(opp.opp.CloseDate > startDate) {
					recordFound = true;
				} else if(startDate === null) {
					recordFound = true;
				}
			}
		}

		return recordFound;
	},

	totalDealApproved : function(cmp, opps) {
		let recordDealApproved = 0;
		for (let index = 0; index < opps.length; index++) {
			if(opps[index].dealApproved == 'Completed') {
				recordDealApproved = recordDealApproved + 1;
			}
		}
		return recordDealApproved;
	},

	totalDollarDealApproved : function(cmp, opps) {
		let dollarDealApproved = 0;
		for (let index = 0; index < opps.length; index++) {
			if(opps[index].dealApproved == 'Completed' && opps[index].opp.Purchase_Price__c !== undefined) {
				dollarDealApproved = dollarDealApproved + 
				opps[index].opp.Purchase_Price__c;
			}
		}
		return dollarDealApproved;
	},

	//pre fc
	totalPreFc : function(cmp, opps) {
		let recordPreFc = 0;
		for (let index = 0; index < opps.length; index++) {
			if(opps[index].preFC == 'Completed') {
				recordPreFc = recordPreFc + 1;
			}
		}
		return recordPreFc;
	},

	totalDollarPreFc : function(cmp, opps) {
		let dollarPreFc = 0;
		for (let index = 0; index < opps.length; index++) {
			if(opps[index].preFC == 'Completed' && opps[index].opp.Purchase_Price__c !== undefined) {
				dollarPreFc = dollarPreFc + 
				opps[index].opp.Purchase_Price__c;
			}
		}
		return dollarPreFc;
	},

	//LOI Sent
	totalLOISent : function(cmp, opps) {
		let recordLOISent = 0;
		for (let index = 0; index < opps.length; index++) {
			if(opps[index].loiSent == 'Completed') {
				recordLOISent = recordLOISent + 1;
			}
		}
		return recordLOISent;
	},

	totalDollarLOISent : function(cmp, opps) {
		let dollarLOISent = 0;
		for (let index = 0; index < opps.length; index++) {
			if(opps[index].loiSent == 'Completed' && opps[index].opp.Purchase_Price__c !== undefined) {
				dollarLOISent = dollarLOISent + 
				opps[index].opp.Purchase_Price__c;
			}
		}
		return dollarLOISent;
	},

    //LOI Signed
	totalLOISigned: function(cmp, opps) {
		let recordLOISigned = 0;
		for (let index = 0; index < opps.length; index++) {
			if(opps[index].loiSigned == 'Completed') {
				recordLOISigned = recordLOISigned + 1;
			}
		}
		return recordLOISigned;
	},

	totalDollarLOISigned : function(cmp, opps) {
		let dollarLOISigned = 0;
		for (let index = 0; index < opps.length; index++) {
			if(opps[index].loiSigned == 'Completed' && opps[index].opp.Purchase_Price__c !== undefined) {
				dollarLOISigned = dollarLOISigned + 
				opps[index].opp.Purchase_Price__c;
			}
		}
		return dollarLOISigned;
	},

    //MOU Sent
	totalMOUSent : function(cmp, opps) {
		let recordMOUSent = 0;
		for (let index = 0; index < opps.length; index++) {
			if(opps[index].mouSent == 'Completed') {
				recordMOUSent = recordMOUSent + 1;
			}
		}
		return recordMOUSent;
	},

	totalDollarMOUSent : function(cmp, opps) {
		let dollarMOUSent = 0;
		for (let index = 0; index < opps.length; index++) {
			if(opps[index].mouSent == 'Completed' && opps[index].opp.Purchase_Price__c !== undefined) {
				dollarMOUSent = dollarMOUSent + 
				opps[index].opp.Purchase_Price__c;
			}
		}
		return dollarMOUSent;
	},

    //MOU Signed
	totalMOUSigned : function(cmp, opps) {
		let recordMOUSigned = 0;
		for (let index = 0; index < opps.length; index++) {
			if(opps[index].mouSigned == 'Completed') {
				recordMOUSigned = recordMOUSigned + 1;
			}
		}
		return recordMOUSigned;
	},

	totalDollarMOUSigned : function(cmp, opps) {
		let dollarMOUSigned = 0;
		for (let index = 0; index < opps.length; index++) {
			if(opps[index].mouSigned == 'Completed' && opps[index].opp.Purchase_Price__c !== undefined) {
				dollarMOUSigned = dollarMOUSigned + 
				opps[index].opp.Purchase_Price__c;
			}
		}
		return dollarMOUSigned;
	},

    //PSA Signed
	totalPSASigned: function(cmp, opps) {
		let recordPSASigned = 0;
		for (let index = 0; index < opps.length; index++) {
			if(opps[index].psaSigned == 'Completed') {
				recordPSASigned = recordPSASigned + 1;
			}
		}
		return recordPSASigned;
	},

	totalDollarPSASigned : function(cmp, opps) {
		let dollarPSASigned = 0;
		for (let index = 0; index < opps.length; index++) {
			if(opps[index].psaSigned == 'Completed' && opps[index].opp.Purchase_Price__c !== undefined) {
				dollarPSASigned = dollarPSASigned + 
				opps[index].opp.Purchase_Price__c;
			}
		}
		return dollarPSASigned;
	},

    //Lease Signed
	totalLeaseSigned : function(cmp, opps) {
		let recordLeaseSigned = 0;
		for (let index = 0; index < opps.length; index++) {
			if(opps[index].leaseSigned == 'Completed') {
				recordLeaseSigned = recordLeaseSigned + 1;
			}
		}
		return recordLeaseSigned;
	},

	totalDollarLeaseSigned : function(cmp, opps) {
		let dollarLeaseSigned = 0;
		for (let index = 0; index < opps.length; index++) {
			if(opps[index].leaseSigned == 'Completed' && opps[index].opp.Purchase_Price__c !== undefined) {
				dollarLeaseSigned = dollarLeaseSigned + 
				opps[index].opp.Purchase_Price__c;
			}
		}
		return dollarLeaseSigned;
	},

    //Final FC
	totalFinalFc : function(cmp, opps) {
		let recordFinalFc = 0;
		for (let index = 0; index < opps.length; index++) {
			if(opps[index].finalFC == 'Completed') {
				recordFinalFc = recordFinalFc + 1;
			}
		}
		return recordFinalFc;
	},

	totalDollarFinalFc : function(cmp, opps) {
		let dollarFinalFc = 0;
		for (let index = 0; index < opps.length; index++) {
			if(opps[index].finalFC == 'Completed' && opps[index].opp.Purchase_Price__c !== undefined) {
				dollarFinalFc = dollarFinalFc + 
				opps[index].opp.Purchase_Price__c;
			}
		}
		return dollarFinalFc;
	},

    //Diligence Waived
	totalDiligenceWaived : function(cmp, opps) {
		let recordDiligenceWaived = 0;
		for (let index = 0; index < opps.length; index++) {
			if(opps[index].diligenceWaived == 'Completed') {
				recordDiligenceWaived = recordDiligenceWaived + 1;
			}
		}
		return recordDiligenceWaived;
	},

	totalDollarDiligenceWaived : function(cmp, opps) {
		let dollarDiligenceWaived = 0;
		for (let index = 0; index < opps.length; index++) {
			if(opps[index].diligenceWaived == 'Completed' && opps[index].opp.Purchase_Price__c !== undefined) {
				dollarDiligenceWaived = dollarDiligenceWaived + 
				opps[index].opp.Purchase_Price__c;
			}
		}
		return dollarDiligenceWaived;
	},

    //Funded
	totalFunded : function(cmp, opps) {
		let recordFunded = 0;
		for (let index = 0; index < opps.length; index++) {
			if(opps[index].funded == 'Completed') {
				recordFunded = recordFunded + 1;
			}
		}
		return recordFunded;
	},

	totalDollarFunded : function(cmp, opps) {
		let dollarFunded = 0;
		for (let index = 0; index < opps.length; index++) {
			if(opps[index].funded == 'Completed' && opps[index].opp.Purchase_Price__c !== undefined) {
				dollarFunded = dollarFunded + 
				opps[index].opp.Purchase_Price__c;
			}
		}
		return dollarFunded;
	},
})