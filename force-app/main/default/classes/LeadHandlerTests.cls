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
public class LeadHandlerTests {
    public static Testmethod void lead(){
        
        ZIP_Master__c zpObj = new ZIP_Master__c();
        zpObj.zip__c = '302 012';
        zpObj.CurrencyIsoCode = 'USD';
        
        insert zpObj;
        
        Territory_Master__c tmObj = new Territory_Master__c();
        tmObj.name = 'Test TM';
        tmObj.ZIP_Master__c = zpObj.id;
        tmObj.CurrencyIsoCode = 'USD';
        tmObj.Sales_business_unit__C = 'lodging';
        
        insert tmObj;
        
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
        accObj.Phone = '(111)111-1211';
        accObj.Type = 'Customer';
        accObj.Business_Type__c = 'Base'; 
        //accObj.Primary_Business__c='Lodging';
        accObj.Rank__c = 'CH A Large >200K';
        accObj.WIN_ID__c = 'GIL210';
        accObj.Industry_Segment__c = 'Chemical';
        accObj.CurrencyIsoCode = 'USD';
        accObj.CS_EPA_ID__c = 'PENDING';
        accObj.Generator_Status__c = 'Large Quantity Generator';
        // accObj.BillingCity = 'Melrose';
        // accObj.BillingCountry = 'US';
        //accObj.BillingState = 'NY';
        //accObj.BillingPostalCode = '12121';
        //accObj.ShippingPostalCode = '12121';
        //accObj.Manifest_Post_Code__c = '12121'; 
        //accObj.Sic = '4833'; 
        
        insert accObj;

        Group g1 = new Group(Name='group name', type='Queue');
        insert g1;

        User userRecord = [SELECT Id FROM User WHERE IsActive = true AND Profile.Name = 'System Administrator' LIMIT 1];
        System.runAs(userRecord) {
          QueuesObject q1 = new QueueSObject(QueueID = g1.id, SobjectType = 'Lead');
          insert q1;
        }

        CLH_Website_Lead_Mapping__c leadMapping = new CLH_Website_Lead_Mapping__c();
        leadMapping.CLH_Website_Service_Request__c = 'Oil & Gas Field Services';
        leadMapping.SK_Queue_Id__c = g1.Id;
        leadMapping.Primary_Business__c = 'lodging';
        insert leadMapping;

        SIC_Codes__c sicCode = new SIC_Codes__c();
        sicCode.SIC_Code__c = '7699';
        insert sicCode;
        
        Lead leadObj = new Lead();
        leadObj.LastName = 'Test';
        leadObj.company = 'Test Company';
        leadObj.title = 'Test Title';
        leadObj.Business_Type__c = 'Base';
        leadObj.primary_business__c = 'lodging';
        leadObj.Rank__c = 'CH A Large>200k';
        leadObj.WIN_ID_reference__c = 'GIL210';
        leadObj.LeadSource = 'Web';
        leadObj.Status = 'Open';
		leadObj.Generator_Status__c = 'Undetermined';
        leadObj.CurrencyIsoCode = 'USD';
        leadObj.postalcode = '45204';
        leadObj.SIC__c = '7699';
        leadObj.Industry_Segment__c = 'Automotive';
        leadObj.Class__c = 'Auto Maintenance';  
        leadObj.Country = 'CA';
        leadObj.PostalCode = '302012';
        leadobj.Lead_Run_Assignment__c=true;
        leadobj.CLH_Website_Service_Requested__c='Oil & Gas Field Services';
        leadobj.CLH_Website_Lead_Recipient_1__c='005j000000DLAap';
        leadobj.CLH_Website_Lead_Recipient_2__c='005j000000GavPS';
        
        insert leadObj;
        
        leadObj.title = 'Test Title2';
        update leadObj;
    } 
    public static testMethod void testclass(){
        // LeadHandler.testclass();
        //repeat the same for the rest of classes.
    }  
    
    public static Testmethod void lead1(){
        
        ZIP_Master__c zpObj = new ZIP_Master__c();
        zpObj.zip__c = '302 012';
        zpObj.CurrencyIsoCode = 'USD';
        
        insert zpObj;
        
        Territory_Master__c tmObj = new Territory_Master__c();
        tmObj.name = 'Test TM';
        tmObj.ZIP_Master__c = zpObj.id;
        tmObj.CurrencyIsoCode = 'USD';
        tmObj.Sales_business_unit__C = 'lodging';
        
        insert tmObj;
        
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
        accObj.Phone = '(111)111-1211';
        accObj.Type = 'Customer';
        accObj.Business_Type__c = 'Base'; 
        //accObj.Primary_Business__c='Lodging';
        accObj.Rank__c = 'CH A Large >200K';
        accObj.WIN_ID__c = 'GIL210';
        accObj.Industry_Segment__c = 'Chemical';
        accObj.CurrencyIsoCode = 'USD';
        accObj.CS_EPA_ID__c = 'PENDING';
        accObj.Generator_Status__c = 'Large Quantity Generator';
        // accObj.BillingCity = 'Melrose';
        // accObj.BillingCountry = 'US';
        //accObj.BillingState = 'NY';
        //accObj.BillingPostalCode = '12121';
        //accObj.ShippingPostalCode = '12121';
        //accObj.Manifest_Post_Code__c = '12121'; 
        //accObj.Sic = '4833'; 
        
        insert accObj;
        
        Lead leadObj = new Lead();
        leadObj.LastName = 'Test';
        leadObj.company = 'Test Company';
        leadObj.title = 'Test Title';
        leadObj.Business_Type__c = 'Base';
        leadObj.primary_business__c = 'lodging';
        leadObj.Rank__c = 'CH A Large>200k';
        leadObj.WIN_ID_reference__c = 'GIL210';
        leadObj.LeadSource = 'Web';
        leadObj.Status = 'Open';
		leadObj.Generator_Status__c = 'Undetermined';
        leadObj.CurrencyIsoCode = 'USD';
        leadObj.postalcode = '45204';
        leadObj.SIC__c = '7699';
        leadObj.Industry_Segment__c = 'Automotive';
        leadObj.Class__c = 'Auto Maintenance';  
        leadObj.Country = 'US';
        leadObj.PostalCode = '302012';
        leadobj.Lead_Run_Assignment__c=true;
        leadobj.CLH_Website_Service_Requested__c='Oil & Gas Field Services';
        leadobj.CLH_Website_Lead_Recipient_1__c='005j000000DLAap';
        leadobj.CLH_Website_Lead_Recipient_2__c='005j000000GavPS';
        
        insert leadObj;
        
        leadObj.title = 'Test Title2';
        update leadObj;
    } 
    
    public static Testmethod void lead2(){
        
        ZIP_Master__c zpObj = new ZIP_Master__c();
        zpObj.zip__c = '302 012';
        zpObj.CurrencyIsoCode = 'USD';
        
        insert zpObj;
        
        Territory_Master__c tmObj = new Territory_Master__c();
        tmObj.name = 'Test TM';
        tmObj.ZIP_Master__c = zpObj.id;
        tmObj.CurrencyIsoCode = 'USD';
        tmObj.Sales_business_unit__C = 'lodging';
        
        insert tmObj;
        
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
        accObj.Phone = '(111)111-1211';
        accObj.Type = 'Customer';
        accObj.Business_Type__c = 'Base'; 
        //accObj.Primary_Business__c='Lodging';
        accObj.Rank__c = 'CH A Large >200K';
        accObj.WIN_ID__c = 'GIL210';
        accObj.Industry_Segment__c = 'Chemical';
        accObj.CurrencyIsoCode = 'USD';
        accObj.CS_EPA_ID__c = 'PENDING';
        accObj.Generator_Status__c = 'Large Quantity Generator';
        // accObj.BillingCity = 'Melrose';
        // accObj.BillingCountry = 'US';
        //accObj.BillingState = 'NY';
        //accObj.BillingPostalCode = '12121';
        //accObj.ShippingPostalCode = '12121';
        //accObj.Manifest_Post_Code__c = '12121'; 
        //accObj.Sic = '4833'; 
        
        insert accObj;
        
        Lead leadObj = new Lead();
        leadObj.LastName = 'Test';
        leadObj.company = 'Test Company';
        leadObj.title = 'Test Title';
        leadObj.Business_Type__c = 'Base';
        leadObj.Rank__c = 'CH A Large>200k';
        leadObj.WIN_ID_reference__c = 'GIL210';
        leadObj.LeadSource = 'Web';
        leadObj.Status = 'Open';
		leadObj.Generator_Status__c = 'Undetermined';
        leadObj.CurrencyIsoCode = 'USD';
        leadObj.postalcode = '45204';
        leadObj.SIC__c = '7699';
        leadObj.Industry_Segment__c = 'Automotive';
        leadObj.Class__c = 'Auto Maintenance';  
        leadObj.Country = 'US';
        leadObj.PostalCode = '302012';
        leadobj.Lead_Run_Assignment__c=true;
        leadobj.CLH_Website_Service_Requested__c='Oil & Gas Field Services';
        leadobj.CLH_Website_Lead_Recipient_1__c='005j000000DLAap';
        leadobj.CLH_Website_Lead_Recipient_2__c='005j000000GavPS';
        
        insert leadObj;
        
        leadObj.title = 'Test Title2';
        update leadObj;
    } 
    
    public static Testmethod void lead3(){
        ZIP_Master__c zpObj = new ZIP_Master__c();
        zpObj.zip__c = '302 012';
        zpObj.CurrencyIsoCode = 'USD';
        
        insert zpObj;
        
        Territory_Master__c tmObj = new Territory_Master__c();
        tmObj.name = 'Test TM';
        tmObj.ZIP_Master__c = zpObj.id;
        tmObj.CurrencyIsoCode = 'USD';
        tmObj.Sales_business_unit__C = 'lodging';
        
        insert tmObj;
        
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
        accObj.Phone = '(111)111-1211';
        accObj.Type = 'Customer';
        accObj.Business_Type__c = 'Base'; 
        //accObj.Primary_Business__c='Lodging';
        accObj.Rank__c = 'CH A Large >200K';
        accObj.WIN_ID__c = 'GIL210';
        accObj.Industry_Segment__c = 'Chemical';
        accObj.CurrencyIsoCode = 'USD';
        accObj.CS_EPA_ID__c = 'PENDING';
        accObj.Generator_Status__c = 'Large Quantity Generator';
        // accObj.BillingCity = 'Melrose';
        // accObj.BillingCountry = 'US';
        //accObj.BillingState = 'NY';
        //accObj.BillingPostalCode = '12121';
        //accObj.ShippingPostalCode = '12121';
        //accObj.Manifest_Post_Code__c = '12121'; 
        //accObj.Sic = '4833'; 
        
        insert accObj;
        
        Lead leadObj = new Lead();
        leadObj.LastName = 'Test';
        leadObj.company = 'Test Company';
        leadObj.title = 'Test Title';
        leadObj.Business_Type__c = 'Base';
        leadObj.Rank__c = 'CH A Large>200k';
        leadObj.WIN_ID_reference__c = 'GIL210';
        leadObj.LeadSource = 'Web';
        leadObj.Status = 'Open';
		leadObj.Generator_Status__c = 'Undetermined';
        leadObj.CurrencyIsoCode = 'USD';
        leadObj.postalcode = '45204';
        leadObj.SIC__c = '7699';
        leadObj.Industry_Segment__c = 'Automotive';
        leadObj.Class__c = 'Auto Maintenance';  
        leadObj.Country = 'CA';
        leadObj.PostalCode = '302012';
        leadobj.Lead_Run_Assignment__c=true;
        leadobj.CLH_Website_Service_Requested__c='Oil & Gas Field Services';
        leadobj.CLH_Website_Lead_Recipient_1__c='005j000000DLAap';
        leadobj.CLH_Website_Lead_Recipient_2__c='005j000000GavPS';
        
        insert leadObj;
        
        leadObj.title = 'Test Title2';
        update leadObj;
    } 

    public static Testmethod void lead4(){
        
      ZIP_Master__c zpObj = new ZIP_Master__c();
      zpObj.zip__c = '302 012';
      zpObj.CurrencyIsoCode = 'USD';
      
      insert zpObj;
      
      Territory_Master__c tmObj = new Territory_Master__c();
      tmObj.name = 'Test TM';
      tmObj.ZIP_Master__c = zpObj.id;
      tmObj.CurrencyIsoCode = 'USD';
      tmObj.Sales_business_unit__C = 'lodging';
      
      insert tmObj;
      
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
      accObj.Phone = '(111)111-1211';
      accObj.Type = 'Customer';
      accObj.Business_Type__c = 'Base'; 
      //accObj.Primary_Business__c='Lodging';
      accObj.Rank__c = 'CH A Large >200K';
      accObj.WIN_ID__c = 'GIL210';
      accObj.Industry_Segment__c = 'Chemical';
      accObj.CurrencyIsoCode = 'USD';
      accObj.CS_EPA_ID__c = 'PENDING';
      accObj.Generator_Status__c = 'Large Quantity Generator';
      // accObj.BillingCity = 'Melrose';
      // accObj.BillingCountry = 'US';
      //accObj.BillingState = 'NY';
      //accObj.BillingPostalCode = '12121';
      //accObj.ShippingPostalCode = '12121';
      //accObj.Manifest_Post_Code__c = '12121'; 
      //accObj.Sic = '4833'; 
      
      insert accObj;

      Group g1 = new Group(Name='group name', type='Queue');
      insert g1;

      User userRecord = [SELECT Id FROM User WHERE IsActive = true AND Profile.Name = 'System Administrator' LIMIT 1];
      System.runAs(userRecord) {
        QueuesObject q1 = new QueueSObject(QueueID = g1.id, SobjectType = 'Lead');
        insert q1;
      }

      CLH_Website_Lead_Mapping__c leadMapping = new CLH_Website_Lead_Mapping__c();
      leadMapping.CLH_Website_Service_Request__c = 'Oil & Gas Field Services';
      leadMapping.CH_Queue_Id__c = g1.Id;
      leadMapping.Primary_Business__c = 'lodging';
      insert leadMapping;

      SIC_Codes__c sicCode = new SIC_Codes__c();
      sicCode.SIC_Code__c = '7699';
      insert sicCode;
      
      Lead leadObj = new Lead();
      leadObj.LastName = 'Test';
      leadObj.company = 'Test Company';
      leadObj.title = 'Test Title';
      leadObj.Business_Type__c = 'Base';
      leadObj.primary_business__c = 'lodging';
      leadObj.Rank__c = 'CH A Large>200k';
      leadObj.WIN_ID_reference__c = 'GIL210';
      leadObj.LeadSource = 'Web';
      leadObj.Status = 'Open';
	  leadObj.Generator_Status__c = 'Undetermined';
      leadObj.CurrencyIsoCode = 'USD';
      leadObj.postalcode = '45204';
      leadObj.SIC__c = '7699';
      leadObj.Industry_Segment__c = 'Automotive';
      leadObj.Class__c = 'Auto Maintenance';  
      leadObj.Country = 'CA';
      leadObj.PostalCode = '302012';
      leadobj.Lead_Run_Assignment__c=true;
      leadobj.CLH_Website_Service_Requested__c='Oil & Gas Field Services';
      leadobj.CLH_Website_Lead_Recipient_1__c='005j000000DLAap';
      leadobj.CLH_Website_Lead_Recipient_2__c='005j000000GavPS';
      
      insert leadObj;
      
      leadObj.title = 'Test Title2';
      update leadObj; 
  }  
}