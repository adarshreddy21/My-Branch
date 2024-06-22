@isTest
public class AccountReceivableListControllerTest {
    
    static testMethod void TestAccountReceivable(){
        
        Id accRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        
        TERRITORY_MANAGEMENT__c territoryMgmt = new TERRITORY_MANAGEMENT__c();
        territoryMgmt.Name = 'TERRITORY_MGMT_SETTING';
        territoryMgmt.TM_FLAG__c = true;
        insert territoryMgmt;
        
        SIC_VALIDATION_SETTING__c sicValidation = new SIC_VALIDATION_SETTING__c();
        sicValidation.Name = 'SIC_VALIDATION_SETTING';
        sicValidation.SIC_VALIDATION_FLAG__c = true;
        insert sicValidation;
        
		Account testAcc = new Account(Name = 'Test Account', Business_Type__c = 'Base', AccountSource = 'Phone', CS_EPA_ID__c = '12345', RecordTypeId = accRecTypeId,                               
                                    Rank__c = 'CH A Large >200K', Reporting_Vertical__c = 'Automotive', Industry_Segment__c = 'Automotive', Class__c = 'Agricultural Production');
        insert testAcc;
        
        Accounts_Receivable__c AccRec = new Accounts_Receivable__c(name='TestAR1');
        AccRec.Account__c = testAcc.Id;
        insert AccRec;
        
        test.startTest();
        
        Apexpages.StandardController sc = new Apexpages.StandardController(testAcc);
        AccountReceivableListController ext = new AccountReceivableListController(sc);
        
        test.stopTest();               
        
        
    }
        


}