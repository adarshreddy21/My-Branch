@isTest
private class OwnershipDAOTest {
    private final static string TEST_NAME='Farheen';
    private final static string TEST_RECORDTYPE_ID = Schema.Sobjecttype.Account.getRecordTypeInfosByDeveloperName().get(CHConstants.ACCOUNT_RECORD_TYPE_HR_TALENT_POOLS).getRecordTypeId();
    private final static string TEST_ORGANISATION_STATUS = 'Draft';
    private final static string TEST_SHIPPING_STREET = 'Tolichowki';
    private final static string TEST_SHIPPING_CITY = 'Hyderabad';
    private final static string TEST_SHIPPING_STATE = 'Telangana';
    private final static string TEST_SHIPPING_COUNTRY = 'India';
    private final static string TEST_SHIPPING_POSTAL_CODE = '500001';
    
 @testSetup  private static void setupmethod(){
      Account acc = new Account(Name = TEST_NAME, RecordTypeId =TEST_RECORDTYPE_ID,
                               Organization_Status__c = TEST_ORGANISATION_STATUS,
                               ShippingStreet = TEST_SHIPPING_STREET, ShippingCity = TEST_SHIPPING_CITY,
                               ShippingState = TEST_SHIPPING_STATE, ShippingCountry = TEST_SHIPPING_COUNTRY,
                               ShippingPostalCode = TEST_SHIPPING_POSTAL_CODE );
      insert acc;
    }
 @IsTest private static void TestOrganizationOwner(){
     Account accList = [SELECT ID, name FROM Account WHERE Name =: TEST_NAME limit 1];
     OwnershipDAO.getListOfOwnershipByOrganizationIds(new Set<ID>{accList.ID});
     Account acc1 = [select ID from Account where ID=:accList.ID];
     System.assertEquals(accList.ID, acc1.ID);
      } 
}