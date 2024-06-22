@istest
public class TestContact1 {
  public static Testmethod void method1(){
    
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
            if(i < 5 ){
                conList.add(new Contact(AccountId = accList[i].Id, LastName = 'Last ' + i, FirstName = 'First ' + i, Email = 'test'+i+'@test.com', Salutation = 'Mr.'));
            }
            else{
                conList.add(new Contact(AccountId = accList[i].Id, LastName = 'Last ' + i, FirstName = 'First ' + i, Email = 'test'+i+'@test.com', Salutation = 'Mr.'));
            }
        }
        insert conList;
        
        
        
    }

	
	
}