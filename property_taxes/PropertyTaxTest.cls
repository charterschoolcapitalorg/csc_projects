@isTest
public with sharing class PropertyTaxTest {
    @testSetup
    static void setup() {
        //create parcel
        Parcel__c parcel = new Parcel__c();
        parcel.Current_Tax_Year__c = '2022';
        insert parcel;

        //create property tax record
		Property_Tax__c propTax = new Property_Tax__c();
		propTax.Property_Tax_Status__c = 'Finalized';
        propTax.Parcel__c = parcel.id;
        //propTax.Property__c = property.id;
        propTax.Tax_Year_Number__c = '2022';
        propTax.Next_record_trigger_days__c = 60;
        propTax.X1st_Tax_Due_Date__c = Date.newInstance(Date.today().year(), Date.today().month(), Date.today().day() - 305);
        propTax.Non_School_Occupied__c = false;
		insert propTax;

        system.debug('@@@ property Tax status = ' + propTax.Property_Tax_Status__c);
        
    }

    @isTest 
    static void test() {
        Test.startTest();
        Database.executeBatch(new PropertyTax());
        Test.stopTest();
    }
}