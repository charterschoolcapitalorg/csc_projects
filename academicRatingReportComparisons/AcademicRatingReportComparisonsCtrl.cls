/**=====================================================================
 * Charter School Capital
 * Name: AcademicRatingReportComparisonsCtrl
 * Test Class: AcademicRatingReportComparisonsCtrlTest
 * Description: 
 * Created Date: []
 * Created By: [] 
 *
 * Date Modified                Modified By                  Description of the update
 * [MON DD, YYYY]             	[FirstName LastName]		 [Short description for changes]
 =====================================================================*/

public with sharing class AcademicRatingReportComparisonsCtrl {

    @AuraEnabled(cacheable=true)
    public static List<SchoolDataWrapper> getSchoolData(String searchKey, String searchOwner){

        system.debug('@@@ searchKey = ' + searchKey);
        system.debug('@@@ searchOwner = ' + searchOwner);

        String leaseSchoolsQueryString = 'SELECT Id, Name, Account_School__r.Name, Account_School__r.Owner_Portfolio_Formula__c, Account_School__r.Grade_Level_Served__c, Account_School__r.Operating_State__r.Name, Lease__r.Property__r.Name, Lease__r.Owner_Portfolio__c, Lease__r.Property__r.Nick_Name__c, Lease_Status__c, Lease__r.Property__r.Equity_Investor__r.Name FROM Lease_School__c ';
        String leaseSchoolsWhereString;
        String active = 'Active';

        List<String> ownerList;
        if(searchOwner == '' || searchOwner == 'All') {
            leaseSchoolsWhereString = ' WHERE Lease_Status__c = '+'\''+active+'\' AND (Off_Date__c >= Today OR Off_Date__c = null) ORDER BY Lease__r.Property__r.Nick_Name__c';
        } else if(searchOwner == 'WFCS I' || searchOwner == 'WFCS II' || searchOwner == 'CSC Owned') {
            ownerList = new List<String>{searchOwner};
            leaseSchoolsWhereString = ' WHERE Lease_Status__c = '+'\''+active+'\' AND (Off_Date__c >= Today OR Off_Date__c = null) AND Lease__r.Owner_Portfolio__c IN : ownerList ORDER BY Lease__r.Property__r.Nick_Name__c';
        }

        leaseSchoolsQueryString += leaseSchoolsWhereString;

        List<SchoolDataWrapper> schoolDataList = new List<SchoolDataWrapper>();
        //Get list of 'Active' Lease Schools
        List<Lease_School__c> leaseSchools = Database.query(leaseSchoolsQueryString);

        //Create list of School Ids
        List<Id> schoolIds = new List<Id>();
        for(Lease_School__c ls : leaseSchools){
            schoolIds.add(ls.Account_School__r.Id);
        }
        
        // String currentYear;

        // system.debug('@@@ myYear = ' + searchKey);
        // system.debug('@@@ myOwner = ' + searchOwner);

        // if (searchKey == '' || searchKey == 'current' || searchKey == ' ' || searchKey == null) {
        //     currentYear = getFY();
        // } else {
        //     currentYear = searchKey;
        // }

        //Create a map of account Id to school with attendance and charter terms records
        Map<Id, Account> idToSchool = new Map<Id, Account>([
            SELECT Id, (SELECT Id, Name, Fiscal_Year__c, Description__c, Total_Attendance__c, Attendance_Type__c, Student_Count_Source__c, Report_Date__c, School__r.Id, School__r.Name 
            FROM School_Attendance__r 
            WHERE RecordType.DeveloperName = 'Facilities' 
            AND Fiscal_Year__c = :searchKey
            ORDER BY School__r.Id, Fiscal_Year__c asc, Report_Date__c desc), (SELECT Start_Date__c, End_Date__c, Days_Left__c, Enrollment_Cap__c, No_Cap_Limit__c FROM Terms__r WHERE Status__c = 'Active') FROM Account WHERE id IN :schoolIds ORDER BY Name]);
		
        List <Academic_Rating__c> schoolARs = [
            SELECT 
                Id, 
                Name, 
                FY__c, 
                CSC_Color_Rating__c, 
                Total_Grade__c, 
                Account__c, 
                Account__r.Name, 
                Academic_Performance_Comparison__c 
            FROM Academic_Rating__c 
            WHERE FY__c = :searchKey
            ORDER BY Account__r.Id, FY__c asc];
    
        Id schoolId;

        for(Lease_School__c ls : leaseSchools){
            SchoolDataWrapper schoolData = new SchoolDataWrapper();
            Account school = idToSchool.get(ls.Account_School__r.Id);
            schoolData.currentFY = searchKey;
            schoolData.PropertyNickName = ls.Lease__r.Property__r.Nick_Name__c;
            schoolData.SchoolName = ls.Account_School__r.Name;
            schoolData.SchoolUrl = Url.getSalesforceBaseUrl().toExternalForm() + '/lightning/r/Account/' + ls.Account_School__r.Id + '/view' ;
            schoolData.StateName = ls.Account_School__r.Operating_State__r.Name;
            schoolData.PropertyOwner = ls.Lease__r.Owner_Portfolio__c;
            schoolData.GradeServed = ls.Account_School__r.Grade_Level_Served__c;

            for(Academic_Rating__c ar : schoolARs){
                if(ar.Account__c == school.Id){
                    schoolData.CRCurrentYear = ar.CSC_Color_Rating__c;
                    schoolData.TGCurrentYear = ar.Total_Grade__c;
                    if(ar.Academic_Performance_Comparison__c != null) {
                        schoolData.Comparisons = ar.Academic_Performance_Comparison__c.replaceAll('<[^>]+>',' ');
                    }
                    
                }
            }

            for(Charter_Term__c ct : school.Terms__r){
                schoolData.CharterExpirationDate = ct.End_Date__c;
            }

            schoolDataList.add(schoolData);
        }
        return schoolDataList;
    }


    public class SchoolDataWrapper{
        @AuraEnabled
        public String StateName{get;set;}
        @AuraEnabled
        public String SchoolName{get;set;}
        @AuraEnabled
        public String PropertyNickName{get;set;}
        @AuraEnabled
        public String PropertyOwner{get;set;}
        @AuraEnabled
        public Date CharterExpirationDate{get;set;}
        @AuraEnabled
        public String GradeServed{get;set;}
        @AuraEnabled
        public String CRCurrentYear{get;set;}
        @AuraEnabled
        public String TGCurrentYear{get;set;}
        @AuraEnabled
        public String Comparisons{get;set;}
        @AuraEnabled
        public String SchoolUrl{get;set;}
        @AuraEnabled
        public String currentFY{get;set;}
    }

    // public static String getFY() {
    //     String currentYear;
    //     Integer year;
    //     if (Date.today().year() == 2022){
    //         year = Date.today().year() - 1;
    //     } else {
    //         if(Date.today().month()>=11){
    //             year = Date.today().year();
    //             } else {
    //             year = Date.today().year() - 1;
    //         }
    //     }
    //     currentYear = String.valueOf(year).right(2) + '-' + String.valueOf(year + 1).right(2);
    //     return currentYear;
    // }
}