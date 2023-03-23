/**=====================================================================
 * Charter School Capital
 * Name: PricingRateScore
 * Test Class: PricingRateScoreTest
 * Description: 
 * Created Date: 2023, Jan 05
 * Created By: Slava Krel
 *
 * Date Modified                Modified By                  Description of the update
 * [MON DD, YYYY]             	[FirstName LastName]		 [Short description for changes]
 =====================================================================*/
public inherited sharing class PricingRateScore {

    @AuraEnabled
    public List<Pricing_Rate__c> childRates { get; set; }
    @AuraEnabled
    public Boolean isPortfolio { get; set; }
    @AuraEnabled
    public Pricing_Rate__c rateScoring { get; set; }
    private Set<Id> schoolIds { get; set; }
    @AuraEnabled
    public Map<String, String> errors { get; set; }
    private Map<Id, Charter_Term__c> schoolToTermMap { get; set; } 

    // constructor
    public PricingRateScore(Id pRateId) {
        this.rateScoring = fetchPricingRateDetails(pRateId);

        if(this.rateScoring.RecordType.DeveloperName == 'School') {
            system.debug('!!! it s a school');
            this.childRates = new List<Pricing_Rate__c>();
            this.isPortfolio = false;
            this.schoolIds = new Set<Id>();
            this.schoolIds.add(this.rateScoring.Account__c);
        }
        
        if (this.rateScoring.RecordType.DeveloperName == 'Portfolio') {
            system.debug('!!! it s a portfolio');
            this.isPortfolio = true;
            this.childRates = fetchPricingRateDetailsPortfolio(pRateId);
            this.schoolIds = new Set<Id>();
            for (Pricing_Rate__c cRate : this.childRates) {
                this.schoolIds.add(cRate.Account__c);
            }
        }
    }


    public void rescore() {
        
        Pricing_Rate__c prToUpdate = new Pricing_Rate__c();
        this.rateScoring.Rescored__c = true;
        //prToUpdate = this.rateScoring;
        Map<Id, Account> schools = new Map<Id, Account>(fetchSchoolInformation(this.schoolIds));
        buildcharterTermsMap(this.schoolIds);

        // school rescore
        if(this.rateScoring.RecordType.DeveloperName == 'School') {
            // set charter terms
            setCharterTerm(this.rateScoring);

            // set current student count
            if(string.isNotEmpty(this.rateScoring.Account__c)) {
                Account schSchool = schools.get(this.rateScoring.Account__c);
                setCurrentStudentCounts(this.rateScoring, schSchool.School_Attendance__r);
            }

        // portfolio rescore
        } else if(this.rateScoring.RecordType.DeveloperName == 'Portfolio') {
            List<Charter_Term__c> renewedAcct = new List<Charter_Term__c>();
            List<Charter_Term__c> nonrenewedAcct = new List<Charter_Term__c>();
            //Integer recordCount = 0;
            Integer yesRecordCount = 0;
            Integer noRecordCount = 0;

            // convert 18 digit into 15 digit id
            system.debug('@@@ rateScoring.Account__c = ' + rateScoring.Account__c);
            String fifteenDigitAcctId = String.valueOf(rateScoring.Account__c).substring(0, 15);

            // quering Schools on Charter/Business (not schools on pricing rate)
            List<Account> acctList = [
                SELECT 
                Id, 
                Name
                FROM Account 
                WHERE Top_Level_Parent_Account_Id__c =: fifteenDigitAcctId 
                AND WC_Client_Pricing_School__c = true];

            system.debug('!!! acctList = ' + acctList);

            List<Charter_Term__c> chtList = [
                SELECT 
                Id, 
                Type__c 
                FROM Charter_Term__c 
                WHERE Status__c = 'Active' 
                AND School__r.Top_Level_Parent_Account_Id__c =: fifteenDigitAcctId 
                AND School__r.WC_Client_Pricing_School__c = true];

            system.debug('!!! chtList = ' + chtList);

            // set charter terms
            for(Charter_Term__c chTerm : chtList) {
                if(chTerm != null && chTerm.Type__c != null) {
                    if(chTerm.Type__c == 'Initial' || chTerm.Type__c == 'Extension') {
                        noRecordCount = noRecordCount + 1;
                        nonrenewedAcct.add(chTerm);
                    } else if(chTerm.Type__c == 'Renewal') {
                        yesRecordCount = yesRecordCount + 1;
                        renewedAcct.add(chTerm);
                    }
                }
            }
            if(!renewedAcct.isEmpty() && !nonrenewedAcct.isEmpty()) {
                this.rateScoring.Charter_Renewed__c = 'Partial';
            } else if(!nonrenewedAcct.isEmpty() && nonrenewedAcct.size() == noRecordCount) {
                this.rateScoring.Charter_Renewed__c = 'No';
            } else if(!renewedAcct.isEmpty() && renewedAcct.size() == yesRecordCount) {
                this.rateScoring.Charter_Renewed__c = 'Yes';
            }


            // set current student count
            // the value that essentially will be displayed 
            // TODO: rename variable
            Decimal xToSet = 0;
            Decimal yToSet = 0;
            Decimal zToSet = 0;

            // store the values from each school
            List<Decimal> studentCountCFYList = new List<Decimal>();
            List<Decimal> studentCount1FYPriorList = new List<Decimal>();
            List<Decimal> studentCount2FYPriorList = new List<Decimal>();

            // record count
            Integer i = 0;

            for(Account acct : acctList) {

                i = i + 1;

                // record index -- will show where to stop adding student counts
                Integer indexOneYearPrior;
                Integer indexTwoYearPrior;

                // student count values per school
                Decimal studentCountCFY = 0;
                Decimal studentCount1FYPrior = 0;
                Decimal studentCount2FYPrior = 0;

                List<School_Attendance__c> saList = [
                    SELECT 
                    Id, 
                    Total_Attendance__c, 
                    Report_Date__c,
                    Fiscal_Year__c 
                    FROM School_Attendance__c 
                    WHERE School__c =: acct.id
                    AND Total_Attendance__c != null
                    AND Fiscal_Year__c != null
                    ORDER BY Report_Date__c DESC];

                for(School_Attendance__c x : saList) {
                    system.debug('@@@ x = ' + x);
                }
                

                if(!saList.isEmpty()) {
                    studentCountCFY = studentCountCFY + saList[0].Total_Attendance__c;
                    system.debug('@@@ studentCountCFY = ' + studentCountCFY);
                    
                    // building logic on report date
                    Integer curFY;
                    if(saList[0].Report_Date__c.month() >= 7) {
                        curFY = saList[0].Report_Date__c.year() + 1;
                    } else {
                        curFY = saList[0].Report_Date__c.year();
                    }

                    Integer fy1Prior = curFY - 1;
                    Integer fy2Prior = curFY - 2;

                    for(School_Attendance__c sa : saList) {
                        if(sa.Report_Date__c.month() < 7 && sa.Report_Date__c.year() == fy1Prior && sa.Total_Attendance__c != null && indexOneYearPrior == null) {
                            indexOneYearPrior =+ 1;
                            studentCount1FYPrior = studentCount1FYPrior + sa.Total_Attendance__c;
                        }
                        if(sa.Report_Date__c.month() < 7 && sa.Report_Date__c.year() == fy2Prior && sa.Total_Attendance__c != null && indexTwoYearPrior == null) {
                            indexTwoYearPrior =+ 1;
                            studentCount2FYPrior = studentCount2FYPrior + sa.Total_Attendance__c;
                        }
                    }

                    // check values
                    system.debug('===================================================');
                    system.debug('!!! record = ' + i);
                    system.debug('!!! acct.name = ' + acct.name);
                    system.debug('!!! studentCountCFY = ' + studentCountCFY);
                    system.debug('!!! studentCount1FYPrior = ' + studentCount1FYPrior);
                    system.debug('!!! studentCount2FYPrior = ' + studentCount2FYPrior);
                    system.debug('===================================================');

                    studentCountCFYList.add(studentCountCFY);
                    studentCount1FYPriorList.add(studentCount1FYPrior);
                    studentCount2FYPriorList.add(studentCount2FYPrior);
                }
            }

            if(!studentCountCFYList.isEmpty()) {
                for(Decimal x : studentCountCFYList) {
                    xToSet = xToSet + x;
                }
            }

            if(!studentCount1FYPriorList.isEmpty()) {
                for(Decimal y : studentCount1FYPriorList) {
                    yToSet = yToSet + y;
                }
            }

            if(!studentCount2FYPriorList.isEmpty()) {
                for(Decimal z : studentCount2FYPriorList) {
                    zToSet = zToSet + z;
                }
            }

            this.rateScoring.Student_Count_Current_FY__c = xToSet;
            this.rateScoring.Student_Count_1_FY_Prior__c = yToSet;
            this.rateScoring.Student_Count_2_FY_Prior__c = zToSet;

        }
        
        prToUpdate = this.rateScoring;

        system.debug('!!! prToUpdate = ' + prToUpdate);
        update prToUpdate;
    }

    private void setCharterTerm(Pricing_Rate__c pRate) {
        if (this.schoolToTermMap.containsKey(pRate.Account__c)) {
            Charter_Term__c ct = this.schoolToTermMap.get(pRate.Account__c);
            pRate.Charter_Term_Record__c = ct.Id;

            if (String.isEmpty(ct.Type__c)) {
                pRate.Charter_Renewed__c = null;
            }
            else if (ct.Type__c == 'Initial' || ct.Type__c == 'Extension') {
                pRate.Charter_Renewed__c = 'No';
            }
            else if (ct.Type__c == 'Renewal') {
                pRate.Charter_Renewed__c = 'Yes';
            }
        }
        else {
            pRate.Charter_Term_Record__c = null;
            pRate.Charter_Renewed__c = null;
        }
    }

    private void setCurrentStudentCounts(Pricing_Rate__c pRate, List<School_Attendance__c> studCnts) { 

        if (studCnts.isEmpty()) return;

        School_Attendance__c mstRcntAttend;
        School_Attendance__c lstYrAttend;
        School_Attendance__c twoYrAttend;

        mstRcntAttend = studCnts[0];

        if (mstRcntAttend.Fiscal_Year__c==null) {
            return;
        }

        pRate.Student_Count_Record__c = mstRcntAttend.Id;
        pRate.Student_Count_Current_FY__c = mstRcntAttend.Total_Attendance__c; 

        String actFY = mstRcntAttend.Fiscal_Year__c;
        String curFYStrt = actFY.substringBefore('-');
        String curFYEnd = actFY.substringAfter('-');
        Integer currentFYStart = Integer.valueOf(curFYStrt); 
        Integer currentFYEnd = Integer.valueOf(curFYEnd);
        String lastFY = String.valueOf(currentFYStart-1)+'-'+String.valueOf(currentFYEnd-1);
        String twoLastFY = String.valueOf(currentFYStart-2)+'-'+String.valueOf(currentFYEnd-2);

        for (School_Attendance__c sc : studCnts) {
            if (sc.Fiscal_Year__c==lastFY && (lstYrAttend==null || lstYrAttend.Report_Date__c <sc.Report_Date__c)) {
                lstYrAttend = sc;
            }
            if (sc.Fiscal_Year__c==twoLastFY && (twoYrAttend==null || twoYrAttend.Report_Date__c <sc.Report_Date__c)) {
                twoYrAttend = sc;
            }
        }

        if (lstYrAttend!=null) {
            pRate.Student_Count_1_FY_Prior__c = lstYrAttend.Total_Attendance__c;
        }
        if (twoYrAttend!=null) {
            pRate.Student_Count_2_FY_Prior__c = twoYrAttend.Total_Attendance__c;
        }

    }

    private void buildcharterTermsMap(Set<id> schoolIds) {
        this.schoolToTermMap = new Map<Id, Charter_Term__c>();
        List<Charter_Term__c> chTermList = [
            SELECT Id, 
            Type__c, 
            School__c 
            FROM Charter_Term__c 
            WHERE School__c IN: schoolIds 
            AND Status__c = 'Active'];

        for (Charter_Term__c ct : chTermList) {
            schoolToTermMap.put(ct.School__c, ct);
        }
    }

    // two query methods below: one for list and one for a single record
    private static Pricing_Rate__c fetchPricingRateDetails(Id pRateId) {
        String prRateQueryString = 'SELECT Id, Name, Portfolio_Rate_Record__c, Account__c, Final_Discount_Rate_Portfolio__c, RecordTypeId, RecordType.DeveloperName, Account__r.Name, Account__r.RecordTypeId, Account__r.RecordType.DeveloperName,Account__r.WC_Client_Pricing_School__c,Charter_Terms_Record__c, Market_Rate__c, Market_Rate__r.One_Month_Index_Rate__c, Market_Rate__r.Three_Month_Index_Rate__c, Market_Rate__r.Six_Month_Index_Rate__c,Charter_Renewed__c,Student_Count_Current_FY__c FROM Pricing_Rate__c';
        String whereString = ' WHERE Id =: pRateId';
        prRateQueryString += whereString;
        //system.debug('@@@ prRateQueryString = ' + prRateQueryString);
        Pricing_Rate__c prRateRecord = Database.query(prRateQueryString);
        return prRateRecord;
    }

    private static List<Pricing_Rate__c> fetchPricingRateDetailsPortfolio(Id pRateId) {
        String prRateQueryString = 'SELECT Id, Name, Portfolio_Rate_Record__c, Account__c, Final_Discount_Rate_Portfolio__c, RecordTypeId, RecordType.DeveloperName, Account__r.Name, Account__r.RecordTypeId, Account__r.RecordType.DeveloperName,Account__r.WC_Client_Pricing_School__c,Charter_Terms_Record__c, Market_Rate__c, Market_Rate__r.One_Month_Index_Rate__c, Market_Rate__r.Three_Month_Index_Rate__c, Market_Rate__r.Six_Month_Index_Rate__c,Charter_Renewed__c,Student_Count_Current_FY__c FROM Pricing_Rate__c';
        String whereString = ' WHERE Portfolio_Rate_Record__c =: pRateId';
        prRateQueryString += whereString;
        List<Pricing_Rate__c> prRateRecordList = Database.query(prRateQueryString);
        return prRateRecordList;
    }

    private static List<Account> fetchSchoolInformation(Set<Id> schoolIds) { 
        return [
                    SELECT Id, FDA_County__c, 
                        (
                            SELECT Id, 
                            School__c, 
                            Report_Date__c, 
                            Fiscal_Year__c, 
                            Is_Active__c, 
                            Total_Attendance__c, 
                            Total_Students__c
                            FROM School_Attendance__r 
                            ORDER BY Report_Date__c DESC
                            LIMIT 10
                        )
                    FROM Account 
                    WHERE Id IN: schoolIds 
                ];
    }
}