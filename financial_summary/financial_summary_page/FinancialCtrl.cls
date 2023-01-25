/**=====================================================================
 * Charter School Capital
 * Name: FinancialCtrl
 * Test Class: TestFinancials
 * Description: financial information button
 * Created Date: ???
 * Created By: ??? 
 *
 * Date Modified                Modified By                  Description of the update
 * [MON DD, YYYY]             	[FirstName LastName]		 [Short description for changes]
 *  Jan 11, 2023				Slava Krel				     Add new fields 

 =====================================================================*/

 public class FinancialCtrl {
    
    
	private static Integer defaultYears = 3;
    //setting these vars so we can calculate the maximum window width, because there is a minimum size we want the 
    //  column data to be, so in order to have scrolling when the number of columns is large, we need this
    //  if  windows size is < the max window wid3th after this calulation, the cells will auto expand (in the css)
    private static Integer headerColumn1Size = 205;//125;
    private static Integer headerColumnSize = 70;
    private static Integer defaultNumColumnsShown = 12;//17;
	
    public static Map<String, Integer> monthsMap = new Map<String, Integer>{
      	'Jan' => 1,
      	'Feb' => 2,
      	'Mar' => 3,
        'Apr' => 4,
        'May' => 5,
        'Jun' => 6,
        'Jul' => 7,
        'Aug' => 8,
        'Sep' => 9,
        'Oct' => 10,
        'Nov' => 11,
        'Dec' => 12
    };
    
    public static List<String> months {
        
        get {
            if (months==null) {
                List<String> themonths = new List<STring>();
                Schema.DescribeFieldResult F = Financial__c.Month__c.getDescribe();
                Schema.sObjectField T = F.getSObjectField();
                for (PicklistEntry p : T.getDescribe().getPicklistValues()) {
                    //System.debug('adding month: ' + p.getValue());
                    themonths.add(p.getValue());
                }
                return themonths;
            } else {
                return months;
            }
            
        }
    }
    
    
    //for this - add word BLANK to insert a blank row, add a field name, or add text (not containg __c) for just a Label in the Row
    private static List<String> UIfieldNames = new List<String>{
        'Data_Source__c', 
        'Audited__c', 
        'Actual_Student_Count__c', 
        'Breakeven_Enrollment__c', 
        
        'Income Statement' , // section
        'Federal_Revenue__c', 
        'State_Revenue__c', 
        'Local_Revenue__c', 
        'Donations__c', 
        'Other_Revenue__c', 
        'Total_Revenue__c', 
        'BLANK', 
        'Rent__c', 
        'Utilities__c', 
        'Salaries_Benefits__c', 
        'Management_Fee__c', 
        'Other_Opex__c', 
        'Total_Opex_Ex__c',
        'Interest__c', 
        'Depreciation_Amortization__c', 
        'Income_Taxes__c', // added 20230111 - case 2364
        'Total_Expense__c', 
        'BLANK', 
        'Nonrecurring_expense__c',
        'BLANK', 
        'Stated_Net_Income__c', 
        'Non_Recurring_Non_Cash_Income__c', // added 20230111 - case 2364
        'Adjusted_Net_Income__c', 
        'EBITDA__c', 
        'EBITDAR__c', 
        'EBITDARM__c', 
        
        'Other Financial Information', // new section added 20230111 - case 2364
        'Lease_Rent__c', // added 20230111 - case 2364
        'Other_Rent__c', // added 20230111 - case 2364

        'Balance Sheet', // section
        'Cash__c', 
        'Accounts_Receivable__c', 
        'Other_Current_Assets__c', 
        'Current_Assets__c', 
        'Capital_Assets__c', 
        'Other_Non_Current_Assets__c', 
        'Total_Assets__c', 
        'BLANK', 
        'Accounts_Payable__c', 
        'Other_Current_Liabilities__c', 
        'Current_Liabilities__c', 
        'Net_Pension_Liability__c', 
        'Other_Long_Term_Liabilities__c', 
        'Total_Liabilities__c', 
        'BLANK', 
        'Net_Assets__c', 
        'Total_Liabilities_Net_Assets__c',
        
        'Growth', // section
        'Student_Count_Growth__c',
        'Revenue__c', 
        'Salary__c',
        'Expense__c', 
        'EBITDAR_Growth__c', 
        'AP__c', 
        'Net_Asset__c', 
        
        'Ratios', // section
        'EBITDAR_Rent_Coverage__c', 
        'EBITDARM_Rent_Coverage__c', 
        'Rent_Revenue_Ratio__c', 
        'Salaries_Student__c', 
        'Rent_Student__c', 
        'Revenue_Student__c', 
        'Opex_Student__c', 
        'Days_Cash_On_Hand__c', 
        'Current_Ratio__c', 

        'Ratio Total Rent', // new section added 20230111 - case 2364
        'Adj_EBITDAR_Other_Rent__c', // added 20230111 - case 2364
        'EBITDAR_Other_Rent_Coverage__c', // added 20230111 - case 2364
        'EBITDARM_Other_Rent_Coverage__c', // added 20230111 - case 2364
        'Total_Rent_Revenue__c', // added 20230111 - case 2364
        'Total_Rent_Student__c', // added 20230111 - case 2364
        
        'Audit Information', // section
        'Going_Concern__c', 
        'Internal_Control_Issues__c', 
        'Audit_Opinion__c', 
        'BLANK', 
        
        'Financial Analysis', // section
        'Analysis_Summary__c', 
        'Asset_Management__c',
        'Actual_to_Budget_Variance_Comments__c'
        
        };

    private static List<String> negativeVarianceFields = new List<String>{'Rent__c', 'Utilities__c', 'Salaries_Benefits__c', 'Management_Fee__c', 'Other_Opex__c', 'Total_Opex_Ex__c', 'Interest__c', 'Depreciation_Amortization__c', 'Total_Expense__c'};
    private static List<String> AddtlFieldNamesForQuery = new List<String>{'RecordTypeId','Fiscal_Year__c', 'Fiscal_Quarter__c', 'Month__c'};
        
    public static Map<String,DataWrapper> allDataMap = new Map<String,DataWrapper>(); //map of field name to that DataWrapper record
    public static Map<String,Financial__c> fyFqObjsMap = new Map<String,Financial__c>(); //map of RecordType/FiscalQUarter/FIscalYear (index) to the associated FIeld Name to the FInancial object record
    public static Map<String,Financial__c> monthObjsMap = new Map<String,Financial__c>(); //map of RecordType/MOnth (index) to the associated FIeld Name to the FInancial object record
    public static Map<String,Financial__c> budgetActualMap = new Map<String,Financial__c>(); //map of RecordType/MOnth (index) to the associated FIeld Name to the FInancial object record
    
    private static boolean quarterlyonly = false;
    private static boolean annualonly = false;
    private static boolean monthlyonly = false;
    private static boolean DoDefaultLoad = false;
    
    public static STring currYear2Digit = (date.today().month()>=7 ? String.valueOf(date.today().addYears(1).year()).right(2) : String.valueOf(date.today().year()).right(2));
    public static STring defaultStartYear2Digit = (Integer.valueOf(currYear2Digit) -defaultYears+1)+'';
    
    private static STring currFQ2Digit = 
        (date.today().month()>=10 ? 'Q2' : (date.today().month()>=7 ? 'Q1' : (date.today().month()>=4 ? 'Q4' : 'Q3')));
    
    private static Date currYearInSchoolFY = (date.today().month()>=7 ? date.today().addYears(1) : date.today());
    
    @AuraEnabled
    public static String getCurrFY() {
        System.debug('getCurrFY: ' + currYear2Digit);
        return currYear2Digit;
    }
    @AuraEnabled
    public static String getCurrFQ() {
        System.debug('getCurrFQ: ' + currFQ2Digit);
        return currFQ2Digit;
    }
    
    @AuraEnabled(cacheable=true)
    public static String getColumnData(String d, String index) {
        System.debug('getColumnData: ' + d + ' - ' + index);
        DataWrapper dw = (DataWrapper)JSON.deserialize(d, DataWrapper.class);
        Integer indx = Integer.valueOf(index);
        System.debug('getColumnData return: ' +  dw.allVals.get(indx));
    	return dw.allVals.get(indx);
    }
    
    private static Integer getNextFQ(Integer thisFQ) {
            return  ( (Integer.valueOf(thisFQ))==4 ? 1 : (Integer.valueOf(thisFQ))+1);
    }  
    private static Integer getNextFY(Integer thisFY, Integer thisFQ) {
            return ( (Integer.valueOf(thisFQ))==4 ? (Integer.valueOf(thisFY))+1 : (Integer.valueOf(thisFY))) ; 
    }

    private static String getFiscalYear(Integer currentYear){
        return (currentYear - 1) + '-' + currentYear;
    }
    
    private static List<String> buildMonthlyColumns(String stDtfy) {
        System.debug('buildMonthlyColumns: ' + stDtFy);
        /*Set<String> mm = monthsMap.keyset();//new List<String>();
        List<STring> ss = new List<STring>();
        ss.addAll(mm);
        */
        List<STring> ss = new List<STring>();
        Map<Integer,String > monthsMapInverse = new  Map<Integer,String >();
        for (String s : monthsMap.keyset()) {
            monthsMapInverse.put(monthsMap.get(s),s);
        }
        for (Integer i=7;i<=12;i++) {
            ss.add(monthsMapInverse.get(i));
        }
        for (Integer i=1;i<7;i++) {
            ss.add(monthsMapInverse.get(i));
        }
        //List<STring> ss = months;
        
        System.debug('month columns: ' + ss);
        return ss;
    }
    
    private static List<String> buildColumnsFromStartEndDate(String stDtfq, String endDtfq, String stDtfy, String endDtfy) {
        System.debug('buildColumnsFromStartEndDate" ' + stDtfq + ' - ' + endDtfq  + ' - ' + stDtfy  + ' - ' + endDtfy);
        List<String> ss = new List<String>();
        Integer i = defaultYears;
        STring endYear;
        STring startYear;
        STring endFQ;
        STring startFQ;
        if (stDtfq==null && endDtfq != null) {
            //end date no start date
        	//take end date and move back to 2016
        	System.debug('end date no start date');	  
        	 endYear= endDtfy+'';
             //startYear = currYear2Digit;
             startYear = '16';//( Integer.valueOf(currYear2Digit)- defaultYears+1)+'';
             startFQ =1+'';
             endFQ =  endDtfq+'';  
        } else if (stDtfq!=null && endDtfq==null) {
            //start date no end date
             startYear = stDtfy+'';
             //end date is just current year/quarter
             endYear = currYear2Digit;
             startFQ =stDtfq+'';
             endFQ =  4+''; 
        } else {
            //start and end date
             startYear = stDtfy+'';
             endYear = endDtfy+'';
             startFQ =stDtfq+'';
             endFQ =  endDtfq+'';
        }
        System.debug('startYear: ' + startYear);
        System.debug('endYear: ' + endYear);
        System.debug('startFQ: ' + startFQ);
        System.debug('endFQ: ' + endFQ);
        
        Integer thisFQ = (Integer.valueOf(startFQ));
        Integer thisFY = (Integer.valueOf(startYear));
        Integer lastFQ = (Integer.valueOf(endFQ));
        Integer lastFY = (Integer.valueOf(endYear));
        
        Integer nextFQ = getNextFQ(thisFQ);
        Integer nextFY = getNextFY(thisFY, thisFQ);
		System.debug('nextFQ: ' + nextFQ);
        System.debug('nextFY: ' + nextFY);
        
        if ( !annualonly) ss.add(startFQ+'Q'+startYear);
        
        boolean hasnext = (
            (nextFY < lastFY) ||
            (nextFQ <= lastFQ && nextFY <= lastFY)
            );
        
        while (hasnext) {
            if ( !annualonly) ss.add(nextFQ+'Q'+nextFY) ;
            if (nextFQ==4 && !quarterlyonly) ss.add('20'+nextFY);
            
            nextFY = getNextFY(nextFY, nextFQ);
            nextFQ = getNextFQ(nextFQ);
        	
            System.debug('nextFQ: ' + nextFQ);
        	System.debug('nextFY: ' + nextFY);
            
			hasnext = (
                (nextFY < lastFY) ||
                (nextFQ <= lastFQ && nextFY <= lastFY)
                );
            if (!hasnext && nextFQ!=1 && !quarterlyonly) ss.add('20'+nextFY);
        }
        
        
        return ss;
    }
    
    private static List<String> buildBudgetToActualColumns(String stDtfq, String endDtfq, String stDtfy) {
        System.debug('buildBudgetToActualColumns: ' + stDtfq + ' ' + endDtfq + ' ' + stDtFy);
        integer startQ = 1, endQ = 4;

        List<String> ss = new List<String>();
        if(stDtfq != null && stDtfq != 'All' && endDtfq != null && endDtfq != 'All'){
            startQ = Integer.valueOf(stDtfq.right(1));
            endQ = Integer.valueOf(endDtfq.right(1));
        }
        for (Integer i = startQ ; i <= endQ; i++) {
            ss.add('Q' + i + ' Act.');
            ss.add('Q' + i + ' Bud.');
            ss.add('Q' + i + ' Var. $');
            ss.add('Q' + i + ' Var. %');
        }
        return ss;
    }

    private static List<String> buildAllColumns() {
        System.debug('buildAllColumns');
        //default is from 2016 to today
        List<String> ss = new List<String>();
        
        for ( INteger i = 16;i<=Integer.valueOf(currYear2Digit);i++) {
            Integer j = i*-1;
            //Integer iyear = currYearInSchoolFY.addYears(j).year();
        	STring year = '20'+i;//String.valueOf(iyear).right(2);
            //Integer currFQ = Integer.valueOf(currFQ2Digit.right(1));
            
            if (!annualonly) {
                ss.add('1Q'+i);
                ss.add('2Q'+i);
                ss.add('3Q'+i);
                ss.add('4Q'+i); 
            }
            if (!quarterlyonly) {
                ss.add(year+'');
            }
        }
        return ss;
    }
        
    //@AuraEnabled(cacheable=true)
    private static List<String> getColumns( String stDtfq, String endDtfq, String stDtfy, String endDtfy, String type ) {
        System.debug('getcolumns startdate: ' + stDtfq + ' - ' + stDtfy);
        System.debug('getcolumns enddate : ' + endDtfq + ' - ' + endDtfy);
        
        List<String> endDateExpanded;
        List<String> stDateExpanded;
        stDtfq = (stDtfq == 'All' ? null : stDtfq);
        stDtfy = (stDtfy == 'All' ? null : stDtfy);
        endDtfq = (endDtfq == 'All' ? null : endDtfq);
        endDtfy = (endDtfy == 'All' ? null : endDtfy);
        System.debug(' DoDefaultLoad: ' + DoDefaultLOad);
        
        List<String> ss;
        if (DoDefaultLoad) {
            ss = buildColumnsFromStartEndDate(currFQ2Digit.right(1), currFQ2Digit.right(1), defaultStartYear2Digit, currYear2Digit ); 
        } else if (type=='Monthly') {
        	ss = buildMonthlyColumns(endDtfy);
        } else if (type=='Monthly/Annual') {
        	ss = buildMonthlyColumns(endDtfy);  
            //get 1 annual record
            ss.add('20'+endDtfy);
        } else if (type=='Annual') {
            ss = buildColumnsFromStartEndDate('1', '4', stDtfy, endDtfy );
        } else if (type=='BudgetvActual') {
            ss = buildBudgetToActualColumns(stDtfq, endDtfq, endDtfy);
        } else if ((endDtfq==null || endDtfq=='') && (stDtfq==null || stDtfq=='')) {
        	ss = buildAllColumns();    
        } else {
            ss = buildColumnsFromStartEndDate( (stDtfq == null ? null : stDtfq.right(1)),  (endDtfq == null ? null : endDtfq.right(1)),  stDtfy,  endDtfy);
        }
        
        System.debug('final columns: ' + ss);
        return ss;
    }
    
    public static Id quarterlyRecType() {
        return getRecordTypeId('Quarterly');
    }
    public static Id monthlyRecType() {
        return getRecordTypeId('Monthly');
    }
    public static Id annualRecType() {
        return getRecordTypeId('Annual');
    }
    public static Id getRecordTypeId(String name) {
        RecordTypeInfo info = Schema.SObjectType.Financial__c.getRecordTypeInfosByDeveloperName().get(name);
        return info == null ? null : info.getRecordTypeId();
    }
    
    @AuraEnabled
    public static String getAccountName(String acctId) {
        return [Select Name from Account Where Id=:acctId].Name;
    }
    
    @AuraEnabled
    public static List<Account> getAccounts2(String acctId) {
        system.debug('getAccounts for: ' + acctId);
        List<Account> accts = new List<Account>();
        Account a = [SELECT Id, ParentId, Name, RecordType.Name, RecordTypeId FROM Account WHERE Id=:acctId];
        if (a.RecordTypeId==RecordTypes.IDCharterAccount) {
            accts.add(a);
            for (Account b: [SELECT Id, ParentId, Name, RecordType.Name, RecordTypeId FROM Account WHERE ParentId=:a.Id]) {
                accts.add(b);
            }
        } else if (a.RecordTypeId==RecordTypes.IDSChoolAccount) {
            for (Account b: [SELECT Id, ParentId, Name, RecordType.Name, RecordTypeId FROM Account WHERE ParentId=:a.ParentId]) {
                accts.add(b);	
            }
            Account cha = [SELECT Id, ParentId, Name, RecordType.Name, RecordTypeId FROM Account WHERE Id=:a.ParentId];
            accts.add(cha);
        }
        system.debug('getAccounts return: ' + accts);
        return accts;
    }
 
    @AuraEnabled
    public static List<String> getFiscalYears() {
        List<String> vals = new List<STring>();
        //STring currYear = (date.today().month()>=7 ? String.valueOf(date.today().addYears(1).year()).right(2) : String.valueOf(date.today().year()).right(2));
        for (Integer i = Integer.valueOf(currYear2Digit) + 3;i>=16;i--) {
            vals.add(i+'');
        }
        return vals;
    }

    @AuraEnabled
    public static void updateComments(String recordId, String comments){
        try {
            System.debug('updating comments');
            Financial__c fin = [SELECT Id, Actual_to_Budget_Variance_Comments__c FROM Financial__c WHERE Id =: recordId];
            fin.Actual_to_Budget_Variance_Comments__c = comments;
            update fin;
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    private static List<Financial__c> getFinObjs(String acctId, String type, String auditstatus) {
        STring query = 'Select Account__c, ';
        for (String s : UIfieldNames) {
            if (s == 'Asset_Management__c' || s == 'Actual_to_Budget_Variance_Comments__c'){
                query+=s + ', ';
            } else if (s.contains('__c')) {
                query+=s + ', ';
                query+= s.replaceAll('__c', '')+'_Comment__c' + ', ';
            }
            
        }
        for (String s : AddtlFieldNamesForQuery) {
            if (s.contains('__c') || s=='RecordTypeId') query+=s + ', ';
        }
        query = query.removeEnd(', ');
        query+=' from Financial__c where Active__c = True And Account__c=\'' + acctId + '\'';
        Id qrt = quarterlyRecType();
        Id art = annualRecType();
        Id mrt = monthlyRecType();
        if (type!='' && type!='All') {
            if (type=='Quarterly') {
                query+=' AND RecordTypeId=:qrt ';
                quarterlyonly = true;
            } else if (type=='Annual') {
                query+=' AND RecordTypeId=:art '; 
                annualonly = true;
            } else if (type=='Monthly') {
                query+=' AND RecordTypeId=:mrt ';
                monthlyonly = true;
            } else if (type=='Monthly/Annual') {
				query+=' AND (RecordTypeId=:mrt or RecordTypeId=:art) ';                
            } else if (type=='Quarterly/Annual') {
                query+=' AND (RecordTypeId=:qrt or RecordTypeId=:art) ';    
            } else if (type=='BudgetvActual') {
                query+=' AND (RecordTypeId=:qrt or RecordTypeId=:art) ';    
            }            
        }
        // if (auditstatus!='' && auditstatus!='All') {
        //     if (auditstatus=='Audited') {
        //         query+=' AND Audited__c = True ';       
        //     } else if (auditstatus=='Unaudited') {
        //         query+=' AND Audited__c = False ';
        //     }
        // }
        system.debug('@@@ auditstatus = ' + auditstatus);
        if (auditstatus!='') {
            if (auditstatus=='Audited') {
                query+=' AND Audited__c = True ORDER BY CreatedDate DESC';       
            } else if (auditstatus=='Unaudited') {
                query+=' AND Audited__c = False ORDER BY CreatedDate DESC';
            } else if(auditstatus=='All') {
                system.debug('@@@ condition for ALL is working');
                query+=' ORDER BY CreatedDate DESC'; // AND Audited__c = False AND Audited__c = true
            }
        } else {query+=' ORDER BY CreatedDate DESC';}
        //query+=' ORDER BY CreatedDate DESC';
        System.debug('***query: ' + query);
        return Database.query(query);
    }
    
    @AuraEnabled(cacheable=true)
    public static List<DataWrapper> getData(String isDefault, String acctId, String type, String auditstatus, String stDtfq, String endDtfq, String stDtfy, String endDtfy) {
        system.debug('@@-');
        System.debug('getData: ' + acctId + ' - type: ' + type + ' - auditstatus: ' + auditstatus + ' - stDt: ' + stDtfq + ' - endDt: ' + endDtfq);
        DoDefaultLoad = Boolean.valueOf(isDefault);
        List<DataWrapper> dd = new List<DataWrapper>();
        List<Financial__c> objs = getFinObjs(acctId, type, auditstatus);

        System.debug('**** found Financial records for account: ' + objs);
        // see what records we got
        for(Financial__c obj : objs) {
            System.debug('@@@ obj = ' + obj);
        }

		//create Object Map based on the quarter, month and year
        for (Financial__c f : objs) {
            if (f.recordtypeid==monthlyRecType()) {
                monthObjsMap.put((f.Fiscal_Year__c!=null?f.Fiscal_Year__c:'')+(f.month__c!=null?f.month__c:''),f);
                System.debug('added month object for: ' + f.month__c);
            } else if(type== 'BudgetvActual'){
                if(f.recordtypeid==quarterlyRecType() && f.Fiscal_Year__c == getFiscalYear(Integer.valueOf(endDtfy))){
                    System.debug('financials: ' + f.Fiscal_Year__c);
                    System.debug('financials: ' + f.Fiscal_Quarter__c);
                    budgetActualMap.put(f.Fiscal_Quarter__c + ' Act.', f);
                }
                if(f.recordtypeid==annualRecType() && f.Fiscal_Year__c == getFiscalYear(Integer.valueOf(endDtfy)) && f.Data_Source__c == 'Budget'){
                    System.debug('financials: - actual');
                    System.debug('financials: ' + f.Fiscal_Year__c);
                    System.debug('financials: ' + f.Fiscal_Quarter__c);
                    CreateQtlyBudgets(f);
                    // for(Integer i = 1; i <= 4; i++){
                    //     Financial__c newF = f.clone();
                    //     f.Fiscal_Quarter__c = 'Q' + i;
                    //     budgetActualMap.put(f.Fiscal_Quarter__c + ' Bud.', f);
                    // }
                }
            } else {
                fyFqObjsMap.put((f.Fiscal_Year__c!=null?f.Fiscal_Year__c:'')+(f.Fiscal_Quarter__c!=null?f.Fiscal_Quarter__c:''),f); // <-- add id to have a unique key
            	System.debug('added object for: ' + f.Fiscal_Year__c+f.Fiscal_Quarter__c); // now all 18 getting added
            }
        }
        if(type=='BudgetvActual' && !budgetActualMap.isEmpty()){
            CreateQtlyVariances();
        }
        // remove after testing
        // System.debug('fyFqObjsMap: ' +fyFqObjsMap);
        // for(String record : fyFqObjsMap.keySet()) {
        //     system.debug('@@@! record = ' + record + '; value = ' + fyFqObjsMap.get(record)); // all 18 records visible here
        // }
        // System.debug('monthObjsMap: ' +monthObjsMap);
        // System.debug('budgetActualMap: ' +budgetActualMap.keySet());
        // remove after testing
        
        for (String s : UIfieldNames) {
            System.debug('fieldName: ' +s);
				
            //build record for each field, where:
            // s - field name
            // stDtfq - startdatefq
            // endDtfq - enddatefq
            // stDtfy - startdatefy
            // endDtfy - enddatefy
            DataWrapper d =  new DataWrapper(s, stDtfq, endDtfq, stDtfy, endDtfy, type);
            dd.add(d);
            System.debug('*** adding new data row: ' + d);
            allDataMap.put(d.Name, d);
        }
		
        System.debug('getData result: ' + budgetActualMap.keySet());
        System.debug('getData result: ' + dd[0].columns);
        return dd;
    }

    @AuraEnabled
    public static List<Financial__c> getActualBudgetComments(String clientId, String quarters, String fiscalYear){
        system.debug('@#$ quarters = ' + quarters);
        try {
            //get actual records for specified quarters
            List<String> qtrs = new List<String>();
            Object[] values = (Object[])System.JSON.deserializeUntyped(quarters);
            system.debug('@#$ values = ' + values);
            if(values.size()>0){         
                for (Object val : values) {
                    qtrs.add(string.valueof(val));
                }
            }
            System.debug('clientId: ' + clientId);
            System.debug('quarters: ' + System.JSON.deserializeUntyped(quarters));
            System.debug('year: ' + fiscalYear);
            return [SELECT Id, Fiscal_Quarter__c, Actual_to_Budget_Variance_Comments__c FROM Financial__c WHERE Account__c = :clientId AND Fiscal_Year__c = :fiscalYear AND Fiscal_Quarter__c IN :qtrs AND Active__c = true AND RecordType.DeveloperName = 'Quarterly'];
            // return 'got ya';

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    private static void CreateQtlyBudgets(Financial__c annualBudget){
        for(Integer i = 1; i <= 4;i++){
            Financial__c newFO = annualBudget.clone();
            newFO.Calculation_Type__c = 'Budget Actual $';
            newFO.Federal_Revenue__c = newFO.Federal_Revenue__c == null ? 0 : (newFO.Federal_Revenue__c / 4 * i);
            newFO.State_Revenue__c = newFO.State_Revenue__c == null ? 0 : (newFO.State_Revenue__c / 4 * i);
            newFO.Local_Revenue__c = newFO.Local_Revenue__c == null ? 0 : (newFO.Local_Revenue__c / 4 * i);
            newFO.Donations__c = newFO.Donations__c == null ? 0 : (newFO.Donations__c / 4 * i);
            newFO.Total_Revenue__c = newFO.Total_Revenue__c == null ? 0 : (newFO.Total_Revenue__c / 4 * i);
            newFO.Rent__c = newFO.Rent__c == null ? 0 : (newFO.Rent__c / 4 * i);
            newFO.Utilities__c = newFO.Utilities__c == null ? 0 : (newFO.Utilities__c / 4 * i);
            newFO.Salaries_Benefits__c = newFO.Salaries_Benefits__c == null ? 0 : (newFO.Salaries_Benefits__c / 4 * i);
            newFO.Management_Fee__c = newFO.Management_Fee__c == null ? 0 : (newFO.Management_Fee__c / 4 * i);
            newFO.Interest__c = newFO.Interest__c == null ? 0 : (newFO.Interest__c / 4 * i);
            newFO.Depreciation_Amortization__c = newFO.Depreciation_Amortization__c == null ? 0 : (newFO.Depreciation_Amortization__c / 4 * i);
            newFO.Nonrecurring_expense__c = newFO.Nonrecurring_expense__c == null ? 0 : (newFO.Nonrecurring_expense__c / 4 * i);
            newFO.Total_Expense__c = newFO.Total_Expense__c == null ? 0 : (newFO.Total_Expense__c / 4 * i);
            newFO.recalculateFormulas();
            budgetActualMap.put('Q' + i + ' Bud.', newFO);
        }
    }

    private static void CreateQtlyVariances(){
        List<Financial__c> newFOs = new List<Financial__c>();
        for(Integer i = 1; i <= 4;i++){
            Financial__c actualQ = new Financial__c();
            Financial__c budgetQ = new Financial__c();

            actualQ = budgetActualMap.get('Q' + i + ' Act.');
            System.debug('ActualQ ' + actualQ);
            budgetQ = budgetActualMap.get('Q' + i + ' Bud.');
            System.debug('budgetQ ' + budgetQ);

            if(actualQ != null && budgetQ != null){ 
                Financial__c newVarianceFO = new Financial__c();
                newVarianceFO.Data_Source__c = 'Variance $';
                newVarianceFO.Fiscal_Quarter__c = 'Q' + i;
                newVarianceFO.Calculation_Type__c = 'Budget Variance $';
                newVarianceFO.Account__c = actualQ.Account__c;
                newVarianceFO.Actual_Student_Count_Manual__c = (actualQ.Actual_Student_Count__c == null ? 0 : actualQ.Actual_Student_Count__c) - budgetQ.Actual_Student_Count__c;
                newVarianceFO.Federal_Revenue__c = (actualQ.Federal_Revenue__c == null ? 0 : actualQ.Federal_Revenue__c) - budgetQ.Federal_Revenue__c;
                newVarianceFO.State_Revenue__c = (actualQ.State_Revenue__c == null ? 0 : actualQ.State_Revenue__c) - budgetQ.State_Revenue__c;
                newVarianceFO.Local_Revenue__c = (actualQ.Local_Revenue__c == null ? 0 : actualQ.Local_Revenue__c) - budgetQ.Local_Revenue__c;
                newVarianceFO.Donations__c = (actualQ.Donations__c == null ? 0 : actualQ.Donations__c) - budgetQ.Donations__c;
                newVarianceFO.Total_Revenue__c = (actualQ.Total_Revenue__c == null ? 0 : actualQ.Total_Revenue__c) - budgetQ.Total_Revenue__c;
                newVarianceFO.Rent__c = (actualQ.Rent__c == null ? 0 : actualQ.Rent__c) - budgetQ.Rent__c;
                newVarianceFO.Utilities__c = (actualQ.Utilities__c == null ? 0 : actualQ.Utilities__c) - budgetQ.Utilities__c;
                newVarianceFO.Salaries_Benefits__c = (actualQ.Salaries_Benefits__c == null ? 0 : actualQ.Salaries_Benefits__c) - budgetQ.Salaries_Benefits__c;
                newVarianceFO.Management_Fee__c = (actualQ.Management_Fee__c == null ? 0 : actualQ.Management_Fee__c) - budgetQ.Management_Fee__c;
                newVarianceFO.Interest__c = (actualQ.Interest__c == null ? 0 : actualQ.Interest__c) - budgetQ.Interest__c;
                newVarianceFO.Depreciation_Amortization__c = (actualQ.Depreciation_Amortization__c == null ? 0 : actualQ.Depreciation_Amortization__c) - budgetQ.Depreciation_Amortization__c;
                newVarianceFO.Nonrecurring_expense__c = (actualQ.Nonrecurring_expense__c == null ? 0 : actualQ.Nonrecurring_expense__c) - budgetQ.Nonrecurring_expense__c;
                newVarianceFO.Total_Expense__c = (actualQ.Total_Expense__c == null ? 0 : actualQ.Total_Expense__c) - budgetQ.Total_Expense__c;
                newFOs.add(newVarianceFO);

                Financial__c newVariancePercentageFO = new Financial__c();
                newVariancePercentageFO.Data_Source__c = 'Variance %';
                newVariancePercentageFO.Fiscal_Quarter__c = 'Q' + i;
                newVariancePercentageFO.Calculation_Type__c = 'Budget Variance %';
                newVariancePercentageFO.Account__c = newVarianceFO.Account__c;
                newVariancePercentageFO.Actual_Student_Count_Manual__c = nullZeroCheck(budgetQ.Actual_Student_Count__c) ? null : newVarianceFO.Actual_Student_Count_Manual__c / budgetQ.Actual_Student_Count__c;
                newVariancePercentageFO.Federal_Revenue__c = nullZeroCheck(budgetQ.Federal_Revenue__c) ? 0 : newVarianceFO.Federal_Revenue__c / budgetQ.Federal_Revenue__c;
                newVariancePercentageFO.State_Revenue__c = nullZeroCheck(budgetQ.State_Revenue__c) ? 0 : newVarianceFO.State_Revenue__c / budgetQ.State_Revenue__c;
                newVariancePercentageFO.Local_Revenue__c = nullZeroCheck(budgetQ.Local_Revenue__c) ? 0 : newVarianceFO.Local_Revenue__c / budgetQ.Local_Revenue__c;
                newVariancePercentageFO.Donations__c = nullZeroCheck(budgetQ.Donations__c) ? 0 : newVarianceFO.Donations__c / budgetQ.Donations__c;
                newVariancePercentageFO.Total_Revenue__c = nullZeroCheck(budgetQ.Total_Revenue__c) ? 0 : newVarianceFO.Total_Revenue__c / budgetQ.Total_Revenue__c;
                newVariancePercentageFO.Rent__c = nullZeroCheck(budgetQ.Rent__c) ? 0 : newVarianceFO.Rent__c / budgetQ.Rent__c;
                newVariancePercentageFO.Utilities__c = nullZeroCheck(budgetQ.Utilities__c) ? 0 : newVarianceFO.Utilities__c / budgetQ.Utilities__c;
                newVariancePercentageFO.Salaries_Benefits__c = nullZeroCheck(budgetQ.Salaries_Benefits__c) ? 0 : newVarianceFO.Salaries_Benefits__c / budgetQ.Salaries_Benefits__c;
                newVariancePercentageFO.Management_Fee__c = nullZeroCheck(budgetQ.Management_Fee__c) ? 0 : newVarianceFO.Management_Fee__c / budgetQ.Management_Fee__c;
                newVariancePercentageFO.Interest__c = nullZeroCheck(budgetQ.Interest__c) ? 0 : newVarianceFO.Interest__c / budgetQ.Interest__c;
                newVariancePercentageFO.Depreciation_Amortization__c = nullZeroCheck(budgetQ.Depreciation_Amortization__c) ? 0 : newVarianceFO.Depreciation_Amortization__c / budgetQ.Depreciation_Amortization__c;
                newVariancePercentageFO.Nonrecurring_expense__c = nullZeroCheck(budgetQ.Nonrecurring_expense__c) ? 0 : newVarianceFO.Nonrecurring_expense__c / budgetQ.Nonrecurring_expense__c;
                newVariancePercentageFO.Total_Expense__c = nullZeroCheck(budgetQ.Total_Expense__c) ? 0 : newVarianceFO.Total_Expense__c / budgetQ.Total_Expense__c;
                newVariancePercentageFO.Other_Revenue_var__c = nullZeroCheck(budgetQ.Other_Revenue__c) ? 0 : (actualQ.Other_Revenue__c - budgetQ.Other_Revenue__c) / (budgetQ.Other_Revenue__c);
                newVariancePercentageFO.Other_Opex_var__c = nullZeroCheck(budgetQ.Other_Opex__c) ? 0 : (actualQ.Other_Opex__c - budgetQ.Other_Opex__c) / (budgetQ.Other_Opex__c);
                newVariancePercentageFO.Total_Operating_Expense_var__c = nullZeroCheck(budgetQ.Total_Opex_Ex__c) ? 0 : (actualQ.Total_Opex_Ex__c - budgetQ.Total_Opex_Ex__c) / (budgetQ.Total_Opex_Ex__c);
                newVariancePercentageFO.Actual_Student_Count_var__c = nullZeroCheck(budgetQ.Actual_Student_Count__c) ? 0 : (actualQ.Actual_Student_Count__c - budgetQ.Actual_Student_Count__c) / (budgetQ.Actual_Student_Count__c);
                newVariancePercentageFO.EBITDAR_Rent_Coverage_var__c = nullZeroCheck(budgetQ.Rent__c) ? 0 : ((nullZeroCheck(actualQ.Rent__c) ? 0 : actualQ.EBITDAR__c/actualQ.Rent__c) - (budgetQ.EBITDAR__c/budgetQ.Rent__c))/(budgetQ.EBITDAR__c/budgetQ.Rent__c);
                newVariancePercentageFO.EBITDARM_Rent_Coverage_var__c = nullZeroCheck(budgetQ.Rent__c) ? 0 : (nullZeroCheck(actualQ.Rent__c) ? 0 : ((actualQ.EBITDAR__c + (nullZeroCheck(actualQ.Management_Fee__c) ? 0 : actualQ.Management_Fee__c)))/actualQ.Rent__c - ((budgetQ.EBITDAR__c + budgetQ.Management_Fee__c)/budgetQ.Rent__c))/((budgetQ.EBITDAR__c + budgetQ.Management_Fee__c)/budgetQ.Rent__c);
                newVariancePercentageFO.Rent_Revenue_var__c = nullZeroCheck(budgetQ.Rent__c) ? 0 : ((nullZeroCheck(actualQ.Total_Revenue__c) ? 0 : actualQ.Rent__c/actualQ.Total_Revenue__c) - (budgetQ.Rent__c/budgetQ.Total_Revenue__c))/(budgetQ.Rent__c/budgetQ.Total_Revenue__c);
                newVariancePercentageFO.Salaries_Revenue_var__c = ((nullZeroCheck(actualQ.Total_Revenue__c) ? 0 : actualQ.Salaries_Benefits__c/actualQ.Total_Revenue__c) - (budgetQ.Salaries_Benefits__c/budgetQ.Total_Revenue__c))/(budgetQ.Salaries_Benefits__c/budgetQ.Total_Revenue__c);
                newFOs.add(newVariancePercentageFO);
            }

        }

        Formula.recalculateFormulas(newFOs);
        // Integer countDollar = 1;
        // Integer countPercent = 1;
        for(Financial__c f : newFOs){
            if (f.Data_Source__c == 'Variance $'){
                budgetActualMap.put(f.Fiscal_Quarter__c + ' Var. $', f);
                // countDollar++;
            }
            if (f.Data_Source__c == 'Variance %'){
                budgetActualMap.put(f.Fiscal_Quarter__c + ' Var. %', f);
                // countPercent++;
            }
        }
    }

    private static Boolean nullZeroCheck(Decimal value){
        return value == 0 || value ==null;
    }

    @AuraEnabled 
    public static List<ContentDocument> getFiles(STring objId) {
        System.debug('****files: ' + objId);
        List<ContentDocument> files =MyItemRowCtlr.getFiles(objId);
        System.debug('**** returning: ' + files);
        return files;
        
    }
    
    /*@AuraEnabled 
    public static String getReportId() {
        return  FinancialsReport__c.getOrgDefaults().ReportId__c;
    }*/
    
    
    private class DataWrapperException extends Exception {}
    
    public class ColumnWrapper {
        @AuraEnabled public String columnname ;
        @AuraEnabled public String objectid ;
        @AuraEnabled public List<ContentDocument> files ;
        private ColumnWrapper(String cname, String objId) {
            columnname = cname;
            objectid = objid;
        }
    }
    //this inner class is the wrapper class which represents a given field (i.e. row ) in the interface
    //it cannot be instantiated outside the getData method
    private class DataWrapper {
        @AuraEnabled public String Name = 'FieldName';
        @AuraEnabled public String helptext = '';
        @AuraEnabled public String FieldType = '';
        @AuraEnabled public Decimal GoodVarianceSign = 1;       //J Caughie - used to calculate if a -ve variance is good or bad.
        @AuraEnabled public String isFormula = '';
        @AuraEnabled public Boolean isDivider = false;
        @AuraEnabled public List<String> columns ;
        @AuraEnabled public Integer screensize ;
        @AuraEnabled public List<ColumnWrapper> columnobjects = new List<ColumnWrapper>();
        @AuraEnabled public Map<Integer, STring> allVals = new Map<Integer,String>(); //this Map is used to index the column (just sequential numbering) to the Value for that column
        @AuraEnabled public Map<Integer, STring> allComments = new Map<Integer,String>(); //this Map is used to index the column (just sequential numbering) to the Value for that column
        @AuraEnabled public Map<Integer, Boolean> allIsNegativeFormula = new Map<Integer,Boolean>();//this Map is used to index the column (just sequential numbering) to whether the val contains a negative value for a Formula Text field (Like EBITDAR Rent Coverage)
        
        private DataWrapper(String fieldName, String stDtfq, String endDtfq, String stDtfy, String endDtfy, String type) {
            	Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.Financial__c.fields.getMap();
            	
            	//name should be the label
            	this.Name = (fieldName.contains('__c') ? fieldMap.get(fieldName).getDescribe().getLabel() : fieldName );
            	
            	//help text
            	this.helptext = ((fieldName.contains('__c') && fieldMap.get(fieldName).getDescribe().getInlineHelpText()!=null) ? fieldMap.get(fieldName).getDescribe().getInlineHelpText() : '' );
            
            	if (!fieldName.contains('__c')) isDivider = True;
            
                //each column has a data value
                Integer i = 0;
            	this.columns = getColumns(stDtfq, endDtfq, stDtfy, endDtfy, type);
            	screensize = (((this.columns.size()>defaultNumColumnsShown?this.columns.size():defaultNumColumnsShown)*headerColumnSize) + headerColumn1Size);
            	
                for (String c : this.columns) {
                    
                    String objid = '';
                    String fiscalQUarter = '';
                    String fiscalYear = '';
                    this.allIsNegativeFormula.put(i,false);
                    
                    System.debug('column: ' + c + ' stDtfy: ' + stDtfy + ' stDtfq: ' + stDtfq);
                    Financial__c found = null;
                    
                    if (monthsMap.keyset().contains(c)) {
                        //find matching Financial record for this FY/Month
                        //FY i.e. 18 = 17-18
                        System.debug('***looking for monthly fin obj: ' +(Integer.valueOf(endDtfy)-1)+'-'+endDtfy+ c);
                        found = monthObjsMap.get((Integer.valueOf(endDtfy)-1)+'-'+endDtfy+c);
                    } else if(type== 'BudgetvActual'){
                        System.debug('***looking for budgetActualMap: ' + (Integer.valueOf(endDtfy)-1)+'-'+endDtfy+' Act.');
                        found = budgetActualMap.get(c);

                        // this 
                    } else {
                        fiscalQUarter = this.getFQFromColumnName(c);
                    	fiscalYear = this.getFYFromColumnName(c);
                        //find matching Financial record for this FQ/FY
                        System.debug('***looking for fin obj: ' + fiscalYear+fiscalQUarter);

                        // testing
                        // String x = fiscalYear+fiscalQUarter;
                        // for(String record : fyFqObjsMap.keySet()) {
                        //     system.debug('@@@# record = ' + record); 
                        //     if(record.Substring(0,record.length()-18) == x) {
                        //         system.debug('@@@# = ' + fyFqObjsMap.get(record)); 
                        //     }
                        // }
                        // testing
                        
                        found = fyFqObjsMap.get(fiscalYear+fiscalQUarter);
                    }
                    
                    if (found==null) {
                        System.debug('Could not find financial record for: ' + fiscalYear+fiscalQUarter+c);
                        //no value for this column
                    } else {
                            objid = found.Id;
                            System.debug('financial record found: ' + found );
                            SObject sObj = (SObject)found;
                            if (fieldName.contains('__c')) {
                                System.debug('fieldName: ' + fieldName);
                                if(negativeVarianceFields.contains(fieldName)){
                                    System.debug('GoodVarianceSign: ' + this.GoodVarianceSign);
                                    this.GoodVarianceSign = -1; 
                                }                           
                                String commentFieldName = fieldName.replaceAll('__c', '')+'_Comment__c';
                                Schema.SObjectField field = fieldMap.get(fieldName);
                                System.debug('fieldType: ' + field.getDescribe().getType());
                                this.FieldType = field.getDescribe().getType()+'';
                                this.isFormula = (field.getDescribe().isCalculated()+'').toUpperCase();
                        
                                if (field.getDescribe().getType()==Schema.DisplayType.Integer) {
                                    this.allVals.put(i,(Integer)sObj.get(fieldName)+'');
                                } else if (field.getDescribe().getType()==Schema.DisplayType.Double) {
                                    this.allVals.put(i,(Decimal)sObj.get(fieldName)+'');
                                } else if (field.getDescribe().getType()==Schema.DisplayType.Picklist) {
                                    this.allVals.put(i,(STring)sObj.get(fieldName)+'');
                                } else if (field.getDescribe().getType()==Schema.DisplayType.STring) {
                                    this.allVals.put(i,(STring)sObj.get(fieldName)+'');
                                    if ( (STring)sObj.get(fieldName)!=null && ((STring)sObj.get(fieldName)).contains('-')) { 
                                        System.debug('********* val: ' + ((STring)sObj.get(fieldName)) + ' contains negative');
                                        this.allIsNegativeFormula.put(i,true);
                                    }
                                } else if (field.getDescribe().getType()==Schema.DisplayType.Currency) {
                                    this.allVals.put(i,(Decimal)sObj.get(fieldName)+'');
                                } else if (field.getDescribe().getType()==Schema.DisplayType.Percent) {
                                    this.allVals.put(i,((Decimal)sObj.get(fieldName)!=null ? (Decimal)sObj.get(fieldName)/100 : null) +'');
                                } else if (field.getDescribe().getType()==Schema.DisplayType.Boolean) {
                                    this.allVals.put(i,sObj.get(fieldName)+'');
                                } else {
                                    System.debug('other val: ' + (STring)sObj.get(fieldName)+'');
                                    this.allVals.put(i,(STring)sObj.get(fieldName)+'');
                                }
                                
                        //System.debug('&&&& field: ' + fieldName + ' val: ' + this.alLVals.get(i));
                        
                                try {
                                    System.debug('comment value: ' + (String)sObj.get(commentFieldName));
                                    this.allComments.put(i,(String)sObj.get(commentFieldName));
                                } catch (EXception e) {
                                    System.debug('comment not found for: ' + commentFieldName + ' ' + e.getmessage() + ' - ' + e.getstacktracestring());
                                }
                           }    
                    }
                    
                    System.debug('*** new column - ' + c + ' - ' + objid);
                    columnobjects.add(new ColumnWrapper(c,objid ));
                    i++;
                    
                }
            
        }
        
        private STring getFQFromColumnName(STring c) {
            // delete id
            if (!c.contains('Q')) {
                //for just year columns there is no FQ
                return '';
            }else {
                STring fq = c.left(2);
                String reverse = '';
                 
                for (Integer i = fq.length()-1; i >= 0; i--)
                {
                    reverse += fq.substring(i, i+1);
                }
                return reverse;
            }
                
    	}
        private STring getFYFromColumnName(STring c) {
                String fy = c.right(2);
                //fy=fy+'-'+(Integer.valueOf(fy)+1)+'';
                fy=(Integer.valueOf(fy)-1)+'-'+fy;
                return fy;
            
    	}
        
    }
}