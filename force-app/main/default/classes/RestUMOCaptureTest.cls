@isTest
public class RestUMOCaptureTest {
    
    private static testmethod void CreateUMOCaptureTest(){
        
        TERRITORY_MANAGEMENT__c territoryMgmt = new TERRITORY_MANAGEMENT__c();
        territoryMgmt.Name = 'TERRITORY_MGMT_SETTING';
        territoryMgmt.TM_FLAG__c = true;
        insert territoryMgmt;
        
        SIC_VALIDATION_SETTING__c sicValidation = new SIC_VALIDATION_SETTING__c();
        sicValidation.Name = 'SIC_VALIDATION_SETTING';
        sicValidation.SIC_VALIDATION_FLAG__c = true;
        insert sicValidation;
        
        List<SIC_Codes__c> sicList = new List<SIC_Codes__c>();
        SIC_Codes__c sicObj = new SIC_Codes__c(SIC_Code__c =  '0111', Class__c = 'Agricultural Production');
        sicList.add(sicObj);
        
        sicObj = new SIC_Codes__c(SIC_Code__c =  '0112', Class__c = 'Agricultural Production');
        sicList.add(sicObj);
        insert siclist;
        
        Id accRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        Account acc = new Account(Name = 'Test ', Business_Type__c = 'Base', AccountSource = 'Phone', CS_EPA_ID__c = '12345', Sic = '0111', RecordTypeId = accRecTypeId,                               
                                  Rank__c = 'CH A Large >200K', Reporting_Vertical__c = 'Automotive', Industry_Segment__c = 'Automotive', Class__c = 'Agricultural Production', WIN_ID__c = 'AC5255'
                                 ); 
        
        insert acc;
        
        Account acc1 = new Account(Name = 'Test2', Business_Type__c = 'Base', AccountSource = 'Phone', CS_EPA_ID__c = '12345', Sic = '0112', RecordTypeId = accRecTypeId,                               
                                   Rank__c = 'CH A Large >200K', Reporting_Vertical__c = 'Automotive', Industry_Segment__c = 'Automotive', Class__c = 'Agricultural Production',
                                   WIN_ID__c = 'AB4523'                                   ); 
        
        insert acc1;
        
        RestUMOCapture.RequestWrapper reqObj = new RestUMOCapture.RequestWrapper();
        reqObj.CUST_ID = 'AC5255';
        reqObj.COMPTR_CUST_ID = 'AB4523';
        reqObj.COMMENTS = 'TEST COMMENTS';
        reqObj.CURRENCY_CODE = 'USD';
        reqObj.OIL_FILTER_PRICE = '1222';
        reqObj.FILTER_PRICE_TYPE = 'Bin';
       
        reqObj.PAYORCHARGE = 'PFO';
        reqObj.PROD_PACKG = 'Bulk';
        //reqObj.REC_TYPEID = '012j00000004WMlAAM';
        reqObj.UOMPRICE = '80122.1';
        reqObj.UNITS = 'Liters';
        reqObj.WASTE_PRICE = '99921';
        reqObj.INVOICE_OR_PROP_DT = '2020-01-04';
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/CreateUMOCapture/*';
        req.httpMethod = 'POST';
        req.requestBody = Blob.ValueOf(JSON.serialize(reqObj));
        RestContext.request = req;
        RestContext.response = res;
        RestUMOCapture.createnewUMOcapture();
        
    }
}