@RestResource(urlMapping = '/CreateSalesOpportunity/*')
global class CreateSalesOpportunityAPI {
	@HttpPost
    global static void createOpportunity(){
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        Boolean isFound = false;
        Savepoint sp = Database.setSavepoint(); 
        String reqBody = req.requestBody.toString();
        SalesOpportunityRequest salesOpportunityRequestObj =
            (SalesOpportunityRequest)JSON.deserialize(reqBody, SalesOpportunityRequest.class);
        
        CreateSalesOpportunityRequest oppReqObj = salesOpportunityRequestObj.SaveOpportunityData;
        
        List<SalesOpportunityResponse> salesOppResLst = new List<SalesOpportunityResponse>();
        
        Set<String> winIdSet = new Set<String>();
        
        Map<String, Account> accountMap = new Map<String, Account>();
        for(Account accountObj : [
            SELECT Id, Account_Owner_Sales_Branch__c, OwnerId,Owner.IsActive, WIN_ID__c, Owner.Sales_Person_Type__c, Secondary_Owner__c, ShippingCountry,Primary_Service_Provider_New__c,Primary_Business__c,ZIP_Master__c,ZIP_Master__r.CHES_Region__c, Primary_SK_Branch__c 
            FROM Account
            WHERE WIN_ID__c = :oppReqObj.OpportunityGeneratorCoCd
        ]){
            accountMap.put(accountObj.WIN_ID__c, accountObj);
        }
        
        String isoCode = 'USD';
        if(
            accountMap.containsKey(oppReqObj.OpportunityGeneratorCoCd) 
            && accountMap.get(oppReqObj.OpportunityGeneratorCoCd).ShippingCountry == 'CA'
        ){
            isoCode = 'CAD';
        }
        
        for(OpportunityLineItem oppLineItemObj : [
            SELECT Id, Opportunity.Account.WIN_ID__c, Product2.Product_Hierarchy_Number__c
            FROM OpportunityLineItem
            WHERE Opportunity.Account.WIN_ID__c = :oppReqObj.OpportunityGeneratorCoCd
            AND Product2.Product_Hierarchy_Number__c IN :oppReqObj.OpportunityPHNumber
            AND Opportunity.IsClosed = FALSE
        ]){
            winIdSet.add(oppLineItemObj.Opportunity.Account.WIN_ID__c.toLowerCase() + '-' + oppLineItemObj.Product2.Product_Hierarchy_Number__c);
        } 
        
        Map<String, Product2> productMap = new Map<String, Product2>();
        for(Product2 prodObj : [
            SELECT Id, Product_Hierarchy_Number__c, Name 
            FROM Product2 
            WHERE Product_Hierarchy_Number__c IN :oppReqObj.OpportunityPHNumber
        ]){
            productMap.put(prodObj.Product_Hierarchy_Number__c, prodObj);
        }
        
        List<PricebookEntry> pbEntLst = [
            SELECT Id, PriceBook2Id, Product2Id  
            FROM PricebookEntry 
            WHERE Product2Id IN :productMap.values() 
            AND CurrencyISOCode = :isoCode 
            AND PriceBook2.Name = 'Safety-Kleen / BPS'
            AND IsActive = TRUE
        ];
        
        Map<Id, PricebookEntry> priceBookEntryMap = new Map<Id, PricebookEntry>();
        for(PricebookEntry pbEntryObj : pbEntLst){
            priceBookEntryMap.put(pbEntryObj.Product2Id, pbEntryObj);
        }
        
        if(accountMap.size() == 0){
            SalesOpportunityResponse salesOppRes = new SalesOpportunityResponse();
            salesOppRes.OpportunityPHNumber = '';
            salesOppRes.message = 'No Account found for the particular win id.';
            salesOppRes.status = 'Error';
            salesOppResLst.add(salesOppRes);
        }else{
        	            
            Map<String, Opportunity> newOppMap = new Map<String, Opportunity>();
            for(String phNumber : oppReqObj.OpportunityPHNumber){
                String key = oppReqObj.OpportunityGeneratorCoCd.toLowerCase() + '-' + phNumber;
                
                if(!winIdSet.contains(key)){
                    Account accountRec = accountMap.get(oppReqObj.OpportunityGeneratorCoCd);
                    if(productMap.containsKey(phNumber)){
                        Product2 prodObj = productMap.get(phNumber);
                        PricebookEntry pbe = priceBookEntryMap.get(prodObj.Id);
                        Opportunity oppRec = new Opportunity();		  
                        oppRec.Name = 'SK Driver ' + oppReqObj.OpportunityStrengthId + '-' + prodObj.Name;
                        oppRec.CloseDate = Date.today().addMonths(1);
                        oppRec.Job_Start_Date__c = Date.today().addMonths(1);
                        oppRec.StageName = '1 - Prospecting';
                        oppRec.Creator_Username__c = oppReqObj.OpportunityCreatorUsername;
                        oppRec.Creator_ID__c = oppReqObj.OpportunityCreatorID;
                        oppRec.Opp_Strength__c = oppReqObj.OpportunityStrengthId;
                        oppRec.Description = oppReqObj.OpportunityComments;
                        oppRec.Services_Discussed__c = phNumber;

                        List<Territory_Master__c> territoryLst = [
                            SELECT Id, ZIP_Master__c,Sales_Business_Unit__c, Territory_ID__r.Territory_OwnerID__c, Name, Territory_ID__c
                            FROM Territory_Master__c WHERE ZIP_Master__c = :accountRec.ZIP_Master__c];
                        
                        User beaconIntegrationUser = [SELECT Id FROM User WHERE Name = 'Beacon Integration User' LIMIT 1];
                        List<SSR_Opportunity_Owner_Assignment__mdt> ssrCustomMetadata = SSR_Opportunity_Owner_Assignment__mdt.getall().values();
                        Map<String, String> userCHESRegionMap = new Map<String, String>();
                        String pspCHESRegionKey = accountRec.Primary_Service_Provider_New__c + accountRec.ZIP_Master__r.CHES_Region__c;
                        
                        for(SSR_Opportunity_Owner_Assignment__mdt ssrOpty : ssrCustomMetadata){
                            String ssrKey = ssrOpty.Operating_Segment__c + ssrOpty.CHES_Region__c;
                            userCHESRegionMap.put(ssrKey,ssrOpty.Employee_Number__c);
                        }
                        
                        if(accountRec.Primary_Service_Provider_New__c == 'SK ENV' || accountRec.Primary_Service_Provider_New__c == 'SK BPS'){
                            if(accountRec.Owner.IsActive == true){
                                oppRec.OwnerId = accountRec.OwnerId;
                                isFound = true;
                            }
                            else{
                                if(userCHESRegionMap.containsKey(pspCHESRegionKey)){
                                    String empNumber = userCHESRegionMap.get(pspCHESRegionKey);
                                    User matchingUser = [select id from user where EmployeeNumber = :empNumber LIMIT 1];                            
                                    if(matchingUser != null){
                                        oppRec.OwnerId = matchingUser.id;
                                        isFound = true;
                                    }
                                }
                            }
                        }
                        else if(accountRec.Primary_Service_Provider_New__c == 'SK KPP' || accountRec.Primary_Service_Provider_New__c == 'Clean Harbors ENV'
                               || accountRec.Primary_Service_Provider_New__c == 'CHES Oil and Gas' || accountRec.Primary_Service_Provider_New__c == 'CHES Industrial'){
                            for(Territory_Master__c territoryRec : territoryLst){
                                if(territoryRec.Territory_ID__c != NULL && territoryRec.Territory_ID__r.Territory_OwnerID__c != NULL && territoryRec.Name.contains('Safety-Kleen')){
                                    oppRec.OwnerId = territoryRec.Territory_ID__r.Territory_OwnerID__c;
                                    isFound = true;
                                    break;
                                }                               
                            }                            
                        }                        
                        if(!isFound){
                        	oppRec.OwnerId = beaconIntegrationUser.Id;
                        }

                        oppRec.AccountId = accountRec.Id; 
                        oppRec.Pricebook2Id = pbe.PriceBook2Id;
                        oppRec.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Safety_Kleen_BPS_Opportunity').getRecordTypeId();
                        oppRec.CurrencyISOCode = isoCode;
                        newOppMap.put(key, oppRec);
                    }else{
                        SalesOpportunityResponse salesOppRes = new SalesOpportunityResponse();
                        salesOppRes.OpportunityPHNumber = phNumber;
                        salesOppRes.message = 'Product not found for given phNumber';
                        salesOppRes.status = 'Error';
                        salesOppResLst.add(salesOppRes); 
                    }
                }else{
                    SalesOpportunityResponse salesOppRes = new SalesOpportunityResponse();
                    salesOppRes.OpportunityPHNumber = phNumber;
                    salesOppRes.message = 'Product Already Exist';
                    salesOppRes.status = 'Error';
                    salesOppResLst.add(salesOppRes);
                }
            }
            
            if(newOppMap.size() > 0){
                try{
                    INSERT newOppMap.values();    
                }catch(Exception exc){
                    Database.rollback(sp);
                    SalesOpportunityResponse salesOppRes = new SalesOpportunityResponse();
                    salesOppRes.OpportunityPHNumber = '';
                    salesOppRes.message = exc.getMessage();
                    salesOppRes.status = 'Error';
                    salesOppResLst.add(salesOppRes);
                }
            }
			
			 Map<String, Id> accountBranchCodeMap = new Map<String, Id>();
             Map<Id, Id> accountBranchToAccountMap = new Map<Id, Id>();
            for(Account accountObj : accountMap.values()){
                if(String.isNotBlank(accountObj.Primary_SK_Branch__c)){
                    accountBranchCodeMap.put(accountObj.Primary_SK_Branch__c, accountObj.Id);
                }
            }
            for(Account accountRec : [
                SELECT Id, Branch_Code__c 
                FROM Account 
                WHERE Branch_Code__c IN :accountBranchCodeMap.keySet()
            ]){
                accountBranchToAccountMap.put(accountBranchCodeMap.get(accountRec.Branch_Code__c), accountRec.Id);
            }
			
            List<OpportunityLineItem> oppLineItems = new List<OpportunityLineItem>();
            List<String> phNumbers = new List<String>();
            for(String phNumber : oppReqObj.OpportunityPHNumber){
                String key = oppReqObj.OpportunityGeneratorCoCd.toLowerCase() + '-' + phNumber;
                
                if(!winIdSet.contains(key)){
                    if(productMap.containsKey(phNumber)){
                        Account accountRec = accountMap.get(oppReqObj.OpportunityGeneratorCoCd);                    
                        Product2 prodObj = productMap.get(phNumber);
                        PricebookEntry pbe = priceBookEntryMap.get(prodObj.Id);
                        Opportunity oppRec = newOppMap.get(key);
                        OpportunityLineItem oppLineItemObj = new OpportunityLineItem();
                        oppLineItemObj.OpportunityId = oppRec.Id;
                        oppLineItemObj.Product2Id = prodObj.Id;
						if(accountBranchToAccountMap.containsKey(accountRec.Id)){
                            oppLineItemObj.Branch__c = accountBranchToAccountMap.get(accountRec.Id);
                        }
                        oppLineItemObj.PricebookEntryId = pbe.Id;
                        oppLineItems.add(oppLineItemObj);
                        phNumbers.add(phNumber);
                    }
                }
            }
            
            if(oppLineItems.size() > 0){
                Boolean isSuccess = false;
                Database.SaveResult[] srList = Database.insert(oppLineItems, false);
                    
                Integer indx = 0;
                for(Database.SaveResult sr : srList) {
                    SalesOpportunityResponse salesOppRes = new SalesOpportunityResponse();
                    if(sr.isSuccess()){
                        isSuccess = true;
                        salesOppRes.OpportunityPHNumber = phNumbers[indx];
						salesOppRes.message = 'Record Successfully Created';
                        salesOppRes.status = 'Success';
                    }else{
                        for(Database.Error err : sr.getErrors()){
                            salesOppRes.OpportunityPHNumber = phNumbers[indx];
                            salesOppRes.message = err.getMessage();
                            salesOppRes.status = 'Error';
                        }
                    }
                    
                    salesOppResLst.add(salesOppRes);
                    
                    indx++;
                }
                
                if(!isSuccess){
                    Database.rollback(sp);
                }
            }    
        }
        
        res.responseBody = Blob.valueOf(JSON.serialize(salesOppResLst));
    }
    
    public class SalesOpportunityRequest{
        public CreateSalesOpportunityRequest SaveOpportunityData;
    }
    
    public class CreateSalesOpportunityRequest{
        public String OpportunityGeneratorCoCd;
        public String OpportunityCreatorUsername;
        public String OpportunityCreatorID;
        public String OpportunityStrengthId;
        public List<String> OpportunityPHNumber;
        public String OpportunityComments;
       // public String OpportunityPartsCleanerType;
    } 
    
    public class SalesOpportunityResponse{
        public String OpportunityPHNumber;
        public String message;
        public String status;
    }
}