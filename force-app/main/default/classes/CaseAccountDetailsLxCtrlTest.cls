@isTest
public class CaseAccountDetailsLxCtrlTest {
	@testSetup
    private static void setup(){
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
        
        List<ZIP_Master__c> zipMasterList = new List<ZIP_Master__c>();
        for(Integer i = 0; i < 10; i++){
            zipMasterList.add(new ZIP_Master__c(Zip__c = '12345',Country__c = 'US', State__c = 'NY',City__c ='Ashburn'));
			zipMasterList.add(new ZIP_Master__c(Zip__c = '20147',Country__c = 'US', State__c = 'NY',City__c ='Ashburn'));
        }
        insert zipMasterList;
        
        Id branchRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Branch').getRecordTypeId();
        Account a = new Account(Name='Test Account',RecordTypeId=branchRecTypeId,Branch_Opportunity_Allowed__c =true ,AccountSource='Web',Rank__c='CH A Large >200K',Industry_Segment__c='Other',Phone='5555555555',CS_EPA_ID__c='100',Generator_Status__c='Small Quantity Generator',Branch_Call_Origin_Flag__c=TRUE,CurrencyIsoCode='USD');
        insert a;
        user activeUser =[select id from user where IsActive = True limit 1];
        
        Account accObj = new Account();
        accObj.Name = 'Gillette Company';
        accObj.Phone = '5555555554';
        accObj.dunbrdst__c = '12345';
        accObj.ShippingCountry = 'US';
        accObj.ShippingState = 'NY';
        accObj.ShippingStreet = 'Test Street';
        accObj.ShippingCity = 'Ashburn';
        accObj.ShippingPostalCode = '12345';
        accObj.KAM_Manager__c = activeUser.id;
        accObj.KAM_Support__c = activeUser.id;
        accObj.OwnerId = activeUser.id;
        accObj.Type = 'Customer';
        accObj.Business_Type__c = 'Base'; 
        accObj.Rank__c = 'CH A Large >200K';
        accObj.WIN_ID__c = 'GIL210';
        accObj.Industry_Segment__c = 'Chemical';
        accObj.CurrencyIsoCode = 'USD';
        accObj.CS_EPA_ID__c = 'PENDING';
        accObj.Generator_Status__c = 'Large Quantity Generator';
        accObj.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Corporate').getRecordTypeId();
       
        insert accObj;
        
        Account accObjCust = new Account();
        accObjCust.Name = 'Gillette Company';
        accObjCust.Phone = '5555555654';
        accObjCust.Type = 'Customer';
        accObjCust.Business_Type__c = 'Base'; 
        accObjCust.Rank__c = 'CH A Large >200K';
        //accObj.WIN_ID__c = 'GIL210';
        accObjCust.Industry_Segment__c = 'Chemical';
        accObjCust.CurrencyIsoCode = 'USD';
        accObjCust.CS_EPA_ID__c = 'PENDING';
        accObjCust.Generator_Status__c = 'Large Quantity Generator';
        accObjCust.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        accObjCust.ParentId = accObj.Id;
        insert accObjCust;
        
        Account gens = new Account();
        gens.ParentId = accObjCust.id;
        gens.Name = 'Gillette';
        gens.Phone = '5555555754';
        gens.Type = 'ShipTo/Gen';
        gens.Business_Type__c = 'Base'; 
        gens.Rank__c = 'CH A Large >200K';
        gens.WIN_ID__c = 'GI11503';
        gens.Industry_Segment__c = 'Machinery Manufacturing';
        gens.CurrencyIsoCode = 'USD';
        gens.CS_EPA_ID__c = 'MP6174632383';
        gens.Generator_Status__c = 'Undetermined';
        gens.Missing_Contact_Type__c='MAIN';
        gens.Status__c = 'Active';
       // gens.Tax_Exemption_Type__c = 'Non Exempt';
        gens.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer Location').getRecordTypeId();
        insert gens;
    }
    
    @isTest
    private static void unitTest(){

        SIC_VALIDATION_SETTING__c svsObj = new SIC_VALIDATION_SETTING__c();
        svsObj.name = 'SIC_VALIDATION_SETTING';
        svsObj.SIC_VALIDATION_FLAG__c = true;
        insert svsObj;
        
        TERRITORY_MANAGEMENT__c tmgObj = new TERRITORY_MANAGEMENT__c();
        tmgObj.name = 'TERRITORY_MGMT_SETTING';
        tmgObj.TM_FLAG__c = true;
        insert tmgObj;
        
        
        Account accObj = new Account();
        accObj.Name = 'Gillette Company';
        accObj.Phone = '5555455554';
        accObj.Type = 'Customer';
        accObj.Business_Type__c = 'Base'; 
        accObj.Rank__c = 'CH A Large >200K';
        //accObj.WIN_ID__c = 'GIL210';
        accObj.Industry_Segment__c = 'Chemical';
        accObj.CurrencyIsoCode = 'USD';
        accObj.CS_EPA_ID__c = 'PENDING';
        accObj.Generator_Status__c = 'Large Quantity Generator';  
        accObj.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        insert accObj;
        Test.startTest();
        
        Account accRec = [SELECT Id FROM Account WHERE RecordType.Name = 'Branch' LIMIT 1];
        case casobj = new case();
        casobj.Type = 'New';
        casobj.Effective_Date__c = system.today();
        casobj.AccountId = accObj.Id;
        casobj.Proposed_Owner__c = UserInfo.getUserId();
        casobj.List_of_Postal_Codes__c = '02061';
        casobj.List_of_WIN_IDs__c = 'ECOMT2';
        casobj.Branch_Account__c = accRec.Id;
        casObj.Caller_s_First_Name__c = 'ABC';
        casobj.Caller_s_Phone_Number__c = '5555587554';
        casobj.Include_all_locations__c = false;
        casobj.Description = 'Test';
        casobj.CurrencyIsoCode = 'USD';
        casObj.recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('New Customer Request').getRecordTypeId();
        insert casobj;
        
        List<Case> caseLst = CaseAccountDetailsLxCtrl.getCaseDetails(casobj.Id);
        System.assertEquals(caseLst.size(), 1);
        
        //casobj.Specialist_Products__c = 'Emergency Response Services';
        //update casobj;
        Test.stopTest(); 
    }
}