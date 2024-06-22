/**
* @description       : 
* @author            : Gantla Adarsh Reddy
* @group             : 
* @last modified on  : 
* @last modified by  :  
* Modifications Log
* Ver   Date         Author           Modification
* 1.0   01-10-2024   Gantla Adarsh Reddy  Initial Version 
**/ 
@isTest 
public class FinancialHandlerTests {  
    @testSetup static void setupmethod() { 
        SIC_VALIDATION_SETTING__c sicValidation = new SIC_VALIDATION_SETTING__c();
        sicValidation.Name = 'SIC_VALIDATION_SETTING';
        sicValidation.SIC_VALIDATION_FLAG__c = true;
        insert sicValidation;
        
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
        Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId();
        List<Account> accList = new List<Account>();
            accList.add(new Account(Name = 'Test567', CS_EPA_ID__c = '12345', RecordTypeId = recordTypeIdAccount, Sic = '0111',                              
                                Rank__c = 'CH A Large >200K', Reporting_Vertical__c = 'Automotive', Industry_Segment__c = 'Automotive', Class__c = 'Agricultural Production',
                                Primary_Service_Provider_New__c = 'SK ENV', Primary_Business__c = 'Safety-Kleen'));
        insert accList;
        
        User u = [select id,name, Profile.Name from user where Primary_Business__c = 'Safety-Kleen' limit 1];
        List<Ownership_Change_Request__c> ownershipChangeList = new List<Ownership_Change_Request__c>();
        Ownership_Change_Request__c OCR = new Ownership_Change_Request__c(Account__c = accList[0].id, EligibileForIntraQuarterFlip__c=true,
                                                                          Status__c = 'Draft', Reason_for_Change__c = 'Unmanaged Account', New_Owner__c =u.id,
                                                                          New_Operating_Segment__c = 'SK ENV', New_Primary_Service_Provider__c = 'Safety-Kleen');
        
        ownershipChangeList.add(OCR);
        insert ownershipChangeList ;
        
        List<Financials__c> financialList = new List<Financials__c>();
        Financials__c financialRecord = new Financials__c(Account__c = accList[0].id, Customer_Amount__c = 100,Customer_Oil_Gallons_Collected__c = 100,
                                                          Amount__c =100, Location_Oil_Gallons_Collected__c =100);
        financialList.add(financialRecord);
        insert financialList;
    }
    
    @isTest
    static void testUpdateOCRQuarterFlipEligibility() {
        
        List<Account> accList = [select id,Name from Account];
        List<Financials__c> financialList = [select id,Account__c from Financials__c];
        List<Ownership_Change_Request__c> ownershipChangeList = [Select id,Account__c from Ownership_Change_Request__c];
        Map<Id, SObject> newItemsMap = new Map<Id, SObject>{financialList[0].Id => financialList[0]};
        Map<Id, SObject> oldItemsMap = new Map<Id, SObject>();
        
        Test.startTest();
        	FinancialHandler financialHandler = new FinancialHandler();
        	financialHandler.updateOCRQuarterFlipEligibility(newItemsMap, oldItemsMap);
        Test.stopTest();
        
        Ownership_Change_Request__c updatedOCR = [SELECT Id, EligibileForIntraQuarterFlip__c FROM Ownership_Change_Request__c WHERE Id = :ownershipChangeList[0].Id LIMIT 1];
        System.assertEquals(true, updatedOCR.EligibileForIntraQuarterFlip__c, 'Intra-quarter checkbox not updated correctly');
    }
}