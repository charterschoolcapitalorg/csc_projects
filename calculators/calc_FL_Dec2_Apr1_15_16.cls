public class calc_FL_Dec2_Apr1_15_16 implements FinancialCalculatorAPI{
	
	public Decimal computeReceivable(){
		try{
			if(!FinancialCalcModel.currentProcessHasStateRateCard){
				ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,'Florida Dec(2)-Apr(1) Calculation Failed. No Active State Rate Card found. Please contact your Salesforce Administrator.');
				ApexPages.addMessage(msg);
				return null;
			} else {
				if(FinancialCalcModel.currentProcessingStateRateCard.Record_Type_Text__c != 'Florida State'){
					ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,'Florida Dec(2)-Apr(1) Calculation failed. School\'s Operating State Active Rate Card not of type "Florida State". Please contact your Salesforce Administrator.');
					ApexPages.addMessage(msg);
					return null;
				}
			}
			if(!FinancialCalcModel.currentProcessHasDistRateCard){
				ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,'Florida Dec(2)-Apr(1) Calculation Failed. No Active District Rate Card found. Please contact your Salesforce Administrator.');
				ApexPages.addMessage(msg);
				return null;
			} else {
				if(FinancialCalcModel.currentProcessingDistRateCard.Record_Type_Text__c != 'Florida District'){
					ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,'Florida Dec(2)-Apr(1) Calculation failed. School\'s District Active Rate Card not of type "Florida District". Please contact your Salesforce Administrator.');
					ApexPages.addMessage(msg);
					return null;
				}
			}
			if(FinancialCalcModel.currentProcessingSchAttendance.Record_Type_Text__c != 'Florida'){
				ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,'Florida Dec(2)-Apr(1) Calculation failed. School\'s Active Attendance record not of type "Florida". Please contact your Salesforce Administrator.');
				ApexPages.addMessage(msg);
				return null;
			}

			Decimal retVal;
			School_Attendance__c att = FinancialCalcModel.currentProcessingSchAttendance;
			Rate_Card__c src = FinancialCalcModel.currentProcessingStateRateCard;
			Rate_Card__c drc = FinancialCalcModel.currentProcessingDistRateCard;
			Receivable_Type__c rt = FinancialCalcModel.currentProcessingReceivableType;
			/*#########################################################################################################
			########################################## Steps 1-4 ######################################################
			#########################################################################################################*/
			FinancialCalcModel.addLog('######################## Steps 1-4 ########################');

			Decimal x101BasicK3 = 0;
			Decimal x111BasicK3ESE = 0;
			Decimal x102Basic48 = 0;
			Decimal x112Basic48ESE = 0;
			Decimal x103Basic912 = 0;
			Decimal x113Basic912ESE = 0;
			Decimal x254LVL4ESEPK3 = 0;
			Decimal x254LVL4ESE48 = 0;
			Decimal x254LVL4ESE912 = 0;
			Decimal x255LVL5ESEPK3 = 0;
			Decimal x255LVL5ESE48 = 0;
			Decimal x255LVL5ESE912 = 0;
			Decimal x130ESOLPK3 = 0;
			Decimal x130ESOL48 = 0;
			Decimal x130ESOL912 = 0;
			Decimal x300CareerEdu912 = 0;

			Decimal x111ESELevel1 = 0;
			Decimal x111ESELevel2 = 0;
			Decimal x111ESELevel3 = 0;
			Decimal x112ESELevel1 = 0;
			Decimal x112ESELevel2 = 0;
			Decimal x112ESELevel3 = 0;
			Decimal x113ESELevel1 = 0;
			Decimal x113ESELevel2 = 0;
			Decimal x113ESELevel3 = 0;

			//2015.07.29 - J Caughie - Added for 2015-16 calculator
			Decimal xAdvancedPlacement = 0;
			Decimal xInternationalBaccalaureate = 0;
			Decimal xAdvancedInternationalCertificate = 0;
			Decimal xIndustryCertifiedCareerEd = 0;
			Decimal xEarlyHighSchoolGraduation = 0;
			Decimal xSmallDistrictESESupplement = 0;

			Decimal xMilitaryAndIndian = 0;
			Decimal xCiviliansonFederal = 0;
			Decimal xStudentsWithDisabilities = 0;
			//2015.07.29 - J Caughie - Added for 2015-16 calculator

			if(Integer.valueOf(rt.Fiscal_Year__c.left(2)) > Integer.valueOf(att.Fiscal_Year__c.left(2))){
				//if the receivable fiscal year is greater than the attendance data, use this year's february FTE x2
				if(att.This_FY_February_Data_Included__c != true){
					ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.WARNING,'Florida Dec(2)-Apr(1) Calculation could not calculate for future fiscal year receivables. This year\'s February FTE must be included to calculate.');
					ApexPages.addMessage(msg);
					return null;
				}
				FinancialCalcModel.addLog('Calculating Florida Dec(2)-Apr(1) for FUTURE fiscal year with THIS YEAR February data.');
				x101BasicK3 = att.X101_Basic_K_3_This_Feb__c * 2;
				x111BasicK3ESE = att.X111_Basic_K_3_with_ESE_This_Feb__c * 2;
				x102Basic48 = att.X102_Basic_4_8_This_Feb__c * 2;
				x112Basic48ESE = att.X112_Basic_4_8_with_ESE_This_Feb__c * 2;
				x103Basic912 = att.X103_Basic_9_12_This_Feb__c * 2;
				x113Basic912ESE = att.X113_Basic_9_12_with_ESE_This_Feb__c * 2;
				x254LVL4ESEPK3 = att.X254_ESE_Level_4_PK_3_This_Feb__c * 2;
				x254LVL4ESE48 = att.X254_ESE_Level_4_4_8_This_Feb__c * 2;
				x254LVL4ESE912 = att.X254_ESE_Level_4_9_12_This_Feb__c * 2;
				x255LVL5ESEPK3 = att.X255_ESE_Level_5_PK_3_This_Feb__c * 2;
				x255LVL5ESE48 = att.X255_ESE_Level_5_4_8_This_Feb__c * 2;
				x255LVL5ESE912 = att.X255_ESE_Level_5_9_12_This_Feb__c * 2;
				x130ESOLPK3 = att.X130_ESOL_PK_3_This_Feb__c * 2;
				x130ESOL48 = att.X130_ESOL_4_8_This_Feb__c * 2;
				x130ESOL912 = att.X130_ESOL_9_12_This_Feb__c * 2;
				x300CareerEdu912 = att.X300_Career_Education_9_12_This_Feb__c * 2;

				x111ESELevel1 = att.X111_PK_3_ESE_Matrix_Level_251_This_Feb__c * 2;
			 	x111ESELevel2 = att.X111_PK_3_ESE_Matrix_Level_252_This_Feb__c * 2;
				x111ESELevel3 = att.X111_PK_3_ESE_Matrix_Level_253_This_Feb__c * 2;
				x112ESELevel1 = att.X112_4_8_ESE_Matrix_Level_251_This_Feb__c * 2;
				x112ESELevel2 = att.X112_4_8_ESE_Matrix_Level_252_This_Feb__c * 2;
				x112ESELevel3 = att.X112_4_8_ESE_Matrix_Level_253_This_Feb__c * 2;
				x113ESELevel1 = att.X113_9_12_ESE_Matrix_Level_251_This_Feb__c * 2;
				x113ESELevel2 = att.X113_9_12_ESE_Matrix_Level_252_This_Feb__c * 2;
				x113ESELevel3 = att.X113_9_12_ESE_Matrix_Level_253_This_Feb__c * 2;

				//2015.07.29 - J Caughie - Added for 2015-16 calculator
				xAdvancedPlacement = att.Advanced_Placement_This_Feb__c * 2;
				xInternationalBaccalaureate = att.International_Baccalaureate_This_Feb__c * 2;
				xAdvancedInternationalCertificate = att.Advanced_International_Cert_This_Feb__c * 2;
				xIndustryCertifiedCareerEd = att.Industry_Certified_Career_Ed_This_Feb__c * 2;
				xEarlyHighSchoolGraduation = att.Early_High_School_Graduation_This_Feb__c * 2;
				xSmallDistrictESESupplement = att.Small_District_ESE_Supplement_This_Feb__c * 2;

				xMilitaryAndIndian = att.Military_and_Indian_Lands_This_Feb__c * 2;
				xCiviliansonFederal = att.Civilians_on_Federal_Lands_This_Feb__c * 2;
				xStudentsWithDisabilities = att.Students_with_Disabilities_This_Feb__c * 2;
				//2015.07.29 - J Caughie - Added for 2015-16 calculator

			} else {
				//otherwise, use this year's october FTE x2
				if(att.This_FY_October_Data_Included__c != true){
					ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.WARNING,'Florida Dec(2)-Apr(1) Calculation could not calculate for this fiscal year receivables. This year\'s October FTE must be included to calculate.');
					ApexPages.addMessage(msg);
					return null;
				}
				FinancialCalcModel.addLog('Calculating Florida Dec(2)-Apr(1) for THIS fiscal year with THIS YEAR October data.');
				x101BasicK3 = att.X101_Basic_K_3_This_Oct__c * 2;
				x111BasicK3ESE = att.X111_Basic_K_3_with_ESE_This_Oct__c * 2;
				x102Basic48 = att.X102_Basic_4_8_This_Oct__c * 2;
				x112Basic48ESE = att.X112_Basic_4_8_with_ESE_This_Oct__c * 2;
				x103Basic912 = att.X103_Basic_9_12_This_Oct__c * 2;
				x113Basic912ESE = att.X113_Basic_9_12_with_ESE_This_Oct__c * 2;
				x254LVL4ESEPK3 = att.X254_ESE_Level_4_PK_3_This_Oct__c * 2;
				x254LVL4ESE48 = att.X254_ESE_Level_4_4_8_This_Oct__c * 2;
				x254LVL4ESE912 = att.X254_ESE_Level_4_9_12_This_Oct__c * 2;
				x255LVL5ESEPK3 = att.X255_ESE_Level_5_PK_3_This_Oct__c * 2;
				x255LVL5ESE48 = att.X255_ESE_Level_5_4_8_This_Oct__c * 2;
				x255LVL5ESE912 = att.X255_ESE_Level_5_9_12_This_Oct__c * 2;
				x130ESOLPK3 = att.X130_ESOL_PK_3_This_Oct__c * 2;
				x130ESOL48 = att.X130_ESOL_4_8_This_Oct__c * 2;
				x130ESOL912 = att.X130_ESOL_9_12_This_Oct__c * 2;
				x300CareerEdu912 = att.X300_Career_Education_9_12_This_Oct__c * 2;

				x111ESELevel1 = att.X111_PK_3_ESE_Matrix_Level_251_This_Oct__c * 2;
			 	x111ESELevel2 = att.X111_PK_3_ESE_Matrix_Level_252_This_Oct__c * 2;
				x111ESELevel3 = att.X111_PK_3_ESE_Matrix_Level_253_This_Oct__c * 2;
				x112ESELevel1 = att.X112_4_8_ESE_Matrix_Level_251_This_Oct__c * 2;
				x112ESELevel2 = att.X112_4_8_ESE_Matrix_Level_252_This_Oct__c * 2;
				x112ESELevel3 = att.X112_4_8_ESE_Matrix_Level_253_This_Oct__c * 2;
				x113ESELevel1 = att.X113_9_12_ESE_Matrix_Level_251_This_Oct__c * 2;
				x113ESELevel2 = att.X113_9_12_ESE_Matrix_Level_252_This_Oct__c * 2;
				x113ESELevel3 = att.X113_9_12_ESE_Matrix_Level_253_This_Oct__c * 2;

				//2015.07.29 - J Caughie - Added for 2015-16 calculator
				xAdvancedPlacement = att.Advanced_Placement_This_Oct__c * 2;
				xInternationalBaccalaureate = att.International_Baccalaureate_This_Oct__c * 2;
				xAdvancedInternationalCertificate = att.Advanced_International_Cert_This_Oct__c * 2;
				xIndustryCertifiedCareerEd = att.Industry_Certified_Career_Ed_This_Oct__c * 2;
				xEarlyHighSchoolGraduation = att.Early_High_School_Graduation_This_Oct__c * 2;
				xSmallDistrictESESupplement = att.Small_District_ESE_Supplement_This_Oct__c * 2;

				xMilitaryAndIndian = att.Military_and_Indian_Lands_This_Oct__c * 2;
				xCiviliansonFederal = att.Civilians_on_Federal_Lands_This_Oct__c * 2;
				xStudentsWithDisabilities = att.Students_with_Disabilities_This_Oct__c * 2;
				//2015.07.29 - J Caughie - Added for 2015-16 calculator

			}

			Decimal sumFTE = x101BasicK3 + x111BasicK3ESE + x102Basic48 + x112Basic48ESE + x103Basic912 + x113Basic912ESE + x254LVL4ESEPK3 + 
				x254LVL4ESE48 + x254LVL4ESE912 + x255LVL5ESEPK3 + x255LVL5ESE48 + x255LVL5ESE912 + x130ESOLPK3 + x130ESOL48 + x130ESOL912 + x300CareerEdu912;
			FinancialCalcModel.addLog('sumFTE = ' + sumFTE);
		   	FinancialCalcModel.currentFLsumFTE = sumFTE;

			Decimal WTx101BasicK3 = x101BasicK3 * src.X101_Basic_K_3_PCF__c;
			Decimal WTx111BasicK3ESE = x111BasicK3ESE * src.X111_Basic_K_3_w_ESE_PCF__c;
			Decimal WTx102Basic48 = x102Basic48 * src.X102_Basic_4_8_PCF__c;
			Decimal WTx112Basic48ESE = x112Basic48ESE * src.X112_Basic_4_8_w_ESE_PCF__c;
			Decimal WTx103Basic912 = x103Basic912 * src.X103_Basic_9_12_PCF__c;
			Decimal WTx113Basic912ESE = x113Basic912ESE * src.X113_Basic_9_12_w_ESE_PCF__c;
			Decimal WTx254LVL4ESEPK3 = x254LVL4ESEPK3 * src.X254_ESE_Level_4_PK_3_PCF__c;
			Decimal WTx254LVL4ESE48 = x254LVL4ESE48 * src.X254_ESE_Level_4_4_8_PCF__c;
			Decimal WTx254LVL4ESE912 = x254LVL4ESE912 * src.X254_ESE_Level_4_9_12_PCF__c;
			Decimal WTx255LVL5ESEPK3 = x255LVL5ESEPK3 * src.X255_ESE_Level_5_PK_3_PCF__c;
			Decimal WTx255LVL5ESE48 = x255LVL5ESE48 * src.X255_ESE_Level_5_4_8_PCF__c;
			Decimal WTx255LVL5ESE912 = x255LVL5ESE912 * src.X255_ESE_Level_5_9_12_PCF__c;
			Decimal WTx130ESOLPK3 = x130ESOLPK3 * src.X130_ESOL_PK_3_PCF__c;
			Decimal WTx130ESOL48 = x130ESOL48 * src.X130_ESOL_4_8_PCF__c;
			Decimal WTx130ESOL912 = x130ESOL912 * src.X130_ESOL_9_12_PCF__c;
			Decimal WTx300CareerEdu912 = x300CareerEdu912 * src.X300_Career_Education_9_12_PCF__c;

			//2015.07.29 - J Caughie
			Decimal TotalWTFTE = (WTx101BasicK3 + WTx111BasicK3ESE + WTx102Basic48 + WTx112Basic48ESE + WTx103Basic912 + WTx113Basic912ESE + 
						WTx254LVL4ESEPK3 + WTx254LVL4ESE48 + WTx254LVL4ESE912 + WTx255LVL5ESEPK3 + WTx255LVL5ESE48 + WTx255LVL5ESE912 + WTx130ESOLPK3 + WTx130ESOL48 + WTx130ESOL912 + WTx300CareerEdu912);
			//2015.07.29 - J Caughie			

			Decimal BFx101BasicK3 = (WTx101BasicK3 * src.Base_Student_Allocation__c * drc.District_Cost_Differential__c).round();
			Decimal BFx111BasicK3ESE = (WTx111BasicK3ESE * src.Base_Student_Allocation__c * drc.District_Cost_Differential__c).round();
			Decimal BFx102Basic48 = (WTx102Basic48 * src.Base_Student_Allocation__c * drc.District_Cost_Differential__c).round();
			Decimal BFx112Basic48ESE = (WTx112Basic48ESE * src.Base_Student_Allocation__c * drc.District_Cost_Differential__c).round();
			Decimal BFx103Basic912 = (WTx103Basic912 * src.Base_Student_Allocation__c * drc.District_Cost_Differential__c).round();
			Decimal BFx113Basic912ESE = (WTx113Basic912ESE * src.Base_Student_Allocation__c * drc.District_Cost_Differential__c).round();
			Decimal BFx254LVL4ESEPK3 = (WTx254LVL4ESEPK3 * src.Base_Student_Allocation__c * drc.District_Cost_Differential__c).round();
			Decimal BFx254LVL4ESE48 = (WTx254LVL4ESE48 * src.Base_Student_Allocation__c * drc.District_Cost_Differential__c).round();
			Decimal BFx254LVL4ESE912 = (WTx254LVL4ESE912 * src.Base_Student_Allocation__c * drc.District_Cost_Differential__c).round();
			Decimal BFx255LVL5ESEPK3 = (WTx255LVL5ESEPK3 * src.Base_Student_Allocation__c * drc.District_Cost_Differential__c).round();
			Decimal BFx255LVL5ESE48 = (WTx255LVL5ESE48 * src.Base_Student_Allocation__c * drc.District_Cost_Differential__c).round();
			Decimal BFx255LVL5ESE912 = (WTx255LVL5ESE912 * src.Base_Student_Allocation__c * drc.District_Cost_Differential__c).round();
			Decimal BFx130ESOLPK3 = (WTx130ESOLPK3 * src.Base_Student_Allocation__c * drc.District_Cost_Differential__c).round();
			Decimal BFx130ESOL48 = (WTx130ESOL48 * src.Base_Student_Allocation__c * drc.District_Cost_Differential__c).round();
			Decimal BFx130ESOL912 = (WTx130ESOL912 * src.Base_Student_Allocation__c * drc.District_Cost_Differential__c).round();
			Decimal BFx300CareerEdu912 = (WTx300CareerEdu912 * src.Base_Student_Allocation__c * drc.District_Cost_Differential__c).round();

			Decimal sumBF = BFx101BasicK3 + BFx111BasicK3ESE + BFx102Basic48 + BFx112Basic48ESE + BFx103Basic912 + BFx113Basic912ESE + 
				BFx254LVL4ESEPK3 + BFx254LVL4ESE48 + BFx254LVL4ESE912 + BFx255LVL5ESEPK3 + BFx255LVL5ESE48 + BFx255LVL5ESE912 + BFx130ESOLPK3 +
				BFx130ESOL48 + BFx130ESOL912 + BFx300CareerEdu912;
			FinancialCalcModel.addLog('sumBF = ' + sumBF);

			//2015.07.29 - J Caughie - Added for 2015-16 calculator
			Decimal additionalFTE = (xAdvancedPlacement + xInternationalBaccalaureate + xAdvancedInternationalCertificate + xIndustryCertifiedCareerEd 
								+ xEarlyHighSchoolGraduation + xSmallDistrictESESupplement);
			Decimal additionalBaseFunds = (additionalFTE * src.Base_Student_Allocation__c * drc.District_Cost_Differential__c).round();

			Decimal totalFundedWTFTE = TotalWTFTE + additionalFTE;
			FinancialCalcModel.addLog('totalFundedWTFTE = ' + totalFundedWTFTE);

			Decimal totalBaseFunding = sumBF + additionalBaseFunds;
			FinancialCalcModel.addLog('totalBaseFunding = ' + totalBaseFunding);
			//2015.07.29 - J Caughie - Added for 2015-16 calculator

			Decimal WTx111ESELevel1 = (x111ESELevel1 * drc.X111_K_3_ESE_Level_1_Rate__c).round();
			Decimal WTx111ESELevel2 = (x111ESELevel2 * drc.X111_K_3_ESE_Level_2_Rate__c).round();
			Decimal WTx111ESELevel3 = (x111ESELevel3 * drc.X111_K_3_ESE_Level_3_Rate__c).round();
			Decimal WTx112ESELevel1 = (x112ESELevel1 * drc.X112_4_8_ESE_Level_1_Rate__c).round();
			Decimal WTx112ESELevel2 = (x112ESELevel2 * drc.X112_4_8_ESE_Level_2_Rate__c).round();
			Decimal WTx112ESELevel3 = (x112ESELevel3 * drc.X112_4_8_ESE_Level_3_Rate__c).round();
			Decimal WTx113ESELevel1 = (x113ESELevel1 * drc.X113_9_12_ESE_Level_1_Rate__c).round();
			Decimal WTx113ESELevel2 = (x113ESELevel2 * drc.X113_9_12_ESE_Level_2_Rate__c).round();
			Decimal WTx113ESELevel3 = (x113ESELevel3 * drc.X113_9_12_ESE_Level_3_Rate__c).round();

			Decimal totalWTESE = WTx111ESELevel1 + WTx111ESELevel2 + WTx111ESELevel3 + WTx112ESELevel1 + WTx112ESELevel2 +
				WTx112ESELevel3 + WTx113ESELevel1 + WTx113ESELevel2 + WTx113ESELevel3;
			FinancialCalcModel.addLog('totalWTESE = ' + totalWTESE);
			FinancialCalcModel.addLog('Total ESE Allocation = ' + att.Total_ESE_Allocation__c);

			Decimal totalESE = 0;
			If(att.Total_ESE_Allocation__c>0){
				totalESE = att.Total_ESE_Allocation__c;
			}else{
				totalESE = totalWTESE;
			}
			FinancialCalcModel.addLog('totalESE = ' + totalESE);

			//2015.07.29 - J Caughie - Rearranged as per FL calc
			Decimal ufteShare = (sumFTE / drc.Unweighted_FTE__c).setScale(6);
			FinancialCalcModel.addLog('ufteShare = ' + (ufteShare * 100));

			Decimal wfteShare = (totalFundedWTFTE / drc.Weighted_FTE__c).setScale(6);
			FinancialCalcModel.addLog('wfteShare = ' + (wfteShare * 100));

			/*#########################################################################################################
			########################################## Steps 4-16 #####################################################
			#########################################################################################################*/
			FinancialCalcModel.addLog('######################## Steps 4-16 ########################');

			//4
			Decimal totalSAI = (drc.Supplemental_Academic_Instruction__c * ufteShare).round();
			FinancialCalcModel.addLog('totalSAI = ' + totalSAI);

			//5
			Decimal x748mills = (drc.Discretionary_Tax_Compression__c * ufteShare).round();
			FinancialCalcModel.addLog('x748mills = ' + x748mills);

			//6
			Decimal digitalClassroomsAllocation = (drc.Digital_Classrooms_Allocation__c * ufteShare).round();	//added for 14-15 calculator J Caughie 2014.07.02
			FinancialCalcModel.addLog('digitalClassrooms = ' + digitalClassroomsAllocation);	//added for 14-15 calculator J Caughie 2014.07.02	

			//7
			Decimal safeSchoolsAllocation = (drc.Safe_Schools_Allocation__c * ufteShare).round();
			FinancialCalcModel.addLog('safeSchools = ' + safeSchoolsAllocation);

			//8
			Decimal instrucMatAlloc = (drc.Instructional_Materials_Allocation__c * ufteShare).round();
			FinancialCalcModel.addLog('instrucMatAlloc = ' + instrucMatAlloc);

	        Decimal dualEnrollment = (att.Dual_Enrollment__c);
	        FinancialCalcModel.addLog('Dual Enrollment =' + dualEnrollment);

			//J Caughie - 2018-19 1st FEFP
			//9
			Decimal mentalHealth = (drc.Mental_Health_Assistance_Allocation__c * ufteShare).round();
			FinancialCalcModel.addLog('mentalHealth = ' + mentalHealth);

	        //J Caughie - 2018-19 1st FEFP
	        //10
	        Decimal compressionEnrollment = (drc.Total_Funds_Compression_Allocation__c * ufteShare).round();
	        FinancialCalcModel.addLog('compressionEnrollment =' + compressionEnrollment);

			//11
			// Decimal decliningEnrollment = (drc.Declining_Enrollment_Supplement__c * wfteShare).round();
			// FinancialCalcModel.addLog('decliningEnrollment = ' + decliningEnrollment);

			//11
			Decimal sparsitySupplement = (drc.Sparsity_Supplement__c * wfteShare).round();
			FinancialCalcModel.addLog('sparsitySupplement = ' + sparsitySupplement);

			//12
			Decimal readingAllocation = (drc.Reading_Allocation__c * wfteShare).round();
			FinancialCalcModel.addLog('readingAllocation = ' + readingAllocation);

			//13
			Decimal discLocalEffort = (drc.Total_Disc__c * wfteShare).round();
			FinancialCalcModel.addLog('discLocalEffort = ' + discLocalEffort);

			//14
			Decimal prorationFunds = (drc.Total_Proration_to_Funds_Available__c * wfteShare).round();
			FinancialCalcModel.addLog('prorationFunds = ' + prorationFunds);

			//15
			Decimal discLottery = (drc.Lottery_Discretionary_Funds__c * wfteShare).round();
			FinancialCalcModel.addLog('discLottery = ' + discLottery);

			//16
			Decimal teacherSalaryIncrease = att.Teacher_Salary_Increase_Allocation__c;
			FinancialCalcModel.addLog('teacherSalaryIncrease = ' + teacherSalaryIncrease);			

			/*#########################################################################################################
			########################################## Steps 17-21 #####################################################
			#########################################################################################################*/
			FinancialCalcModel.addLog('######################## Steps 17-21 ########################');

			//17
			//2017.02.17 Override for CSRF
			Decimal sumCSRF = 0;
			if(att.Total_CSRF_Override__c > 0){
				sumCSRF = att.Total_CSRF_Override__c;
			} else {
				Decimal wt_PK3FTE = WTx101BasicK3 + WTx111BasicK3ESE + WTx254LVL4ESEPK3 + WTx255LVL5ESEPK3 + WTx130ESOLPK3;
				Decimal wt_48FTE = WTx102Basic48 + WTx112Basic48ESE + WTx254LVL4ESE48 + WTx255LVL5ESE48 + WTx130ESOL48;
				Decimal wt_912FTE = WTx103Basic912 + WTx113Basic912ESE + WTx254LVL4ESE912 + WTx255LVL5ESE912 + WTx130ESOL912 + WTx300CareerEdu912;

				Decimal csrf_PK3 = (wt_PK3FTE * drc.District_Cost_Differential__c * src.Prorated_Class_Size_Alloc_Factors_K_3__c).round();
				Decimal csrf_48 = (wt_48FTE * drc.District_Cost_Differential__c * src.Prorated_Class_Size_Alloc_Factors_4_8__c).round();
				Decimal csrf_912 = (wt_912FTE * drc.District_Cost_Differential__c * src.Prorated_Class_Size_Alloc_Factors_9_12__c).round();
				sumCSRF = csrf_PK3 + csrf_48 + csrf_912;
			}
			FinancialCalcModel.addLog('sumCSRF = ' + sumCSRF);

			//18
			Decimal allRiders = (att.Student_Transportation_All_Riders__c * drc.Transport_Allocation_per_Base_Student__c).round();
			FinancialCalcModel.addLog('allRiders = ' + allRiders);

			Decimal eseRiders = (att.Student_Transportation_ESE_Riders__c * drc.Transport_Allocation_per_ESE_Student__c).round();
			FinancialCalcModel.addLog('eseRiders = ' + eseRiders);

			//19
			Decimal iaMilitary = (xMilitaryAndIndian * (drc.Exempt_Property_Allocation_Per_Military__c + src.All_Qualifiying_Students__c)).round();
			Decimal iaCiviliansOnFedereal = (xCiviliansonFederal * (drc.Exempt_Property_Allocation_Per_Military__c + src.All_Qualifiying_Students__c) / 2).round();
			Decimal iaStudentsWithDisabilities = (xStudentsWithDisabilities * (src.Qualifying_Students_With_Disabilities_BS__c)).round();
			Decimal totalImpactAid = iaMilitary + iaCiviliansOnFedereal + iaStudentsWithDisabilities;
			FinancialCalcModel.addLog('Impact Aid: ' + totalImpactAid);

			//20
			// Decimal additionalAllocation = (drc.Additional_Allocation__c * wfteShare).round();
	        // FinancialCalcModel.addLog('additionalAllocation = ' + additionalAllocation);

			//18
			//2015.10.19 J Caughie - Updated to reflect calculator
			//Decimal totalRA = att.Reading_Allocation__c;
			//FinancialCalcModel.addLog('totalRA = ' + totalRA);

			//20
			//2015.10.19 J Caughie - Updated to reflect calculator
			Decimal teacherAllocation = att.FL_Teachers_Lead_Program_Stipend__c;
			/*Decimal teacherAllocation = 0;
			if(att.Include_Teacher_Salary_Allocation__c == true){
				teacherAllocation = (drc.Teacher_Salary_Allocation__c * wfteShare).round();
			}*/
			FinancialCalcModel.addLog('teacherAllocation = ' + teacherAllocation);

			//21
			Decimal foodService = (att.Food_Service_Allocation__c);
			FinancialCalcModel.addLog('Food Service Allocation =' + foodService);		//2014.09.30 J Caughie - added Food Service Allocations as per SH	

			/*#########################################################################################################
			########################################## Final Math #####################################################
			#########################################################################################################*/
			FinancialCalcModel.addLog('######################## Final Math ########################');

			Decimal totalBaseValue = (totalBaseFunding + totalESE + totalSAI + x748mills + digitalClassroomsAllocation + safeSchoolsAllocation + instrucMatAlloc + 
				dualEnrollment + mentalHealth + compressionEnrollment + sparsitySupplement + readingAllocation + teacherSalaryIncrease +
				discLocalEffort + prorationFunds + discLottery + sumCSRF + allRiders + eseRiders + totalImpactAid + 
				teacherAllocation + foodService).round();
			FinancialCalcModel.addLog('totalBaseValue = ' + totalBaseValue);

			Decimal adminFee = 1;
			if (sumFTE > 250){
				adminFee = (250/sumFTE);
			}
			FinancialCalcModel.addLog('adminFee = ' + adminFee);

			Decimal annualAdminFee = 0; // (totalBaseValue * .05 * adminFee).setScale(2);
			FinancialCalcModel.addLog('annualAdminFee = ' + annualAdminFee);

			Decimal annualNetToSchool = totalBaseValue - annualAdminFee;
			//FinancialCalcModel.addLog('annualNetToSchool = ' + annualNetToSchool);

			Decimal adjustedPaidYTD = (att.Paid_Year_to_Date__c / (1 - (0.05 * adminFee))).setScale(2);
			FinancialCalcModel.addLog('adjustedPaidYTD = ' + adjustedPaidYTD);

			Decimal netRemainingToSchool = annualNetToSchool + adjustedPaidYTD;  //att.Paid_Year_to_Date__c;
			FinancialCalcModel.addLog('netRemainingToSchool = ' + netRemainingToSchool);

			Decimal semiMonthlyDueSchool = 0;
			if(Integer.valueOf(rt.Fiscal_Year__c.left(2)) > Integer.valueOf(att.Fiscal_Year__c.left(2))){
				//For future FY calculations, just use Annual amount divided by 24
				semiMonthlyDueSchool = annualNetToSchool/24;
			}else{
				if(att.Periods_Remaining__c > 0){
					semiMonthlyDueSchool = (netRemainingToSchool / att.Periods_Remaining__c).setScale(2);
				} else {
					ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,'Florida Apr(2)-June(2) Calculation failed. Periods remaining cannot be less than 1.');
					ApexPages.addMessage(msg);
					return null;
				}
			}
			FinancialCalcModel.addLog('semiMonthlyDueSchool = ' + semiMonthlyDueSchool);

			Decimal semiMonthlyAvailable = semiMonthlyDueSchool; //+ att.Prior_Year_Adjustments__c;
			FinancialCalcModel.addLog('semiMonthlyAvailable = ' + semiMonthlyAvailable);

			Decimal annualModifiedAvailable = semiMonthlyAvailable * 24;
			FinancialCalcModel.addLog('annualModifiedAvailable = ' + annualModifiedAvailable);

			retVal=annualModifiedAvailable;
			
			return retVal;
		} catch (Exception e) {
			ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,'Florida Dec(2)-Apr(1) Calculation failed. Please contact your Salesforce Administrator. (Error: ' + e.getMessage() + ')');
			ApexPages.addMessage(msg);
			return null;
		}
	}
}