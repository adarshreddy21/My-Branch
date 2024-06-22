@isTest
public class ConvertRecTypeController_Test {
    
    private static testmethod void ConvertRTTest(){
        
        TERRITORY_MANAGEMENT__c territoryMgmt = new TERRITORY_MANAGEMENT__c();
        territoryMgmt.Name = 'TERRITORY_MGMT_SETTING';
        territoryMgmt.TM_FLAG__c = true;
        insert territoryMgmt;
        
        SIC_VALIDATION_SETTING__c sicValidation = new SIC_VALIDATION_SETTING__c();
        sicValidation.Name = 'SIC_VALIDATION_SETTING';
        sicValidation.SIC_VALIDATION_FLAG__c = true;
        insert sicValidation;
        
        List<SIC_Codes__c> sicList = new List<SIC_Codes__c>();
        SIC_Codes__c sicObj = new SIC_Codes__c(SIC_Code__c =  '0111', Class__c = 'Agricultural Production');
        sicList.add(sicObj);
        
        sicObj = new SIC_Codes__c(SIC_Code__c =  '0112', Class__c = 'Agricultural Production');
        sicList.add(sicObj);
        insert siclist;
        
        Id accRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId();
        Account acc = new Account(Name = 'Test ', Business_Type__c = 'Base', AccountSource = 'Phone', CS_EPA_ID__c = '12345', Sic = '0111', RecordTypeId = accRecTypeId,                               
                                  Rank__c = 'CH A Large >200K', Reporting_Vertical__c = 'Automotive', Industry_Segment__c = 'Automotive', Class__c = 'Agricultural Production', WIN_ID__c = 'AC5255'
                                 ); 
        
        insert acc;
         Id accRecTypeId1 = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect Gen').getRecordTypeId();
        Account acc1 = new Account(Name = 'Test2', Business_Type__c = 'Base', AccountSource = 'Phone', CS_EPA_ID__c = '12345', Sic = '0112', RecordTypeId = accRecTypeId1,                               
                                   ParentId=acc.Id,Rank__c = 'CH A Large >200K', Reporting_Vertical__c = 'Automotive', Industry_Segment__c = 'Automotive', Class__c = 'Agricultural Production',
                                   WIN_ID__c = 'AB4523'                                   ); 
        
        insert acc1;
        
        Test.startTest();
        
        PageReference pageRef = Page.ConvertRecType;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('Id', String.valueOf(acc.Id));
        ApexPages.StandardController sc = new ApexPages.StandardController(acc);
        ConvertRecTypeController testAcc = new ConvertRecTypeController(sc);
        testAcc.updateRecType();
        
        Test.stopTest();
    }
}