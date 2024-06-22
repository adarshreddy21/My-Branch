public class EPAIdUpdateController {
    @InvocableMethod(callout=true label='update EPA ID') 
    public static List<EPAValidationResult> UpdateEPAID(List<EPAIdRequest> accWrapper) {
        List<EPAValidationResult> results = new List<EPAValidationResult>();
        List<id> accIds =new List<id>();
        for(EPAIdRequest accWrap : accWrapper) 
        { 
            accIds.add(accWrap.accId); 
        }
        List<Account> accList = [select id,Generator_Status__c,GENREG__c,RecordTypeId,RecordType.DeveloperName,RecordType.Name, State_EPA_ID__c, Primary_Service_Provider__c,Primary_Business__c,CS_EPA_ID__c,ShippingStreet,ShippingCity,ShippingState,ShippingCountry from Account where id in :accIds];
        accList[0].CS_EPA_ID__c = accWrapper[0].epaIDValue;
        if(!String.isBlank(accWrapper[0].stateEpaIDValue)){
             accList[0].State_EPA_ID__c = accWrapper[0].stateEpaIDValue;
        }
        AccountValidatorController.EPAIdResponse epaResponse =  AccountValidatorController.validateEPAId(accList[0]);
        EPAValidationResult result = new EPAValidationResult();        
        if(epaResponse != null)
        {
            result.messageCode = epaResponse.messageCode;
            result.message = epaResponse.message;
            results.add(result);
        } 
        return results;
    }
     
    public class EPAIdRequest{
        @InvocableVariable(required=true)
        public Id accId;        
        
        @InvocableVariable(required=true)
        public String epaIDValue;
        
        @InvocableVariable
        public String stateEpaIDValue;
    }

    public class EPAValidationResult{
        @InvocableVariable(label='Message Code')
        public Integer messageCode;
        
        @InvocableVariable(label='Message')
        public String message;
    }    
    
}