/**=====================================================================
 * Appirio, Inc
 * Name: FundingEstimateCalculatorController
 * Test Class: FundingEstimateCalculatorControllerTest
 * Description: T-269750: Funding Estimate Tool - First Jaipur Spec
 * Created Date: [04/08/2014]
 * Created By: [Rahul Agrawal] (Appirio)
 *
 * Date Modified                Modified By                  Description of the update
 * [Feb 09, 2017]               [John Caughie]              [Added feature showing Charter Terms termination date]
 * [Apr 10, 2020]               [John Caughie]              [Added feature to identify donation receivables]
 * [Sep 15. 2022]               [Slava Krel]                [Funding Estimate Data Mapping for School over Charter Holder]
 =====================================================================*/
public class FundingEstimateCalculatorController {
	private string oppId;
	public Funding_Estimates__c fundingEst{get;set;}
	public double totalGRV{get;set;}
	public Opportunity opp{get;set;}
	public List<Funding_Estimate_Receivable__c> listFER{get;set;}
	public List<OppSchoolWrapper> listFER_Step2{get;set;}
	public List<OppSchoolWrapper> listFER_Step3{get;set;}

    public boolean DisplayPopup {get; set;} 

	// constructor
	public FundingEstimateCalculatorController(ApexPages.Standardcontroller sc){
		totalGRV = 0.0;
		fundingEst = new Funding_Estimates__c();
		if(sc <> null){
			if(!test.isRunningTest()){
				sc.addFields(new list<string>{'id', 'Opportunity__c', 'Discount__c', 'Transaction_Fee_Collected__c',
											'Program_Fees_Collected__c', 'Unpaid_Balance_Receivables_Collected__c',
											'Description_of_Unpaid_Balance_Receivable__c', 'Application_Fee_Credit__c',
											'Penalty_Interest__c', 'Blocked_Account_Fee_Collected__c', 'Bond_or_Other_Payment__c',
											'Refund_Reimbursements__c', 'Transaction_Fee__c', 'Net_to_School__c', 
                                            'Total_Upfront_Purchase_Price__c', 'Target_Effective_Rate__c'
											});
			}
			fundingEst = (Funding_Estimates__c)sc.getRecord();
			oppId = fundingEst.Opportunity__c;
		}

		if(fundingEst.Id == null){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Funding Estimate Record does not exist.'));
		}else{
			getOpportunityDetail();
			getListExistingFundingEstimateReceivables();
			if(listFER.isEmpty()){
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'No funding estimate receivables exist for this funding estimate record'));
			}
		}
	}

	// get opportunity details
    // Add Record Type???
	public void getOpportunityDetail(){
        opp = [
                SELECT 
                    id, 
                    Name, 
                    RPA__r.Id, 
                    RPA__c,  
                    RPA__r.RPA_Face_Value_Estimate__c, 
                    RPA__r.Percent_Funded__c,
                    RPA__r.Program_Fee_Estimate__c, 
                    Account.Name, 
                    CloseDate, 
                    RPA__r.RPA_FV_Utilized__c, 
                    RPA__r.RPA_FV_Remaining_Estimate__c,
                    RPA__r.RPA_Program_Fee_Collected__c, 
                    RPA__r.Remaining_Fee_to_Collect_Estimate__c, 
                    RPA__r.Percent_Fee_Collected_Estimate__c,
                    Funded_Date__c, 
                    NET_Amount_Requested__c
                FROM Opportunity
                WHERE id = : oppId 
                LIMIT 1
            ];
		// opp = new Opportunity();
		// for(Opportunity o : [SELECT id, Name, RPA__r.Id, RPA__c,  RPA__r.RPA_Face_Value_Estimate__c, RPA__r.Percent_Funded__c,
		// 						RPA__r.Program_Fee_Estimate__c, Account.Name, CloseDate, RPA__r.RPA_FV_Utilized__c, RPA__r.RPA_FV_Remaining_Estimate__c,
		// 						RPA__r.RPA_Program_Fee_Collected__c, RPA__r.Remaining_Fee_to_Collect_Estimate__c, RPA__r.Percent_Fee_Collected_Estimate__c,
		// 						Funded_Date__c, NET_Amount_Requested__c
		// 					 FROM Opportunity
		// 					 WHERE id = : oppId 
        //                      LIMIT 1]){
		// 	opp = o;
        //     system.debug('@@@ opp = ' + opp);
		// }
	}

    // method to fetch existing FER records for funding estimate
	// 2015.08.19 J Caughie - Added FV_Deduction__c to the SOQL query
    public void getListExistingFundingEstimateReceivables(){
        listFER = [SELECT id, Name, Purchase_Date__c, Maturity_Buffer__c, Initial_Purchase_Factor__c, Already_Purchased__c,
                       Included_in_Estimate__c, School__c, FV_Amount__c , Discount_Amount__c, Maturity_Date__c,
                       GRV_Amount__c, Expected_Pay_Date__c, Opp_School__r.Name, Opp_School__c, Upfront_Purchase_Price__c,
                       Max_Deferred_Purchase_Price__c, Days_Outstanding__c, FV_Deductions__c, Opp_School__r.School__r.Charter_Termination__c , 
                       Effective_Rate__c,                 //2017.02.09 J Caughie added Opp_School__r.School__r.Charter_Termination__c
                       Funding_Estimate__r.Manual_FE__c, Discount_Rate__c, Funding_Estimate__r.Opportunity__r.Account.Donated_Discount_Rate__c,
                       Opp_School__r.School__r.Pricing_Discount_Rate__c,
                       Opp_School__r.School__r.Discount_Rate__c,
                       Opp_School__r.School__r.Default_Maturity_Buffer__c,
                       Opp_School__r.School__r.Default_Initial_Purchase_Factor__c,
                       Opp_School__r.Opportunity__c,
                       Opp_School__r.School__r.FDA_County__c,
                       Opp_School__r.School__r.FDA_District__c
                   FROM Funding_Estimate_Receivable__c
                    WHERE Funding_Estimate__c = :fundingEst.Id
                    AND Already_Purchased__c = false];
    }



	// method to be called on clicking of Next on Step 1
	public void NextOnStep1(){
		system.debug('-------------' + listFER);
		try{
			update listFER;
			getListExistingFundingEstimateReceivables();
			listFER_Step2 = new list<OppSchoolWrapper>();
			totalGRV = 0;
			map<Id, OppSchoolWrapper> mapOppSchoolIdWrapper = new map<Id, OppSchoolWrapper>();
			OppSchoolWrapper oppWrapper;
			for(Funding_Estimate_Receivable__c fer : listFER){
				if(fer.Included_in_Estimate__c){
					if(!mapOppSchoolIdWrapper.containsKey(fer.Opp_School__c)){
                        // system.debug('@@@ fer.Opp_School__r.Opportunity__c = ' + fer.Opp_School__r.Opportunity__c);
                        Opportunity feOpportunity = [SELECT Id, Name, Pre_Year_0_Funding__c, Year_0_Funding__c, RecordType.DeveloperName FROM Opportunity WHERE Id = :fer.Opp_School__r.Opportunity__c];
						mapOppSchoolIdWrapper.put(fer.Opp_School__c, 
                            new OppSchoolWrapper(fer.School__c, 
                                                fer.Opp_School__r.School__r.Charter_Termination__c, 
                                                fer.Opp_School__r.School__r.Pricing_Discount_Rate__c,
                                                fer.Opp_School__r.School__r.Discount_Rate__c,
                                                feOpportunity.Pre_Year_0_Funding__c, 
                                                feOpportunity.Year_0_Funding__c, 
                                                feOpportunity.RecordType.DeveloperName,
                                                fer.Opp_School__r.School__r.FDA_County__c, fer.Opp_School__r.School__r.FDA_District__c));
					}
					oppWrapper = mapOppSchoolIdWrapper.get(fer.Opp_School__c);
					oppWrapper.listFERForOppSchool.add(fer);

					if(fer.GRV_Amount__c <> null){
						totalGRV = totalGRV + fer.GRV_Amount__c;
						oppWrapper.grvAmount = oppWrapper.grvAmount + fer.GRV_Amount__c;
					}
				}
			}
			listFER_Step2.addAll(mapOppSchoolIdWrapper.values());

		}catch(exception ex){
			system.debug('an exception occurred while processing ' + ex.getMessage());
		}
	}


	// method to be called on clicking of Next on step 2
	public void NextOnStep2(){
		saveDataOnStep2();
		fundingEst = [SELECT id, Opportunity__c, Discount__c, Transaction_Fee_Collected__c,
											Program_Fees_Collected__c, Unpaid_Balance_Receivables_Collected__c,
											Description_of_Unpaid_Balance_Receivable__c, Application_Fee_Credit__c,
											Penalty_Interest__c, Blocked_Account_Fee_Collected__c, Bond_or_Other_Payment__c,
											Refund_Reimbursements__c, Transaction_Fee__c, Net_to_School__c, Total_Upfront_Purchase_Price__c, 
                                            Target_Effective_Rate__c
					  FROM Funding_Estimates__c
					  WHERE Id = :fundingEst.Id];

		listFER_Step3 = new list<OppSchoolWrapper>();
		map<Id, OppSchoolWrapper> mapOppSchoolIdWrapper = new map<Id, OppSchoolWrapper>();
		OppSchoolWrapper wrapper;
		for(Funding_Estimate_Receivable__c fer : [Select School__c, Upfront_Purchase_Price__c, Opp_School__c, Opp_School__r.School__r.Charter_Termination__c,			                 //2017.02.09 J Caughie added Opp_School__r.School__r.Charter_Termination__c
													Discount_Rate__c
													from Funding_Estimate_Receivable__c where Id in : listFER and included_In_Estimate__c = true]){
			if(!mapOppSchoolIdWrapper.containsKey(fer.Opp_School__c)){
				mapOppSchoolIdWrapper.put(fer.Opp_School__c, new OppSchoolWrapper(fer.School__c, 0, fer.Opp_School__r.School__r.Charter_Termination__c));
			}
			wrapper = mapOppSchoolIdWrapper.get(fer.Opp_School__c);
			if(fer.Upfront_Purchase_Price__c <> null){
				wrapper.amount = wrapper.amount + fer.Upfront_Purchase_Price__c;
			}
		}
		listFer_Step3.addAll(mapOppSchoolIdWrapper.values());
	}

	public Pagereference saveOnStep1(){
		try{
			update listFER;
			return new Pagereference('/' + oppId);
		}catch(exception ex){
			system.debug('exception while updating records ' + ex.getMessage());
		}
		return null;
	}

	public Pagereference saveOnStep2(){
		try{
			saveDataOnStep2();
			return new Pagereference('/' + oppId);
		}catch(exception ex){
			system.debug('exception while updating records ' + ex.getMessage());
		}
		return null;
	}


	private void saveDataOnStep2(){
		list<Funding_Estimate_Receivable__c> listFERToUpdate = new list<Funding_Estimate_Receivable__c>();
		
		//identify donation receivables
		Set<Id> donatedDiscountFERs = new Set<Id>();
		donatedDiscountFERs = identifyFurthestPurchaseFER(listFER_Step2);

		for(OppSchoolWrapper oppWrapper : listFER_Step2){
			for(Funding_Estimate_Receivable__c fer : oppWrapper.listFERForOppSchool){
				// 05/29/2014 : MG : Upfront_Purchase_Price_Workflow__c is being updated using workflow field update. But, in order to fire the
				// workflow we need to update the field manually
				fer.Upfront_Purchase_Price_Workflow__c = fer.Discount_Amount__c - fer.FV_Amount__c + 1;
				Decimal discountDonatedRate = 0.0;
				//if not a manual FE calculate if donation receivable
				if(fer.Funding_Estimate__r.Manual_FE__c != true){
					if(donatedDiscountFERs.contains(fer.Id)){
						if(fer.Funding_Estimate__r.Opportunity__r.Account.Donated_Discount_Rate__c == 0 || fer.Funding_Estimate__r.Opportunity__r.Account.Donated_Discount_Rate__c == null){
							discountDonatedRate = 100.0;
						} else {
							discountDonatedRate = fer.Funding_Estimate__r.Opportunity__r.Account.Donated_Discount_Rate__c;
						}
						fer.Donated_Discount_Receivable__c = true;
						fer.Donated_Discount_Rate__c = discountDonatedRate;
					} else {
						fer.Donated_Discount_Receivable__c = false;
					}
				}
				listFERToUpdate.add(fer);
			}
			//listFERToUpdate.addAll(oppWrapper.listFERForOppSchool);
		}

		//calculate which receivables get 

		/*try{*/
			update fundingEst;
			if(!listFERToUpdate.isEmpty()) update listFERToUpdate;
		/*}Catch(exception ex){
			system.debug('Exception while updating records === ' + ex.getMessage());
		}*/
	}

	// method to save and navigate to Opp record on clicking of save and close from Step 3
	public pagereference saveOnStep3(){
		try{
			if(fundingEst.Unpaid_Balance_Receivables_Collected__c == null ||
							fundingEst.Unpaid_Balance_Receivables_Collected__c == 0){
				fundingEst.Description_of_Unpaid_Balance_Receivable__c = '';
			}
			update fundingEst;
			return new pageReference('/'+opp.Id);
		}catch(exception ex){
			system.debug('Exception while updating funding estimate : ' + ex.getMessage());
		}
		return null;
	}

	// method to be called on clicking of previous on step 2
	public void PreviousOnStep2(){
		saveDataOnStep2();
	}

	// method to be called on clicking of Previous on step 3
	public void PreviousOnStep3(){
		try{
			if(fundingEst.Unpaid_Balance_Receivables_Collected__c == null ||
							fundingEst.Unpaid_Balance_Receivables_Collected__c == 0){
				fundingEst.Description_of_Unpaid_Balance_Receivable__c = '';
			}
			update fundingEst;
		}catch(exception ex){
			system.debug('Exception while updating funding estimate : ' + ex.getMessage());
		}

	}

	

 	public pagereference saveAndGenerateInternalSummary(){
 		try{
			update fundingEst;
			return new pageReference('/apex/FundingEstimate_InternalSummary?id='+fundingEst.Id);
		}catch(exception ex){
			system.debug('Exception while updating funding estimate : ' + ex.getMessage());
		}
		return null;
 	}

 	public pagereference saveAndGoFERecord(){
 		try{
			update fundingEst;
			return new pageReference('/'+fundingEst.Id);
		}catch(exception ex){
			system.debug('Exception while updating funding estimate : ' + ex.getMessage());
		}
		return null;
 	}

	/*
	Wrapper class to group FER rcords based on School
	*/
	public class OppSchoolWrapper{
		public String oppSchoolName{get;set;}
		public double amount{get;set;}
		public list<Funding_Estimate_Receivable__c> listFERForOppSchool{get;set;}
		public double grvAmount{get;set;}
        public Date charterTermination{get;set;}                                                //2017.02.09 J Caughie charter termination date
        public Decimal targetEffectiveRate {get;set;}
        public Decimal discountRate {get;set;}
        public Integer discountRateId {get;set;}
        // adding opportunity info
        // from record
        public Boolean preYear0Funding {get;set;}
        public Boolean year0Funding {get;set;}
        public String recordType {get;set;}
        // calculated
        public Decimal fiveDayFundingRateCalc {get;set;}
        public Decimal preYear0FundingCalc {get;set;}
        public Decimal year0FundingCalc {get;set;}
        public Decimal discountRateFinal {get;set;}
        public Decimal intercept {get;set;}
        public Decimal totalAdjustments {get;set;}

		// constructor
		// This will be used when creating list for step 3
		public OppSchoolWrapper(String oppSchoolName, double amount, Date charterTermination){
			this.oppSchoolName = oppSchoolName;
			this.amount = amount;
			this.charterTermination = charterTermination;
		}

		// constructor
		// this will be used when creating list for step 2
		public OppSchoolWrapper(
            String oppSchoolName, 
            Date charterTermination, 
            Decimal targetEffectiveRate, 
            Decimal discountRate, 
            Boolean preYear0Funding, 
            Boolean year0Funding, 
            String recordType,
            String fdaCounty, 
            String fdaDistrict){

			this.OppSchoolName = oppSchoolName;
			this.listFERForOppSchool = new list<Funding_Estimate_Receivable__c>();
			this.grvAmount = 0;
			this.amount = 0;
			this.charterTermination = charterTermination;
            if(targetEffectiveRate == null) {
                this.targetEffectiveRate = 0;
            } else {
                this.targetEffectiveRate = targetEffectiveRate;
            }
            
            this.discountRate = discountRate;
            //create id for discount rate and target eff rate
            this.discountRateId = Integer.valueof(Math.round((Math.random() * (900000) + 100000)));
            // adding opportunity info
            this.preYear0Funding = preYear0Funding;
            this.year0Funding = year0Funding;
            this.recordType = recordType;
            if(recordType == 'X5DF') {
                this.fiveDayFundingRateCalc = 1;
            } else {
                this.fiveDayFundingRateCalc = 0;
            }
            if(preYear0Funding == true) {
                this.preYear0FundingCalc = 1.75;
            } else {
                this.preYear0FundingCalc = 0;
            }
            if(year0Funding == true) {
                this.year0FundingCalc = 1;
            } else {
                this.year0FundingCalc = 0;
            }
            
            if(fdaCounty != null || fdaDistrict != null) {
                if(fdaCounty == 'No' || fdaDistrict == 'No') {
                    this.intercept = 2;
                } else {
                    this.intercept = 0;
                }
            } else {
                this.intercept = 0;
            }
            this.totalAdjustments = fiveDayFundingRateCalc + preYear0FundingCalc + year0FundingCalc + intercept;
            this.discountRateFinal = this.targetEffectiveRate + fiveDayFundingRateCalc + preYear0FundingCalc + year0FundingCalc + intercept;

		}
	}


	private static Set<Id> identifyFurthestPurchaseFER(List<OppSchoolWrapper> listFER_Step2){
		Set<Id> updatedFERids = new Set<Id>();
		List<Id> originalFERids = new List<Id>();
		List<Funding_Estimate_Receivable__c> updatableFERs = new List<Funding_Estimate_Receivable__c>();
	
		//get a list of FERs in the current FE - we need to query for other fields
		for(OppSchoolWrapper oppWrapper : listFER_Step2){
			for(Funding_Estimate_Receivable__c fer : oppWrapper.listFERForOppSchool){
				if(fer.Included_in_Estimate__c == true){
					originalFERids.add(fer.Id);
				}
			}
		}
	
		//query for FERs again to get the needed fields and filter not needed out, ie opp or receivable don't qualify
		updatableFERs = [SELECT Id, Name, Donated_Discount_Receivable__c, Source_Payout_Date_Record__r.Receivable_Representative_Date__c,
							Source_Payout_Date_Record__r.Calculation__r.Receivable_Type__r.Discount_Donation_Receivable__c,
							Source_Payout_Date_Record__r.Calculation__r.Receivable_Type__r.Name,
							Funding_Estimate__r.Opportunity__r.Free_Financing_Opp__c, School_ID__c
							FROM Funding_Estimate_Receivable__c
							WHERE Id IN :originalFERids
							AND Funding_Estimate__r.Opportunity__r.Free_Financing_Opp__c = true
							AND ((Source_Payout_Date_Record__r.Calculation__r.Receivable_Type__r.Discount_Donation_Receivable__c = true
							AND Source_Payout_Date_Record__r.Receivable_Representative_Date__c <= 2020-12-31) OR Source_Payout_Date_Record__r.Discount_Donation_Receivable__c = true)
							ORDER BY Opp_School__c asc, Source_Payout_Date_Record__r.Calculation__r.Receivable_Type__r.Name, Source_Payout_Date_Record__r.Receivable_Representative_Date__c desc];
	
		//loop through new FERs - discover last based on school and receivable rep date	- return list of ids	
		Date lastRepresentativeDate;
		Id schoolId;
		String recTypeName;
		for(Funding_Estimate_Receivable__c fer : updatableFERs){

			if((schoolId == null || fer.School_ID__c != schoolId) && (recTypeName == null || fer.Source_Payout_Date_Record__r.Calculation__r.Receivable_Type__r.Name != recTypeName)){
				schoolId = fer.School_ID__c;
				lastRepresentativeDate = fer.Source_Payout_Date_Record__r.Receivable_Representative_Date__c;
				recTypeName = fer.Source_Payout_Date_Record__r.Calculation__r.Receivable_Type__r.Name;
			}
			if(fer.School_ID__c != schoolId){
				schoolId = fer.School_ID__c;
				lastRepresentativeDate = fer.Source_Payout_Date_Record__r.Receivable_Representative_Date__c;
				recTypeName = fer.Source_Payout_Date_Record__r.Calculation__r.Receivable_Type__r.Name;
			}
			if(fer.Source_Payout_Date_Record__r.Calculation__r.Receivable_Type__r.Name != recTypeName){
				lastRepresentativeDate = fer.Source_Payout_Date_Record__r.Receivable_Representative_Date__c;
				recTypeName = fer.Source_Payout_Date_Record__r.Calculation__r.Receivable_Type__r.Name;
			}

			if(lastRepresentativeDate == fer.Source_Payout_Date_Record__r.Receivable_Representative_Date__c){
				updatedFERids.add(fer.Id);
			}
		}
		return updatedFERids;

	}

    public void ShowPopup() {       
        DisplayPopup = true;
    }

    public void ClosePopup() {       
        DisplayPopup = false;
    }

}