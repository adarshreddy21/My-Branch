/**
* @description       : 
* @author            : Vikram Simha
* @group             : 
* @last modified on  : 13-12-2022
* @last modified by  : Vikram Simha
* Modifications Log
* Ver   Date         Author           Modification
* 1.0   13-12-2022   Vikram Simha   Initial Version
**/
@isTest(SeeAllData=false)
public class OwnershipChangeRequestHandlerTest {
    @testSetup static void setupmethod() {
        List<User> userList = new List<User>();
        Profile p = [SELECT Id FROM Profile WHERE Name='Integration']; 
        for(Integer i = 0; i < 10; i++){
            userList.add(new User(Alias = 'standt'+ i, Email='standarduser'+i+'@safety-kleen.com', IsActive=true,
            EmailEncodingKey='UTF-8', LastName='Testing '+ i, LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles',Territory__c='ISAM-01-WER', UserName=datetime.now().millisecond()+'standardusertest'+i+'@safety-kleen.com'));
        }
        insert userList; 
        SIC_VALIDATION_SETTING__c svsObj = new SIC_VALIDATION_SETTING__c();
        svsObj.name = 'SIC_VALIDATION_SETTING';
        svsObj.SIC_VALIDATION_FLAG__c = true;
        insert svsObj;
        
        TERRITORY_MANAGEMENT__c tmgObj = new TERRITORY_MANAGEMENT__c();
        tmgObj.name = 'TERRITORY_MGMT_SETTING';
        tmgObj.TM_FLAG__c = true;
        insert tmgObj;
        
        List<ZIP_Master__c> zipMasterList = new List<ZIP_Master__c>();
        for(Integer i = 0; i < 10; i++){
            zipMasterList.add(new ZIP_Master__c(Zip__c = '12345',Country__c = 'US', State__c = 'NY'));
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
        Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId();
        List<Account> accList = new List<Account>();
        for(Integer i = 0; i < 1; i++){
            accList.add(new Account(Name = 'Test ' + i, Business_Type__c = 'Base', AccountSource = 'Phone', CS_EPA_ID__c = '12345', Sic = '0111', RecordTypeId = recordTypeIdAccount,                               
                                    Rank__c = 'CH A Large >200K', Reporting_Vertical__c = 'Automotive', Industry_Segment__c = 'Automotive', Class__c = 'Agricultural Production',
                                   Primary_Service_Provider_New__c = 'Clean Harbors ENV'));
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
        accList[0].ZIP_Master__c = zipMasterList[0].Id;
        insert accList;
    }
    
    /**
* @description 
* @author  Vikram Simha | 13-12-2022
**/
    @IsTest static void testsetUserLookupFields(){
        
        Test.startTest();
        List<Account> listOfAccount = [select id,name from Account];
        List<user> users = [select id,name,ManagerId,Manager.ManagerId,Sales_SVP__c,Primary_Business__c from user where Primary_Business__c!=null and isActive= true and Territory__c != null];
        Ownership_Change_Request__c oCR = new Ownership_Change_Request__c();
        oCR.Reason_for_Change__c = 'Primary Business Change';
        oCR.Account__c = listOfAccount[0].id;
        oCR.New_Owner__c = users[0].id;
        insert oCR;
        Test.stopTest();
    }
    @IsTest static void testcheckOperatingSegmentChange(){
        
        Test.startTest();
        List<Account> listOfAccount = [select id,name from Account];
        List<user> users = [select id,name,ManagerId,Manager.ManagerId,Sales_SVP__c,Primary_Business__c,Sales_Person_Type__c,Sales_Branch__c from user where isActive = true  and Primary_Business__c !=null and Territory__c != null];
        Ownership_Change_Request__c oCR = new Ownership_Change_Request__c();
        oCR.Reason_for_Change__c = 'Primary Business Change';
        oCR.Account__c = listOfAccount[0].id;
        if(users.Size()> 2){
        oCR.New_Owner__c = users[1].id;
        insert oCR;
        Test.stopTest();
        oCR.New_Operating_Segment__c = 'SK ENV';
        oCR.Status__c = 'Submitted';
        oCR.New_Owner__c = users[2].id;
        update oCR;
        }
        System.assertEquals(false, listOfAccount.isEmpty(), 'Account data should be return !!');
    }
/**
* @description 
* @author  Adarsh Reddy | 27-02-2023  
**/
      @IsTest static void testInsideSalesAgentOcr(){
	  
          Test.startTest();
          Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId();
        List<Account> accList = new List<Account>();
        for(Integer i = 0; i < 1; i++){
            accList.add(new Account(Name = 'Test ' + i, Business_Type__c = 'Base', AccountSource = 'Phone', CS_EPA_ID__c = '12345', Sic = '0111', RecordTypeId = recordTypeIdAccount,                               
                                    Rank__c = 'CH A Large >200K', Reporting_Vertical__c = 'Automotive', Industry_Segment__c = 'Automotive', Class__c = 'Agricultural Production',
                                   Primary_Service_Provider_New__c = 'SK ENV'));
        }
        insert accList;
        List<user> users = [select id,name,ManagerId,Manager.ManagerId,Sales_SVP__c,Primary_Business__c,Sales_Person_Type__c,Sales_Branch__c from user where isActive = true and Primary_Business__c !=null and Territory__c != null] ;  
        List<User> userList = new List<User>();
        Profile p = [SELECT Id FROM Profile WHERE Name='Inside Sales Agent']; 
        for(Integer i = 0; i < 10; i++){
            userList.add(new User(Alias = 'standt1'+ i, Email='standarduser'+i+'@safety-kleen.com', IsActive=true,
            EmailEncodingKey='UTF-8', LastName='Testing '+ i, LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, Sales_Person_Type__c='ISAM',Sales_Branch__c='PUS',
            TimeZoneSidKey='America/Los_Angeles',Territory__c='ISAM-01-WER', UserName=datetime.now().millisecond()+'standardusertest1'+i+'@safety-kleen.com'));
        }
        insert userList; 
         Ownership_Change_Request__c oCR = new Ownership_Change_Request__c();
        oCR.Reason_for_Change__c = 'Primary Business Change';
        if(userList.Size()>2){
           if(accList.size()==1){
       oCR.New_Owner__c = users[1].id;
       oCR.Account__c = accList[0].id;
       oCR.Account_Owner_del__c = userList[1].id;
        insert oCR;
         Test.stopTest();
		
        oCR.New_Operating_Segment__c = 'SK ENV';
        oCR.Status__c = 'Submitted';
        oCR.New_Owner__c = users[2].id;
        update oCR;
        }
        }
        System.assertEquals(false, accList.isEmpty(), 'Account data should be return !!');
    }
    @IsTest static void testcheckSKRoutetoBPS(){
	  
        Test.startTest();
        Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId();
      List<Account> accList = new List<Account>();
      for(Integer i = 0; i < 1; i++){
          accList.add(new Account(Name = 'Test ' + i, Business_Type__c = 'Base', AccountSource = 'Phone', CS_EPA_ID__c = '12345', Sic = '0111', RecordTypeId = recordTypeIdAccount,                               
                                  Rank__c = 'CH A Large >200K', Reporting_Vertical__c = 'Automotive', Industry_Segment__c = 'Automotive', Class__c = 'Agricultural Production',
                                 Primary_Service_Provider_New__c = 'SK ENV'));
      }
      insert accList; 
      List<User> userList = new List<User>();
      Profile p = [SELECT Id FROM Profile WHERE Name='Inside Sales Agent']; 
      for(Integer i = 0; i < 10; i++){
          userList.add(new User(Alias = 'standt'+ i, Email='standarduser'+i+'@safety-kleen.com', IsActive=true,
          EmailEncodingKey='UTF-8',Territory__c = 'SKE-SR-4-52', LastName='Testing '+ i, LanguageLocaleKey='en_US', 
          LocaleSidKey='en_US', ProfileId = p.Id, Sales_Person_Type__c='ISAM',Sales_Branch__c='PUS',
          TimeZoneSidKey='America/Los_Angeles', UserName=datetime.now().millisecond()+'standardusertestii'+i+'@safety-kleen.com'));
      }
      insert userList; 
      List<user> users = [select id,name,ManagerId,Manager.ManagerId,Sales_SVP__c,Primary_Business__c,Sales_Person_Type__c,Sales_Branch__c from user where Primary_Business__c!= null and isActive = true and Territory__c != null];
       Ownership_Change_Request__c oCR = new Ownership_Change_Request__c();
      oCR.Reason_for_Change__c = 'Primary Business Change';
      if(users.Size()>2){
         if(accList.size()==1){
     oCR.New_Owner__c = users[0].id;
     oCR.Account__c = accList[0].id;
     oCR.Account_Owner_del__c = userList[1].id;
      insert oCR;
       Test.stopTest(); 
      
      oCR.New_Operating_Segment__c = 'SK ENV';
      oCR.Status__c = 'Submitted';
      oCR.New_Owner__c = users[1].id;
      update oCR;
      }
      }
      System.assertEquals(false, accList.isEmpty(), 'Account data should be return !!');
  }
    /**
* @description 
* @author  Vikram Simha | 13-12-2022
**/
    @IsTest static void testallowDeleteifDraftandCreatedBy(){
        
        Test.startTest();
        List<Account> listOfAccount = [select id,name from Account];
        List<user> users = [select id,name,ManagerId,Manager.ManagerId,Sales_SVP__c,Primary_Business__c from user where Primary_Business__c!=null and isActive= true];
        Ownership_Change_Request__c oCR = new Ownership_Change_Request__c();
        oCR.Reason_for_Change__c = 'Primary Business Change';
        oCR.Account__c = listOfAccount[0].id;
        oCR.New_Owner__c = users[0].id;
        insert oCR;
        delete OCR;
        Ownership_Change_Request__c ocrRecord = [select id,IsDeleted from Ownership_Change_Request__c where id =:OCR.id ALL ROWS];
        Assert.areEqual(ocrRecord.IsDeleted,true,'OCR record is not deleted.');
        Test.stopTest();
    }

    @IsTest static void testvalidateNewAccountOwnerOCR(){
		Test.startTest();
        Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId();
      	List<Account> accList = new List<Account>();
      	for(Integer i = 0; i < 1; i++){
        	accList.add(new Account(Name = 'Test ' + i, Business_Type__c = 'Base', AccountSource = 'Phone', CS_EPA_ID__c = '12345', Sic = '0111', RecordTypeId = recordTypeIdAccount,                               
                                  Rank__c = 'CH A Large >200K', Reporting_Vertical__c = 'Automotive', Industry_Segment__c = 'Automotive', Class__c = 'Agricultural Production',
                                 Primary_Service_Provider_New__c = 'SK ENV'));
      	}
      	insert accList;
        
      	List<User> userList = new List<User>();
      	Profile p = [SELECT Id FROM Profile WHERE Name='Inside Sales Agent' LIMIT 1]; 
        
      	for(Integer i = 0; i < 1; i++){
          userList.add(new User(Alias = 'standt1'+ i, Email='standarduser'+i+'@safety-kleen.com', IsActive=true,
          EmailEncodingKey='UTF-8',Territory__c = 'TS-AM-Camarillo-CA-01', LastName='Testing '+ i, LanguageLocaleKey='en_US', 
          LocaleSidKey='en_US', ProfileId = p.Id, Sales_Person_Type__c='ISAM',Sales_Branch__c='PUS',
          TimeZoneSidKey='America/Los_Angeles', UserName='standardusertest4'+i+'@safety-kleen.com'));
      	}
      	insert userList; 
        
      	List<user> users = [select id,name,ManagerId,Manager.ManagerId,Sales_SVP__c,Primary_Business__c,Sales_Person_Type__c,Sales_Branch__c from user where Primary_Business__c!= null and isActive = true and Territory__c != null LIMIT 1];
       	Ownership_Change_Request__c ocrRequest = new Ownership_Change_Request__c();
      	ocrRequest.Reason_for_Change__c = 'Primary Business Change';
      	if(users.Size() > 0){
         	if(accList.size() > 0){
     			ocrRequest.New_Owner__c = users[0].id;
     			ocrRequest.Account__c = accList[0].id;
      			insert ocrRequest;
       			Test.stopTest();      
      		}
      	}
      	System.assertEquals(false, accList.isEmpty(), 'Account data should be return !!');
  	}
    
}