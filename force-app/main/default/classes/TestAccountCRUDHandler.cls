/**
 * Test class for the ContactHelper.
 * This class is responsible for testing the logic around the class.
 * 
 * @author      Jerome Liwanag, Cloud Sherpas
 * @createddate 30-Oct-2015
 */ 
@isTest 
private class TestAccountCRUDHandler {
     private final static string TEST_NAME = 'Test Lead';
     private final static string TEST_POSTALCODE = '12345-0000'; 
     private final static string TEST_Country = 'US';  
     private final static string TEST_State = 'NY';
     private final static string TEST_City = 'Ashburn';
     private final static string TEST_Street = 'Test Street';
     private final static string TEST_FIRST_NAME = 'Test';
     private final static string TEST_LAST_NAME = 'Lead';
     private final static string TEST_SALUTATION = 'Mr';
     private final static string TEST_COMAPNY = 'Test Company';
     private final static string TEST_TITLE = 'Testing';
     private final static string TEST_CURRENCYISOCODE = 'USD';
     private final static string TEST_LEADSOURCE = 'Cold Call';
     private final static string TEST_STATUS = 'Open';
     private final static string TEST_PHONE = '799856414';
     private final static string TEST_EPA_ID = 'PENDING';
	 private final static string TEST_Generator_Status = 'Small Quantity Generator';
    
    @testSetup static void setupRecords() {
       
        Id accRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        Profile p = [SELECT Id FROM Profile WHERE Name='Integration'];  
        
        TERRITORY_MANAGEMENT__c territoryMgmt = new TERRITORY_MANAGEMENT__c();
        territoryMgmt.Name = 'TERRITORY_MGMT_SETTING';
        territoryMgmt.TM_FLAG__c = true;
        insert territoryMgmt;
        
       // Bypass_Account_Validation__c accountValidation = new Bypass_Account_Validation__c();
       // accountValidation.Bypass_Manifest_Address_Requirement__c = false;
       // INSERT accountValidation;
        
        SIC_VALIDATION_SETTING__c sicValidation = new SIC_VALIDATION_SETTING__c();
        sicValidation.Name = 'SIC_VALIDATION_SETTING';
        sicValidation.SIC_VALIDATION_FLAG__c = true; 
        insert sicValidation;
        
        List<User> userList = new List<User>();
        for(Integer i = 0; i < 10; i++){
            userList.add(new User(Alias = 'standt'+ i, Email='standarduser'+i+'@safety-kleen.com', 
            EmailEncodingKey='UTF-8', LastName='Testing '+ i, LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName=datetime.now().millisecond()+'standardusertest'+i+'@safety-kleen.com'));
        }
        insert userList; 
		COUNTRY_CODES__c countrycodes = new COUNTRY_CODES__c();
        countrycodes.Name = 'CA';
        insert countrycodes;
        
        COUNTRY_CODES__c countrycodes1 = new COUNTRY_CODES__c();
        countrycodes1.Name = 'US';
        insert countrycodes1;
        
        List<ZIP_Master__c> zipMasterList = new List<ZIP_Master__c>();
        for(Integer i = 0; i < 10; i++){
            zipMasterList.add(new ZIP_Master__c(Zip__c = '12345',Country__c = 'US', State__c = 'NY',City__c ='Ashburn'));
			zipMasterList.add(new ZIP_Master__c(Zip__c = '10047',Country__c = 'US', State__c = 'NY',City__c = 'New York'));
           // if(i > 5){
          //      zipMasterList.add(new ZIP_Master__c(Zip__c = '12345',Country__c = 'CA', State__c = 'PR'));
           // }
        }
       insert zipMasterList;
        
        Set<Id> sicCodesSet = new Set<Id>();
        List<SIC_Codes__c> sicCodesList = new List<SIC_Codes__c>();
        for(Integer i = 0; i < 10; i++){
            sicCodesList.add(new SIC_Codes__c(SIC_Code__c =  '011' + i, Class__c = 'Agricultural Production'));
        }
        insert sicCodesList;
        
        for(SIC_Codes__c sicCodesLoop : sicCodesList){
            sicCodesSet.add(sicCodesLoop.Id);
        }
        
        sicCodesList.clear();
        
        for(SIC_Codes__c sicCodesLoop : [SELECT Name,SIC_Code__c from SIC_Codes__c WHERE Id IN :sicCodesSet ]){
            sicCodesList.add(sicCodesLoop);
        }

        List<Account> accList = new List<Account>();
        for(Integer i = 0; i < 10; i++){
            accList.add(new Account(Name = 'Test ' + i, Business_Type__c = 'Base', AccountSource = 'Phone', CS_EPA_ID__c = '12345', Sic = '0111', RecordTypeId = accRecTypeId,                               
                                   Generator_Status__c = 'Small Quantity Generator', Rank__c = 'CH A Large >200K', Reporting_Vertical__c = 'Automotive', Industry_Segment__c = 'Automotive', Class__c = 'Agricultural Production',
                                   Primary_Service_Provider_New__c = 'SK BPS')); //
        }
        Territory__c t = new Territory__c();
        t.name = 'TS-AM-Camarillo-CA-01';
        t.Territory_OwnerID__c = UserInfo.getUserId();
        INSERT t;
        Territory_Master__c tm = new Territory_Master__c();
        tm.ZIP_Master__c = zipMasterList[0].Id;
        tm.Sales_Business_Unit__c = 'BPS';
        tm.Name = 'SK BPS IS';
        tm.Territory_ID__c = t.Id;
        INSERT tm;
        test.startTest();
        accList[0].ZIP_Master__c = zipMasterList[0].Id;
        insert accList;
        test.stopTest();
        
    }
    private static Account getCorpAccount(){
        Id corpRecordTypeId= Schema.Sobjecttype.Account.getRecordTypeInfosByName().get(CHConstants.ACCOUNT_RECORD_TYPE_CORPORATE).getRecordTypeId();
        Account corpAccount=new Account(Id= CHTestFactory.getFakeId(Account.SObjectType), RecordTypeId= corpRecordTypeId);
        return corpAccount;    
    }
    private static void createMainContact(Id accId){
        Contact con = new Contact(AccountId = accId);
        con.LastName = 'Contact';
        con.FirstName = 'Main';
        con.Salutation = 'Mr';
        con.Title = 'Default Mgr';
        con.Email = 'Main@default.com';
        con.Phone = '781-792-5000';
        con.Contact_Type__c = 'MAIN';
        insert con;
    }
    private static testMethod void method1(){
        Id accRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        Id branchRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Branch').getRecordTypeId();
        user u=[select id from user where profile.name='System administrator' limit 1];
        
        Account acc = new Account(Name = 'Test ', Business_Type__c = 'Base', AccountSource = 'Phone', CS_EPA_ID__c = '12345', Sic = '0111', RecordTypeId = accRecTypeId,                               
                                  Rank__c = 'CH A Large >200K', Reporting_Vertical__c = 'Automotive', Industry_Segment__c = 'Automotive', Class__c = 'Agricultural Production',
                                  ownerId = u.id, Primary_Service_Provider_New__c='SK ENV'); 
        
        insert acc;
        
        Account acc1 = new Account(Name = 'Test2', Business_Type__c = 'Base', AccountSource = 'Phone', CS_EPA_ID__c = '12345', Sic = '0111', RecordTypeId = branchRecTypeId,                               
                                  Rank__c = 'CH A Large >200K', Reporting_Vertical__c = 'Automotive', Industry_Segment__c = 'Automotive', Class__c = 'Agricultural Production',
                                  ownerId = u.id); 
        
        insert acc1;
        u.Primary_Business__c = 'Emerald Services';
        update u;
        acc.Primary_Branch_Alternate__c = acc1.id;
        update acc;
    }
    
   private static testMethod void method2(){
        Id accRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        Id branchRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Branch').getRecordTypeId();
        user u=[select id from user where profile.name='System administrator' limit 1];
		
        
        Account acc1 = new Account(Name = 'Test2', Business_Type__c = 'Base', AccountSource = 'Phone', CS_EPA_ID__c = '12345', Sic = '0111', RecordTypeId = branchRecTypeId,                               
                                  Rank__c = 'CH A Large >200K',Branch_code__c = 'SBB' , Reporting_Vertical__c = 'Automotive', Industry_Segment__c = 'Automotive', Class__c = 'Agricultural Production',
                                  ownerId = u.id); 
        
        insert acc1;
        
        Account acc = new Account(Name = 'Test ', Business_Type__c = 'Base', AccountSource = 'Phone', CS_EPA_ID__c = '12345', Sic = '0111', RecordTypeId = accRecTypeId,                               
                                  Rank__c = 'CH A Large >200K', Reporting_Vertical__c = 'Automotive', Industry_Segment__c = 'Automotive', Class__c = 'Agricultural Production',
                                  ownerId = u.id); 
        
        insert acc;
        
       acc.Primary_Branch_Alternate__c = acc1.id;
        update acc;
        
        u.Primary_Business__c = 'Emerald Services1';
        update u;
        
        test.startTest();
        u.Primary_Business__c = 'Performance Plus Products';
        update u;
        
        update acc;
       u.Primary_Business__c = 'CYN OIL';
        update u;
        
        update acc;
       u.Primary_Business__c = 'Healthcare Services';
        update u;
        
        update acc;
        u.Primary_Business__c = 'CYN ENVIRONMENTAL';
        update u;
        
        update acc;
       u.Primary_Business__c = '';
        update u;
        
        update acc;
        test.StopTest();
    }
    
     private static testMethod void method3(){
        Id accRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        Id branchRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Branch').getRecordTypeId();
        user u=[select id from user where profile.name='System administrator' limit 1];
        
        Account acc1 = new Account(Name = 'Test2', Business_Type__c = 'Base', AccountSource = 'Phone', CS_EPA_ID__c = '12345', Sic = '0111', RecordTypeId = branchRecTypeId,                               
                                  Rank__c = 'CH A Large >200K', Reporting_Vertical__c = 'Automotive', Industry_Segment__c = 'Automotive', Class__c = 'Agricultural Production',
                                  ownerId = u.id); 
        
        insert acc1;
        
        Account acc = new Account(Name = 'Test ', Business_Type__c = 'Base', AccountSource = 'Phone', CS_EPA_ID__c = '12345', Sic = '0111', RecordTypeId = accRecTypeId,                               
                                  Rank__c = 'CH A Large >200K', Reporting_Vertical__c = 'Automotive', Industry_Segment__c = 'Automotive', Class__c = 'Agricultural Production',
                                  ownerId = u.id); 
        
        insert acc;
        List<account> accList = new List<account>();
         accList.add(acc);
         AccountCRUDHandler.updateAccountPrimaryBusiness(accList);
        
        u.Primary_Business__c = '';
        update u;
       
        test.startTest();
        u.Primary_Business__c = 'CYN OIL';
        update u;
        
        update acc;

        u.Primary_Business__c = 'CYN ENVIRONMENTAL';
        update u;
        
        update acc;
        test.stopTest();
    }
    
    private static testMethod void method4(){
        Id accRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        
        Id branchRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Branch').getRecordTypeId();
        user u=[select id from user where profile.name='System administrator' limit 1];
       
        
        Account acc = new Account(Name = 'Test224', Business_Type__c = 'Base', AccountSource = 'Phone', CS_EPA_ID__c = '12345', Sic = '0111', RecordTypeId = accRecTypeId,                               
                                  Rank__c = 'CH A Large >200K', Reporting_Vertical__c = 'Automotive', Industry_Segment__c = 'Automotive', Class__c = 'Agricultural Production',
                                  ownerId = u.id); 
        
        insert acc;
        
        
        u.Primary_Business__c = 'Emerald Services1';
        update u;
        
        test.startTest();
        u.Primary_Business__c = 'Performance Plus Products';
        update u;
        
        update acc;
        
        AccountCRUDHandler.lockAccountRecord(acc,true);
        test.StopTest();
    }
    
    private static testMethod void method5(){
        Id accRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        user u=[select id from user where profile.name='System administrator' limit 1];
                
        Account acc = new Account(Name = 'Test ', Business_Type__c = 'Base', AccountSource = 'Phone', CS_EPA_ID__c = '12345', Sic = '0111', RecordTypeId = accRecTypeId,                               
                                  Rank__c = 'CH A Large >200K',Reporting_Vertical__c = 'Automotive', Industry_Segment__c = 'Automotive', Class__c = 'Agricultural Production',
                                  ownerId = u.id); 
       
        insert acc;
        
        u.Primary_Business__c = '';
        update u;
       
        test.startTest();
              
        u.Primary_Business__c = 'CYN OIL';
        update u;
        
        update acc;

        u.Primary_Business__c = 'CYN ENVIRONMENTAL';
        update u;
        
        update acc;
         u.Primary_Business__c = 'Performance Plus Products';
        update u;
        
        update acc;
         u.Primary_Business__c = 'Emerald Services';
        update u;
        
        update acc;
   
       
        test.stopTest();
    }
    
  private static testMethod void testPopulateAccountFields() {
        user u=[select id from user where profile.name='System administrator' limit 1];
		
        Account acc = [SELECT Id,ShippingPostalCode  FROM Account WHERE Name = 'Test 2' LIMIT 1];
        
      
        acc.Type = 'Customer';
        //acc.Class__c = 'Individuals & Homeowners';
        acc.CS_EPA_ID__c = 'NOTREQUIRED';
        //update acc;
        
        try{
            
            ZIP_Master__c zm = new ZIP_Master__c();
            zm.zip__C = '12345' ;
            zm.name = 'test ZM';
            zm.CurrencyIsoCode = 'USD';
            insert zm;
            
            Territory_master__c tm = new Territory_master__c();
            tm.name = 'Test TM';
            tm.ZIP_Master__c = zm.id;
            
            insert tm;

            
            acc.CurrencyIsoCode = 'CAD';
            update acc;
            

        }
        catch(Exception e)
        {
            Boolean expectedExceptionThrown =  e.getMessage().contains('Currency should have the same value as the parent account\'s currency.') ? true : false;
            
            System.AssertEquals(expectedExceptionThrown, true);
        }
        
  //      try{
  //          acc.ShippingPostalCode = '12121';
  //          acc.BillingPostalCode = '12121';
  //          acc.Manifest_Post_Code__c = '12121';
  //          update acc;
  //      }
  //      catch(Exception e)
  //      {
  //          Boolean expectedExceptionThrown =  e.getMessage().contains('The Country, State and ZIP combination entered is either invalid or not found in the ZIP Master.') ? true : false;
  //          System.AssertEquals(expectedExceptionThrown, true);
  //      } 
        try{
            acc.ShippingPostalCode = null;
            acc.BillingPostalCode = null;
            acc.Manifest_Post_Code__c = null;
            acc.BillingCountry = 'AR';
            update acc;
            

        }
        catch(Exception e)
        {
            Boolean expectedExceptionThrown =  e.getMessage().contains('All the address fields are required for each address type Billing/Shipping/Manifest') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        }
        try{
            acc.ShippingCountry = 'US';
			acc.Generator_Status__c = 'Small Quantity Generator';
            acc.ShippingState = 'NJ';
            acc.ShippingPostalCode = '12345';
            acc.BillingCountry = 'US';
            acc.BillingState = 'NJ';
            acc.BillingPostalCode = '12345';
            acc.Manifest_Post_Code__c = '12345';
            acc.Manifest_Country_Code__c = 'US';
            acc.Manifest_Region_Code__c = 'NJ';
            update acc;
        }
        catch(Exception e)
        {
            system.debug(e);
            Boolean expectedExceptionThrown =  e.getMessage().contains('The Country, State and ZIP combination entered is either invalid or not found in the ZIP Master.') ? true : false;
       //     System.AssertEquals(expectedExceptionThrown, true);
        }
        try{
            acc.ShippingCountry = 'CA';
            acc.ShippingState = 'NJ';
            acc.ShippingPostalCode = '12345';
            acc.BillingCountry = 'CA';
            acc.BillingState = 'NJ';
            acc.BillingPostalCode = '12345';
            acc.Manifest_Post_Code__c = '12345';
            acc.Manifest_Country_Code__c = 'CA';
            acc.Manifest_Region_Code__c = 'NJ';
            update acc;
        }
      
        catch(Exception e)
        {
            Boolean expectedExceptionThrown =  e.getMessage().contains('The Country, State and ZIP combination entered is either invalid or not found in the ZIP Master.') ? true : false;
    //        System.AssertEquals(expectedExceptionThrown, true);
        } 
       /* try{
            acc.Manifest_Post_Code__c = '12121';
            update acc;
        }
        catch(Exception e)
        {
            Boolean expectedExceptionThrown =  e.getMessage().contains('Manifest Postal Code is not found in ZIP Master.') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        }*/
       test.startTest();
        //Account acc3 = [SELECT Credit_Status__c FROM Account WHERE Id = :acc.Id];
        Account acc3 = acc;
        //System.assertEquals(acc3.Credit_Status__c, 'Hold');
        
        User user1 = [SELECT Id,profile.name FROM User WHERE LastName = 'Testing 2' LIMIT 1];
        system.debug('user1-->'+user1);
        
        acc.Type = 'Corporate';
		acc.Generator_Status__c = 'Small Quantity Generator';
        acc.ShippingPostalCode = '12345';
        acc.ShippingCountry = 'US';
        acc.ShippingState = 'NY';
		acc.ShippingStreet= 'Street 1'; 
		acc.ShippingCity= 'BR';
        acc.BillingPostalCode = '12345';
        acc.BillingCountry = 'US';
        acc.BillingState = 'NY';
		acc.BillingStreet= 'Street 1';
		acc.BillingCity = 'BR';
        acc.Manifest_Post_Code__c = '12345';
        acc.Manifest_Country_Code__c = 'US';
        acc.Manifest_Region_Code__c = 'NY';
		acc.Manifest_Locality1__c = 'Street 1';
		acc.Manifest_Address1__c = 'Street 2';
        acc.Credit_Terms__c = 'Net 30 Days';
        acc.win_validated__c = true; 
      //acc.Status__c='Inactive';
          acc.Lost_Reason__c='Company Bought out';
        update acc;
        
        acc3 = [SELECT Rank__c FROM Account WHERE Id = :acc.Id];
        System.assertEquals(acc3.Rank__c, 'CH A Large >200K');
        
        System.runAs(user1){
            acc.win_validated__c = false;
          acc.New_Customer_validated__c = true;
            acc.Existing_Customer_validated__c = true;
            acc.Audit_fields_check__c = true;
            update acc;
        }
        test.stoptest();
    }
    
    @isTest
    static void method8(){
        Id accRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        Account acc = new account();
         acc.Name = 'TestName ';
         acc.Business_Type__c = 'Base';
	     acc.ShippingPostalCode = '12345';	
         acc.ShippingCountry = 'US';	
         acc.ShippingState = 'NY';	
         acc.ShippingStreet= 'Street 1';	
         acc.ShippingCity= 'BR';	
         acc.BillingPostalCode = '12345';	
         acc.BillingCountry = 'US';	
         acc.BillingState = 'NY';	
          acc.BillingStreet= 'Street 1';	
            acc.BillingCity = 'BR';
            acc.WIN_ID__c ='D1234';
            acc.AccountSource = 'Phone';
			acc.Generator_Status__c = 'Small Quantity Generator';
            acc.CS_EPA_ID__c = 'pending';
            acc.RecordTypeId = accRecTypeId;
            acc.Rank__c = 'CH A Large >200K';
            acc.Reporting_Vertical__c = 'Agriculture';
            acc.Industry_Segment__c = 'Agriculture'; 
           insert acc;
           acc.Name = 'testAsh' ;
        update acc ;
    }
    @istest
     static void method9(){
        // Setup Account records
       Account acc = [SELECT Id,ShippingPostalCode,ShippingCountry,ShippingState,BillingCountry,BillingState,BillingPostalCode  FROM Account LIMIT 1];
        
          try{
		    acc.Generator_Status__c = 'Small Quantity Generator';
            acc.ShippingCountry = 'US';
            acc.ShippingState = 'NJ';
            acc.ShippingPostalCode = '12345';
            acc.BillingCountry = 'US';
            acc.BillingState = 'NJ';
            acc.BillingPostalCode = '12345';
            acc.Manifest_Post_Code__c = '12345';
            acc.Manifest_Country_Code__c = 'US';
            acc.Manifest_Region_Code__c = 'NJ';
            update acc;
        }
        catch(Exception e)
        {
            system.debug(e);
            Boolean expectedExceptionThrown =  e.getMessage().contains('The Country, State and ZIP combination entered is either invalid or not found in the ZIP Master.') ? true : false;
       //     System.AssertEquals(expectedExceptionThrown, true);
        }
           
            
     }
    @istest
     static void method10(){
         
        // Setup Account records
       Account acc = [SELECT Id,ShippingPostalCode  FROM Account LIMIT 1];
        
           try{
		    acc.Generator_Status__c = 'Small Quantity Generator';
            acc.ShippingCountry = 'US';
            acc.ShippingState = 'NJ';
            acc.ShippingPostalCode = '12345';
            acc.BillingCountry = 'US';
            acc.BillingState = 'NJ';
            acc.BillingPostalCode = '12345';
            acc.Manifest_Post_Code__c = '12345';
            acc.Manifest_Country_Code__c = 'CA';
            acc.Manifest_Region_Code__c = 'NJ';
            update acc;
        }
      
        catch(Exception e)
        {
            Boolean expectedExceptionThrown =  e.getMessage().contains('The Country, State and ZIP combination entered is either invalid or not found in the ZIP Master.') ? true : false;
    //        System.AssertEquals(expectedExceptionThrown, true);
        } 
     }
    @istest
     static void method11(){
         // Setup Account records
                      
        // List<Territory_master__c> tmList = [select id,ZIP_Code__c,Sales_Business_Unit__c,Territory_Branch_Code__c,Territory_ID__c,Branch_Account__c from Territory_master__c WHERE ZIP_Code__c in: zipSet];
         Account acc = [SELECT Id,Manifest_Post_Code__c  FROM Account LIMIT 1];
         
       try{
            acc.ShippingCountry = 'US';
			acc.Generator_Status__c = 'Small Quantity Generator';
            acc.ShippingState = 'NJ';
            acc.ShippingPostalCode = '12345';
            acc.BillingCountry = 'US';
            acc.BillingState = 'NJ';
            acc.BillingPostalCode = '12345';
            acc.Manifest_Post_Code__c = '12345';
            acc.Manifest_Country_Code__c = 'US';
            acc.Manifest_Region_Code__c = 'NJ';
            update acc;
        }
        catch(Exception e)
        {
            system.debug(e);
            Boolean expectedExceptionThrown =  e.getMessage().contains('The Country, State and ZIP combination entered is either invalid or not found in the ZIP Master.') ? true : false;
       //     System.AssertEquals(expectedExceptionThrown, true);
        }
     }
    @istest
     static void method12(){
         
        // Setup Account records
       Account acc = [SELECT Id,Manifest_Post_Code__c  FROM Account LIMIT 1];
        try{
            acc.ShippingCountry = 'CA';
            acc.ShippingState = 'NJ';
            acc.ShippingPostalCode = '12345';
            acc.BillingCountry = 'CA';
            acc.BillingState = 'NJ';
            acc.BillingPostalCode = '12345';
            acc.Manifest_Post_Code__c = '12345';
            acc.Manifest_Country_Code__c = 'CA';
            acc.Manifest_Region_Code__c = 'NJ';
            update acc;
        }
      
        catch(Exception e)
        {
            Boolean expectedExceptionThrown =  e.getMessage().contains('The Country, State and ZIP combination entered is either invalid or not found in the ZIP Master.') ? true : false;
    //        System.AssertEquals(expectedExceptionThrown, true);
        } 
     }
    @istest
     static void method13(){
                  
        Account acc = [SELECT Id,ShippingPostalCode,Owner_Primary_Business__c,Owner_Territory__c  FROM Account LIMIT 1];
         
       
              acc.Primary_Business__c ='Cyn';
           
           acc.Primary_Branch_Alternate__c=null;
		   acc.Generator_Status__c = 'Small Quantity Generator';
         acc.Primary_Business__c='Emerald Services';
         //acc.Owner_Primary_Business__c='Emerald Services';
          acc.ShippingCountry = 'US';
            acc.ShippingState = 'MA';
            acc.ShippingPostalCode = '43204';
         acc.Primary_Service_Provider_New__c = 'SK BPS';
          List<account> acclist = new list<account>();
         acclist.add(acc);
         //UPDATE accList;
         List<ZIP_Master__c> zipMasterList = new List<ZIP_Master__c>();
        for(Integer i = 0; i < 2; i++){
            zipMasterList.add(new ZIP_Master__c(Zip__c = '43204',Country__c = 'US', State__c = 'NY'));
          
        }
         acc.ZIP_Master__c = zipMasterList[0].Id;
         
         List<Territory__c> Territory = new List<Territory__c>();
        for(Integer i = 0; i < 2; i++){
            Territory.add(new Territory__c(name = '43204'));
          
        }
       insert Territory;
            AccountCRUDHandler.updateZipMaster(acclist);
         AccountCRUDHandler.updateTerritoryLookup(acclist);
     }
     
         @istest
     static void method14(){
         
        Id accRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        
        Profile p = [SELECT Id FROM Profile where name ='system administrator' limit 1]; 
                
        User u = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1].Id,
            LastName = 'last2',
            FirstName='First2',
            Email = 'TESTING2@safety-kleen.com',
            Username = 'TESTING2@safety-kleen.com',
            CompanyName = 'TEST2',
            Title = 'title2',
            Alias = 'alias2',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            Primary_Business__c = 'Safety-Kleen'
        );
        insert u;
        
        User usr = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1].Id,
            LastName = 'last1',
            FirstName='First1',
            Email = 'TESTING1@safety-kleen.com',
            Username = 'TESTING1@safety-kleen.com',
            CompanyName = 'TEST1',
            Title = 'title1',
            Alias = 'alias1',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            Primary_Business__c = 'Safety-Kleen'
        );
        insert usr;
        
      
       system.runas(u)
       {
            List<Account> accList = new List<Account>();   
            Account acc = new account();
            acc.Name = 'TestName123';
            acc.Business_Type__c = 'Base';
            acc.WIN_ID__c ='D1234';
            acc.ownerId = u.id;
            acc.AccountSource = 'Phone';
			acc.Generator_Status__c = 'Small Quantity Generator';
            acc.CS_EPA_ID__c = 'pending';
            acc.RecordTypeId = accRecTypeId;
            acc.Rank__c = 'CH A Large >200K';
            acc.Reporting_Vertical__c = 'Agriculture';
            acc.Industry_Segment__c = 'Agriculture'; 
            accList.add(acc);
            
            system.debug('old account owner' +accList[0].ownerId);
            
            accList[0].ownerId = usr.id ;
            //update accList;
            system.debug('New account owner' +accList[0].ownerId);
           insert accList;
            
        
        
         //Create the AccountTeam
        List<AccountTeamMember> teamList = new List<AccountTeamMember>();
        For (Integer i = 0; i< accList.size(); i++) {
        AccountTeamMember newTeam = new AccountTeamMember(AccountId = accList[i].ID,
        TeamMemberRole = 'Technical Sales',UserId = u.ID);
        teamList.add(newTeam);
        }
        
            
       }
      }

    public static testMethod void retainparentid(){
        Id accRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        Id keyRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Key_Account').getRecordTypeId();
        User u = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1].Id,
            LastName = 'Integration User',
            FirstName='Beacon',
            Email = 'crmsupport@cleanharbors.com',
            Username = 'beaconintegrationuser@cleanharbors.com.chfull' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            Primary_Business__c = 'Healthcare Services'
        );
        insert u;
        test.startTest();
        
        System.runAs(u)
        {
            
            Account acc = new Account(Name = 'Test ', Business_Type__c = 'Base', AccountSource = 'Phone', CS_EPA_ID__c = '12345', /*Sic = '54321',*/ RecordTypeId = keyRecordTypeId,
                                      Rank__c = 'CH A Large >200K', Reporting_Vertical__c = 'Chemical', Industry_Segment__c = 'Chemical - Distributor', Class__c = 'Chemical - Distributor',Type = 'Key Account',
                                     Generator_Status__c = 'Small Quantity Generator', ShippingPostalCode = '12345', ShippingCountry = 'US' , ShippingState = 'NY', ShippingCity = 'Test City' , ShippingStreet = 'Test Street',
                                      billingPostalCode = '12345', billingCountry = 'US' , billingState = 'NY', billingCity = 'Test City' , billingStreet = 'Test Street'
                                     );
            insert acc;
            Account acc2 = new Account(Name = 'Test ', Business_Type__c = 'Base', AccountSource = 'Phone', CS_EPA_ID__c = '12345', /*Sic = '54321',*/ RecordTypeId = accRecTypeId,
                                       Rank__c = 'CH A Large >200K', Reporting_Vertical__c = 'Chemical', Industry_Segment__c = 'Chemical - Distributor', Class__c = 'Chemical - Distributor',Type = 'Customer',
                                      Generator_Status__c = 'Small Quantity Generator', ShippingPostalCode = '12345', ShippingCountry = 'US' , ShippingState = 'NY', ShippingCity = 'Test City' , ShippingStreet = 'Test Street',Win_ID_Sequence_Number__c=0000,
                                       Parentid=acc.id);
            insert acc2;
            Account acc3 = new Account(Name = 'Test ', Business_Type__c = 'Base', AccountSource = 'Phone', CS_EPA_ID__c = '12345', /*Sic = '54321',*/ RecordTypeId = accRecTypeId,
                                       Rank__c = 'CH A Large >200K', Reporting_Vertical__c = 'Chemical', Industry_Segment__c = 'Chemical - Distributor', Class__c = 'Chemical - Distributor',Type = 'Customer',
                                      Generator_Status__c = 'Small Quantity Generator', ShippingPostalCode = '12345', ShippingCountry = 'US' , ShippingState = 'NY', ShippingCity = 'Test City' , ShippingStreet = 'Test Street',Win_ID_Sequence_Number__c=0000);
            Database.DMLOptions dml = new Database.DMLOptions(); 
			dml.DuplicateRuleHeader.AllowSave = true;
			Database.SaveResult sr = Database.insert(acc3, dml);
            acc2.Parentid=null;
            update acc2;
            acc3.Parentid=acc.id;
            update acc3;
            
            test.stopTest();
            account updateacc=[select id,WIN_Validated__c,Win_Validation_NonRollupAccount__c from account where id=:acc2.id limit 1];
            System.assertEquals(true, updateacc.Win_Validation_NonRollupAccount__c);
            
        }  
        
    }  
    
    @isTest
    private static void handleUpdateShipGenRecordOnCustomerOwnerChange(){
        Bypass_Account_Validation__c accountValidation = new Bypass_Account_Validation__c();
        accountValidation.Bypass_Manifest_Address_Requirement__c = false;
        INSERT accountValidation;
        
        Id accRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        User userRec = [SELECT Id FROM User WHERE Alias = 'standt3'];
        
        Account accRec = [
            SELECT Id, OwnerId 
            FROM Account
            WHERE RecordTypeId = :accRecTypeId
            LIMIT 1
        ];
        
        Id customerLocationAccountRecordType = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get(CHConstants.ACCOUNT_RECORD_TYPE_CUSTOMER_LOCATION).getRecordTypeId();
        Account accChildRec = new Account(Name = 'Test Child', Business_Type__c = 'Base', AccountSource = 'Phone', CS_EPA_ID__c = '12345', Sic = '0111', RecordTypeId = customerLocationAccountRecordType,                               
                                  Generator_Status__c = 'Small Quantity Generator',  Rank__c = 'CH A Large >200K', Reporting_Vertical__c = 'Automotive', Industry_Segment__c = 'Automotive', Class__c = 'Agricultural Production',
                                   Primary_Service_Provider_New__c = 'Clean Harbors ENV', ParentId=accRec.Id);
        INSERT accChildRec;
        
        accRec.OwnerId = userRec.Id;
        accRec.Primary_Service_Provider_New__c = 'Clean Harbors ENV';
        UPDATE accRec;
    }

    @isTest
    private static void testtrackAccountsForWinIdGeneration(){
        Id accRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        Account accRec = [SELECT Id, OwnerId, Name, RecordTypeId 
                          FROM Account
                          WHERE RecordTypeId = :accRecTypeId
                          LIMIT 1];                 
      
        accRec.Win_Validate_New__c= false;
        accRec.WIN_ID__c= null;
        Map<Id,Account> oldMap= new Map<Id,Account>(new List<Account>{accRec});
        Account accRecNew= accRec.clone();
        accRecNew.Id= accRec.Id;
        accRecNew.Win_Validate_New__c= true;
        accRecNew.High_Priority__c= true;
        Test.setMock(HttpCalloutMock.class, new MagentoUMOAPIMock(400));
		
        Test.startTest();
            AccountCRUDHandler.trackAccountsForWinIdGeneration(new List<Account>{accRecNew});
        Test.stopTest();
		
        List<Integration_Process__c> integrationRecords= [SELECT Id from Integration_Process__c];
        System.assertEquals(integrationRecords.size(), 1, 'Records Queued successfully');
    }

    @isTest
    private static void testCreatePlatformEventsForLowPriorityWithoutWinId(){
        Id accRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        Account accRec = [SELECT Id, OwnerId, Name, RecordTypeId
                          FROM Account
                          WHERE RecordTypeId = :accRecTypeId
                          LIMIT 1];                 
      
        accRec.Win_Validate_New__c= false;
        accRec.WIN_ID__c= null;
        Map<Id,Account> oldMap= new Map<Id,Account>(new List<Account>{accRec});
        Account accRecNew= accRec.clone();
        accRecNew.Id= accRec.Id;
        accRecNew.Win_Validate_New__c= true;
        accRecNew.High_Priority__c= false;
		
        Test.startTest();
            AccountCRUDHandler.trackAccountsForWinIdGeneration(new List<Account>{accRecNew});
        Test.stopTest();
		
        List<Integration_Process__c> integrationRecords= [SELECT Id from Integration_Process__c];
        System.assertEquals(integrationRecords.size(), 1, 'Records Queued successfully');
    }
    
    @isTest
    private static void testValidateHybridLOBForExclusiveRecords(){
        Account account=getCorpAccount();
        account.Hybrid_Central_LOBs__c= 'Antifreeze;CleanPack;Vac Services;UMO';
        account.Hybrid_Local_LOBs__c= 'Allied;Blended Oil Sales – Direct;Containerized Waste;Emergency Response;Field Services;Oil Filter Recycling;Oily Water;Parts Washer';      

        Test.startTest();
            AccountCRUDHandler.validateHybridLOB(new List<Account>{account},null);
        Test.stopTest();

        System.assertEquals(0,account.getErrors().size(), 'Validation succeeded');
    }

    @isTest
    private static void testInsertNewAccountCase(){
        Id accRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        Account accRec = [SELECT Id, OwnerId, Name, RecordTypeId, New_Customer_validated__c, Existing_Customer_Validated__c, Inactivate_Reactivate_In_Progress__c, 
        Audit_Account_Name__c, Audit_Business_Type__c, Audit_Vertical__c, Audit_Class__c, Audit_Sic_code__c, Audit_GenReg_Id__c, Audit_EPA_ID__c, 
        audit_state_epa_id__c, Audit_Corporate_Account__c, Audit_Chain_Account__c, Audit_Corporate_Address__c, Audit_Shipping_Street__c, Audit_Shipping_State__c, 
                   Audit_Shipping_City__c, Audit_Shipping_Country__c, Audit_Shipping_Postal_Code__c, Audit_Billing_Address__c, Audit_Billing_Street__c,
                   Audit_Billing_State__c, Audit_Billing_City__c, Audit_Billing_Country__c, Audit_Billing_Postal_Code__c, Audit_Manifest_Street1__c, Audit_Manifest_Street2__c, 
                   Audit_Manifest_State__c, Audit_Manifest_City__c, Audit_Manifest_Country__c, Audit_Manifest_Postal_Code__c, Audit_Site_Id__c, 
                   Audit_Waste_Oil__c, Audit_Insite__c, Audit_Rank__c, Audit_Division__c, Audit_Expired__c, 
                   Audit_Lost_Reason__c, Audit_Expired_Date__c, Business_Type__c, Industry_Segment__c, Class__c, Status__c, Sic, GenReg__c, CS_EPA_ID__c, 
                   State_epa_id__c, parentid, Expired__c, Chain__c, ShippingStreet, Shippingcity, ShippingState, ShippingCountry,
                   ShippingPostalCode, BillingStreet, Billingcity, BillingState, BillingCountry, BillingPostalCode, Duplicate_Reason__c, Duplicate_Justification__c
                          FROM Account
                          WHERE RecordTypeId = :accRecTypeId
                          LIMIT 1];             
        Map<Id,Account> oldMap= new Map<Id,Account>(new List<Account>{accRec});
        Account accRecNew= accRec.clone();
        accRecNew.New_Customer_validated__c= true;
        accRecNew.Id= accRec.Id;

        Test.startTest();
            AccountCRUDHandler.InsertNewAccountCase(new List<Account>{accRecNew}, oldMap);
        Test.stopTest();

        System.assertEquals(1,[select id from Case where accountId=:accRec.Id].size(), 'Creation successful');
    }
    
    @isTest
    private static void testCreateMainContact(){
        Id competitorAccountRecordType = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get(CHConstants.ACCOUNT_RECORD_TYPE_COMPETITOR).getRecordTypeId();
        Id accRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        Account accRec = [SELECT Id, OwnerId, Name 
        FROM Account
        WHERE RecordTypeId = :accRecTypeId
        LIMIT 1];     
        accRec.RecordTypeId= competitorAccountRecordType;

        Test.startTest();
            AccountCRUDHandler.createMainContact(new List<Account>{accRec});
        Test.stopTest();

        System.assertEquals(1,[select id from Contact where accountId=:accRec.Id].size(), 'Creation successful');
    }

   
    @isTest
    private static void testUpdateBeaconMainContactList(){
        Id competitorAccountRecordType = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get(CHConstants.ACCOUNT_RECORD_TYPE_COMPETITOR).getRecordTypeId();
        Id accRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        Account accRec = [SELECT Id, OwnerId, Name, WIN_ID__c, RecordTypeId, WIN_Validated__c, Status__c 
        FROM Account
        WHERE RecordTypeId = :accRecTypeId
        LIMIT 1];  
        accRec.Win_Validated__c= true;  

        Test.startTest();
            createMainContact(accRec.Id);
            AccountCRUDHandler.UpdateBeaconMainContactList(new List<Account>{accRec});
        Test.stopTest();

        System.assertEquals(1,[select id from Contact where accountId=:accRec.Id and WIN_Validated__c= true].size(), 'Contact updated with WIN_Validated__c as true');
    }
    
	@istest
     private static void testLockAccount(){
         
        Id accRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        Id branchRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Branch').getRecordTypeId();
        User u = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1].Id,
            LastName = 'last',
            FirstName='First',
            Email = 'TEST@safety-kleen.com',
            Username = 'TEST@safety-kleen.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            Primary_Business__c = 'Safety-Kleen'
        );
        insert u;
       	List<Id> accId = new List<Id>();
 		Account acc = new Account(Name = 'Test ', Business_Type__c = 'Base', AccountSource = 'Phone', CS_EPA_ID__c = '12345', Sic = '0111', RecordTypeId = accRecTypeId,                               
                                 Generator_Status__c = 'Small Quantity Generator', Rank__c = 'CH A Large >200K', Reporting_Vertical__c = 'Automotive', Industry_Segment__c = 'Automotive', Class__c = 'Agricultural Production',
                                  ownerId = u.id, Primary_Service_Provider_New__c='SK ENV'); 
        
        accId.add(acc.id);
        AccountCRUDHandler.lockAccountRecordbyId(accId);         
    }

    @isTest
    private static void testHandleAccountOwnershipChanges(){
        Id currentUserId = UserInfo.getUserId();
        User userRec = [
            SELECT Id, Sales_Person_Type__c, Profile.Name, Territory__c
            FROM User
            WHERE Id =:currentUserId
        ];   
        List<ZIP_Master__c> zipMasterList = new List<ZIP_Master__c>();
        zipMasterList.add(new ZIP_Master__c(Zip__c = '23456',Country__c = 'US', State__c = 'NY'));
        insert zipMasterList;        
        
        Territory__c t = new Territory__c();
        t.name = 'TS-AM-Camarillo-CA-05';
        t.Territory_OwnerID__c = userRec.id;
        t.Primary_Business__c = 'Safety-Kleen';
        insert t;
        
        Territory_Master__c tm = new Territory_Master__c();
        tm.ZIP_Master__c = zipMasterList[0].Id;
        tm.Sales_Business_Unit__c = 'SK ENV';
        tm.Name = 'SK ENV Terr';
        tm.Territory_ID__c = t.Id;
        insert tm;
        
		Id corpRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Corporate').getRecordTypeId();
		user activeUser =[select id from user where IsActive = True limit 1];
        Account corpAccount = new Account();
        corpAccount.Name = 'Parent Corporate Account';
        corpAccount.ShippingCountry = 'US';
        corpAccount.ShippingState = 'NY';
        corpAccount.ShippingStreet = 'Test Street';
        corpAccount.ShippingCity = 'Ashburn';
        corpAccount.ShippingPostalCode = '12345';
		corpAccount.dunbrdst__c = '12345';
        corpAccount.KAM_Manager__c = activeUser.id;
        corpAccount.KAM_Support__c = activeUser.id;
        corpAccount.OwnerId = activeUser.id;
        corpAccount.RecordTypeId = corpRecTypeId;
        corpAccount.Buying_Decision__c = 'Locally Managed';
        corpAccount.Account_Assign_Override__c = false;
        corpAccount.Status__c = 'Active';
        insert corpAccount;
        
        Id accRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
		Account accRec = new Account(Name = 'Test567', Business_Type__c = 'Base', AccountSource = 'Phone', CS_EPA_ID__c = '12345', Sic = '0111', RecordTypeId = accRecTypeId,                               
                                   Rank__c = 'CH A Large >200K', Reporting_Vertical__c = 'Automotive', Industry_Segment__c = 'Automotive', Class__c = 'Agricultural Production',
                                   Primary_Service_Provider_New__c = 'SK ENV', Primary_Business__c = 'Safety-Kleen', ParentId = corpAccount.id, Territory_ID_SKE__c = t.id,
                                   ZIP_Master__c = zipMasterList[0].Id, Territory_ID_SK__c = t.id, ShippingPostalCode = '23456', ShippingCountry = 'US',
                                 Generator_Status__c = 'Small Quantity Generator',  ShippingState = 'NY', ShippingCity = 'Test City' , ShippingStreet = 'Test Street', billingPostalCode = '23456', billingCountry = 'US', 
                                   billingState = 'NY', billingCity = 'Test City' , billingStreet = 'Test Street');
        insert accRec;
		accRec.Primary_Business__c = 'BPS';
        accRec.Primary_Service_Provider__c = 'SK BPS';
        update accRec;
        System.assertEquals(1,[select id from account where Id=:accRec.Id].size(), 'Record Created');

    }

    
    private static testMethod void testcreateAccountPlatformEvents(){
        Id accRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        Account accRec = [SELECT Id, OwnerId, Name 
                          FROM Account
                          WHERE RecordTypeId = :accRecTypeId
                          LIMIT 1];                 
      
        accRec.Win_Validate_New__c= false;
        accRec.WIN_ID__c= null;
        Map<Id,Account> oldMap= new Map<Id,Account>(new List<Account>{accRec});
        Account accRecNew= accRec.clone();
        accRecNew.Id= accRec.Id;
        accRecNew.Win_Validate_New__c= true;
        accRecNew.WIN_ID__c= 'AR001';
        accRecNew.High_Priority__c= true;
		
        Test.startTest();
        List<Database.SaveResult> saveResult = AccountCRUDHandler.createAccountPlatformEvents(new List<Account>{accRecNew});
        Test.stopTest();
		System.assertEquals(true, saveResult[0].isSuccess());
    }
    private static testMethod void testcreateAccountPlatformEventsLowPriority(){
       
        Id accRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        Account accRec = [SELECT Id, OwnerId, Name 
                          FROM Account
                          WHERE RecordTypeId = :accRecTypeId
                          LIMIT 1];                 
      
        accRec.Win_Validate_New__c= false;
        accRec.WIN_ID__c= null;
        Map<Id,Account> oldMap= new Map<Id,Account>(new List<Account>{accRec});
        
		
        Test.startTest();
        Account accRecNew1= accRec.clone();
        accRecNew1.Id= accRec.Id;
        accRecNew1.Win_Validate_New__c= true;
        accRecNew1.WIN_ID__c= 'AR001';
        accRecNew1.High_Priority__c= false;
        List<Database.SaveResult> saveResult = AccountCRUDHandler.createAccountPlatformEvents(new List<Account>{accRecNew1});
        Test.stopTest();
		System.assertEquals(true, saveResult[0].isSuccess());
    }

    public static testMethod void handleupdateSecondaryOwner(){
        Id accRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        Territory__c t = new Territory__c();
        t.name = 'TS-AM-Camarillo-CA-01';
        t.Territory_OwnerID__c = UserInfo.getUserId();
        insert t;
        User u = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Integration' LIMIT 1].Id,
            LastName = 'Integration User',
            FirstName='Beacon',
            Email = 'crmsupport@cleanharbors.com',
            Username = 'beaconintegrationuser@cleanharbors.com.chfull' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            Territory__c = t.id,
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            Primary_Business__c = 'Healthcare Services'
        );
        insert u;
        List<ZIP_Master__c> zipMasterList = [select id,name,Zip__c from ZIP_Master__c];
        Territory_Master__c tm1 = new Territory_Master__c();
        tm1.ZIP_Master__c = zipMasterList[0].Id;
        tm1.Sales_Business_Unit__c = 'BPS';
        tm1.Name = 'SK BPS IS';
        tm1.Territory_ID__c = t.Id;
        insert tm1;        
        Test.startTest();
        Account acc1 = new Account(Name = 'Test 123', Business_Type__c = 'Base', AccountSource = 'Phone', CS_EPA_ID__c = '12345', RecordTypeId = accRecTypeId,
                                   Rank__c = 'CH A Large >200K', Reporting_Vertical__c = 'Chemical', Industry_Segment__c = 'Chemical - Distributor', Class__c = 'Chemical - Distributor',Type = 'Key Account',ZIP_Master__c=zipMasterList[0].Id,
                                  Generator_Status__c = 'Small Quantity Generator', ShippingPostalCode = '12345', ShippingCountry = 'US' , ShippingState = 'NY', ShippingCity = 'Test City' , ShippingStreet = 'Test Street',Primary_Business__c = 'BPS',Primary_Service_Provider_New__c='SK BPS',
                                   billingPostalCode = '12345', billingCountry = 'US' , billingState = 'NY', billingCity = 'Test City' , billingStreet = 'Test Street',ownerid=u.id
                                  );  
        insert acc1;
        
        Test.stopTest();
        Account updateacc=[select id,WIN_Validated__c,Win_Validation_NonRollupAccount__c,Secondary_Owner__c from account where id=:acc1.id limit 1];
        System.assertEquals(true, updateacc.Secondary_Owner__c == null );
    }

    @isTest
    private static void testSetTerritoryOverrideFields(){    
           	User u = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Inside Sales Agent' LIMIT 1].Id,
            LastName = 'LastName1', FirstName='FirstName1', Email = 'TEST5863@safety-kleen.com', Username = 'TEST5863@safety-kleen.com' + System.currentTimeMillis(),
            CompanyName = 'TEST', Territory__c = 'TS-AM-Camarillo-CA-05', Title = 'title', Alias = 'alia78',TimeZoneSidKey = 'America/Los_Angeles',EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', Primary_Business__c = 'Safety-Kleen'
        );
        insert u;
        System.runAs(u)
        {
            List<ZIP_Master__c> zipMasterList = new List<ZIP_Master__c>();
            zipMasterList.add(new ZIP_Master__c(Zip__c = '23456',Country__c = 'US', State__c = 'NY'));
            insert zipMasterList;        
            
            Territory__c t = new Territory__c();
            t.name = 'TS-AM-Camarillo-CA-05';
            t.Territory_OwnerID__c = u.id;
            t.Primary_Business__c = 'Safety-Kleen';
            insert t;
            
            Territory_Master__c tm = new Territory_Master__c();
            tm.ZIP_Master__c = zipMasterList[0].Id;
            tm.Sales_Business_Unit__c = 'SK ENV';
            tm.Name = 'SK ENV Terr';
            tm.Territory_ID__c = t.Id;
            insert tm;            

            Id accRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
            Account accRec = new Account(Name = 'Test567', Business_Type__c = 'Base', AccountSource = 'Phone', CS_EPA_ID__c = '12345', Sic = '0111', RecordTypeId = accRecTypeId,                               
                                       Rank__c = 'CH A Large >200K', Reporting_Vertical__c = 'Automotive', Industry_Segment__c = 'Automotive', Class__c = 'Agricultural Production',
                                       Primary_Service_Provider_New__c = 'SK ENV', Primary_Business__c = 'Safety-Kleen', Territory_ID_SKE__c = t.id,
                                       ZIP_Master__c = zipMasterList[0].Id, Territory_ID_SK__c = t.id, ShippingPostalCode = '23456', ShippingCountry = 'US',
                                       ShippingState = 'NY', ShippingCity = 'Test City' , ShippingStreet = 'Test Street', billingPostalCode = '23456', billingCountry = 'US', 
                                       billingState = 'NY', billingCity = 'Test City' , billingStreet = 'Test Street');
            insert accRec;
            Map<Id,Account> oldMap= new Map<Id,Account>(new List<Account>{accRec});
            Account accRecNew= accRec.clone();
            accRecNew.Existing_Customer_validated__c= true;
            accRecNew.Id= accRec.Id;
            accRecNew.ownerID = u.id;
            update accRecNew;
            AccountCRUDHandler.setTerritoryOverrideFields(new Map<Id,Account>(new List<Account>{accRecNew}), oldMap);
            System.assertEquals(true, accRecNew.Existing_Customer_validated__c);
        }
    }

    @isTest
    private static void testhandleParentAccountChange(){
        Map<Id, Account> newAccountMap = new Map<Id, Account>();
        Map<Id, Account> oldAccountMap = new Map<Id, Account>();
		Id customerAccountRecordType = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get(CHConstants.ACCOUNT_RECORD_TYPE_CUSTOMER).getRecordTypeId();
        Id customerLocationAccountRecordType = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get(CHConstants.ACCOUNT_RECORD_TYPE_CUSTOMER_LOCATION).getRecordTypeId();
       	Id CORPORATE_ACCOUNT_TYPE = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get(CHConstants.ACCOUNT_RECORD_TYPE_CORPORATE).getRecordTypeId();
        User activeUser = [SELECT Id FROM User WHERE isActive = True Limit 1];

        Account corpAccount = new Account();
        corpAccount.Name = 'Parent Corporate Account';
		corpAccount.dunbrdst__c = '12345';
        corpAccount.ShippingCountry = 'US';
        corpAccount.ShippingState = 'NY';
        corpAccount.ShippingStreet = 'Test Street';
        corpAccount.ShippingCity = 'Ashburn';
        corpAccount.ShippingPostalCode = '12345';
        corpAccount.KAM_Manager__c = activeUser.id;
        corpAccount.KAM_Support__c = activeUser.id;
        corpAccount.OwnerId = activeUser.id;
        corpAccount.RecordTypeId = CORPORATE_ACCOUNT_TYPE;
        corpAccount.Buying_Decision__c = 'Locally Managed';
        corpAccount.Account_Assign_Override__c = false;
        corpAccount.Status__c = 'Active';
        corpAccount.Active_ER_Contract__c = false;
        insert corpAccount;
        
        Account accRec = [SELECT Id, OwnerId, Name 
                          FROM Account
                          WHERE RecordTypeId = :customerAccountRecordType
                          LIMIT 1];     
        
        Account custAccount = new Account(Name = 'Test ', Business_Type__c = 'Base', AccountSource = 'Phone', CS_EPA_ID__c = '12345', /*Sic = '54321',*/ RecordTypeId = customerAccountRecordType,
                                       Rank__c = 'CH A Large >200K', Reporting_Vertical__c = 'Chemical', Industry_Segment__c = 'Chemical - Distributor', Class__c = 'Chemical - Distributor',Type = 'Customer',
                                      Generator_Status__c = 'Small Quantity Generator', ShippingPostalCode = '12345', ShippingCountry = 'US' , ShippingState = 'NY', ShippingCity = 'Test City' , ShippingStreet = 'Test Street',
                                      Active_ER_Contract__c = true, Parentid=corpAccount.id);
        insert custAccount;

        Account shipToGenAccount = new Account(Name = 'Test Child1', Business_Type__c = 'Base', AccountSource = 'Phone', CS_EPA_ID__c = '12345', Sic = '0111', RecordTypeId = customerLocationAccountRecordType,                               
                                  Generator_Status__c = 'Small Quantity Generator',  Rank__c = 'CH A Large >200K', Reporting_Vertical__c = 'Automotive',ShippingPostalCode = '12345', ShippingCountry = 'US' , ShippingState = 'NY', ShippingCity = 'Test City' , 
                                  ShippingStreet = 'Test Street1', Industry_Segment__c = 'Automotive', Class__c = 'Agricultural Production',
                                  Active_ER_Contract__c = true,Primary_Service_Provider_New__c = 'Clean Harbors ENV', ParentId=custAccount.Id);
        insert shipToGenAccount;
        
        Contract c = new Contract();
        c.Name = 'Test Contract1';
        c.AccountId = custAccount.Id;
        c.Status = 'Active';
        c.Job_Type__c = 'ER';
        c.StartDate = System.today();
        c.EndDate = System.today()+1;
        c.Description = 'testDescription';
        insert c;
        
        oldAccountMap.put(shipToGenAccount.id,shipToGenAccount);
        Account shipToGenAccountNew= shipToGenAccount.clone();
        shipToGenAccountNew.ParentId=accRec.id;
        newAccountMap.put(shipToGenAccount.id,shipToGenAccountNew);
        
        Test.startTest();
            AccountCRUDHandler.handleParentAccountChange(newAccountMap,oldAccountMap);
        Test.stopTest();
        System.assertEquals(1,[select id from account where Id=:shipToGenAccount.Id].size(), 'Record Updated');

    }
	
	@isTest
    private static void validateAccountUnitTest(){
        Id custRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId(); 
        Id customerLocationAccountRecordType = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get(CHConstants.ACCOUNT_RECORD_TYPE_CUSTOMER_LOCATION).getRecordTypeId();
        
        User u = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1].Id,
            LastName = 'Integration User',
            FirstName='Beacon',
            Email = 'crmsupport@cleanharbors.com',
            Username = 'beaconintegrationuser@cleanharbors.com.chfull' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            Primary_Business__c = 'Healthcare Services'
        );
        insert u;
        test.startTest();
        
        System.runAs(u)
        {
            
            Account acc = new Account(Name = 'Test ', Business_Type__c = 'Base', AccountSource = 'Phone', CS_EPA_ID__c = '12345', /*Sic = '54321',*/ RecordTypeId = custRecordTypeId,
                                      Rank__c = 'CH A Large >200K', Reporting_Vertical__c = 'Chemical', Industry_Segment__c = 'Chemical - Distributor', Class__c = 'Chemical - Distributor',
                                      WIN_ID__c = null,
                                      billingPostalCode = '12345', billingCountry = 'US' , billingState = 'NY', billingCity = 'Test City' , billingStreet = 'Test Street'
                                     );
            insert acc;
            Account acc2 = new Account(Name = 'Test ', Business_Type__c = 'Base', AccountSource = 'Phone', CS_EPA_ID__c = '12345', /*Sic = '54321',*/ RecordTypeId = customerLocationAccountRecordType,
                                       Rank__c = 'CH A Large >200K', Reporting_Vertical__c = 'Chemical', Industry_Segment__c = 'Chemical - Distributor', Class__c = 'Chemical - Distributor',
                                       ShippingPostalCode = '12345', ShippingCountry = 'US' , ShippingState = 'NY', ShippingCity = 'Test City' , ShippingStreet = 'Test Street',Win_ID_Sequence_Number__c=0000,
                                       Parentid=acc.id);
            insert acc2;
            
            try{
                Accounts.validateAccount(new Set<Id>{acc.Id}, true);
            }catch(Exception exObj){
                System.assert(exObj.getMessage() != NULL);
            }
            
            Tax_Document__c taxDoc = new Tax_Document__c();
            taxDoc.Account__c = acc.Id;
            INSERT taxDoc;
            
            Blob bodyBlob=Blob.valueOf('Unit Test ContentVersion Body to be insert in test class for testing the'); 
            
            ContentVersion contentVersion_1 = new ContentVersion(
                Title='SampleTitle', 
                PathOnClient ='SampleTitle.jpg',
                VersionData = bodyBlob, 
                origin = 'H'
            );
            insert contentVersion_1; 
            
            ContentVersion contentVersion_2 = [SELECT Id, Title, ContentDocumentId 
                                               FROM ContentVersion WHERE Id = :contentVersion_1.Id LIMIT 1];
            
            ContentDocumentLink contentlink = new ContentDocumentLink();
            contentlink.LinkedEntityId = taxDoc.id;
            contentlink.contentdocumentid = contentVersion_2.contentdocumentid;
            contentlink.ShareType = 'V';
            insert contentlink;
            
            try{
                Accounts.validateAccount(new Set<Id>{acc.Id}, true);
            }catch(Exception exObj){
                System.assert(exObj.getMessage() != NULL);
            }
            
            acc.ShippingPostalCode = '12345';
            acc.ShippingCountry = 'US';
            acc.ShippingState = 'NY';
            acc.ShippingCity = 'Test City';
            acc.ShippingStreet = 'Test Street';
            UPDATE acc;
            
            try{
                Accounts.validateAccount(new Set<Id>{acc2.Id}, true);
            }catch(Exception exObj){
                System.assert(exObj.getMessage() != NULL);
            }
            
            Contact con = new Contact(AccountId = acc.Id);
            con.LastName = 'Contact';
            con.FirstName = 'Main';
            con.Salutation = 'Mr';
            con.Title = 'Default Mgr';
            con.Phone = '781-792-5000';
            con.Contact_Type__c = 'MAIN';
            insert con;
            
            try{
                Accounts.validateAccount(new Set<Id>{acc.Id}, true);
            }catch(Exception exObj){
                System.assert(exObj.getMessage() != NULL);
            }
            
            con.Email = 'test@test.com';
            UPDATE con;
            
            try{
                //AccountCRUDHandler.checkAndValidateAccountWithoutWinId(new List<Account>{acc});
                Accounts.validateAccount(new Set<Id>{acc.Id}, true);                
            }catch(Exception exceptionObj){}
            
        }
    }	
	
    @isTest
    Private static void testinsertShippingAddressWhenLeadConverted() {
        Lead testLead = new Lead(
            FirstName = TEST_FIRST_NAME,LastName = TEST_LAST_NAME,Salutation = TEST_SALUTATION,Company = TEST_COMAPNY,Title = TEST_TITLE,Phone = TEST_PHONE,CurrencyIsoCode = TEST_CURRENCYISOCODE,
            LeadSource  = TEST_LEADSOURCE,Status = TEST_STATUS,Generator_Status__c = TEST_Generator_Status, Street = TEST_Street,City = TEST_City,State = TEST_State,Country = TEST_Country,PostalCode = TEST_POSTALCODE
        );
		 insert testLead;
        
        List<Account> accList = new List<Account>();
        Id accRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        Account testAccount = new Account();
            for(Integer i = 0; i < 10; i++){          
		    testAccount.Name = TEST_NAME;
            testAccount.CS_EPA_ID__c = TEST_EPA_ID;
            testAccount.RecordTypeId = accRecTypeId;
            testAccount.BillingStreet = testLead.Street;
            testAccount.BillingCity = testLead.City;
            testAccount.BillingState = testLead.State;
            testAccount.BillingPostalCode = testLead.PostalCode;
            testAccount.BillingCountry = testLead.Country;
            testAccount.ShippingStreet = testLead.Street;
            testAccount.ShippingCity = testLead.City;
            testAccount.ShippingState = testLead.State;
            testAccount.ShippingPostalCode = testLead.PostalCode;
            testAccount.ShippingCountry = testLead.Country;
            testAccount.LeadID__c = testLead.Id;
            accList.add(testAccount);
            }
        insert testAccount; 
       
	    Test.startTest();
            List<Account> accountList = new List<Account>{testAccount};
            AccountCRUDHandler.insertShippingAddressWhenLeadConverted(accountList);
        Test.stopTest();

        Account acc = [SELECT ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode, ShippingCountry FROM Account WHERE Id = :testAccount.Id];
        System.assertEquals(testAccount.BillingStreet, acc.ShippingStreet);
        System.assertEquals(testAccount.BillingCity, acc.ShippingCity);
        System.assertEquals(testAccount.BillingState, acc.ShippingState);
        System.assertEquals(testAccount.BillingPostalCode, acc.ShippingPostalCode);
        System.assertEquals(testAccount.BillingCountry, acc.ShippingCountry);
    }
    @isTest
    Private static void testGetReviewerForParentCase() {
 
         user u=[select id from user where profile.name='Master Data Management' limit 1];
         Id accRecTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByDeveloperName().get(CHConstants.ACCOUNT_RECORD_TYPE_CUSTOMER).getRecordTypeId();
         Id caseRecTypeId =  Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(CHConstants.CASE_RECORD_TYPE_ACCOUNT_UPDATE_VALIDATIONS).getRecordTypeId();
    
         Test.startTest();   
    
         Account testAccount = new Account(Name = 'Test567', CS_EPA_ID__c = '12345', RecordTypeId = accRecTypeId,                               
                                Rank__c = 'CH A Large >200K', Reporting_Vertical__c = 'Automotive', Industry_Segment__c = 'Automotive', Class__c = 'Agricultural Production',
                                Primary_Service_Provider_New__c = 'SK ENV', Primary_Business__c = 'Safety-Kleen', 
                                ShippingPostalCode = '10047', ShippingCountry = 'US',
                                ShippingState = 'NY', ShippingCity = 'New York' , ShippingStreet = 'Test Street', billingPostalCode = '10047', billingCountry = 'US', 
                                billingState = 'NY', billingCity = 'New York' , billingStreet = 'Test Street');
          insert testAccount;
      Case newCase = new Case(
         AccountId = testAccount.Id,
         Status = 'New',
         RecordTypeId = caseRecTypeId
      );
        insert newCase;
        newCase.MDM_Approver__c = u.id; 
        update newCase;
        String reviewer = AccountCRUDHandler.getReviewerForParentCase(testAccount.Id);
     Case testCase = new Case(
         AccountId = testAccount.Id,
         Status = 'Complete - Approved',
         MDM_Approver__c = u.id,
         RecordTypeId = caseRecTypeId
      );
        insert testCase;
      Case newCase1 = new Case(
         AccountId = testAccount.Id,
         Status = 'New',
         MDM_Approver__c = testCase.MDM_Approver__c,
         RecordTypeId = caseRecTypeId
       );
       
        insert newCase1;
        String reviewer1 = AccountCRUDHandler.getReviewerForParentCase(testAccount.Id); 
     Case testCase1 = new Case(
         AccountId = testAccount.Id,
         Status = 'In Progress',
         MDM_Approver__c = u.id,
         RecordTypeId = caseRecTypeId
       );
        insert testCase1;
     Case newCase2 = new Case(
        AccountId = testAccount.Id,
        Status = 'New',
        MDM_Approver__c = testCase1.MDM_Approver__c,
        RecordTypeId = caseRecTypeId
       );
        insert newCase2;
        String reviewer2 = AccountCRUDHandler.getReviewerForParentCase(testAccount.Id);
          
      Test.stopTest();
    
        System.assertNotEquals(newCase.MDM_Approver__c, reviewer);
        System.assertNotEquals(newCase1.MDM_Approver__c, reviewer1);
        System.assertEquals(newCase2.MDM_Approver__c, reviewer2);
   
      }
	@isTest
    Private static void testCopyCorpAsPayToAddress (){
       List<Account> accList = new List<Account>();
       Account acc = [Select id,ShippingStreet, ShippingCity,ShippingState,ShippingCountry, SHippingPostalCode from Account Limit 1];
        	acc.ShippingCountry = 'US';
            acc.ShippingState = 'NY';
        	acc.ShippingStreet = 'Test Street';
       	    acc.ShippingCity = 'Ashburn';
            acc.ShippingPostalCode = '12345';
        	acc.PayTo_Address_Same_As_Corp__c  = True;
        	accList.add(acc);
            update accList;
        Test.StartTest();
        AccountCRUDHandler.copyCorpAsPayToAddress(accList, null);
        Test.StopTest();
        
        System.assertEquals('NY', acc.Pay_To_Region_Code__c);
        System.assertEquals('Test Street', acc.PayTo_Address1__c);
        System.assertEquals('US', acc.Pay_To_Country_Code__c);
        System.assertEquals('Ashburn', acc.Pay_To_Locality1__c);
        System.assertEquals('12345', acc.Pay_To_Post_Code__c);
    }
}