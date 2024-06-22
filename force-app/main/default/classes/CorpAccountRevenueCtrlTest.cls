@isTest
public class CorpAccountRevenueCtrlTest { 
     @testSetup
    static void testDataSetup(){
        SIC_VALIDATION_SETTING__c svs = new SIC_VALIDATION_SETTING__c();
        svs.Name = 'SIC_VALIDATION_SETTING';
        svs.SIC_VALIDATION_FLAG__c = false;
        insert svs;
        
        TERRITORY_MANAGEMENT__c tm = new TERRITORY_MANAGEMENT__c();
        tm.Name = 'TERRITORY_MGMT_SETTING';
        tm.TM_FLAG__c = false;
        insert tm;
    } 
    static testMethod void CorpAccountRevenueCtrlTest1() {
    
        Id accRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Corporate').getRecordTypeId();
        Bypass_Account_Validation__c accountValidation = Bypass_Account_Validation__c.getOrgDefaults(); 
        accountValidation.Bypass_Account_Country_Validation__c= true;
        user activeUser =[select id from user where IsActive = True limit 1]; 
        upsert accountValidation Bypass_Account_Validation__c.Id;
        
        Test.StartTest();
        string corpcode;
         Account acc = new Account(Name = 'Eagle Specialty Materials - 87484 ', WIN_ID__c ='D1234',Business_Type__c = 'Base', AccountSource = 'Phone', CS_EPA_ID__c = '12345', Sic = '0111', RecordTypeId = accRecTypeId,                               
                                OwnerId = activeUser.Id,Rank__c = 'CH A Large >200K', Reporting_Vertical__c = 'Automotive', Industry_Segment__c = 'Automotive', Class__c = 'Agricultural Production',dunbrdst__c = '12345',KAM_Manager__c = activeUser.Id,KAM_Support__c = activeUser.Id,
                                Type='ShipTo/Gen',phone='7022967724',ShippingStreet= 'Las Vegas', ShippingCity='Las Vegas',ShippingState='NV',ShippingCountry='US',ShippingPostalcode='12345',Status__c='ACTIVE'); 
        insert acc;
        Apexpages.StandardController stdController = new Apexpages.StandardController(acc);
        CorpAccountRevenueCtrl acc1=new CorpAccountRevenueCtrl(stdController);
       
        Test.StopTest();
         
}
    
}