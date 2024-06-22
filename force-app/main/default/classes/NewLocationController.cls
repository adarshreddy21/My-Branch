/**
 * @description       : 
 * @author            : Irfan Khan
 * @group             : 
 * @last modified on  : 01-09-2023
 * @last modified by  : Irfan Khan
**/
public class NewLocationController {
	@AuraEnabled
    public static LocationWrapper redirectToNewLocation(String recordId) {
    	Account account = [
            select Id, RecordTypeId, RecordType.DeveloperName, Type, Name,
            Division__c, Business_Type__c, AccountSource, Reporting_Vertical__c,
            Industry_Segment__c, Class__c, Sic, Rank__c, Risk_Category__c,
            CurrencyISOCode, ShippingState, ShippingStreet, ShippingCountry, ShippingCity, ShippingPostalCode, 
            BillingState, BillingStreet, BillingCountry, BillingCity, BillingPostalCode
            from Account
            where Id =:recordId
            limit 1
        ];
		String accountType;
	    Id recordType;

        // for customer, create a new customer location type only
        if(CHConstants.ACCOUNT_RECORD_TYPE_CUSTOMER.equalsIgnoreCase(account.RecordType.DeveloperName)) {
            accountType = CHConstants.ACCOUNT_TYPE_SHIPTO_GEN;
            recordType = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get(
                CHConstants.ACCOUNT_RECORD_TYPE_CUSTOMER_LOCATION).getRecordTypeId();
        }
        
         if(CHConstants.ACCOUNT_RECORD_TYPE_CUSTOMER_Chain.equalsIgnoreCase(account.RecordType.DeveloperName)) {
            accountType = CHConstants.ACCOUNT_TYPE_SHIPTO_GEN;
            recordType = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get(
                CHConstants.ACCOUNT_RECORD_TYPE_CUSTOMER_LOCATION).getRecordTypeId();
        }
        
        // for broker, create a new broker location type only
        if(CHConstants.ACCOUNT_RECORD_TYPE_BROKER.equalsIgnoreCase(account.RecordType.DeveloperName)) {
            accountType = CHConstants.ACCOUNT_TYPE_BROK_GEN;
            recordType = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get(
                CHConstants.ACCOUNT_RECORD_TYPE_BROKER_LOCATION).getRecordTypeId();
        }

        // for distributor, create a new distributor location type only
        if(CHConstants.ACCOUNT_RECORD_TYPE_DISTRIBUTOR.equalsIgnoreCase(account.RecordType.DeveloperName)) {
            accountType = CHConstants.ACCOUNT_TYPE_DIST_GEN;
            recordType = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get(
                CHConstants.ACCOUNT_RECORD_TYPE_DISTRIBUTOR_LOCATION).getRecordTypeId();
        }

        Account newLocationAccount = 
            new Account(
                Name = account.Name,
                Skip_Duplicate_Check__c = true,
                Business_Type__c = account.Business_Type__c,
                AccountSource = account.AccountSource,
                Reporting_Vertical__c = account.Reporting_Vertical__c,
                Industry_Segment__c = account.Industry_Segment__c,
                Class__c = account.Class__c,
                Sic = account.Sic,
                ParentId = account.Id,
                RecordTypeId = recordType,
                Type = accountType,
            	Rank__c = account.Rank__c,
            	Risk_Category__c = account.Risk_Category__c,
                CurrencyISOCode = account.CurrencyIsoCode);

        LocationWrapper locWrap = new LocationWrapper();
        try {
            // we don't need validations during account creation, as the rep will still need
            // to edit the record after it was redirected to the location record
            AccountCRUDHandler.SKIP_VALIDATION = true;
            insert newLocationAccount;
            locWrap.isSuccess = true;
            locWrap.newLocationId = newLocationAccount.Id;
        } catch (Exception e) {
            locWrap.isSuccess = false;
            system.debug(LoggingLevel.ERROR, 'Error creating location account - ' + e.getStackTraceString());
            locWrap.errorMsg = Label.ERROR_CREATING_LOCATION + e.getMessage();
        }
       
        return locWrap;
    }
    
    public class LocationWrapper{
        @AuraEnabled public Boolean isSuccess;
        @AuraEnabled public String newLocationId;
        @AuraEnabled public String errorMsg;
    }
}