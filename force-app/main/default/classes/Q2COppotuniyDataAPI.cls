@RestResource(urlMapping = '/Q2COppotuniyData/*')
global class Q2COppotuniyDataAPI {
@HttpPost
    global static void getQ2COppData(){
        RestResponse res = RestContext.response;
       
        res.statusCode = 200;
        res.addHeader('Content-Type', 'application/json');
       
        RestRequest req = RestContext.request;
       
        String reqBody = req.requestBody.toString();
        Q2COpportunityDataRequest Q2COppReq =
            (Q2COpportunityDataRequest)JSON.deserialize(reqBody, Q2COpportunityDataRequest.class);
        
        Boolean isError = false;
       
        List<Account> accountLst = [
            SELECT Id, Account_Owner_Sales_Branch__c, OwnerId
            FROM Account
            WHERE WIN_ID__c = :Q2COppReq.OpportunityGeneratorCoCd
        ];
       
        List<Q2COpportunityDataWrapper> q2cDataWrapLst = new List<Q2COpportunityDataWrapper>();
       
        if(accountLst.size() > 0){
            Account accountRec = accountLst[0];
           
            List<Opportunity> oppLst = [
                SELECT Id
                FROM Opportunity
                WHERE AccountId = :accountRec.Id
                AND RecordType.DeveloperName = 'Safety_Kleen_BPS_Opportunity'
                AND IsClosed = FALSE 
                ORDER BY CreatedDate DESC
            ];
           
            String productHierarchyNum = '';
            for(OpportunityLineItem oppLineItemObj : [
                SELECT Id, Product2.Product_Hierarchy_Number__c, Opportunity.Name,Opportunity.Description, Opportunity.Creator_ID__c, Opportunity.CreatedDate,
                Opportunity.Opp_Strength__c, OpportunityId, Opportunity.Creator_username__c
                FROM OpportunityLineItem
                WHERE OpportunityId IN :oppLst
                AND Product2Id != NULL
                AND Product2.Product_Hierarchy_Number__c != NULL
                AND Opportunity.Creator_ID__c !=null
            ]){
                productHierarchyNum = oppLineItemObj.Product2.Product_Hierarchy_Number__c;
              
                Q2COpportunityDataWrapper q2cDataWrap = new Q2COpportunityDataWrapper();
                q2cDataWrap.OpportunityNumber = oppLineItemObj.Opportunity.id;
                q2cDataWrap.OpportunityPHNumber = oppLineItemObj.Product2.Product_Hierarchy_Number__c;
                q2cDataWrap.OpportunityCreatorId = oppLineItemObj.Opportunity.Creator_ID__c;
                q2cDataWrap.OpportunityCreatorUsername = oppLineItemObj.Opportunity.Creator_username__c;
                q2cDataWrap.OpportunityCreationDate = oppLineItemObj.Opportunity.CreatedDate;
                q2cDataWrap.OpportunityStrength = oppLineItemObj.Opportunity.Opp_Strength__c;
                q2cDataWrap.OpportunityComments =oppLineItemObj.Opportunity.Description;
                q2cDataWrap.OpportunityURL =  URL.getSalesforceBaseUrl().toExternalForm()+'/'+oppLineItemObj.OpportunityId;
               
                q2cDataWrapLst.add(q2cDataWrap);
            }
            
        }else{
            Q2COpportunityDataResponse salesOppRes = new Q2COpportunityDataResponse();
            salesOppRes.message = 'No Account found for the particular win id.';
            salesOppRes.status = 'Error';
            res.responseBody = Blob.valueOf(JSON.serialize(salesOppRes));
            isError = true;
        }
       
		if(!isError)
        	res.responseBody = Blob.valueOf(JSON.serialize(q2cDataWrapLst));
    }
   
    public class Q2COpportunityDataRequest{
        public String OpportunityGeneratorCoCd;
    }
   
    public class Q2COpportunityDataWrapper{
        public String OpportunityNumber;
        public String OpportunityPHNumber;
        public String OpportunityCreatorId;
        public String OpportunityCreatorUsername;
        public DateTime OpportunityCreationDate;
        public String OpportunityStrength;
        public String OpportunityURL;
        public String OpportunityComments;
    }
    
    public class Q2COpportunityDataResponse{
        public String message;
        public String status;
    }
}