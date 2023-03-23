/**=====================================================================
 * Charter School Capital
 * Name: RescorePricingRateController
 * Test Class: RescorePricingRateControllerTest
 * Description: 
 * Created Date: 2023, Jan 05
 * Created By: Slava Krel
 *
 * Date Modified                Modified By                  Description of the update
 * [MON DD, YYYY]             	[FirstName LastName]		 [Short description for changes]
 =====================================================================*/
public without sharing class RescorePricingRateController {
    
    private static final String CLASS_NAME = 'RescorePricingRateController';

    @AuraEnabled
	public static List<Object> whatToRescore(Id pRateId) {
        // ExceptionLogger.flushable = true;
        List<Object> respObjs = new List<Object>();

        try {
            PricingRateScore score = new PricingRateScore(pRateId);
            ResponseObject respObj = new ResponseObject('score', score);
            respObjs.add(respObj);
        } catch (Exception e) {
            // ResponseObject errObj = new ResponseObject('error', e);
            // respObjs.add(errObj);
            // ExceptionLogger.log(e, 'Pricing_Rate__c', CLASS_NAME, 'whatToRescore');
        }

        // ExceptionLogger.flushLogCache();
        return respObjs;
    }

    @AuraEnabled
	public static PricingRateScore rescoreRate(Id pRateId) { 
        System.debug('START: Apex rescore ctrl fires');
        PricingRateScore score = new PricingRateScore(pRateId);
        score.rescore();
        System.debug('FINISH: Apex rescore ctrl finishes');
        return score;
    }

    @AuraEnabled
	public static List<Object> getFieldSets() {
        List<Object> respObjs = new List<Object>();

        try {
            // List<FieldSetUtility.FieldDescription> cRateFlds = FieldSetUtility.getFieldSetFields('RescorePageChildRates', 'Pricing_Rate__c');
            // ResponseObject respObj = new ResponseObject('cRateFlds', cRateFlds);
            // respObjs.add(respObj);  
        } catch (Exception e) {
            // ExceptionLogger.log(e, 'Pricing_Rate__c', CLASS_NAME, 'getFieldSets');
            // ResponseObject respObj = new ResponseObject('error', e);
            // respObjs.add(respObj); 
        }

        try {
            // List<FieldSetUtility.FieldDescription> rateFields = FieldSetUtility.getFieldSetFields('RescorePageRateDetails', 'Pricing_Rate__c');
            // ResponseObject respObj = new ResponseObject('rateFields', rateFields);
            // respObjs.add(respObj);  
        } catch (Exception e) {
            // ExceptionLogger.log(e, 'Pricing_Rate__c', CLASS_NAME, 'getFieldSets');
            // ResponseObject respObj = new ResponseObject('error', e);
            // respObjs.add(respObj); 
        }

        try {
            // List<FieldSetUtility.FieldDescription> mRateFields = FieldSetUtility.getFieldSetFields('RescorePageMRateDetails', 'Market_Rate__c');
            // ResponseObject respObj = new ResponseObject('mRateFields', mRateFields);
            // respObjs.add(respObj);  
        } catch (Exception e) {
            // ExceptionLogger.log(e, 'Market_Rate__c', CLASS_NAME, 'getFieldSets');
            // ResponseObject respObj = new ResponseObject('error', e);
            // respObjs.add(respObj); 
        }

        // ExceptionLogger.flushLogCache();
        return respObjs;
	}

    public class ResponseObject {
        @AuraEnabled
        public String type { get; set; }
        @AuraEnabled
        public String recId { get; set; }
        @AuraEnabled
        public Object obj { get; set; }

        public ResponseObject(String type, Object obj) {
            this.type = type;
            this.obj = obj;
            this.recId = '';
        }

        public ResponseObject(String type, String recId, Object obj) {
            this.type = type;
            this.obj = obj;
            this.recId = recId;
        }
    }
}