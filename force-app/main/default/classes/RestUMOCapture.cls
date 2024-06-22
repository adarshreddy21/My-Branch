/**
 * @description       : 
 * @author            : Irfan Khan
 * @group             : 
 * @last modified on  : 01-09-2023
 * @last modified by  : Irfan Khan
**/
@RestResource(urlMapping = '/CreateUMOCapture/*')

global class RestUMOCapture {
    
    @HttpPost
    
    global static void createnewUMOcapture(){
        
        RestRequest request = RestContext.request;
        
        RequestWrapper reqWrapper = (RequestWrapper)JSON.deserialize(request.requestbody.tostring(), RequestWrapper.class);
                
        try{
            
            Competitor_Capture__c ccObj = new Competitor_Capture__c();
            
            List<Account> accs = new List<Account>();
            accs = [Select Id, Name, OwnerId from Account where WIN_ID__c =:reqWrapper.CUST_ID LIMIT 1];
            if(!accs.isEmpty()){
                ccObj.Account__c = accs[0].Id; 
            }
            
            List<Account> compAccs = new List<Account>();
            compAccs = [Select Id, Name, OwnerId from Account where WIN_ID__c =:reqWrapper.COMPTR_CUST_ID LIMIT 1];
            if(!compAccs.isEmpty()){
                ccObj.Competitor_Account__c = compAccs[0].Id; 
            }
            
            ccObj.Comments__c = reqWrapper.COMMENTS;
            ccObj.CurrencyIsoCode = reqWrapper.CURRENCY_CODE;
            ccObj.Oil_Filter_Prices__c = Decimal.ValueOf(reqWrapper.OIL_FILTER_PRICE);
            ccObj.Oil_Filter_Price__c = reqWrapper.FILTER_PRICE_TYPE;
            ccObj.Invoice_or_Proposal_date__c = (Date.valueOf(reqWrapper.INVOICE_OR_PROP_DT));
            ccObj.Pay_or_Charge__c = reqWrapper.PAYORCHARGE;
            ccObj.Product_Packaging__c = reqWrapper.PROD_PACKG;
            ccObj.RecordTypeId = '012j00000004WMl';
            ccObj.Price_per_UOM__c = Decimal.ValueOf(reqWrapper.UOMPRICE);
            ccObj.Unit_of_Measure__c = reqWrapper.UNITS;
            ccObj.Waste_AF_Price_per_Gallon__c = (Decimal.ValueOf(reqWrapper.WASTE_PRICE));
            ccObj.Annual_UMO_Volume__c = Decimal.ValueOf(reqWrapper.ANNUAL_GALLONS);
            ccObj.CreatedBy_Username__c = reqWrapper.CREATEDBY_USERNAME;
            
            
            insert ccObj;
            
            string Name;
            List<Competitor_Capture__c> cCapt= [select Id,Name from Competitor_Capture__c where Id=: ccObj.Id];
            for(Competitor_Capture__c c: cCapt) {  Name = c.Name;}     RestContext.response.responseBody = Blob.valueOf('{"CompCaptureId" :"' +ccObj.Id+'","Error":"","Comp Capture":"'+Name+'"}');
        }
            	
        
        catch (Exception e){
            system.debug('---'+e.getLineNumber());
            RestContext.response.responseBody = Blob.valueOf('{"CompCap_Id":"","Error":"'+ e.getMessage() +'","CompCaptureId":""}');
        }
    }
        

    global class RequestWrapper{
        
        public String CUST_ID;
        public String COMPTR_CUST_ID;
        public String COMMENTS;
               
        
        public String CREATED_DATE;
        public String CURRENCY_CODE;
        public String OIL_FILTER_PRICE;
        public String FILTER_PRICE_TYPE;
        public String PAYORCHARGE;
        public String UOMPRICE;
        public String PROD_PACKG;
        
        
        //public String REC_TYPEID;
        public String UNITS;
        public String WASTE_PRICE;
        public String INVOICE_OR_PROP_DT;
        public String ANNUAL_GALLONS;
        public String CREATEDBY_USERNAME;
        
    }
}