/**
 * Test class for the ContactCRUDHandler.
 * This class is responsible for testing the logic around the class.
 * 
 * @author		Jerome Liwanag, Cloud Sherpas
 * @createddate	30-Oct-2015
 */ 
@isTest
private class TestContactCRUDHandler {

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
        for(Integer i = 0; i < 20; i++){
            accList.add(new Account(Name = 'Test ' + i, Business_Type__c = 'Base', AccountSource = 'Phone', CS_EPA_ID__c = '12345', /*Sic = '54321',*/ RecordTypeId = accRecTypeId,
            Rank__c = 'CH A Large >200K', Reporting_Vertical__c = 'Chemical', Industry_Segment__c = 'Chemical - Distributor', Class__c = 'Chemical - Distributor'
                                    /*Manifest_Post_Code__c = '12345', ShippingPostalCode = '12345', BillingPostalCode = '12345'*/));
        }
        insert accList;
        
        List<Contact> conList = new List<Contact>();
        for(Integer i = 0; i < 20; i++){
            if(i < 5 ){
                conList.add(new Contact(AccountId = accList[i].Id, LastName = 'Last ' + i, FirstName = 'First ' + i, Email = 'test'+i+'@test.com', Salutation = 'Mr.',Phone='7654839274' + i, Contact_type__c = 'Main'));
            }
            else if (5 <= i && i < 10){
                conList.add(new Contact(AccountId = accList[i].Id, LastName = 'Last ' + i, FirstName = 'First ' + i, Email = 'test'+i+'@test.com', Salutation = 'Mr.',Phone='7654839254' + i, Contact_type__c = 'SALE'));
            }
            else if (i == 10){
                conList.add(new Contact(AccountId = accList[i].Id, LastName = 'Last ' + i, FirstName = 'First ' + i, Email = 'test'+i+'@test.com', Salutation = 'Mr.',Phone='7654832374' + i, Contact_type__c = 'PO'));
            }
            else if (i == 11){
                conList.add(new Contact(AccountId = accList[i].Id, LastName = 'Last ' + i, FirstName = 'First ' + i, Email = 'test'+i+'@test.com', Salutation = 'Mr.',Phone='7654833274' + i, Contact_type__c = 'AP'));
            }
             else if (i == 12){
                conList.add(new Contact(AccountId = accList[i].Id, LastName = 'Last ' + i, FirstName = 'First ' + i, Email = 'test'+i+'@test.com', Salutation = 'Mr.',Phone='7655859274' + i, Contact_type__c = 'MAIN;PO'));
            }
            else if (i == 13){
                conList.add(new Contact(AccountId = accList[i].Id, LastName = 'Last ' + i, FirstName = 'First ' + i, Email = 'test'+i+'@test.com', Salutation = 'Mr.',Phone='7654869274' + i, Contact_type__c = 'MAIN;AP'));
            }
            else if (i == 14){
                conList.add(new Contact(AccountId = accList[i].Id, LastName = 'Last ' + i, FirstName = 'First ' + i, Email = 'test'+i+'@test.com', Salutation = 'Mr.', Phone='9876453627' + i, Contact_type__c = 'PO;AP'));
            }
            else{
                conList.add(new Contact(AccountId = accList[i].Id, LastName = 'Last ' + i, FirstName = 'First ' + i, Email = 'test'+i+'@test.com', Salutation = 'Mr.', Phone='9845395749' + i, Contact_type__c = 'MAIN;PO;AP'));
            }
        }
        insert conList;
    }
	
	private static testMethod void testValidateMasterContact() {
        
        // Setup account
        Account acc = [SELECT Id FROM Account WHERE Name = 'Test 5' LIMIT 1];
        
        // Query the created beacon contact record
        try
        {
            Contact con2 = new Contact(AccountId = acc.Id, LastName = 'Lasty ', FirstName = 'Firsty ', Contact_type__c = 'MAIN', Department__c = 'Main Contact');
            insert con2;
        }
        catch(Exception e)
        {   system.debug('Error message-->'+e.getMessage());
            Boolean expectedExceptionThrown =  e.getMessage().contains('Duplicate Beacon department code already exists on related Account.') ? true : false;
           // System.AssertEquals(expectedExceptionThrown, true);
        } 
        
	}
	
	private static testMethod void testUpdateRelatedBeaconContacts() {        
        Contact con = [SELECT Id, email, title FROM Contact WHERE LastName = 'Last 1' LIMIT 1];
        con.LastName = 'Last 1';
        update con;
     
        con.LastName = 'Last 33';
        update con;   
	}

    /* Test for CheckForContactType
    @author Reeta Gaokar Created date 04/06/2020*/  
    private static testMethod void testCheckForContactType() {              
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        delete con;
    	undelete con;
    
	} 
    static testMethod void testMethodupdateVerificationDates()     
    {         
        Contact con = [SELECT Id, email, title FROM Contact WHERE LastName = 'Last 1' LIMIT 1];
        con.title = 'Last1';
        update con;        
    }

    private static testMethod void testCheckDuplicateContact(){
        Account acc = [SELECT Id FROM Account WHERE Name = 'Test 5' LIMIT 1];
        Contact oldContact = new Contact(AccountId = acc.Id, LastName = 'Last', FirstName = 'First', Contact_type__c = 'CUST', Title = 'TestTitle', Email = 'testContact1@test.com');

        List<Contact> newContacts = new List<Contact>();
        newContacts.add(new Contact(AccountId = acc.Id, LastName = 'Last', FirstName = 'First', Contact_type__c = 'ACCT', Title = 'TestTitle', Email = 'testContact1@test.com'));
        newContacts.add(new Contact(AccountId = acc.Id, LastName = 'Last1', FirstName = 'First1', Contact_type__c = 'PO', Title = 'TestTitle', Email = 'testContact2@test.com'));
        
        ContactCRUDHandler.checkDuplicateContact(newContacts, null);
        List<Contact> contacts = [SELECT Id, email,AccountId, title FROM Contact WHERE Email IN ('testContact1@test.com' , 'testContact2@test.com')];

        for(Contact c : contacts){
            if(c.Email == 'testContact1@test.com'){
                system.assertEquals(c.hasErrors(), true);
            }
            else{
                system.assertEquals(c.hasErrors(), false);
            }            
        }
    }
}