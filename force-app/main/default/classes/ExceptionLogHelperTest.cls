/**
 * @description       : 
 * @author            : Suresh Beniwal
 * @group             : 
 * @last modified on  : 11-28-2022
 * @last modified by  : Suresh Beniwal 
 * Modifications Log
 * Ver   Date         Author           Modification
 * 1.0   11-28-2022   Suresh Beniwal   Initial Version
**/
@istest
private class ExceptionLogHelperTest {
     @IsTest
     static void testExceptionLogHelper() {   
         Test.startTest();
         	Id accRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();

         	List<Account> updAccList = new List<Account>();
            for(Integer i = 0; i < 10; i++){
                updAccList.add(new Account(Name = 'Test ' + i, Business_Type__c = 'Base', AccountSource = 'Phone', CS_EPA_ID__c = '12345', /*Sic = '54321',*/ RecordTypeId = accRecTypeId,
                                        Rank__c = 'CH A Large >200K', Reporting_Vertical__c = 'Chemical', Industry_Segment__c = 'Chemical - Distributor', Class__c = 'Chemical - Distributor'
                                        /*Manifest_Post_Code__c = '12345', ShippingPostalCode = '12345', BillingPostalCode = '12345'*/));
            }
         	List<Database.SaveResult> results = Database.update(updAccList, false);
            ExceptionLogHelper.logException(true, results, 'Account', updAccList, 'ContactCRUDHandler', 'updateAccountMissingTypesAccountflow');
         Test.stopTest();
    }
}