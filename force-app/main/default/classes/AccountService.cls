/**
 * @description       : 
 * @author            : Suresh Beniwal
 * @group             : 
 * @last modified on  : 08-17-2022
 * @last modified by  : Suresh Beniwal
 * Modifications Log
 * Ver   Date         Author           Modification
 * 1.0   06-10-2022   Suresh Beniwal   Initial Version
**/
public without sharing class AccountService {
    
    /**
    * @description 
    * @author Suresh Beniwal | 06-10-2022 
    * @param List<Account> listOfAccount 
    * @return List<AccountWrapper> 
    **/
    public static List<AccountWrapper> getListOfAccounts(List<Account> listOfAccount) {
        List<AccountWrapper> listOfAccountWrapper = new List<AccountWrapper>();

        for (Account accountRecord: listOfAccount) {
            AccountWrapper accountWrapperRecord = new AccountWrapper();
            accountWrapperRecord.organizationName = accountRecord.Name;
            accountWrapperRecord.organizationCode = accountRecord.Organization_Id__c;
            accountWrapperRecord.parentAccount = accountRecord.Parent.Name;
            accountWrapperRecord.organizationStatus = accountRecord.Organization_Status__c;
            accountWrapperRecord.organizationCategory = accountRecord.Organization_Category__c;
            accountWrapperRecord.organizationCategoryDetail = accountRecord.Organization_Category_Detail__c;
            accountWrapperRecord.diversityOrganizationDetail = accountRecord.Diversity_Organization_Detail__c;
            accountWrapperRecord.sizeofCandidatePool = accountRecord.Size_of_Candidate_Pool__c;
            accountWrapperRecord.numberofHires = accountRecord.Number_of_Hires__c;
            accountWrapperRecord.status = accountRecord.Status__c;
            accountWrapperRecord.activeInactive = accountRecord.Active_Inactive__c;
            accountWrapperRecord.shippingAddress = accountRecord.ShippingStreet != null ? (accountRecord.ShippingStreet + ' ' + accountRecord.ShippingCity + ' , ' + accountRecord.ShippingState + ' , ' + accountRecord.ShippingCountry + ' ' + accountRecord.ShippingPostalCode) : '';
            accountWrapperRecord.street = accountRecord.ShippingStreet;
            accountWrapperRecord.city = accountRecord.ShippingCity;
            accountWrapperRecord.state = accountRecord.ShippingState;
            accountWrapperRecord.country = accountRecord.ShippingCountry;
            accountWrapperRecord.zipcode = accountRecord.ShippingPostalCode;

            listOfAccountWrapper.add(accountWrapperRecord);
        }

        return listOfAccountWrapper;
    }
    
    public class AccountWrapper {
        @AuraEnabled public String organizationName;
        @AuraEnabled public String organizationCode;
        @AuraEnabled public String parentAccount;
        @AuraEnabled public String organizationStatus;
        @AuraEnabled public String organizationCategory;
        @AuraEnabled public String organizationCategoryDetail;
        @AuraEnabled public String diversityOrganizationDetail;
        @AuraEnabled public Decimal sizeofCandidatePool;
        @AuraEnabled public Decimal numberofHires;
        @AuraEnabled public String activeInactive;
        @AuraEnabled public String status;
        @AuraEnabled public String shippingAddress;
        @AuraEnabled public String street;
        @AuraEnabled public String city;
        @AuraEnabled public String state;
        @AuraEnabled public String country;
        @AuraEnabled public String zipcode;
    }
}