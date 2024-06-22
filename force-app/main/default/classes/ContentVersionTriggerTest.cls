/**
 * @description       : 
 * @author            : Suresh Beniwal
 * @group             : 
 * @last modified on  : 11-28-2022
 * @last modified by  : Suresh Beniwal
 * Modifications Log
 * Ver   Date         Author           Modification
 * 1.0   10-04-2022   Suresh Beniwal   Initial Version
**/
@isTest
public class ContentVersionTriggerTest {
    @testSetup
    private static void setupData(){ 
        Id accRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        Profile p = [SELECT Id FROM Profile WHERE Name='Integration']; 
        
        TERRITORY_MANAGEMENT__c territoryMgmt = new TERRITORY_MANAGEMENT__c();
        territoryMgmt.Name = 'TERRITORY_MGMT_SETTING';
        territoryMgmt.TM_FLAG__c = true;
        insert territoryMgmt;
        
        
        
        SIC_VALIDATION_SETTING__c sicValidation = new SIC_VALIDATION_SETTING__c();
        sicValidation.Name = 'SIC_VALIDATION_SETTING';
        sicValidation.SIC_VALIDATION_FLAG__c = true;
        insert sicValidation;
        
        List<User> userList = new List<User>();
        for(Integer i = 0; i < 10; i++){
            userList.add(new User(Alias = 'standt'+ i, Email='standarduser'+i+'@cleanharbors.com', 
                                  EmailEncodingKey='UTF-8', LastName='Testing '+ i, LanguageLocaleKey='en_US', 
                                  LocaleSidKey='en_US', ProfileId = p.Id, 
                                  TimeZoneSidKey='America/Los_Angeles', UserName=datetime.now().millisecond()+'standardusertest'+i+'@cleanharbors.com'));
        }
        insert userList; 
        
        List<ZIP_Master__c> zipMasterList = new List<ZIP_Master__c>();
        for(Integer i = 0; i < 10; i++){
            zipMasterList.add(new ZIP_Master__c(Zip__c = '12345',Country__c = 'US', State__c = 'NY'));
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
                                    Rank__c = 'CH A Large >200K', Reporting_Vertical__c = 'Automotive', Industry_Segment__c = 'Automotive', Class__c = 'Agricultural Production',
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
        Tax_Document__c taxDoc = new Tax_Document__c();
        taxDoc.Account__c = accList[0].Id;
        INSERT taxDoc;
        
        test.stopTest();
        COUNTRY_CODES__c countrycodes = new COUNTRY_CODES__c();
        countrycodes.Name = 'CA';
        insert countrycodes;
        
        COUNTRY_CODES__c countrycodes1 = new COUNTRY_CODES__c();
        countrycodes1.Name = 'US';
        insert countrycodes1;
    }
    
    @isTest
    private static void unitTest(){
        Survey_Monkey__c surveyMonekyObj = new Survey_Monkey__c();
        surveyMonekyObj.Name = 'Test';
        INSERT surveyMonekyObj;

        ContentNote noteRecord = new ContentNote();
        noteRecord.Title   = 'Test Content Note by sfdcpanther.com Approach 2';
        String body        = 'Test Content Note by sfdcpanther.com Approach 2';
        noteRecord.Content = Blob.valueOf(body.escapeHTML4());
        insert noteRecord;
        
        ContentDocumentLink link = new ContentDocumentLink();
        link.ContentDocumentId   = noteRecord.Id;
        link.LinkedEntityId      = surveyMonekyObj.Id;
        link.ShareType           = 'V';
        insert link;
        
        /*ContentNote noteRecord2 = new ContentNote();
        noteRecord2.Title   = 'Test Content Note by sfdcpanther.com Approach 2';
        noteRecord2.Content = Blob.valueOf(body.escapeHTML4());
        noteRecord2.ContentDocumentId = contentVersion_2.ContentDocumentId;
        insert noteRecord2;*/
        //ContentVersionTriggerHandler.Dummytestmethod('test');
    }
    
    @isTest
    private static void unitTest1(){
        Tax_Document__c taxDocument = [SELECT Id FROM Tax_Document__c LIMIT 1];

        ContentNote noteRecord = new ContentNote();
        noteRecord.Title   = 'Test Content Note by sfdcpanther.com Approach 2';
        String body        = 'Test Content Note by sfdcpanther.com Approach 2';
        noteRecord.Content = Blob.valueOf(body.escapeHTML4());
        insert noteRecord;
        
        ContentDocumentLink link = new ContentDocumentLink();
        link.ContentDocumentId   = noteRecord.Id;
        link.LinkedEntityId      = taxDocument.Id;
        link.ShareType           = 'V';
        
        Test.startTest();
        try {
        	insert link;
        } catch(Exception ex) {}
        Test.stopTest();
       
    }
}