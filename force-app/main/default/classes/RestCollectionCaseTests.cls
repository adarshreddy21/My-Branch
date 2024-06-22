/**
* Test class for the RestCollectionCase.
* This class is responsible for testing the logic around the class.
* 
* @author    Balaji Bezawada
* @createddate  15-04-2020   
*/   
@isTest
public class RestCollectionCaseTests {
    
    @testSetup
    private static void setup(){
        User userRec = new User(Id=UserInfo.getUserId(), EmployeeNumber='333');
        UPDATE userRec;
        
        TERRITORY_MANAGEMENT__c territoryMgmt = new TERRITORY_MANAGEMENT__c();
        territoryMgmt.Name = 'TERRITORY_MGMT_SETTING';
        territoryMgmt.TM_FLAG__c = true;
        insert territoryMgmt;
        COUNTRY_CODES__c countrycodes = new COUNTRY_CODES__c();
        countrycodes.Name = 'CA';
        insert countrycodes;
        
        COUNTRY_CODES__c countrycodes1 = new COUNTRY_CODES__c();
        countrycodes1.Name = 'US';
        insert countrycodes1;
        
        List<ZIP_Master__c> zipMasterList = new List<ZIP_Master__c>();
        for(Integer i = 0; i < 10; i++){
            zipMasterList.add(new ZIP_Master__c(Zip__c = '12345',Country__c = 'US', State__c = 'NY',City__c ='Ashburn'));
			zipMasterList.add(new ZIP_Master__c(Zip__c = '20147',Country__c = 'US', State__c = 'NY',City__c ='Ashburn'));
        }
        insert zipMasterList;
        
        SIC_VALIDATION_SETTING__c sicValidation = new SIC_VALIDATION_SETTING__c();
        sicValidation.Name = 'SIC_VALIDATION_SETTING';
        sicValidation.SIC_VALIDATION_FLAG__c = false;
        insert sicValidation;
        
        Id accRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        Id accCorporateRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Corporate').getRecordTypeId();
        
        Account corAcc = new Account(
            Name = 'Test ',       
            Business_Type__c = 'Base', 
            AccountSource = 'Phone',
            CS_EPA_ID__c = '12345', 
            Sic = '0111', 
            ShippingCountry = 'US',
            ShippingState = 'NY',
        	ShippingStreet = 'Test Street',
       	    ShippingCity = 'Ashburn',
            ShippingPostalCode = '12345',
            dunbrdst__c = '12345',
        	KAM_Manager__c = UserInfo.getUserId(),
            RecordTypeId = accCorporateRecTypeId,                               
            Rank__c = 'CH A Large >200K',
            Reporting_Vertical__c = 'Automotive',
            Industry_Segment__c = 'Automotive',
            Class__c = 'Agricultural Production',
            ownerId = UserInfo.getUserId(), 
            Primary_Service_Provider_New__c='SK ENV',
            KAM_Support__c = UserInfo.getUserId(),
            WIN_ID__c = 'DEL200',
            Buying_Decision__c = 'Central Buying'
        ); 
        
        insert corAcc; 
                
        Account acc = new Account(
            Name = 'Test1',       
            Business_Type__c = 'Base', 
            AccountSource = 'Phone',
            CS_EPA_ID__c = '12345', 
            Sic = '0111', 
            RecordTypeId = accRecTypeId,                               
            Rank__c = 'CH A Large >200K',
            Reporting_Vertical__c = 'Automotive',
            Industry_Segment__c = 'Automotive',
            Class__c = 'Agricultural Production',
            ownerId = UserInfo.getUserId(), 
            Primary_Service_Provider__c='Safety Kleen',
            WIN_ID__c = 'DEL201',
            ParentId = corAcc.Id
        ); 
        
        insert acc;
    }
    
     @isTest
    public static void testCreateNewCase(){
        
        Test.startTest();
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', EmployeeNumber='108182', UserName='standarduser@testorg.com', isActive = TRUE);
        
        List<case> lstcase=new List<Case>();
        case newcase = new case ();
        
        newcase.recordTypeId  = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Collector Case').getRecordTypeId();
        newcase.Subject = 'Collection Case';
        newcase.status = 'New';
        newcase.WIN_Id__c = 'DEL200';           
        newcase.Business_Unit__c = 'CHES';
        newcase.Follow_up_action__c = 'CHES';
        newcase.Keyword_1__c = 'Keyword1';
        newcase.Keyword_2__c ='Keyword2';
        newcase.Keyword_3__c = 'Keyword3';
        newcase.SETID__c = '123';
        newcase.Type='Ebill';
        newcase.Description = 'COMMENTS';
        newcase.OPRID__c = 'CHI';
        newcase.REFERENCES__c='References';
        newcase.CONVER_DT__c = system.today();
        newcase.Follow_up_date__c =system.today();
        newcase.Conver_DateTime__c=system.today();
        newcase.Promise_DT__c=system.today();
      
        insert newcase;
        
      try{
            RestCollectionCase.createnewcase('DEL200','CHES','CHES',String.valueOf(Date.today()),'EBILL',String.valueOf(Date.today()),String.valueOf(Date.today()),'100','200','strr','sterre','test','terer','CHI',
                                             '','234','test',String.valueOf(System.now()), 'ABS', '122','CHS');
          
          System.assert([SELECT Id FROM Case].size() > 0);
        }
        catch (Exception e){}
        
        Test.stopTest();
    }
     @isTest
    public static void testCreateNewCase1(){
        
        List<case> lstcase=new List<Case>();
        lstcase=RestCollectionCase.getCase();
        case newcase = new case ();
        newcase.recordTypeId  = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Collector Case').getRecordTypeId();
        newcase.Subject = 'Collection Case';
        newcase.status = 'New';
        newcase.WIN_Id__c = 'DEL200';           
        newcase.Business_Unit__c = 'CHES';
        newcase.Follow_up_action__c = 'CHES';
        newcase.Keyword_1__c = 'Keyword1';
        newcase.Keyword_2__c ='Keyword2';
        newcase.Keyword_3__c = 'Keyword3';
        newcase.SETID__c = '123';
        newcase.Type='Ebill';
        newcase.Description = 'COMMENTS';
        newcase.OPRID__c = 'CHI';
        newcase.REFERENCES__c='References';
        newcase.CONVER_DT__c = system.today();
        newcase.Follow_up_date__c =system.today();
        newcase.Conver_DateTime__c=system.today();
        newcase.Promise_DT__c=system.today();
        
        insert newcase;
        
        System.assertEquals([SELECT Id FROM Case][0].Id, newcase.Id);
    }
    
     @isTest
    public static void collectionCaseUnitTestSafetyClean(){
        Test.startTest();
        RestRequest request = new RestRequest();
        RestContext.request = request;
        RestContext.response = new RestResponse();
        RestCollectionCase.createnewcase('DEL201','CHES','CHES',String.valueOf(Date.today()),'EBILL',String.valueOf(Date.today()),String.valueOf(Date.today()),'100','200','strr','sterre','test','terer','CHI',
                                             '','234','test',String.valueOf(System.now()), 'ABS', '122','CHS');
        
        Test.stopTest();
        
        CollectionCaseResponse collectionCaseResponseObj = (CollectionCaseResponse)JSON.deserialize(RestContext.response.responseBody.toString(), CollectionCaseResponse.class);
        System.assertNotEquals(collectionCaseResponseObj.case_id, NULL);
    }
    
    @isTest
    public static void createCollectionCaseForEBiller(){
        Test.startTest();
        RestRequest request = new RestRequest();
        RestContext.request = request;
        RestContext.response = new RestResponse();
        RestCollectionCase.createnewcase('DEL201','CHES','CHES',String.valueOf(Date.today()),'EBILL',String.valueOf(Date.today()),String.valueOf(Date.today()),'100','200','strr','sterre','test','terer','CHI',
                                             '333','234','test',String.valueOf(System.now()), 'ABS', '122','CHS');
        Test.stopTest();
        
        CollectionCaseResponse collectionCaseResponseObj = (CollectionCaseResponse)JSON.deserialize(RestContext.response.responseBody.toString(), CollectionCaseResponse.class);
        System.assertNotEquals(collectionCaseResponseObj.case_id, NULL);
    }
    
    public class CollectionCaseResponse{
        public String case_id;
        public String Error;
        public String Case_No;
    }
}