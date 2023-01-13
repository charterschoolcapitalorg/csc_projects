@isTest
public with sharing class PropertyTaxHandlerTest {

    @testSetup
    private static void setup() {
        Account charterHolderAcct = TestDiligenceUtils.getCharterHolder();
        insert charterHolderAcct;

        Account schoolAcct = TestDiligenceUtils.getSchool(charterHolderAcct);
        insert schoolAcct;

        Intake_Item__c ii = TestDiligenceUtils.getOngoingDiligenceItem(schoolAcct);
        ii.Client_Comments__c = 'Test Client Comment';
        ii.Status__c = 'Submitted';
        insert ii;

        ContentVersion file = TestDiligenceUtils.getFile(ii);
        insert file;

        CSC_Action_List__c actionList = TestDiligenceUtils.getActionList(schoolAcct);
        insert actionList;

        CSC_Action_Item__c actionItem = TestDiligenceUtils.getActionItem(actionList);
        insert actionItem;

        Account prop = TestDiligenceUtils.getProperty();
        insert prop;

        Lease__c lease = TestDiligenceUtils.getLease(prop);
        lease.Lease_Status__c = 'Active';
        lease.recordtypeid = '0120g000000l48pAAA';
        insert lease;

        Lease_School__c leaseSchool = TestDiligenceUtils.getLeaseSchool(lease, schoolAcct);
        insert leaseSchool;

        //create parcel
        Parcel__c parcel = new Parcel__c();
        parcel.Current_Tax_Year__c = '2022';
        insert parcel;

        //create property tax record
		Property_Tax__c propTax = new Property_Tax__c();
		propTax.Property_Tax_Status__c = 'Draft';
        propTax.Parcel__c = parcel.id;
        propTax.Property__c = prop.id;
        propTax.Tax_Year_Number__c = '2022';
        propTax.Next_record_trigger_days__c = 60;
		insert propTax;
    }

    @isTest
    private static void testUpdatePropertyTax() {
        Property_Tax__c pt = [ SELECT Id, Property_Tax_Status__c FROM Property_Tax__c ];
        system.debug(pt);
        pt.Property_Tax_Status__c = 'Active';
        update pt;
    }
}