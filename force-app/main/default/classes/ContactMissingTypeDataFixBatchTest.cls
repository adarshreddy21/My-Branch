@isTest 
public class ContactMissingTypeDataFixBatchTest
{
     private static testMethod void testContactMissingTypeDataFixBatch() {   
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
        
        
     
       Test.startTest();

            ContactMissingTypeDataFixBatch con1 = new ContactMissingTypeDataFixBatch();
            
            DataBase.executeBatch(con1); 
            
        Test.stopTest();
    }
}