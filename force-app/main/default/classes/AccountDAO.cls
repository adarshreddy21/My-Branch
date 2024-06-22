/**
 * @description       : 
 * @author            : Suresh Beniwal
 * @group             : 
 * @last modified on  : 08-18-2022
 * @last modified by  : Suresh Beniwal
 * Modifications Log
 * Ver   Date         Author           Modification
 * 1.0   06-09-2022   Suresh Beniwal   Initial Version
**/
public without sharing class AccountDAO { 
    private static Id hrTalentPoolsAccountRecordType = Schema.Sobjecttype.Account.getRecordTypeInfosByDeveloperName().get(CHConstants.ACCOUNT_RECORD_TYPE_HR_TALENT_POOLS).getRecordTypeId();
    private static List<Company_Sync__mdt> companySyncMetadataLst = null;
    /**
    * @description
    * @author Suresh Beniwal | 06-09-2022 
    * @param String where_cond 
    * @return List<Account> 
    **/
    public static List<Account> dynamicQueryGetListOfAccounts(String where_cond,  List<String> listOfOption) {
        String query = 'SELECT Id, Name, Parent.Name, Organization_Id__c, Organization_Status__c, Organization_Category__c, Diversity_Organization_Detail__c, Size_of_Candidate_Pool__c, Number_of_Hires__c, Active_Inactive__c, Status__c, ShippingStreet, ShippingCity, ShippingState, ShippingCountry, ShippingPostalCode, Organization_Category_Detail__c FROM Account ';
        if (String.isNotBlank(where_cond)) {
            query += 'WHERE '+ where_cond;
        }
        query += ' ORDER BY LastModifiedDate DESC'; 

        System.debug(query);
        return Database.query(query);
    }

    /**
    * @description 
    * @author Suresh Beniwal | 07-21-2022 
    * @param Set<Id> setOfId1 
    * @param Set<Id> setOfId2 
    * @return List<Account> 
    **/
    public static List<Account> getListOfAccountByIdSets(Set<Id> setOfId1, Set<Id> setOfId2) {
        return [
            SELECT Id, Parent.Name
            FROM Account
            WHERE Id IN: setOfId1 AND Id IN: setOfId2 AND RecordTypeId =: hrTalentPoolsAccountRecordType
            ORDER BY LastModifiedDate DESC
        ];
    }

    /**
    * @description 
    * @author Suresh Beniwal | 08-15-2022 
    * @param Set<Id> setOfAccountId 
    * @return List<Account> 
    **/
    public static List<Account> getAccountsByIdSet(Set<Id> setOfAccountId) {
        return [
            SELECT Id, Name, Organization_Id__c, Parent.Name 
            FROM Account
            WHERE Id IN: setOfAccountId AND RecordTypeId =: hrTalentPoolsAccountRecordType
            ORDER BY LastModifiedDate DESC
        ];
    }
	
    /**
    * @description 
    * @author Vikram Simha | 08-04-2023 
    * @param Set<String> setOfWinId
    * @return List<Account> 
    **/
    public static List<Account> getAccountsByWinIdS(Set<string> winIds) {
        return [
            SELECT Id, Name,OwnerId, WIN_ID__c,Secondary_Owner__c,Secondary_Owner__r.ManagerId,Secondary_Owner__r.IsActive,Owner.ManagerId,Owner.IsActive 
            FROM Account
            WHERE  WIN_ID__c IN : winIds 
            ORDER BY LastModifiedDate DESC
        ];
    }


 /**
    * @description 
    * @author Raghav | 22-09-2022 
    * @param setOfAccountId 
    * @return Set<Account> 
    **/
    public static List<Account> getAccountsByIds(Set<Id> accountIds) {
        return [ 
            SELECT  AccountSource, BillingCity, BillingCountry, BillingPostalCode, BillingState, BillingStreet,
                    CS_EPA_ID__c, Corporate_Address_2__c, CurrencyIsoCode, Owner.EmployeeNumber, Name, Primary_Service_Provider_New__c, Phone,
                    Primary_Business__c, ShippingCity, ShippingCountry, ShippingPostalCode, ShippingStreet, ShippingState, Type, WIN_ID__c,
                    Fax, Website, Sic, CreatedDate, CreatedBy.FederationIdentifier, LastModifiedDate, LastModifiedBy.FederationIdentifier, Billing_Address_2__c, 
                    Business_Type__c, Chain_Code__c, Class__c, Industry_Segment__c, Division__c, Status__c, State_EPA_ID__c, Rank__c, Manifest_Address1__c, 
                    Manifest_Address2__c, Manifest_Address_ID__c, Manifest_Country_Code__c, Manifest_Locality1__c, Manifest_Post_Code__c, Manifest_Region_Code__c,
                    PayTo_Address1__c, PayTo_Address2__c, Pay_To_Address_3__c, Pay_To_Address_ID__c, Pay_To_Country_Code__c, Pay_To_Locality1__c,
                    Pay_To_Post_Code__c, Pay_To_Region_Code__c, Primary_SK_Branch__c, Primary_Service_Provider__c, Secondary_ID__c, Consolidated_Bill_To__c, 
                    Credit_Status__c, Parent.WIN_ID__c, Credit_Terms__c, Email_Invoices__c, GENREG__c, Generator_Status__c, Insite__c,
                    Language__c, Lost_Reason__c, Lost_To__c, Previous_Type__c, Risk_Category__c, Site_ID__c, Territory_Override__c, Waste_Oil__c, Broker_Group__c,
                    Territory_ID_SK__c, LastUpdate_CRM__c, Billing_expired__c, Manifest_expired__c, SRP__c, Milkrun_Zone__c, Milkrun_Service_Type__c, Origin__c, Dunbrdst_Reference__c, Key_Buying_Decision__c,
                    RecordTypeId, RecordType.DeveloperName, Reporting_Vertical__c, Tax_Exemption_Type__c, ParentId, WIN_Validated__c, Win_Validate_New__c, High_Priority__c, 
                    WIN_Compliance_Errors__c, New_Customer_validated__c, Accounts_with_WINID__c,Credit_Cutoff__c, Credit_Limit__c,Parent.RecordType.DeveloperName, Group_3_UMO__c, Account_Headline__c,Headline_Expiration__c,Branch_Code__c,
					Dunbrdst__c, KAM_Manager__c, Customer_Engagement_Manager__c, Dual_Corp_Account_Owner__c, PO_Management_Support__c, Dual_Corp_Account_Owner__r.FederationIdentifier, PO_Management_Support__r.FederationIdentifier, Customer_Engagement_Manager__r.FederationIdentifier, KAM_Support__c, KAM_Manager__r.FederationIdentifier, KAM_Support__r.FederationIdentifier
            FROM Account
            WHERE Id IN: accountIds  
        ];
    }
	
         /**
    * @description 
    * @author Raghav | 22-09-2022 
    * @param List<Account> accounts 
    **/
    public static void updateAccounts(List<Account> accounts) {
        update accounts;
    }
	
	 public static List<Company_Sync__mdt> getCompanySyncMetadata(){	
        if(AccountDAO.companySyncMetadataLst == NULL){	
            AccountDAO.companySyncMetadataLst = Company_Sync__mdt.getAll().values();	
        }	
        	
        return AccountDAO.companySyncMetadataLst;	
    } 
    public static List<Account> getAccountTerritoryId(Set<Id> accountIds){
        return [
            SELECT Id, Territory_ID_SK__r.Territory_Language__c, Territory_ID_SK__r.Territory_Type__c 
            from Account where Id IN :accountIds
        ];
    }
}