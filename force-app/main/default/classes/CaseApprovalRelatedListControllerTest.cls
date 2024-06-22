/**
* @description       : 
* @author            : Vikram Simha (Yerabov)
* @group             : 
* @last modified on  : 04-03-2024
* @last modified by  : Vikram Simha
**/
@isTest
public class CaseApprovalRelatedListControllerTest {
    private final static string TEST_Shipping_PostalCode = '45204';
    private final static string TEST_Shipping_Country = 'US';
    private final static string TEST_Shipping_State = 'OR';
    private final static string TEST_Shipping_City = 'Brookings';
    private final static string TEST_Shipping_Street = 'Test Street';
    private final static string TEST_NAME = 'Gillette Company';
    private final static string TEST_PHONE = '799856414';
    private final static string TEST_TYPE =  'Customer';
    private final static string TEST_TYPE1 = 'ShipTo/Gen';
    private final static string TEST_BUSINESS_TYPE = 'Base'; 
    private final static string TEST_RANK = 'CH A Large >200K';
    private final static string TEST_INDUSTRY_SEGMENT = 'Chemical';
    private final static string TEST_INDUSTRY_SEGMENT1 = 'Machinery Manufacturing';
    private final static string TEST_CURRENCYISOCODE = 'USD';
    private final static string TEST_CS_EPA_ID = 'PENDING';
    private final static string TEST_GENERATOR_STATUS = 'Large Quantity Generator'; 
    private final static string TEST_MISSING_CONTACT_TYPE = 'MAIN';
    private final static string TEST_STATUS = 'Active';
    private final static string TEST_ZIP = '45204';
    private final static string TEST_SALES_BUSINESS_UNIT = 'lodging';  
    private final static string TEST_CASE_TYPE = 'New';
    private final static string TEST_CASE_POSTAL_CODES = '02061';
    private final static string TEST_CASE_WIN_ID = 'ECOMT2';
    private final static string TEST_CASE_FIRST_NAME = 'ABC';
    private final static string TEST_CASE_DESCRIPTION = 'Test';
    private final static string TEST_CASE_UNEXPIRE_REASON = 'Account needs to be serviced';
    private final static string TEST_CASE_CALL_CENTER_ACTIVITY_ID = 'ASDE234';
    private final static string TEST_CASE_COMEENT_BODY = 'This is closed because no need of service';
    private final static string TEST_FIRST_NAME = 'Test'; 
    private final static string TEST_LAST_NAME = 'Test';
    private final static string TEST_SALUTATION = 'Mr';    
    private final static string TEST_TITLE = 'title';
    private final static string TEST_EMAIL = 'Test1@testemail.com';
    private final static string TEST_REQUEST_TYPE1 = 'Inactivation Request';
    private final static Id accountUpdateValidationRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Account Update Validations').getRecordTypeId();
    private final static Id fieldChangeRequestRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Field Change Request').getRecordTypeId();
    private final static Id customerRecordTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get(CHConstants.ACCOUNT_RECORD_TYPE_CUSTOMER).getRecordTypeId();
    @testsetup
    static void setup(){
        SIC_VALIDATION_SETTING__c svsObj = new SIC_VALIDATION_SETTING__c();
        svsObj.name = 'SIC_VALIDATION_SETTING';
        svsObj.SIC_VALIDATION_FLAG__c = true;
        insert svsObj;
        
        TERRITORY_MANAGEMENT__c tmgObj = new TERRITORY_MANAGEMENT__c();
        tmgObj.name = 'TERRITORY_MGMT_SETTING';
        tmgObj.TM_FLAG__c = true;
        insert tmgObj;
        
        COUNTRY_CODES__c countrycodes = new COUNTRY_CODES__c();	
        countrycodes.Name = 'CA';	
        insert countrycodes;	
        
        COUNTRY_CODES__c countrycodes1 = new COUNTRY_CODES__c();	
        countrycodes1.Name = 'US';	
        insert countrycodes1;	
        
        ZIP_Master__c zpObj = new ZIP_Master__c();	
        zpObj.zip__c = TEST_ZIP;	
        zpObj.CurrencyIsoCode = TEST_CURRENCYISOCODE;	
        zpObj.Country__c = TEST_Shipping_Country;	
        zpObj.State__c = TEST_Shipping_State;	
        insert zpObj;	
        
        Territory_Master__c tmObj = new Territory_Master__c();	
        tmObj.name = 'Test TM';	
        tmObj.ZIP_Master__c = zpObj.id;	
        tmObj.CurrencyIsoCode = TEST_CURRENCYISOCODE;	
        tmObj.Sales_business_unit__C = 'lodging';       	
        insert tmObj;
        user activeUser =[select id from user where IsActive = True limit 1];
        Account accObj = new Account();
        accObj.Name =  TEST_NAME;
        accObj.dunbrdst__c = '12345';
        accObj.KAM_Manager__c = activeUser.id;
        accObj.KAM_Support__c = activeUser.id;
        accObj.OwnerId = activeUser.id;
        accObj.Phone = TEST_PHONE;
        accObj.Type = TEST_TYPE;
        accObj.Business_Type__c = TEST_BUSINESS_TYPE;
        accObj.Rank__c = TEST_RANK;
        accObj.Same_as_Corp_Address__c =true;
        accObj.WIN_ID__c = 'GIL210';
        accObj.Industry_Segment__c = TEST_INDUSTRY_SEGMENT;
        accObj.CurrencyIsoCode = TEST_CURRENCYISOCODE;
        accObj.CS_EPA_ID__c =  TEST_CS_EPA_ID;
        accObj.Generator_Status__c = TEST_GENERATOR_STATUS;
        accObj.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Corporate').getRecordTypeId();
        accObj.ShippingPostalCode = TEST_Shipping_PostalCode;	
        accObj.ShippingCountry = TEST_Shipping_Country;	
        accObj.ShippingState = TEST_Shipping_State;	
        accObj.ShippingCity = TEST_Shipping_City;	
        accObj.ShippingStreet = TEST_Shipping_Street;
        insert accObj;
        
        Account accObjCust = new Account();
        accObjCust.Name = TEST_NAME;
        accObjCust.Phone = TEST_PHONE;
        accObjCust.Type = TEST_TYPE;
        accObjCust.Business_Type__c = TEST_BUSINESS_TYPE; 
        accObjCust.Rank__c = TEST_RANK;
        accObjCust.Same_as_Corp_Address__c =true;
        accObjCust.WIN_ID__c = 'GIL211';
        accObjCust.Industry_Segment__c = TEST_INDUSTRY_SEGMENT;
        accObjCust.CurrencyIsoCode = TEST_CURRENCYISOCODE;
        accObjCust.CS_EPA_ID__c = TEST_CS_EPA_ID;
        accObjCust.Tax_Exemption_Type__c = 'Non Exempt';
        accObjCust.Generator_Status__c = TEST_GENERATOR_STATUS;
        accObjCust.ShippingPostalCode = TEST_Shipping_PostalCode;	
        accObjCust.ShippingCountry = TEST_Shipping_Country;	
        accObjCust.ShippingState = TEST_Shipping_State;	
        accObjCust.ShippingCity = TEST_Shipping_City;	
        accObjCust.ShippingStreet = TEST_Shipping_Street;	
        
        accObjCust.recordtypeId = customerRecordTypeId;
        //accObjCust.ParentId = accObj.Id;
        insert accObjCust;
        
        Contact con = new Contact(AccountId = accObjCust.id);
        con.LastName = 'Contact';
        con.FirstName = 'Main';
        con.Salutation = 'Mr';
        con.Title = 'Default Mgr';
        con.Email = 'Main@default.com';
        con.Phone = '781-792-5000';
        con.Contact_Type__c = 'MAIN';
        insert con;
        Contact con1 = new Contact(AccountId = accObj.id);
        con1.LastName = 'Contact';
        con1.FirstName = 'Main';
        con1.Salutation = 'Mr';
        con1.Title = 'Default Mgr';
        con1.Email = 'Main@default.com';
        con1.Phone = '781-792-5000';
        con1.Contact_Type__c = 'MAIN';
        insert con1;
        Account accObjCust2 = new Account();
        accObjCust2.Name = 'Test2';
        accObjCust2.Phone = TEST_PHONE;
        accObjCust2.Type = TEST_TYPE;
        accObjCust2.Business_Type__c = TEST_BUSINESS_TYPE; 
        accObjCust2.Rank__c = TEST_RANK;
        accObjCust2.Same_as_Corp_Address__c =true;
        accObjCust2.WIN_ID__c = 'GIL212';
        accObjCust2.Industry_Segment__c = TEST_INDUSTRY_SEGMENT;
        accObjCust2.CurrencyIsoCode = TEST_CURRENCYISOCODE;
        accObjCust2.CS_EPA_ID__c = TEST_CS_EPA_ID;
        accObjCust2.Generator_Status__c = TEST_GENERATOR_STATUS;
        accObjCust2.Tax_Exemption_Type__c = 'Non Exempt';
        accObjCust2.ShippingPostalCode = TEST_Shipping_PostalCode;	
        accObjCust2.ShippingCountry = TEST_Shipping_Country;	
        accObjCust2.ShippingState = TEST_Shipping_State;	
        accObjCust2.ShippingCity = TEST_Shipping_City;	
        accObjCust2.ShippingStreet = TEST_Shipping_Street;	
        
        accObjCust2.recordtypeId = customerRecordTypeId;
        //accObjCust2.ParentId = accObj.Id;
        insert accObjCust2;
        
        Contact con2 = new Contact(AccountId = accObjCust2.id);
        con2.LastName = 'Contact';
        con2.FirstName = 'Main';
        con2.Salutation = 'Mr';
        con2.Title = 'Default Mgr';
        con2.Email = 'Main@default.com';
        con2.Phone = '781-792-5000';
        con2.Contact_Type__c = 'MAIN';
        insert con2;
        Test.startTest();
        case casobj = new case();
        casobj.Type = TEST_CASE_TYPE;
        casobj.Effective_Date__c = system.today();
        casobj.Proposed_Owner_Case_Approver__c = UserInfo.getUserId();
        casobj.Current_Owner_Case_Approver__c =UserInfo.getUserId();
        casobj.AccountId = accObjCust2.Id;
        casobj.Status = 'New';
        casObj.recordTypeId = accountUpdateValidationRecordTypeId;
        insert casObj;
        case casobjchild = new case();
        casobjchild.Type = TEST_CASE_TYPE;
        casobjchild.Effective_Date__c = system.today();
        casobjchild.Proposed_Owner_Case_Approver__c = UserInfo.getUserId();
        casobjchild.Current_Owner_Case_Approver__c =UserInfo.getUserId();
        casobjchild.AccountId = accObjCust2.Id;
        casobjchild.Account_Field_Changed__c = 'Name';
        casobjchild.Status ='Awaiting Manager Approval';
        casobjchild.ParentId = casobj.id;
        casobjchild.recordTypeId = fieldChangeRequestRecordTypeId;
        casobjchild.Old_Value__c=TEST_NAME;
        casobjchild.New_Value__c = TEST_NAME+'TEst';
        insert casobjchild;
        Test.stopTest();
    }
    @isTest     
    private static void getChildCaseRecordsTest(){
        
        Test.startTest();
        Account acc =[Select id,Name from Account where name = 'Test2' and recordtypeid=:customerRecordTypeId limit 1];
        List<CAse> casobjchild =[select id,casenumber,Old_value__c, Is_Submitted_for_Approval__c,ParentId,Proposed_Owner_Case_Approver__c from case where accountid=:acc.id and RecordTypeId = : fieldChangeRequestRecordTypeId];
        
        System.debug(casobjchild);
        CaseApprovalRelatedListController.ChildCasesWrapper caseWrapper;
        if(!casobjchild.IsEmpty()){
            caseWrapper = CaseApprovalRelatedListController.getChildCaseRecords(casobjchild[0].parentId);
        } 
        Assert.areNotEqual(caseWrapper.childCasesData,null,'No Case Records Found');
        Test.stopTest();
        
    } 
    @isTest     
    private static void approveRejectCaseRecordsTest(){
        
        Test.startTest();
        Account acc =[Select id,Name from Account where name = 'Test2' and recordtypeid=:customerRecordTypeId limit 1];
        List<CAse> casobjchild =[select id,casenumber,Old_value__c, Is_Submitted_for_Approval__c,ParentId,Proposed_Owner_Case_Approver__c from case where accountid=:acc.id and RecordTypeId = : fieldChangeRequestRecordTypeId];
        System.debug(casobjchild);
        if(!casobjchild.IsEmpty()){
            List<CaseApprovalRelatedListController.DataTableWrapper> wrapperList = CaseApprovalRelatedListController.approveRejectCaseRecords(casobjchild[0].Id, casobjchild[0].parentId,'Approve');
        }
        List<CAse> casobjchild1 =[select id,Status from case where id=:casobjchild[0].Id ];
        Assert.areEqual('Approved', casobjchild1[0].Status,'Case Approval Failed.');
        Test.stopTest();
    } 
}