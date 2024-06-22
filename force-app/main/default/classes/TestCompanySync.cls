@isTest
public class TestCompanySync {
    private final static string TEST_Shipping_PostalCode = '45204'; 
    private final static string TEST_Shipping_Country = 'US';
    private final static string TEST_Shipping_State = 'OH';
    private final static string TEST_Shipping_City = 'Cincinnati';
    private final static string TEST_Shipping_Street = 'Test Street'; 
    private final static string TEST_NAME = 'TestAccount';
    private final static string TEST_PHONE = '799856414';
    private final static string TEST_TYPE =  'Customer';
    private final static string TEST_BUSINESS_TYPE = 'Base'; 
    private final static string TEST_RANK = 'CH A Large >200K';
    private final static string TEST_INDUSTRY_SEGMENT = 'Chemical';
    private final static string TEST_CURRENCYISOCODE = 'USD';
    private final static string TEST_CS_EPA_ID = 'PENDING';
    private final static string TEST_GENERATOR_STATUS = 'Large Quantity Generator'; 
    private final static string TEST_CASE_TYPE = 'New';
    private final static Id accountUpdateValidationRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Account Update Validations').getRecordTypeId();
    private final static Id fieldChangeRequestRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Field Change Request').getRecordTypeId();
    private final static Id customerRecordTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByDeveloperName().get(CHConstants.ACCOUNT_RECORD_TYPE_CUSTOMER).getRecordTypeId();
 
    @testsetup 
    static void setup(){
        List<Account> accountsToInsert = new List<Account>(); 
        List<Contact> contactsToInsert = new List<Contact>();
        
        SIC_VALIDATION_SETTING__c svsObj = new SIC_VALIDATION_SETTING__c();
        svsObj.name = 'SIC_VALIDATION_SETTING';
        svsObj.SIC_VALIDATION_FLAG__c = true;
        insert svsObj;
        
        COUNTRY_CODES__c countrycodes1 = new COUNTRY_CODES__c();
        countrycodes1.Name = 'US';
        insert countrycodes1;
        
        List<ZIP_Master__c> zipMasterList = new List<ZIP_Master__c>();
            zipMasterList.add(new ZIP_Master__c(Zip__c = '45204',Country__c = 'US', State__c = 'OH',City__c = 'Cincinnati'));
        insert zipMasterList;   
        
        for(Integer i=0; i<2; i++){
        	Account accObj = new Account();
            accObj.Name =  TEST_NAME+i;
            accObj.Phone = TEST_PHONE;
            accObj.Type = TEST_TYPE;
            accObj.Business_Type__c = TEST_BUSINESS_TYPE;
            accObj.Rank__c = TEST_RANK;
            accObj.Same_as_Corp_Address__c =true;
            accObj.Tax_Exemption_Type__c = 'Non Exempt';
            accObj.WIN_ID__c = 'GIL21'+i;
            accObj.Industry_Segment__c = TEST_INDUSTRY_SEGMENT;
            accObj.CurrencyIsoCode = TEST_CURRENCYISOCODE;
            accObj.CS_EPA_ID__c =  TEST_CS_EPA_ID;
            accObj.Generator_Status__c = TEST_GENERATOR_STATUS;
            accObj.ShippingPostalCode = TEST_Shipping_PostalCode;	
            accObj.ShippingCountry = TEST_Shipping_Country;	
            accObj.ShippingState = TEST_Shipping_State;	
            accObj.ShippingCity = TEST_Shipping_City;	
            accObj.ShippingStreet = TEST_Shipping_Street;
            accObj.Industry_Segment__c = TEST_INDUSTRY_SEGMENT;
            accObj.recordtypeId = customerRecordTypeId;
            accountsToInsert.add(accObj);
        }
        insert accountsToInsert;       
        
        for(Integer i=0; i<2; i++){
            Contact con = new Contact();
            con.AccountId = accountsToInsert[i].id;
            con.LastName = 'Contact'+i;
            con.FirstName = 'Main'+i;
            con.Salutation = 'Mr';
            con.Title = 'Default Mgr';
            con.Email = 'Main'+i+'@default.com';
            con.Phone = '781-792-500'+i;
            con.Contact_Type__c = 'MAIN';
            contactsToInsert.add(con);
        }        
        insert contactsToInsert; 
      
        case parentCase = new case();
        parentCase.Type = TEST_CASE_TYPE;
        parentCase.Effective_Date__c = system.today();
        parentCase.Proposed_Owner_Case_Approver__c = UserInfo.getUserId();
        parentCase.Current_Owner_Case_Approver__c =UserInfo.getUserId();
        parentCase.AccountId = accountsToInsert[1].Id;
        parentCase.Status = 'New';
        parentCase.recordTypeId = accountUpdateValidationRecordTypeId;
        insert parentCase;

        case childCase = new case();
        childCase.Type = TEST_CASE_TYPE;
        childCase.Effective_Date__c = system.today();
        childCase.Proposed_Owner_Case_Approver__c = UserInfo.getUserId();
        childCase.Current_Owner_Case_Approver__c =UserInfo.getUserId();
        childCase.AccountId = accountsToInsert[1].Id;
        childCase.Account_Field_Changed__c = 'Name';
        childCase.Status ='Awaiting Manager Approval';
        childCase.ParentId = parentCase.id;
        childCase.recordTypeId = fieldChangeRequestRecordTypeId;
        childCase.Old_Value__c=TEST_NAME;
        childCase.New_Value__c = TEST_NAME+'TEst';
        insert childCase; 
    }
    
    @isTest
    private static void checkCompanyCaseCreationTest(){
        Test.startTest();        
            Account acc =[Select id,Name from Account where name = 'TestAccount0' and recordTypeid=:customerRecordTypeId limit 1];
            acc.name='TestCompany';
            update acc;
        Test.StopTest();
        List<Case> cases = [select id,casenumber from Case where Accountid = :acc.id];
        Assert.areEqual(cases!=null,true,'Case Is not created for company sync');
    } 
    
    @isTest
    private static void updateParentCaseStatusTest(){
        Test.startTest();
            Account acc =[Select id,Name from Account where name = 'TestAccount1' and recordtypeid =:customerRecordTypeId limit 1];
            Case casobjchild =[select id,casenumber,Old_value__c, Is_Submitted_for_Approval__c,Proposed_Owner_Case_Approver__c from case where accountid=:acc.id and RecordTypeId = : fieldChangeRequestRecordTypeId];
            system.debug('ChildCase' +casobjchild);
            casobjchild.Status = 'Closed - Rejected';
            casobjchild.Proposed_Owner_Case_Approver__c = UserInfo.getUserId();
            casobjchild.Old_value__c = 'TestAccount1';
            casobjchild.Is_Submitted_for_Approval__c = false;
            update casobjchild;
            Account accnew =[Select id,Name from Account where id= :acc.id limit 1];
            Assert.areEqual(accnew.NAme, casobjchild.Old_value__c,'Account Names didnt match for company sync');
        Test.stopTest();        
    }    
	
	@isTest
    private static void checkUpdateCaseWithdrwan(){
         Test.startTest();        
         User u = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Integration' LIMIT 1].Id,
            LastName = 'Integration User',
            FirstName='First',
            Email = 'TEST@safety-kleen.com',
            Username = 'integrationuser@safety-kleen.com' + System.currentTimeMillis(),
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
        System.runAs(u) 
        {
        
         	Account acc =[Select id,Name from Account where name = 'TestAccount1' and recordtypeid=:customerRecordTypeId limit 1];
            acc.name='Testcomapny';
            acc.ShippingStreet='Test';
            update acc;
            Case casobjchild =[select id,casenumber,Old_value__c, Proposed_Owner_Case_Approver__c from case where accountid=:acc.id and RecordTypeId = : fieldChangeRequestRecordTypeId];
            casobjchild.Status = 'Closed- winbacksync';
            casobjchild.Proposed_Owner_Case_Approver__c = UserInfo.getUserId();
            update casobjchild;
           	// Assertions
            casobjchild = [SELECT Id, CaseNumber, Old_value__c, Status FROM Case WHERE Id = :casobjchild.Id];
            Assert.areEqual(true, casobjchild != null); 
            Test.stopTest();
    	}
    }
    
   	@isTest
    private static void testCompanyCaseCreation(){
        Test.startTest();
        
        Account acc =[Select id,Name from Account where name = 'TestAccount0' and recordTypeid=:customerRecordTypeId limit 1];
        acc.ShippingStreet='TestCompany';
        
        update acc;
        
        for(Case caseObj : [SELECT Id, Status, Account_Field_Changed__c FROM Case WHERE Parent.AccountId = :acc.Id]){
            System.assertEquals('Awaiting Manager Approval', caseObj.Status);
        }        
        AccountCRUDHandler.isAfterAccount = true;
        try{
         	acc.ShippingCity='TestCompany12';
          	acc.Win_Validate_New__c=false;
         	update acc;
        }catch(Exception excpetionObj){
            Boolean isContainsCaseException = excpetionObj.getMessage().contains(CHConstants.CASE_MESSAGE);
           	Assert.areEqual(true, isContainsCaseException);
        }        
        Test.StopTest();
    }    
}