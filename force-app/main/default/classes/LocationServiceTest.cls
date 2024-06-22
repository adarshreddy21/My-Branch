/**
 * @description       : 
 * @author            : Irfan Khan
 * @group             : 
 * @last modified on  : 10-13-2022
 * @last modified by  : Suresh Beniwal
 * Modifications Log
 * Ver   Date         Author       Modification
 * 1.0   08-08-2022   Irfan Khan   Initial Version
**/
@isTest 
private class LocationServiceTest {
    private final static string TEST_NAME = 'Nandyala';
    private final static string TEST_STREET = '518501 Farook Nagar';
    private final static string TEST_CITY = 'Nandyala';
    private final static string TEST_StateCode = 'AP';
    private final static string TEST_CountryCode = 'IN';
    private final static string TEST_PostalCode = '518501';
    
@testSetup static void setupmethod() {
        Id RecordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('HR_Talent_Pools').getRecordTypeId();
        Account acc = new Account();
        acc.Name = 'Farheen';
        acc.RecordTypeId = RecordTypeIdAccount;
        acc.Organization_Status__c ='Draft';
        //acc.Organization_ID__c = acc.id;
        acc.Organization_Category__c = 'Driver School';
        acc.ShippingStreet = '123';
        acc.ShippingCity = 'Jaipur';
        acc.ShippingState = 'Rajasthan';
        acc.ShippingCountry = 'US';
        acc.ShippingPostalCode = '302012';
        insert acc;

        Schema.Location loc = new Schema.Location();
        loc.Organization__c = acc.Id;
        loc.Name = TEST_NAME ;
        loc.Address__Street__s = TEST_STREET;
        loc.Address__City__s = TEST_CITY;
        loc.Address__StateCode__s = TEST_StateCode;
        loc.Address__CountryCode__s = TEST_CountryCode;
        loc.Address__PostalCode__s =TEST_PostalCode;
    
      Test.startTest();
            insert loc;
        Test.stopTest();
}
     @IsTest static void TestOrganizationOwner(){
        List<Schema.Location> LocList = [SELECT Id,Name__c, Name,Location_Id__c,Address__c, Address__Street__s, Address__City__s,Address__StateCode__s,Address__CountryCode__s,Address__PostalCode__s,Location_Phone_Number__c,Size_of_Candidate_Pool__c,Number_of_Hires__c,Status__c,Organization__r.Name, Organization__r.Organization_Id__c FROM Location WHERE Name =: TEST_NAME];
         
         Test.startTest();
            List<LocationService.LocationWrapper> listOfLocationWrapper = LocationService.getListOfLocations(LocList);
        Test.stopTest();
         
         System.assertEquals(false, listOfLocationWrapper.isEmpty(), 'Wrapper data should be return !!');
     }
}