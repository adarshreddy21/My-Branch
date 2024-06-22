@isTest
public class RestTaskControllerTest {
    @testSetup
    private static void setupDate(){
        TERRITORY_MANAGEMENT__c territoryMgmt = new TERRITORY_MANAGEMENT__c();
        territoryMgmt.Name = 'TERRITORY_MGMT_SETTING';
        territoryMgmt.TM_FLAG__c = true;
        insert territoryMgmt;
        COUNTRY_CODES__c countrycodes = new COUNTRY_CODES__c();
        countrycodes.Name = 'CA';
        insert countrycodes;
        
        COUNTRY_CODES__c countrycodes1 = new COUNTRY_CODES__c();
        countrycodes1.Name = 'US';
        insert countrycodes1;
        
        List<ZIP_Master__c> zipMasterList = new List<ZIP_Master__c>();
        for(Integer i = 0; i < 10; i++){
            zipMasterList.add(new ZIP_Master__c(Zip__c = '12345',Country__c = 'US', State__c = 'NY',City__c ='Ashburn'));
			zipMasterList.add(new ZIP_Master__c(Zip__c = '20147',Country__c = 'US', State__c = 'NY',City__c ='Ashburn'));
        }
        insert zipMasterList;
        
        SIC_VALIDATION_SETTING__c sicValidation = new SIC_VALIDATION_SETTING__c();
        sicValidation.Name = 'SIC_VALIDATION_SETTING';
        sicValidation.SIC_VALIDATION_FLAG__c = true;
        insert sicValidation;

        
        Id accRecTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get(CHConstants.ACCOUNT_RECORD_TYPE_CORPORATE).getRecordTypeId();
        User activeUser = [Select id from User where isActive = True Limit 1];
		
        Account accRec = new Account();
        accRec.Name = 'Parent Corporate Account';
		accRec.dunbrdst__c = '12345';
        accRec.ShippingCountry = 'US';
        accRec.ShippingState = 'NY';
        accRec.ShippingStreet = 'Test Street';
        accRec.ShippingCity = 'Ashburn';
        accRec.ShippingPostalCode = '12345';
        accRec.KAM_Manager__c = activeUser.id;
        accRec.KAM_Support__c = activeUser.id;
        accRec.RecordTypeId = accRecTypeId;
        accRec.Buying_Decision__c = 'Central Buying';
        accRec.Account_Assign_Override__c = false;
        accRec.Status__c = 'Active';
        accRec.WIN_ID__c = '1234';
        INSERT accRec;
    }
    
    @isTest
    private static void createNewTaskUnitTest(){
        RestTaskController.PCWBCallSheetNotesRequest notesRequest = new RestTaskController.PCWBCallSheetNotesRequest();
        notesRequest.CallerFirstName = 'Test';
        notesRequest.CallerLastName = 'Test';
        notesRequest.CallerPhone = '123456789';
        notesRequest.WinId = '1234';
        notesRequest.CallSheetType = 'Service Request';
        notesRequest.FocalPointOrderNo = '';
        notesRequest.PrimaryTypeOfService = '';
        notesRequest.CallType = 'Test';
        notesRequest.Priority = 'Normal';
        notesRequest.OrderStatus = 'In Progress';
        notesRequest.CallSheetNotes = 'Test';
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/TaskController/*';
        req.httpMethod = 'POST';
        
        req.requestBody = Blob.ValueOf(JSON.serialize(notesRequest));
        RestContext.request = req;
        RestContext.response = res;
        RestTaskController.createnewtask();
    }
}