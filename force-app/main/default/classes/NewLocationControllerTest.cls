@isTest
public class NewLocationControllerTest {
	@isTest
    public static void testAccountRedirection(){
        AccountCRUDHandler.SKIP_VALIDATION = true;
        SIC_VALIDATION_SETTING__c sicValidation = new SIC_VALIDATION_SETTING__c();
        sicValidation.Name = 'SIC_VALIDATION_SETTING';
        sicValidation.SIC_VALIDATION_FLAG__c = true;
        insert sicValidation;
        Account newLocationAccount = new Account(
                Name = 'Test',
                Skip_Duplicate_Check__c = true,
                Business_Type__c = 'Base',
                AccountSource = 'Import',
                Sic = '1000',
                RecordTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get(
                CHConstants.ACCOUNT_RECORD_TYPE_CUSTOMER).getRecordTypeId(),
            	Rank__c = 'CH E Small <30K',
                CurrencyISOCode = 'USD'
            );
        INSERT newLocationAccount;
        
        NewLocationController.redirectToNewLocation(newLocationAccount.Id);
        
        
        Account newLocationAccount2 = new Account(
                Name = 'Test',
                Skip_Duplicate_Check__c = true,
                Business_Type__c = 'Base',
                AccountSource = 'Import',
                Sic = '1000',
                RecordTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get(
                CHConstants.ACCOUNT_RECORD_TYPE_BROKER).getRecordTypeId(),
            	Rank__c = 'CH E Small <30K',
                CurrencyISOCode = 'USD'
            );
        INSERT newLocationAccount2;
        
        NewLocationController.redirectToNewLocation(newLocationAccount2.Id);
    }
}