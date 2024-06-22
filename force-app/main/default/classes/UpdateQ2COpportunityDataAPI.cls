@RestResource(urlMapping = '/UpdateQ2COpportunityData/*')
global class UpdateQ2COpportunityDataAPI {
    @HttpPost 
    global static void updateOpp(){
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
         
        res.statusCode = 200; 
        res.addHeader('Content-Type', 'application/json');
        
        String reqBody = req.requestBody.toString();
        UpdateOpportunityRequest updateOppReq =
            (UpdateOpportunityRequest)JSON.deserialize(reqBody, UpdateOpportunityRequest.class);
        
        UpdateOpportunityResponse updateOppRes = new UpdateOpportunityResponse();
        
        List<Opportunity> Opplst = [
            SELECT Id,StageName
            FROM Opportunity 
            WHERE Id = :updateOppReq.oppId
            LIMIT 1
        ];
        
        if(Opplst.size() > 0){
            if(String.isNotBlank(updateOppReq.Stage) && updateOppReq.SourceApplication=='Q2C' && 
               (Opplst[0].Stagename =='1 - Prospecting' || Opplst[0].Stagename =='2 - Pursuing')){
                Opplst[0].Stagename = updateOppReq.Stage;
            }else if(String.isNotBlank(updateOppReq.Stage) && updateOppReq.SourceApplication =='Closed Order' &&  Opplst[0].Stagename != '8 - Closed Lost' &&  Opplst[0].Stagename != '9 - Closed-Existing business')
            {
                Opplst[0].Stagename = updateOppReq.Stage;
            }
            List<OpportunityLineItem> oppLineItemLst = new List<OpportunityLineItem>();
            //if(updateOppRes.status != 'Error'){
            if((Opplst[0].Stagename =='1 - Prospecting' || Opplst[0].Stagename =='2 - Pursuing' || Opplst[0].Stagename =='3 - Quoted') && updateOppReq.Salesprice > 0.00){
            	
                if(updateOppReq.Salesprice != NULL){
                    oppLineItemLst = [
                        SELECT Id, Quantity, UnitPrice
                        FROM OpportunityLineItem
                        WHERE OpportunityId = :Opplst[0].Id
                        LIMIT 1
                    ];
                    
                    oppLineItemLst[0].UnitPrice += updateOppReq.Salesprice;
                    //oppLineItemLst[0].TotalPrice = oppLineItemLst[0].Quantity * updateOppReq.Salesprice;
                }
            }
                
                
                try{
                    UPDATE Opplst;
                    if(oppLineItemLst.size() > 0){
                        List<OpportunityLineItemSchedule> oppLineItemSch = [
                            SELECT Id
                            FROM OpportunityLineItemSchedule
                            WHERE OpportunityLineItemID = :oppLineItemLst[0].Id
                        ];
                        
                        if(oppLineItemSch.size() > 0){
                            DELETE oppLineItemSch;
                        }
                        UPDATE oppLineItemLst;
                    }
                
                    if(updateOppRes.status != 'Error'){
                        updateOppRes.status = 'Success';
                        updateOppRes.message = 'Opportunity Successfully Updated';     
                    }
                        
                    
                
                }catch(Exception exceptionObj){
                    updateOppRes.status = 'Error';
                    updateOppRes.message = exceptionObj.getMessage();  
                }
            //}
        }
       
        
        res.responseBody = Blob.valueOf(JSON.serialize(updateOppRes));
    }
    
    public class UpdateOpportunityResponse{
        public String status;
        public String message;
    }
    
    public class UpdateOpportunityRequest{
        public String oppId;
        public String Stage;
        Public String SourceApplication;
        Public Decimal Salesprice;
        
    }
}