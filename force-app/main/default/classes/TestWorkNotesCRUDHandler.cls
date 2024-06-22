/**
 * Test class for the ContactHelper.
 * This class is responsible for testing the logic around the class.
 * 
 * @author		Jerome Liwanag, Cloud Sherpas
 * @createddate	30-Oct-2015
 */ 
@isTest
private class TestWorkNotesCRUDHandler {
    
    @testSetup static void setupRecords() {
        
        Id accRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        
        List<ZIP_Master__c> zipMasterList = new List<ZIP_Master__c>();
        for(Integer i = 0; i < 10; i++){
            zipMasterList.add(new ZIP_Master__c(Zip__c = '12345'));
        }
        insert zipMasterList;
        
        TERRITORY_MANAGEMENT__c territoryMgmt = new TERRITORY_MANAGEMENT__c();
        territoryMgmt.Name = 'TERRITORY_MGMT_SETTING';
        territoryMgmt.TM_FLAG__c = true;
        insert territoryMgmt;
        
        SIC_VALIDATION_SETTING__c sicValidation = new SIC_VALIDATION_SETTING__c();
        sicValidation.Name = 'SIC_VALIDATION_SETTING';
        sicValidation.SIC_VALIDATION_FLAG__c = true;
        insert sicValidation;
        
        List<Account> accList = new List<Account>();
        for(Integer i = 0; i < 10; i++){
            accList.add(new Account(Name = 'Test ' + i, Business_Type__c = 'Base', AccountSource = 'Phone', CS_EPA_ID__c = '12345', /*Sic = '54321',*/ RecordTypeId = accRecTypeId,
            Rank__c = 'CH A Large >200K', Reporting_Vertical__c = 'Chemical', Industry_Segment__c = 'Chemical - Distributor', Class__c = 'Chemical - Distributor'
                                    /*Manifest_Post_Code__c = '12345', ShippingPostalCode = '12345', BillingPostalCode = '12345'*/));
        }
        insert accList;
        
        List<Contact> conList = new List<Contact>();
        for(Integer i = 0; i < 10; i++){
            conList.add(new Contact(AccountId = accList[i].Id, LastName = 'Last ' + i, FirstName = 'First ' + i, Email = 'test'+i+'@test.com', Salutation = 'Mr.'));
        }
        //ContactCRUDHandler.CREATE_BEACON_CONTACT_FROM_MASTER_CONTACT = false;
        insert conList;
        
        
    }

	
	private static testMethod void testUpdateWINValidatedFlag() {
        
        // Setup account
        Account acc = [SELECT Id FROM Account WHERE Name = 'Test 1' LIMIT 1];
        
        Contact con = [SELECT Id FROM Contact WHERE LastName = 'Last 1' LIMIT 1];
        
        Beacon_Contact__c beaconCon = new Beacon_Contact__c(Account_ID__c = acc.Id, Contact__c = con.Id, Department_Code__c = 'MAIN', Email__c = 'test@test.com');
        insert beaconCon;
        
        Beacon_Call_Notes__c beaconCallNote = new Beacon_Call_Notes__c(Account__c = acc.Id, Main_Contact__c = beaconCon.Id, Color__c = 'Green', Type__c = 'Note', Contact_Method__c = 'Phone',
        Services_Discussed__c = 'Surveying', Next_Action__c = 'Call', Account_Class__c = 'Base');
        insert beaconCallNote;
        
        Work_Notes__c workNote = new Work_Notes__c(Beacon_Call_Note__c = beaconCallNote.Id, Body__c = 'Test Body');
        insert workNote;
        
        // Query the created beacon contact record
        Work_Notes__c workNote1 = [SELECT WIN_Validated__c FROM Work_Notes__c WHERE Id = :workNote.Id];
        
        
        // Check if logic applies
        system.assertEquals(workNote1.WIN_Validated__c, true);
        
	}

}