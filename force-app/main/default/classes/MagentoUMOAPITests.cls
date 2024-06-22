@isTest
private class MagentoUMOAPITests {
   
   @isTest
   private static void testCreateMagentoUmoRecordForWinId(){
       RestRequest req = new RestRequest(); 
       RestResponse res = new RestResponse();
       MagentoUMOAPI.CompositeWrapper wrapper= new MagentoUMOAPI.CompositeWrapper();
       Account accountObj=new Account(Name='Test',Type='Customer');
       Contact contactObj=new Contact(FirstName='Test',LastName='Test');
       wrapper.AccountObj= accountObj;
       wrapper.ContactObj= contactObj;
       req.requestBody=Blob.valueOf(JSON.serialize(wrapper));
       RestContext.request = req;
       RestContext.response= res;
       Test.setMock(HttpCalloutMock.class, new MagentoUMOAPIMock(200));

       Test.startTest();
          MagentoUMOAPI.createMagentoUmoRecord();
          System.assertEquals(200, res.statusCode, 'WinId successfully generated');
       Test.stopTest(); 
   } 

   @isTest
   private static void testCreateMagentoUmoRecordForNoWinId(){
       RestRequest req = new RestRequest(); 
       RestResponse res = new RestResponse();
       MagentoUMOAPI.CompositeWrapper wrapper= new MagentoUMOAPI.CompositeWrapper();
       Account accountObj=new Account(Name='Test',Type='Customer');
       Contact contactObj=new Contact(FirstName='Test',LastName='Test');
       wrapper.AccountObj= accountObj;
       wrapper.ContactObj= contactObj;
       req.requestBody=Blob.valueOf(JSON.serialize(wrapper));
       RestContext.request = req;
       RestContext.response= res;
       Test.setMock(HttpCalloutMock.class, new MagentoUMOAPIMock(500));

       Test.startTest();
          MagentoUMOAPI.createMagentoUmoRecord();
          System.assertEquals(500, res.statusCode, 'WinId not returned');
       Test.stopTest(); 
   } 

   @isTest
   private static void testCreateMagentoUmoRecordForNoAccount(){
       RestRequest req = new RestRequest(); 
       RestResponse res = new RestResponse();
       MagentoUMOAPI.CompositeWrapper wrapper= new MagentoUMOAPI.CompositeWrapper();
       Account accountObj=new Account(Name='Test',Type='Customer');
       Contact contactObj=new Contact(FirstName='Test',LastName='Test');
       wrapper.AccountObj= accountObj;
       wrapper.ContactObj= contactObj;
       req.requestBody=Blob.valueOf(JSON.serialize(wrapper));
       RestContext.request = req;
       RestContext.response= res;
       Test.setMock(HttpCalloutMock.class, new MagentoUMOAPIMock(400));

       Test.startTest();
          MagentoUMOAPI.createMagentoUmoRecord();
          System.assertEquals(400, res.statusCode, 'No Account created');
       Test.stopTest(); 
   } 
}