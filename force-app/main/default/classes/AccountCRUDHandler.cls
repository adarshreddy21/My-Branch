/**
* Helper class for the Account Trigger. This class takes care of
* CRUD operations on the Account object.
* 
* @author      Jerome Liwanag, Cloud Sherpas  

* @createddate 29-Oct-2015   
*/ 
public class AccountCRUDHandler {  
    public static Boolean isValidationDisable = true; 
    public static Boolean isAfterAccount = true;
    public static Boolean SKIP_VALIDATION = false;
    public static Boolean IS_RUN_AFTER_UPDATE = FALSE; 
    public static Boolean IS_SKIP_TRIGGER = FALSE;
    public static Boolean sKIP_onOwnerChangeBatch = FALSE;
    public static Id hrTalentPoolsAccountRecordType = Schema.Sobjecttype.Account.getRecordTypeInfosByDeveloperName().get(CHConstants.ACCOUNT_RECORD_TYPE_HR_TALENT_POOLS).getRecordTypeId();
    public static Id customerAccountRecordType = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get(CHConstants.ACCOUNT_RECORD_TYPE_CUSTOMER).getRecordTypeId();
    public static Id brokerAccountRecordType = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get(CHConstants.ACCOUNT_RECORD_TYPE_BROKER).getRecordTypeId();
    public static Id distributorAccountRecordType = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get(CHConstants.ACCOUNT_RECORD_TYPE_DISTRIBUTOR).getRecordTypeId();
    public static Id customerLocationAccountRecordType = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get(CHConstants.ACCOUNT_RECORD_TYPE_CUSTOMER_LOCATION).getRecordTypeId();
    public static Id brokerLocationAccountRecordType = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get(CHConstants.ACCOUNT_RECORD_TYPE_BROKER_LOCATION).getRecordTypeId();
    public static Id distributorLocationAccountRecordType = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get(CHConstants.ACCOUNT_RECORD_TYPE_DISTRIBUTOR_LOCATION).getRecordTypeId();
    public static Id CORPORATE_ACCOUNT_TYPE = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get(CHConstants.ACCOUNT_RECORD_TYPE_CORPORATE).getRecordTypeId();
    public static Id CHAIN_ACCOUNT_TYPE = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get(CHConstants.ACCOUNT_RECORD_TYPE_CHAIN).getRecordTypeId();
    public static Id competitorAccountRecordType = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get(CHConstants.ACCOUNT_RECORD_TYPE_COMPETITOR).getRecordTypeId();
    public static Id rfooAccountRecordType = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get(CHConstants.ACCOUNT_RECORD_TYPE_RFOO).getRecordTypeId();
    public static Id branchAccountRecordType = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get(CHConstants.ACCOUNT_RECORD_TYPE_NAME_BRANCH).getRecordTypeId();
    public static Id CORP_RETIRED_ACCOUNT_RECORD_TYPE = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get(CHConstants.ACCOUNT_RECORD_TYPE_CORPRETIRED).getRecordTypeId();
    public static Id KeyAccountRecordType = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get(CHConstants.ACCOUNT_RECORD_TYPE_KEY_ACCOUNT).getRecordTypeId();
	public static Id CustomerChainRecordType = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get(CHConstants.ACCOUNT_RECORD_TYPE_CUSTOMERChain).getRecordTypeId();
    private static List<AccountTeamMember> accountTeamMembersOnOwnerChange=new List<AccountTeamMember>();
	private static Set<Id> initialAccountIdsWithWinvalidatedTrue = new Set<Id>();
	private final static string Case_Status_ClosedWINBackSync = 'Closed- winbacksync';
    private final static string Case_Status_Awaiting_Manager_Approval = 'Awaiting Manager Approval';
	public final static string OldValueReplace = '$*$';	
    public static Map<Id, Boolean> accountsToggleMeToBypassMap = new Map<Id, Boolean>();
    private static Set<String> skippedAccountRecordTypesforOwnershipChanges = new Set<String>{'CORPORATE_ACCOUNT_TYPE','KeyAccountRecordType','CHAIN_ACCOUNT_TYPE','branchAccountRecordType'};
 
/**
* This method takes care of validating the Business Rules which cannot be handled using OOB validation rules.
* 
* These validation are part of Business rules executed on the entries provided by User during 
* new account creation or updating an existing account which should block the record save until 
* the user has made the necessary corrections in case of any errors.
* 
* 
* @param accountList   the account records which have to undergo validation 
*/
  public static void validateBusinessRules(List<Account> accountList, Map<Id, Account> oldAccountMap) {
    Set<String> corporateZips = new Set<String>();
    Set<String> billingZips = new Set<String>();
    Set<String> manifestZips = new Set<String>();
	Set<String> payToZips = new Set<String>();
    Set<String> allZips = new Set<String>();
    Set<String> countryCodes  = new Set<String>();
    Set<Id> parentAccountIds = new Set<Id>();
    Integer corporateMatchRecord = 0;
    Integer billingMatchRecord = 0;
    Integer manifestMatchRecord = 0;
	Integer payToZipMatchRecord = 0;
    Set<Id> accountIds = new Set<Id>();
    Set<String> sicCodes = new Set<String>();   
    Set<String> classSet = new Set<String>();
    Map<String,SIC_Codes__c> sicCodesMap = new Map<String,SIC_Codes__c>(); 
    Map<String,ZIP_Master__c> billingZipMap = new Map<String,ZIP_Master__c>();
    Map<String,ZIP_Master__c> corporateZipMap = new Map<String,ZIP_Master__c>();
    Map<String,ZIP_Master__c> manifestZipMap = new Map<String,ZIP_Master__c>();
	Map<String,ZIP_Master__c> payToZipMap = new Map<String,ZIP_Master__c>();
    for(Account accountLoop : accountList){
	    Account oldAccountRec = oldAccountMap?.get(accountLoop.Id);
        // validations are required only for specific account record types, validate first
        if(isApplicableForValidation(accountLoop, oldAccountRec)) {
            accountIds.add(accountLoop.Id);
            // add SIC code entered to a list for validating later in the flow
            if(accountLoop.Sic != null){sicCodes.add(accountLoop.Sic);
            } 
            // add Class entered to a list for validating later in the flow
            if(accountLoop.Class__c != null){
                classSet.add(accountLoop.Class__c);        
            }
            /* check if corporate zip is populated. 
            * - for US ZIPs, use only first 5 digits 
            * - for CA Postal Codes, use as-is
            */ 
            if(accountLoop.ShippingPostalCode != null){
                if(accountLoop.ShippingCountry == 'US') {corporateZips.add(accountLoop.ShippingPostalCode.trim().left(5));} else if(accountLoop.ShippingCountry == 'CA'){
                    corporateZips.add(accountLoop.ShippingPostalCode.trim());
                }
            }
            // Checks if Billing zip code is populated
            if(accountLoop.BillingPostalCode != null) {
                if(accountLoop.BillingCountry == 'US') { 
                    billingZips.add(accountLoop.BillingPostalCode.trim().left(5)); 
                } else if(accountLoop.BillingCountry == 'CA'){   
                     billingZips.add(accountLoop.BillingPostalCode.trim());                                                                                                                                                      
                }
            }
            // Checks if Manifest zip code is populated
            if(accountLoop.Manifest_Post_Code__c != null){
                if(accountLoop.Manifest_Country_Code__c == 'US') { 
                    manifestZips.add(accountLoop.Manifest_Post_Code__c.trim().left(5));
                } 
                else if(accountLoop.Manifest_Country_Code__c == 'CA'){  
                    manifestZips.add(accountLoop.Manifest_Post_Code__c.trim());
                }
            }
			// Checks if PayToAddress Zip code is populated
             if(accountLoop.Pay_To_Post_Code__c != null){
                if(accountLoop.Pay_To_Country_Code__c == 'US') { 
                    payToZips.add(accountLoop.Pay_To_Post_Code__c.trim().left(5));
                } 
                else if(accountLoop.Pay_To_Country_Code__c == 'CA'){  
                    payToZips.add(accountLoop.Pay_To_Post_Code__c.trim());
                }
            }
            // Checks if a parent account is associated with the current record
            if(accountLoop.ParentId != null){ 
                parentAccountIds.add(accountLoop.ParentId);             
            }
        }
    } 
    // do not proceed if there are no accounts retrieved in the above iteration
    if(accountIds.isEmpty()){     
        return;
    }        
    if(SIC_VALIDATION_SETTING__c.getInstance('SIC_VALIDATION_SETTING').SIC_VALIDATION_FLAG__c == true){
        // Gets associated field values on SIC_Codes__c object based on SIC Code on Account
        if(!sicCodes.isEmpty()){
            for(SIC_Codes__c sicCodesLoop : [SELECT Name,SIC_Code__c,Class__c FROM SIC_Codes__c WHERE SIC_Code__c IN :sicCodes]){
                for(String classLoop : classSet){
                    if(sicCodesLoop.Class__c == classLoop){
                        sicCodesMap.put(sicCodesLoop.SIC_Code__c,sicCodesLoop);    
                    }
                }
            }
        }
    }
    allZips.AddAll(corporateZips);
    allZips.AddAll(manifestZips);
    allZips.AddAll(billingZips);
	allZips.AddAll(payToZips);
    List<Zip_Master__c> allZipList = [SELECT Zip__c,Country__c,State__c FROM ZIP_Master__c WHERE Zip__c IN :allZips];
    for(ZIP_Master__c zipMasterLoop : allZipList){
         if(corporateZips.contains(zipMasterLoop.Zip__c)){
            if(!corporateZipMap.containsKey(zipMasterLoop.Zip__c)){
                corporateZipMap.put(zipMasterLoop.Zip__c, zipMasterLoop); 
            }
         }
         if(manifestZips.contains(zipMasterLoop.Zip__c)){
            if(!manifestZipMap.containsKey(zipMasterLoop.Zip__c)){            
                manifestZipMap.put(zipMasterLoop.Zip__c, zipMasterLoop);       
            }
         }
         if(billingZips.contains(zipMasterLoop.Zip__c)){
            if(!billingZipMap.containsKey(zipMasterLoop.Zip__c)){ 
                billingZipMap.put(zipMasterLoop.Zip__c, zipMasterLoop);
            }
         }
		 if(payToZips.contains(zipMasterLoop.Zip__c)){
            if(!payToZipMap.containsKey(zipMasterLoop.Zip__c)){ 
                payToZipMap.put(zipMasterLoop.Zip__c, zipMasterLoop);
            }
         }
    }
    // Gets all associated parent accounts
    Map<Id,Account> parentAccountMap = new Map<Id,Account>([SELECT Id,CurrencyISOCode FROM Account WHERE Id IN :parentAccountIds]);
    // Gets the values inside the Custom Setting for country validation
    for(COUNTRY_CODES__c loopCountryCodes : COUNTRY_CODES__c.getall().values()){
        countryCodes.add(loopCountryCodes.Name);
    }
    Bypass_Account_Validation__c accountValidation = Bypass_Account_Validation__c.getOrgDefaults();
    Boolean isCountryValidationEnabled = accountValidation.Bypass_Account_Country_Validation__c;
    for(Account accountLoop : accountList){
        String trimmedShippingPostalCode= accountLoop.ShippingPostalCode?.trim();
        String trimmedBillingPostalCode= accountLoop.BillingPostalCode?.trim();
        String trimmedManifestPostalCode= accountLoop.Manifest_Post_Code__c?.trim();
		String trimmedPayToPostalCode= accountLoop.Pay_To_Post_Code__c?.trim();
        String trimmedShippingPostalCodeWithLeftPrecision= trimmedShippingPostalCode?.left(5);
        String trimmedBillingPostalCodeWithLeftPrecision= trimmedBillingPostalCode?.left(5);
        String trimmedManifestPostalCodeWithLeftPrecision= trimmedManifestPostalCode?.left(5);
		String trimmedPayToPostalCodeWithLeftPrecision= trimmedPayToPostalCode?.left(5);
        // This handles the validation for the Corporate Zip Code (ShippingPostalCode)
        if(!isCountryValidationEnabled){
             if((oldAccountMap == null ||(!(accountLoop.Active_ER_Contract__c != oldAccountMap.get(accountLoop.Id).Active_ER_Contract__c ))) && accountLoop.status__c != 'Inactive' && !accountLoop.Inactivate_Reactivate_In_Progress__c){
                if(accountLoop.ShippingPostalCode != null && !corporateZipMap.containsKey(trimmedShippingPostalCodeWithLeftPrecision) && (accountLoop.ShippingCountry == 'US' || accountLoop.ShippingCountry == null)){
                    accountLoop.ShippingPostalCode.addError(Label.ERROR_MSG_ZIP_VALIDATION);
                }
                else if(accountLoop.ShippingPostalCode != null && corporateZipMap.containsKey(trimmedShippingPostalCodeWithLeftPrecision) && accountLoop.ShippingCountry.trim() == 'US') {
                    ZIP_Master__c zipMasterLoop = corporateZipMap.get(trimmedShippingPostalCodeWithLeftPrecision);
                    if(accountLoop.ShippingCountry != zipMasterLoop.Country__c || accountLoop.ShippingState != zipMasterLoop.State__c) {
                        accountLoop.ShippingPostalCode.addError(Label.ERROR_MSG_ZIP_VALIDATION); 
                    }
                }
                // This handles the validation for the Billing Zip Code
                if(accountLoop.BillingPostalCode != null && !billingZipMap.containsKey(trimmedBillingPostalCodeWithLeftPrecision) && (accountLoop.BillingCountry == 'US' || accountLoop.BillingCountry == null)){
                    accountLoop.BillingPostalCode.addError(Label.ERROR_MSG_ZIP_VALIDATION);
                }
                else if(accountLoop.BillingPostalCode != null && billingZipMap.containsKey(trimmedBillingPostalCodeWithLeftPrecision) && accountLoop.BillingCountry.trim() == 'US') {
                    ZIP_Master__c zipMasterLoop = billingZipMap.get(trimmedBillingPostalCodeWithLeftPrecision);
                    if(accountLoop.BillingCountry != zipMasterLoop.Country__c || accountLoop.BillingState != zipMasterLoop.State__c) {
                        accountLoop.BillingPostalCode.addError(Label.ERROR_MSG_ZIP_VALIDATION); 
                    }
                }       
            }
            // This handles the validation for the Manifest Zip Code
            if((oldAccountMap == null ||(!(accountLoop.Active_ER_Contract__c != oldAccountMap.get(accountLoop.Id).Active_ER_Contract__c ))) && accountLoop.Manifest_Post_Code__c != null && !manifestZipMap.containsKey(trimmedManifestPostalCodeWithLeftPrecision) && 
               accountLoop.RecordTypeId != brokerAccountRecordType && (accountLoop.Manifest_Country_Code__c == 'US'  || accountLoop.Manifest_Country_Code__c == null)){     
                   accountLoop.Manifest_Post_Code__c.addError(Label.ERROR_MSG_ZIP_VALIDATION);
               }
             else if((oldAccountMap == null ||(!(accountLoop.Active_ER_Contract__c != oldAccountMap.get(accountLoop.Id).Active_ER_Contract__c ))) && accountLoop.Manifest_Post_Code__c != null && manifestZipMap.containsKey(trimmedManifestPostalCodeWithLeftPrecision) && 
                    accountLoop.RecordTypeId != brokerAccountRecordType && accountLoop.Manifest_Country_Code__c.trim() == 'US') {
                        ZIP_Master__c zipMasterLoop = manifestZipMap.get(trimmedManifestPostalCodeWithLeftPrecision);
                        if(accountLoop.Manifest_Country_Code__c != zipMasterLoop.Country__c || accountLoop.Manifest_Region_Code__c != zipMasterLoop.State__c) {
                            accountLoop.Manifest_Post_Code__c.addError(Label.ERROR_MSG_ZIP_VALIDATION);
                        }     
            }
			// This handles the validation for the PayToAddress Zip Code
            if((oldAccountMap == null ||(!(accountLoop.Active_ER_Contract__c != oldAccountMap.get(accountLoop.Id).Active_ER_Contract__c ))) && accountLoop.status__c != 'Inactive' && !accountLoop.Inactivate_Reactivate_In_Progress__c && accountLoop.Pay_To_Post_Code__c != null && !payToZipMap.containsKey(trimmedPayToPostalCodeWithLeftPrecision) &&
                (accountLoop.Pay_To_Country_Code__c == 'US' || accountLoop.Pay_To_Country_Code__c == null)){
                   
                   accountLoop.Pay_To_Post_Code__c.addError(Label.ERROR_MSG_ZIP_VALIDATION);
               }
            else if((oldAccountMap == null ||(!(accountLoop.Active_ER_Contract__c != oldAccountMap.get(accountLoop.Id).Active_ER_Contract__c ))) && accountLoop.status__c != 'Inactive' && !accountLoop.Inactivate_Reactivate_In_Progress__c && accountLoop.Pay_To_Post_Code__c != null && payToZipMap.containsKey(trimmedPayToPostalCodeWithLeftPrecision) && 
                      accountLoop.Pay_To_Post_Code__c.trim() == 'US') {
                        ZIP_Master__c zipMasterLoop = payToZipMap.get(trimmedPayToPostalCodeWithLeftPrecision);
                        if(accountLoop.Pay_To_Country_Code__c != zipMasterLoop.Country__c || accountLoop.Pay_To_Region_Code__c != zipMasterLoop.State__c) {
                            accountLoop.Pay_To_Post_Code__c.addError(Label.ERROR_MSG_ZIP_VALIDATION); 
                        }
                    }
            if((oldAccountMap == null ||(!(accountLoop.Active_ER_Contract__c != oldAccountMap.get(accountLoop.Id).Active_ER_Contract__c ))) && accountLoop.status__c != 'Inactive' && !accountLoop.Inactivate_Reactivate_In_Progress__c){
                if(accountLoop.ShippingPostalCode != null && !corporateZipMap.containsKey(trimmedShippingPostalCode) && (accountLoop.ShippingCountry == 'CA' || accountLoop.ShippingCountry == null)){
                    accountLoop.ShippingPostalCode.addError(Label.ERROR_MSG_ZIP_VALIDATION);
                }
                else if(accountLoop.ShippingPostalCode != null && corporateZipMap.containsKey(trimmedShippingPostalCode) && accountLoop.ShippingCountry.trim() == 'CA') {
                    ZIP_Master__c zipMasterLoop = corporateZipMap.get(trimmedShippingPostalCode);
                    if(accountLoop.ShippingCountry != zipMasterLoop.Country__c || accountLoop.ShippingState != zipMasterLoop.State__c) {
                        accountLoop.ShippingPostalCode.addError(Label.ERROR_MSG_ZIP_VALIDATION);    
                    }
                }
                // This handles the validation for the Billing Zip Code
                if(accountLoop.BillingPostalCode != null && !billingZipMap.containsKey(trimmedBillingPostalCode) && (accountLoop.BillingCountry == 'CA'|| accountLoop.BillingCountry == null)){
                    accountLoop.BillingPostalCode.addError(Label.ERROR_MSG_ZIP_VALIDATION);
                }
                else if(accountLoop.BillingPostalCode != null && billingZipMap.containsKey(trimmedBillingPostalCode) && accountLoop.BillingCountry.trim() == 'CA') {
                    ZIP_Master__c zipMasterLoop = billingZipMap.get(trimmedBillingPostalCode);
                    if(accountLoop.BillingCountry != zipMasterLoop.Country__c || accountLoop.BillingState != zipMasterLoop.State__c) {
                        accountLoop.BillingPostalCode.addError(Label.ERROR_MSG_ZIP_VALIDATION);
                    }
                }
            }
            // This handles the validation for the Manifest Zip Code
            if((oldAccountMap == null ||(!(accountLoop.Active_ER_Contract__c != oldAccountMap.get(accountLoop.Id).Active_ER_Contract__c ))) && accountLoop.Manifest_Post_Code__c != null && !manifestZipMap.containsKey(trimmedManifestPostalCode) &&
               accountLoop.RecordTypeId != brokerAccountRecordType && (accountLoop.Manifest_Country_Code__c == 'CA' || accountLoop.Manifest_Country_Code__c == null)){
                   
                   accountLoop.Manifest_Post_Code__c.addError(Label.ERROR_MSG_ZIP_VALIDATION);
               }
             else if((oldAccountMap == null ||(!(accountLoop.Active_ER_Contract__c != oldAccountMap.get(accountLoop.Id).Active_ER_Contract__c ))) && accountLoop.Manifest_Post_Code__c != null && manifestZipMap.containsKey(trimmedManifestPostalCode) && 
                    accountLoop.RecordTypeId != brokerAccountRecordType && accountLoop.Manifest_Country_Code__c.trim() == 'CA') {
                        ZIP_Master__c zipMasterLoop = manifestZipMap.get(trimmedManifestPostalCode);
                        if(accountLoop.Manifest_Country_Code__c != zipMasterLoop.Country__c || accountLoop.Manifest_Region_Code__c != zipMasterLoop.State__c) {
                            accountLoop.Manifest_Post_Code__c.addError(Label.ERROR_MSG_ZIP_VALIDATION); 
                        }
                    }
			// This handles the validation for the PayToAddress Zip Code
            if((oldAccountMap == null ||(!(accountLoop.Active_ER_Contract__c != oldAccountMap.get(accountLoop.Id).Active_ER_Contract__c ))) && accountLoop.status__c != 'Inactive' && !accountLoop.Inactivate_Reactivate_In_Progress__c && accountLoop.Pay_To_Post_Code__c != null && !payToZipMap.containsKey(trimmedPayToPostalCode) &&
                (accountLoop.Pay_To_Country_Code__c == 'CA' || accountLoop.Pay_To_Country_Code__c == null)){
                   
                   accountLoop.Pay_To_Post_Code__c.addError(Label.ERROR_MSG_ZIP_VALIDATION);
               }
            else if((oldAccountMap == null ||(!(accountLoop.Active_ER_Contract__c != oldAccountMap.get(accountLoop.Id).Active_ER_Contract__c ))) && accountLoop.status__c != 'Inactive' && !accountLoop.Inactivate_Reactivate_In_Progress__c && accountLoop.Pay_To_Post_Code__c != null && payToZipMap.containsKey(trimmedPayToPostalCode) && 
                     accountLoop.Pay_To_Post_Code__c.trim() == 'CA') {
                        ZIP_Master__c zipMasterLoop = payToZipMap.get(trimmedPayToPostalCode);
                        if(accountLoop.Pay_To_Country_Code__c != zipMasterLoop.Country__c || accountLoop.Pay_To_Region_Code__c != zipMasterLoop.State__c) {
                            accountLoop.Pay_To_Post_Code__c.addError(Label.ERROR_MSG_ZIP_VALIDATION); 
                        }
                    }    
        }
        // Checks if the Countries are valid and in the custom setting COUNTRY_CODES__c
         if((oldAccountMap == null ||(!(accountLoop.Active_ER_Contract__c != oldAccountMap.get(accountLoop.Id).Active_ER_Contract__c ))) && accountLoop.status__c != 'Inactive' && !accountLoop.Inactivate_Reactivate_In_Progress__c){
            if(accountLoop.ShippingCountry != null && !isCountryValidationEnabled){
                if(!countryCodes.contains(accountLoop.ShippingCountry)){
                    accountLoop.ShippingCountry.addError(Label.ERROR_MSG_COUNTRY_VALIDATION);
                }
            }
            if(accountLoop.BillingCountry != null && !isCountryValidationEnabled){
                if(!countryCodes.contains(accountLoop.BillingCountry)){
                    accountLoop.BillingCountry.addError(Label.ERROR_MSG_COUNTRY_VALIDATION);
                }
            }
        }
         if((oldAccountMap == null ||(!(accountLoop.Active_ER_Contract__c != oldAccountMap.get(accountLoop.Id).Active_ER_Contract__c ))) && accountLoop.Manifest_Country_Code__c != null && !isCountryValidationEnabled){
            if(!countryCodes.contains(accountLoop.Manifest_Country_Code__c)){
                accountLoop.Manifest_Country_Code__c.addError(Label.ERROR_MSG_COUNTRY_VALIDATION);
            }
        }
		if((oldAccountMap == null ||(!(accountLoop.Active_ER_Contract__c != oldAccountMap.get(accountLoop.Id).Active_ER_Contract__c ))) && accountLoop.Pay_To_Country_Code__c != null && !isCountryValidationEnabled){
            if(!countryCodes.contains(accountLoop.Pay_To_Country_Code__c)){
                accountLoop.Pay_To_Country_Code__c.addError(Label.ERROR_MSG_COUNTRY_VALIDATION);
            }
        } 
        if(isCountryValidationEnabled && isValidationDisable) {
            isValidationDisable = false;
            AccountCRUDHandler.disableBypassAccount();
        }
        // Checks if the currency of the parent ID is the same as the current record based on Record type and Type of account
        if(parentAccountMap.containsKey(accountLoop.ParentId)){
            if((oldAccountMap == null ||(!(accountLoop.Active_ER_Contract__c != oldAccountMap.get(accountLoop.Id).Active_ER_Contract__c ))) && accountLoop.RecordTypeId == customerLocationAccountRecordType || accountLoop.RecordTypeId == brokerLocationAccountRecordType || accountLoop.RecordTypeId == distributorLocationAccountRecordType){
                if(accountLoop.CurrencyIsoCode != parentAccountMap.get(accountLoop.ParentId).CurrencyIsoCode){
                    accountLoop.CurrencyIsoCode.addError(Label.ERROR_MSG_CURRENCY_VALIDATION);
                }
            }
        }
        if(SIC_VALIDATION_SETTING__c.getInstance('SIC_VALIDATION_SETTING').SIC_VALIDATION_FLAG__c == true){
            // Validates the SIC based on SIC code and Class combination
             if((oldAccountMap == null ||(!(accountLoop.Active_ER_Contract__c != oldAccountMap.get(accountLoop.Id).Active_ER_Contract__c ))) && !sicCodesMap.containsKey(accountLoop.Sic) && accountLoop.Sic != null){
                accountLoop.Sic.addError(Label.ERROR_MSG_SIC_VALIDATION);
            }
        }
    }
}
    
    
    @future
    public static void disableBypassAccount(){
        Bypass_Account_Validation__c accountValidation = Bypass_Account_Validation__c.getOrgDefaults();
        accountValidation.Bypass_Account_Country_Validation__c = false; 
        UPDATE accountValidation;
    }
    
    
    
    /**
* This method takes care of populating the account fields on some criteria based
* on user input once the record is saved. The method is always invoked after successful
* UI validations are through.
* 
* E.g., populates the account owner based on some criteria, territory owner based on SIC code, etc.
* 
* @param accountList   the account records on which details are to be saved
*/ 
     public static void populateAccountFields(List<Account> accountList, Map<Id, Account> oldAccountMap){
        Set<Id> accountIds = new Set<Id>();
        Set<String> classSet = new Set<String>();
        Set<String> zipCodes = new Set<String>();
        Set<Id> chainIds = new Set<Id>();
        Set<String> CASNames = new Set<String>();
        Map<String,User> UserbyName = new Map<String,User>();        
         
        for(Account accountLoop : accountList){
            if (
                oldAccountMap != null &&
                ((String.isBlank(oldAccountMap.get(accountLoop.Id).WIN_ID__c) && !String.isBlank(accountLoop.WIN_ID__c)) ||
                (!String.isBlank(accountLoop.WIN_ID__c) && accountLoop.WIN_ID_created_date__c == null))
            ) {
                accountLoop.WIN_ID_created_date__c = System.today(); 
            }
            // Invokes the method that checks for the account record type
            if(isApplicableForValidation(accountLoop,null)){
                accountIds.add(accountLoop.Id);
                classSet.add(accountLoop.Class__c);
                // Checks if Corporate zip code is populated
                if(accountLoop.ShippingPostalCode != null){
                    zipCodes.add(accountLoop.ShippingPostalCode);
                }
                // Checks if Chain is populated
                if(accountLoop.Chain__c != null){
                    chainIds.add(accountLoop.Chain__c);
                }
                //Account Owner Assignment based on CAS
                if(accountLoop.Key_Account_Assign_Override__c == FALSE && accountLoop.Key_Buying_Decision__c == 'Central Buying' && accountLoop.Key_Account_Support_Person__c != NULL && (accountLoop.RecordTypeId == customerLocationAccountRecordType || accountLoop.RecordTypeId == customerAccountRecordType)) {
                    CASNames.add(accountLoop.Key_Account_Support_Person__c);                    
                }
            }
            
        }
        
        // Check if the account record type needs to be processed or not
        if(accountIds.isEmpty()){
            return;
        }

        if(oldAccountMap == null && !CASNames.isEmpty()){
            for(User Obj : [Select id, Name from User where isActive = TRUE and Name IN : CASNames]){
                UserbyName.put(Obj.Name,Obj);
                
            }
        }
        
        // Get fields associated with the Chain in the Account 
        Map<Id,Account> chainAccountMap = new Map<Id,Account>([SELECT Id,Chain_Code__c,WIN_ID__c FROM Account WHERE ID IN :chainIds]);
        //Map to bypass this profile from logic to updating branch
        Map<Id,Profile> prfMap =  new Map<Id,Profile>([SELECT id from profile where name = 'Light-Customer Service']);
        
        // Populate account fields based on certain rules
        for(Account accountLoop : accountList){
            
            // Set Expired true for Archive status
            If(accountLoop.Status__c=='Archive')
            {
                accountLoop.Expired__c =True;
            }
            else 
            {
                accountLoop.Expired__c =False;
            }
            
            If(accountLoop.Status__c=='Inactive')
            {
                accountLoop.Territory_Override__c=True;
                if(accountLoop.Expired_Date__c==null)
                {
                    accountLoop.Expired_Date__c=Datetime.now();
                }
                
                if(accountLoop.Primary_Service_Provider__c=='Clean harbors')
                {
                    accountLoop.OwnerId = system.label.SLS30;
                }
                else 
                {
                    accountLoop.OwnerId = system.label.SK_Active_Owner;
                    accountLoop.Territory_ID_AO__c = null;
                    accountLoop.Territory_ID_SK__c = null;
                    
                }                
            }
            // Appends four zeroes to the end of the zip codes if it is of length 5
            if(accountLoop.Manifest_Post_Code__c != null && accountLoop.Manifest_Post_Code__c.length() == 5 && accountLoop.Manifest_Country_Code__c == 'US'){
                accountLoop.Manifest_Post_Code__c += '-0000';
            }
            if(accountLoop.ShippingPostalCode != null  && accountLoop.ShippingPostalCode.length() == 5 && accountLoop.ShippingCountry == 'US'){
                accountLoop.ShippingPostalCode += '-0000';
            }
            if(accountLoop.BillingPostalCode != null  && accountLoop.BillingPostalCode.length() == 5 && accountLoop.BillingCountry == 'US'){
                accountLoop.BillingPostalCode += '-0000';
            }
            if(accountLoop.Pay_To_Post_Code__c != null && accountLoop.Pay_To_Post_Code__c.length() == 5 && accountLoop.Pay_To_Country_Code__c == 'US'){
                accountLoop.Pay_To_Post_Code__c += '-0000';
            }
            
            // Makes the input for EPA constant to all records for NONREQUIRED/NOTREQUIRED
            if(accountLoop.CS_EPA_ID__c == 'NONREQUIRED' || accountLoop.CS_EPA_ID__c == 'NOTREQUIRED'){
                accountLoop.CS_EPA_ID__c = CHConstants.ACCOUNT_EPA_ID_NONREQUIRED;
            }
            // Set EPA to 'FCCANADA' if Corporate Country is CA
            if(accountLoop.ShippingCountry == CHConstants.ACCOUNT_COUNTRY_CA){
                accountLoop.CS_EPA_ID__c = CHConstants.ACCOUNT_EPA_ID_FCCANADA;
            }
            // Set GENREG__c to empty if Corporate Country is US
            if(accountLoop.ShippingCountry == CHConstants.ACCOUNT_COUNTRY_US){
                accountLoop.GENREG__c = null;
            }
           
            // Populates the Rank based on type of account
            if(accountLoop.Type == CHConstants.ACCOUNT_TYPE_CORPORATE){
                accountLoop.Rank__c = CHConstants.ACCOUNT_RANK_CH_A_LARGE_ABOVE_200K;
            } 
            
            if(oldAccountMap == null){ 
                // Populates the Credit terms based on type of account
                if(accountLoop.Type == CHConstants.ACCOUNT_TYPE_TRAN || accountLoop.Type == CHConstants.ACCOUNT_TYPE_RAIL || accountLoop.Type == CHConstants.ACCOUNT_TYPE_RIG ||
                   accountLoop.Type == CHConstants.ACCOUNT_TYPE_SHIPTO_GEN || accountLoop.Type == CHConstants.ACCOUNT_TYPE_BROK_GEN){
                       accountLoop.Credit_Terms__c = CHConstants.ACCOUNT_CREDIT_TERMS_NET_30_DAYs;
                   }
                
                // Populates the Credit Status based on class
                if(accountLoop.Class__c == CHConstants.ACCOUNT_CLASS_INDIVIDUAL_HOMEOWNERS){
                    accountLoop.Credit_Terms__c = CHConstants.ACCOUNT_CREDIT_TERMS_CASH_ON_DELIVERY;
                }
                
                if(accountLoop.Credit_Terms__c == null && accountLoop.ShippingCountry == CHConstants.ACCOUNT_COUNTRY_US && accountloop.Primary_Service_Provider__c == CHConstants.ACCOUNT_PRIMARY_SERVICE_PROVIDER_CLEAN_HARBORS &&
                   (accountLoop.Type == CHConstants.ACCOUNT_RECORD_TYPE_CUSTOMER || accountLoop.Type == CHConstants.ACCOUNT_RECORD_TYPE_BROKER || accountLoop.Type == CHConstants.ACCOUNT_RECORD_TYPE_DISTRIBUTOR)){
                       accountLoop.Credit_Terms__c = CHConstants.ACCOUNT_CREDIT_TERMS_NET_15_DAYS;
                   }
                
                else accountLoop.Credit_Terms__c = CHConstants.ACCOUNT_CREDIT_TERMS_NET_30_DAYS;
                //Account Owner by CAS 
                if(accountLoop.Key_Account_Assign_Override__c == FALSE && accountLoop.Status__c != 'Inactive' && accountLoop.Key_Account_Support_Person__c != NULL 
                && accountLoop.Key_Buying_Decision__c == 'Central Buying' && (accountLoop.RecordTypeId == customerLocationAccountRecordType || accountLoop.RecordTypeId == customerAccountRecordType)
                && UserByName.ContainsKey(accountLoop.Key_Account_Support_Person__c)){   
                    accountLoop.OwnerId = UserByName.get(accountLoop.Key_Account_Support_Person__c).Id;
                }        
            }
            
            if(String.IsBlank(accountLoop.Credit_Status__c) && accountLoop.Class__c == CHConstants.ACCOUNT_CLASS_INDIVIDUAL_HOMEOWNERS){
                accountLoop.Credit_Status__c = CHConstants.ACCOUNT_CREDIT_STATUS_HOLD;
            }
            
            // Populate Chain Code from the Chain Account associated with the record
            if(accountLoop.Chain__c != null){
                if(chainAccountMap.containsKey(accountLoop.Chain__c)){
                    accountLoop.Chain_Code__c = chainAccountMap.get(accountLoop.Chain__c).WIN_ID__c;
                }       
            }
            else{
                accountLoop.Chain_Code__c = null ;
            }
            
            if(!prfMap.containsKey(userInfo.getProfileId()) && String.IsBlank(accountLoop.Risk_Category__c))
            {
                
                if((accountLoop.RecordTypeId==customerAccountRecordType || accountLoop.RecordTypeId==brokerAccountRecordType || accountLoop.RecordTypeId==distributorAccountRecordType ) 
                   && (accountLoop.Key_Account_Name__c == null) 
                   &&(accountLoop.Primary_Service_Provider__c == 'Safety Kleen'|| accountLoop.Primary_Service_Provider__c == 'Thermo Fluids'|| accountLoop.Primary_Service_Provider__c == 'Emerald Services')) 
                {
                    accountLoop.Risk_Category__c='Branch Account';
                }
                if((accountLoop.RecordTypeId==customerAccountRecordType || accountLoop.RecordTypeId==brokerAccountRecordType || accountLoop.RecordTypeId==distributorAccountRecordType ) && (accountLoop.Key_Account_Name__c<>null) && (accountLoop.Primary_Service_Provider__c== 'Safety Kleen'|| accountLoop.Primary_Service_Provider__c == 'Thermo Fluids'|| accountLoop.Primary_Service_Provider__c== 'Emerald Services') && (accountLoop.Primary_Business__c <>'Performance Plus Products' || accountLoop.Primary_Business__c <> 'Kleen Performance Products'||  accountLoop.Primary_Business__c <>'Cyn Oil' || accountLoop.Primary_Business__c<>'Cyn Environmental' ) &&(accountLoop.Risk_Category__c<>'3PC Account' || accountLoop.Risk_Category__c<>'Sensitive Account'))
                {
                    accountLoop.Risk_Category__c='Corp Account'; 
                }
                if((accountLoop.RecordTypeId==customerAccountRecordType || accountLoop.RecordTypeId==brokerAccountRecordType || accountLoop.RecordTypeId==distributorAccountRecordType ) && (accountLoop.Primary_Business__c =='Performance Plus Products' || accountLoop.Primary_Business__c =='Kleen Performance Products'||  accountLoop.Primary_Business__c=='Cyn Oil' || accountLoop.Primary_Business__c=='Cyn Environmental' ))
                {
                    accountLoop.Risk_Category__c='Oil'; 
                }
            }
            if(accountLoop.Primary_Business__c == 'SK ENV'){
                accountLoop.Primary_Business__c = 'Safety-Kleen';
            }
            if(oldAccountMap == null || oldAccountMap.get(accountLoop.Id).CS_EPA_ID__c != accountLoop.CS_EPA_ID__c){
                accountLoop.CS_EPA_ID__c = accountLoop.CS_EPA_ID__c?.toUpperCase();                
            }         
        }  
    }
    
   public static void updateChildKAMSupport(Map<Id, Account> newAccountMap, Map<Id, Account> oldAccountMap){  
        Set<Id> kamSupportAccountMapIds = new Set<Id>();    
        
        for(Account newAccRecord : newAccountMap.values()){  
            Account oldAccRecord = oldAccountMap.get(newAccRecord.Id); 
            if( 
                (newAccRecord.RecordTypeId == CORPORATE_ACCOUNT_TYPE || newAccRecord.RecordTypeId == KeyAccountRecordType)     
                && newAccRecord.KAM_Support__c != oldAccRecord.KAM_Support__c   
                && newAccRecord.KAM_Support__c != null  
            ){  
                kamSupportAccountMapIds.add(newAccRecord.Id);   
            }   
        }   
        
        if(!kamSupportAccountMapIds.isEmpty()){ 
            System.enqueueJob(new KAMSupportQueueHandler(kamSupportAccountMapIds));     
        }   
    }
    public static void updateAccountTerritory(Map<Id, Account> newAccountMap, Map<Id, Account> oldAccountMap){  
        Set<Id> corporateAccountIdsSet = new Set<Id>(); 
        
        for(Id accountRecId : newAccountMap.keySet()){  
            Account newAccRecord = newAccountMap.get(accountRecId); 
            Account oldAccRecord = oldAccountMap.get(accountRecId); 
            
            if( 
                oldAccRecord.Buying_Decision__c == 'Central Buying'     
                && newAccRecord.Buying_Decision__c != oldAccRecord.Buying_Decision__c   
                && newAccRecord.RecordTypeId == CORPORATE_ACCOUNT_TYPE  
                && newAccRecord.Status__c == 'Active'   
            ){  
                corporateAccountIdsSet.add(newAccRecord.Id);    
            }   
        }   
        
        if(corporateAccountIdsSet.size() > 0){  
            System.enqueueJob(new UpdateAccountTerritoryQueueHandler(corporateAccountIdsSet));      
        }   
    }   
    
    
    // This Method is to create dummy contact for Comp and RFO Accounts
    public static void createMainContact(List<Account> newList){
        
        List<Contact> conList = new List<Contact>();
        for(Account acc : newList){
            
            if(acc.RecordTypeId == competitorAccountRecordType || acc.RecordTypeId == rfooAccountRecordType){
                
                Contact con = new Contact(AccountId = acc.Id);
                con.LastName = 'Contact';
                con.FirstName = 'Main';
                con.Salutation = 'Mr';
                con.Title = 'Default Mgr';
                con.Email = 'Main@default.com';
                con.Phone = '781-792-5000';
                con.Contact_Type__c = 'MAIN';
                conList.add(con);
            }
        }
        if(!conList.isEmpty() && conList.size() > 0){
            insert conList;
        }
    }
    
    
    public static void insertTaxDoc(List<Account> newList){
        List<Tax_Document__c> lstToInsert = new List<Tax_Document__c>();
        
        for(Account acc : newList){
            if(acc.RecordTypeId == customerAccountRecordType || acc.RecordTypeId == customerLocationAccountRecordType){
                lstToInsert.add(new Tax_Document__c(Account__c = acc.Id));    
            }
        }
        
        if(!lstToInsert.isEmpty() && lstToInsert.size() > 0){
            insert lstToInsert;
        }    
    } 
    
    
    /**
* This method takes care of checking for the record type of the account record.
* Record Types:
*  - Customer
*  - Customer Location
*  - Broker
*  - Broker Location
*  - Distributor
*  - Distributor Location
* 
* @param acc    the account record for which the validation rules are required or not
* @return true or false based on the condition
*/ 
    private static Boolean isApplicableForValidation(Account acc, Account accOld) {
        if((accOld==null || (!(acc.Inactivate_Reactivate_In_Progress__c == false && accOld.Inactivate_Reactivate_In_Progress__c) && acc.Toggle_Me_to_Bypass_Validation__c == accOld.Toggle_Me_to_Bypass_Validation__c)) &&
		   (acc.RecordTypeId == customerAccountRecordType || acc.RecordTypeId == customerLocationAccountRecordType
           || acc.RecordTypeId == brokerAccountRecordType || acc.RecordTypeId == brokerLocationAccountRecordType 
           || acc.RecordTypeId == distributorAccountRecordType || acc.RecordTypeId == distributorLocationAccountRecordType
           || acc.RecordTypeId == CORPORATE_ACCOUNT_TYPE)) {
               return true;
           } else {
               return false;
           }
    }
    
    
    /**
* This method takes care of unlocking the record if the 
* was updated and the profile of the user is 'Integration'.
* 
* 
* @param accountList   the account records that needs to be unlocked
*/ 
    public static void unlockAccountRecords(List<Account> accountRecords) {
      
        Approval.UnlockResult[] resultList = Approval.Unlock(accountRecords, false);
        Map<Id,Account> accountsMap= new Map<Id,Account>(accountRecords);
        List<Account> updateUnlockAccountLst = new List<Account>();
        Boolean isAccountTriggerContext= (Trigger.new!=null && Trigger.new[0].getSObjectType()==Schema.Account.getSObjectType());
        for(Approval.UnlockResult unlockResult : resultList) {
            if (!unlockResult.isSuccess()) {
                // Operation failed, so get all errors                
              List<Exception_Log__c> logExceptionLst = new List<Exception_Log__c>();                
                for(Database.Error err : unlockResult.getErrors()) {
                    logExceptionLst.add(new Exception_Log__c(
                            Error_Message__c = err.getMessage(),
                            Apex_Class_Trigger__c = AccountCRUDHandler.class.getName(),
                            DML_Object__c = 'Approval.LockResult',
                            Record_Id__c = unlockResult.getId()));                             
                }
          ExceptionLogDAO.logException(logExceptionLst);
            }else{
                if(isAccountTriggerContext){
                    accountsMap.get(unlockResult.getId()).Is_Record_Locked__c = false;
                }
                else{
                    updateUnlockAccountLst.add(new Account(
                        Id = unlockResult.getId(),
                        Is_Record_Locked__c = false));
                }
            }
        }
       
        if(!updateUnlockAccountLst.isEmpty()){
            
            Database.DMLOptions dml = new Database.DMLOptions(); 
            dml.DuplicateRuleHeader.AllowSave = true;
			dml.optAllOrNone= true;
            Database.update(updateUnlockAccountLst,dml);
        }
    }
    
    
    /**
* This method takes care of locking the record if WIN_Validated__c is true.
* AccountValidator class invokes this method.
* 
* 
* @param account   the account record that needs to be locked
*/ 
    public static void lockAccountRecord(Account acc,  Boolean skipUpdatingAccount) {
        
        Approval.LockResult result = Approval.Lock(acc,false);
        
        if (!result.isSuccess()) {
            // Operation failed, so get all errors                
            List<Exception_Log__c> logExceptionLst = new List<Exception_Log__c>();                
            for(Database.Error err : result.getErrors()) {
                logExceptionLst.add(
                  new Exception_Log__c(
                      Error_Message__c = err.getMessage(),
                        Apex_Class_Trigger__c = AccountCRUDHandler.class.getName(),
                        DML_Object__c = 'Approval.LockResult',
                        Record_Id__c = acc.Id ));                
            }
            
            ExceptionLogDAO.logException(logExceptionLst);
        }else if(result.isSuccess()){
            acc.Is_Record_Locked__c = true;
			 if(skipUpdatingAccount)
       update acc;
        }
    }
    
    
    /**
* This Method looks up the zip master record and updates the 
* Zip Master field on the account based of the corporate zip
* inserted or updated. 
*/
    public static void updateZipMaster(List<Account> newAccountList){
        
        set<String> pcSet = new Set<String>();
        for(Account acc : newAccountList){
            //Checks if the Zip code is not null
            if(acc.ShippingPostalCode != null){
                if(acc.ShippingCountry == 'US') {pcSet.add(acc.ShippingPostalCode.trim().left(5));} else if(acc.ShippingCountry == 'CA'){ pcSet.add(acc.ShippingPostalCode.trim());}
            }
        }
        
        Map<String,ID> zmMap = new Map<String,ID>();
        // Get the fields from Zip Master record assosciated with the zip code on the account 
        if(pcSet.size() > 0){
            List<ZIP_Master__c> zipMasterList = [SELECT id,zip__c, Business_Dev_Area__c FROM ZIP_Master__c where zip__c in: pcSet];
            
            if(zipMasterList.size()>0 ) {
                for(ZIP_Master__c zpM : zipMasterList){
                    zmMap.put(zpM.zip__c,zpM.id);
                }
                //Populates the Zip Master records on account if the there is a match.
                for(Account newAcc : newAccountList){
                    if(newAcc.ShippingPostalCode != null ) {
                        if(newAcc.ShippingCountry == 'US') {
                            newAcc.ZIP_Master__c = zmMap.get(newAcc.ShippingPostalCode.trim().left(5));
                            
                        }
                        else if(newAcc.ShippingCountry == 'CA'){
                            newAcc.ZIP_Master__c = zmMap.get(newAcc.ShippingPostalCode.trim());
                        }
                    }
                }
            }
        } 
    }
    
  
 /**
* This method Updates the following fields on account based of corporate zip and Primary Business on account,
*   -Territory(Territort Master record ID) 
*   -Primary SK Branch(Branch Code on the Territory Master record)
* Above fields are updated from the related Territory Master record. 
* Returns the value from Territory Master record to fields only when   
* Primary Business on Account and Sales Business Unit on Territory Master is 'Safety-Kleen'
*/
public static void updateTerritoryLookup(List<Account> newAccountList){
    Set<string> zipSet = new Set<String>();
    for(Account acc : newAccountList){  
        if(acc.ShippingPostalCode != null){
            if(acc.ShippingCountry == 'US') {
                zipSet.add(acc.ShippingPostalCode.trim().left(5));
            } else if(acc.ShippingCountry == 'CA'){
                zipSet.add(acc.ShippingPostalCode.trim());
            }
        }
    }
    //Get related Territory Master record fields 
    Map<string,Territory_master__c> zipCodeTerritoryMasterMapping = new Map<string,Territory_master__c>();
    for(Territory_master__c tm : [select id,ZIP_Code__c,Sales_Business_Unit__c,Territory_Branch_Code__c,Territory_ID__c,Branch_Account__c from Territory_master__c WHERE ZIP_Code__c in: zipSet]){
        string key = tm.ZIP_Code__c+'$$'+tm.Sales_Business_Unit__c;
        if(!zipCodeTerritoryMasterMapping.containsKey(key)){
            zipCodeTerritoryMasterMapping.put(key, tm);
        }
    }
    for(Account acc : newAccountList){
            String tempZip;
            //Check if corporate zip on account is not null.
            if(acc.ShippingPostalCode != null){
                if(acc.ShippingCountry == 'US') {
                    tempZip = acc.ShippingPostalCode.trim().left(5);
                } else if(acc.ShippingCountry == 'CA'){
                    tempZip = acc.ShippingPostalCode.trim();
                }
            }
            if(zipCodeTerritoryMasterMapping.containsKey(tempZip+'$$Safety-Kleen') && !acc.Territory_Override_SKE__c ){    //tempSBU == tm.Sales_Business_Unit__c
                acc.Territory_ID_SKE__c = zipCodeTerritoryMasterMapping.get(tempZip+'$$Safety-Kleen').Territory_ID__c;
            }
            if(zipCodeTerritoryMasterMapping.containsKey(tempZip+'$$Technical Services') && !acc.Territory_Override_TS__c){    
                acc.Territory_ID_TS__c = zipCodeTerritoryMasterMapping.get(tempZip+'$$Technical Services').Territory_ID__c;
            }
            if(zipCodeTerritoryMasterMapping.containsKey(tempZip+'$$Kleen Performance Products') && !acc.Territory_Override_KPP_Fleet__c){    
                acc.Territory_ID_KPP_Fleet__c = zipCodeTerritoryMasterMapping.get(tempZip+'$$Kleen Performance Products').Territory_ID__c;
            }                            
    }    
}
    /*This Method updates the Beacon Primary Business and PSP*/
    public static void updateAccountPrimaryBusiness(List<Account> newAccountList){
        set<string> oSet = new Set<String>();
        set<string> pSet = new Set<String>();
        Set<Id> zipMasterIds = new Set<Id>();
                
        for(Account acc1 : newAccountList){
            oSet.add(acc1.OwnerId);
            pset.add(acc1.Primary_Branch_Alternate__c);
            
            //Collecting Zip Master Ids to process later for populating Primary_SK_Branch__c - Sireesha
            if(acc1.ZIP_Master__c != NULL){
                zipMasterIds.add(acc1.ZIP_Master__c);
            }
        }
        
        //Collecting Territory Master records related to the Zip Master on the Account
        //Storing them in a Map to Process later for populating Primary_SK_Branch__c
        Map<Id, List<Territory_Master__c>> terMasterByZip = new Map<Id, List<Territory_Master__c>>();
        if(!zipMasterIds.isEmpty() && zipMasterIds.size() > 0){
            for(Territory_Master__c terObj : [Select Id, Sales_Business_Unit__c, Branch_Account__c, Branch_Account__r.Branch_Code__c, ZIP_Master__c from Territory_Master__c where ZIP_Master__c IN : zipMasterIds]){
                if(terMasterByZip.containsKey(terObj.Zip_Master__c)){
                    terMasterByZip.get(terObj.Zip_Master__c).add(terObj);
                }
                else{
                    terMasterByZip.put(terObj.Zip_Master__c, new List<Territory_Master__c>{terObj});
                }
            }
        }
        
        MAP<Id,User> pownerMap =  new Map<Id,User>([SELECT id,Sales_Branch__c from user where id in:oSet]);
        
		List<Old_New_Primary_Service_Provider_Mapping__mdt> primaryServiceProvMtdLst = Old_New_Primary_Service_Provider_Mapping__mdt.getAll().values();
        for(Account acc : newAccountList){
            for(Old_New_Primary_Service_Provider_Mapping__mdt primaryServiceProvObj : primaryServiceProvMtdLst){
                if(primaryServiceProvObj.Primary_Business__c == acc.Primary_Business__c){
                    acc.Primary_Service_Provider__c = primaryServiceProvObj.Primary_Service_Provider__c;
                    break;
                } 
            }
			Boolean isSBUMatched = FALSE;
            String branchCode = '';
            set<string> CHESOS = new set<String>{'Clean Harbors ENV','CHES Oil and Gas','CHES Industrial'};
            //Logic to Populate Primary_SK_Branch__c based upon Primary Business and Zip Master on Account
            //Primary_SK_Branch__c will be populated from the Territory Master records related to the Zip Master on Account
            if(acc.Primary_Business__c != NULL && acc.ZIP_Master__c != NULL ){
                if(terMasterByZip.containsKey(acc.ZIP_Master__c) && acc.Primary_SK_Branch_Override__c == FALSE){
                    for(Territory_Master__c tObj : terMasterByZip.get(acc.ZIP_Master__c)){
                        if(tObj.Sales_Business_Unit__c == 'Safety-Kleen'){
                            branchCode = tObj.Branch_Account__r.Branch_Code__c;
                            break;
                        }
                    }
                    for(Territory_Master__c tObj : terMasterByZip.get(acc.ZIP_Master__c)){
                        if( acc.Primary_Business__c == tObj.Sales_Business_Unit__c && tObj.Branch_Account__r.Branch_Code__c!=NULL ){
                            if(acc.Primary_Service_Provider_New__c == 'SK BPS' ) {
                                acc.Primary_SK_Branch__c = tObj.Branch_Account__r.Branch_Code__c;
                                acc.CHESI_Branch__c = NULL;
                                isSBUMatched = true;
                            }
                            
                            else
                                if(CHESOS.Contains(acc.Primary_Service_Provider_New__c) && acc.Primary_Business__c == tObj.Sales_Business_Unit__c) {
                                    acc.CHESI_Branch__c = tObj.Branch_Account__r.Branch_Code__c;
                                    acc.Primary_SK_Branch__c = branchCode;
                                    isSBUMatched = true;
                                    break;
                                }
                        }
                        else
                            if(CHESOS.Contains(acc.Primary_Service_Provider_New__c) && acc.Primary_Business__c != tObj.Sales_Business_Unit__c && !isSBUMatched){
                                acc.CHESI_Branch__c = pownerMap.get(acc.OwnerId).Sales_Branch__c;
                                acc.Primary_SK_Branch__c = branchCode;
                                isSBUMatched = true;
                            }
                    }
                    if (!isSBUMatched){
                        acc.Primary_SK_Branch__c = branchCode;
                        isSBUMatched = true;
                        acc.CHESI_Branch__c = null;
                    }
                }
            }
            
            
            if(acc.Owner_Primary_Business__c=='Safety-Kleen')
            {
                if(acc.Status__c != 'Inactive'){
                    acc.Primary_Service_Branch_c__c=pownerMap.get(acc.OwnerId).Sales_Branch__c;
                    acc.SK_ID__c='Safety-Kleen';                        
                }   
            }
            else if (acc.Owner_Primary_Business__c=='Emerald Services')
            {
                
                acc.Primary_Service_Branch_c__c=pownerMap.get(acc.OwnerId).Sales_Branch__c;
                acc.SK_ID__c='Emerald Services';
                acc.Territory_Override__c=True; 
            }
            
            else if (acc.Owner_Primary_Business__c=='Healthcare Services')
            { 
                acc.Primary_Service_Branch_c__c=pownerMap.get(acc.OwnerId).Sales_Branch__c;                    
                acc.SK_ID__c='Healthcare Services';
                acc.Territory_Override__c=True;
				if(acc.Primary_Branch_Alternate__c <> NULL){
                     acc.Territory_ID_SK__c=NULL;
                }
                
            }
            
            else if (acc.Owner_Primary_Business__c=='Thermo Fluids')
            {
                
                acc.Primary_Service_Branch_c__c=pownerMap.get(acc.OwnerId).Sales_Branch__c;                    
                acc.SK_ID__c='Thermo Fluids';
                acc.Territory_Override__c=True;   
            }
            
            else if (acc.Owner_Primary_Business__c=='Performance Plus Products')
            {
                acc.Primary_Service_Branch_c__c=pownerMap.get(acc.OwnerId).Sales_Branch__c;                    
                acc.SK_ID__c='Performance Plus Products';
                acc.Territory_Override__c=True; 
            }
            
            else if (acc.Owner_Primary_Business__c=='CYN OIL')
            {                    
                acc.SK_ID__c='CYN OIL';
            }
            else if (acc.Owner_Primary_Business__c=='CYN ENVIRONMENTAL')
            {
                acc.SK_ID__c='CYN ENVIRONMENTAL';
            }
            else if (acc.Primary_Branch_Alternate__c<>NULL)
            {
                acc.SK_ID__c='Clean Harbors';
                acc.Territory_Override__c=True; 
                acc.Primary_Service_Branch_c__c=pownerMap.get(acc.OwnerId).Sales_Branch__c;
            }
            else
            {
                acc.Primary_Service_Branch_c__c=pownerMap.get(acc.OwnerId).Sales_Branch__c;
                acc.SK_ID__c='Clean Harbors';
            }
            
        }        
        
        
    }
    
    /*This Method updates the Name of the Customer Engagement Manager on Account record */
    
    public static void updateCustEngManager(List<Account> newList, Map<Id, Account> oldMap){
        
        Set<Id> managerIds = new Set<Id>();
        List<Account> accToProcess = new List<Account>();
        Map<Id, User> userMap = new Map<Id, User>();
        
        for(Account acc : newList){
            if(acc.Customer_Engagement_Manager__c != NULL && (oldMap == NULL || acc.Customer_Engagement_Manager__c != oldMap.get(acc.Id).Customer_Engagement_Manager__c)){
                
                managerIds.add(acc.Customer_Engagement_Manager__c);
                accToProcess.add(acc);
            }
        }
        
        if(!managerIds.isEmpty()){
            
            userMap = new Map<Id, User>([Select Id, FirstName, LastName from User where ID IN : managerIds]);
            
            for(Account accObj : accToProcess){
                if(userMap.containsKey(accObj.Customer_Engagement_Manager__c)){
                    
                    accObj.Corp_CEM_Name__c = userMap.get(accObj.Customer_Engagement_Manager__c).FirstName+' '+userMap.get(accObj.Customer_Engagement_Manager__c).LastName;
                }
            }
        }
    }
    
    
    /*This Method updates the Beacon contact type 'MAIN' and sets the validation flag to true when its related Account is requested for validation*/
    
     public static void UpdateBeaconMainContactList (List<Account> newAccountList){
        
        set<string> Accset = new Set<String>(); 
        Map<Id,Id> contactAccountsMap= new Map<Id,Id>();
        for(Account acc : newAccountList){
            if(acc.Status__c != 'Inactive' && (acc.WIN_Validated__c == true || acc.Win_Validate_new__c == true)){
                Accset.add(acc.id);
            }      
        }     
        if(!AccSet.isEmpty()){
            List<Contact> contacts = [SELECT id, Contact_Type__c, Expired__c,AccountId FROM Contact where AccountId in: AccSet and Contact_Type__c INCLUDES ('MAIN') AND Expired__c=false AND WIN_Validated__c= false];           
            for(Contact Bc : contacts){
                Bc.WIN_Validated__c = true;
                contactAccountsMap.put(Bc.Id, BC.AccountId);            
            }
            if(contacts != null && !contacts.isEmpty()){
                Database.SaveResult[] results= Database.update(contacts, false);
                List<Integration_process__c> integrationProcessLst = new List<Integration_process__c>();
                
                for(Database.SaveResult result : results){
                    if(!result.isSuccess()){
                        Integration_process__c  integProcess =  new Integration_process__c();
                        integProcess.Account__c= contactAccountsMap.get(result.getId());
                        integProcess.Process_Type__c= CHConstants.ContactErrorUpdate;
                        integProcess.Status__c='Error';
                        integProcess.Error_Message__c = '';
                        for(Database.Error err : result.getErrors()) {
                            integProcess.Error_Message__c += err.getMessage() + '\n';
                        }
                            integrationProcessLst.add(integProcess);  
                    }
                } 
                
                if(!integrationProcessLst.isEmpty()){
                    insert integrationProcessLst;
                }
            }
        }
    } 
    
    public static void updateAcctFromSTGtoCUST(List<Account> newAccountList)
    {
        
        for(Account acc : newAccountList){
            
            // Populates the Credit Status based on class
            if(acc.Class__c == CHConstants.ACCOUNT_CLASS_INDIVIDUAL_HOMEOWNERS){
                acc.Credit_Terms__c = CHConstants.ACCOUNT_CREDIT_TERMS_CASH_ON_DELIVERY;              
            }
            
            // Populates the Credit Status based on corporate country
            
            if(acc.Credit_Terms__c == null && acc.ShippingCountry == CHConstants.ACCOUNT_COUNTRY_US && acc.Primary_Service_Provider__c == CHConstants.ACCOUNT_PRIMARY_SERVICE_PROVIDER_CLEAN_HARBORS &&
               (acc.Type == CHConstants.ACCOUNT_RECORD_TYPE_CUSTOMER || acc.Type == CHConstants.ACCOUNT_RECORD_TYPE_BROKER || acc.Type == CHConstants.ACCOUNT_RECORD_TYPE_DISTRIBUTOR)){
                   acc.Credit_Terms__c = CHConstants.ACCOUNT_CREDIT_TERMS_NET_15_DAYS;
               }
            
            else acc.Credit_Terms__c = CHConstants.ACCOUNT_CREDIT_TERMS_NET_30_DAYS;
            
            if(String.IsBlank(acc.Credit_Status__c) && acc.Class__c == CHConstants.ACCOUNT_CLASS_INDIVIDUAL_HOMEOWNERS){
                acc.Credit_Status__c = CHConstants.ACCOUNT_CREDIT_STATUS_HOLD;
            }
        }

        Database.DMLOptions dml = new Database.DMLOptions(); 
        dml.DuplicateRuleHeader.AllowSave = true;
        Database.update(newAccountList,dml);
    } 
    Public Static void UpdateAccountOwnerSalesBranch (List<Account> newAccountList){
        
        set<string> OwnSet = new Set<String>();
        set<string> TerrSet = new Set<String>();
        
        for(Account acc : newAccountList){
            if(acc.OwnerId != null){
                OwnSet.add(acc.OwnerId);
            }
        }
        Map<id,string> userMap = new Map<id,string>();   
        List<User> UserList = [Select id, Sales_Branch__c, Territory__c  From User WHERE id in: OwnSet];
        for(User u : UserList){
            if(u.Sales_Branch__c != null){
                userMap.put(u.id,u.Sales_Branch__c);
            } 
            if(u.Territory__c != null){               
                TerrSet.add(u.Territory__c);
            }
            
        }
        Id recTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Branch').getRecordTypeId();
        Map<string,id> branchCodeMap = new Map<string,id>(); 
        List<Account> branchAcc = [SELECT id,Branch_Code__c FROM Account WHERE recordtypeid =: recTypeId and Branch_Code__c in: userMap.values()];
        for(Account BAcc : branchAcc){
            branchCodeMap.put(BAcc.Branch_Code__c,BAcc.id);
        }
        Map<string,id> TerrCodeMap = new Map<string,id>();
        if(TerrSet.size() > 0){
            List<Territory__c> terrList = [SELECT ID,name FROM Territory__c where name IN: TerrSet];
            for(Territory__c ter : terrList){
                TerrCodeMap.put(ter.name,ter.id);
            }
        }
        
        for(Account acc : newAccountList){
            acc.Account_Owner_Sales_Branch__c = branchCodeMap.get(userMap.get(acc.OwnerId));
            if(TerrCodeMap.containsKey(acc.Owner_Territory__c)){
                acc.Territory_ID_AO__c = TerrCodeMap.get(acc.Owner_Territory__c);
                acc.Territory_ID_SK__c = TerrCodeMap.get(acc.Owner_Territory__c);                                                
            }    
        }
    } 
    
    public static User loggedInuser;
    public static User getLoggedInUser(){
        if(loggedInuser == null){
            loggedInuser = [select Id,Profile.Name, Name from User where Id = :UserInfo.getUserId()];
        }
        
        return loggedInuser;
        
    }

    
    /**
* This method is to copy the Billing Address same as Corp Address based on Checkbox "Same_as_Corp_Address__c".
*Developer: Sireesha
*Date: 5/15/2020
*/ 
    public static void validateAndCopyBillingAddress(List<Account> newList, Map<Id, Account> oldMap){
        
                
        for(Account acc : newList){
            
            if((oldMap == null && acc.Same_as_Corp_Address__c) 
               || (oldMap != null && ((acc.Same_as_Corp_Address__c && !oldMap.get(acc.Id).Same_as_Corp_Address__c) || 
                                      (acc.Same_as_Corp_Address__c && (acc.ShippingState != oldMap.get(acc.Id).ShippingState || acc.ShippingStreet != oldMap.get(acc.Id).ShippingStreet || acc.ShippingCountry != oldMap.get(acc.Id).ShippingCountry || acc.ShippingCity != oldMap.get(acc.Id).ShippingCity || acc.ShippingPostalCode != oldMap.get(acc.Id).ShippingPostalCode)))))
            {
                acc.BillingState = acc.ShippingState;
                acc.BillingStreet = acc.ShippingStreet;
                acc.BillingCountry = acc.ShippingCountry;
                acc.BillingCity = acc.ShippingCity;
                acc.BillingPostalCode = acc.ShippingPostalCode;
            }
        } 
    }
    
    /**
* This method is to copy the Manifest Address same as Corp Address based on Checkbox "Manifest_Address_Same_As_Corp__c".
*Developer: Sireesha
*Date: 7/22/2020
*/ 
    public static void CopyCorpAsManifest(List<Account> newList, Map<Id, Account> oldMap){
        
                
        for(Account acc : newList){
            
            if((oldMap == null && acc.Manifest_Address_Same_As_Corp__c) 
               || (oldMap != null && ((acc.Manifest_Address_Same_As_Corp__c && !oldMap.get(acc.Id).Manifest_Address_Same_As_Corp__c) || 
                                      (acc.Manifest_Address_Same_As_Corp__c && (acc.ShippingState != oldMap.get(acc.Id).ShippingState || acc.ShippingStreet != oldMap.get(acc.Id).ShippingStreet || acc.ShippingCountry != oldMap.get(acc.Id).ShippingCountry || acc.ShippingCity != oldMap.get(acc.Id).ShippingCity || acc.ShippingPostalCode != oldMap.get(acc.Id).ShippingPostalCode)))))
            {
                acc.Manifest_Region_Code__c = acc.ShippingState;
                acc.Manifest_Address1__c = acc.ShippingStreet;
                acc.Manifest_Country_Code__c = acc.ShippingCountry;
                acc.Manifest_Locality1__c = acc.ShippingCity;
                acc.Manifest_Post_Code__c = acc.ShippingPostalCode;
            }
        } 
    }
/**
* This method is to copy the PayTo Address same as Corp Address based on Checkbox "PayTo_Address_Same_As_Corp__c".
*Developer: Gantla Adarsh Reddy
*Date: 05/27/2024
*/ 
	public static void copyCorpAsPayToAddress(List<Account> newList, Map<Id, Account> oldMap){
        for(Account acc : newList){
            if((oldMap == null && acc.PayTo_Address_Same_As_Corp__c) 
               || (oldMap != null && ((acc.PayTo_Address_Same_As_Corp__c && !oldMap.get(acc.Id).PayTo_Address_Same_As_Corp__c) || 
                                      (acc.PayTo_Address_Same_As_Corp__c && (acc.ShippingState != oldMap.get(acc.Id).ShippingState || acc.ShippingStreet != oldMap.get(acc.Id).ShippingStreet || acc.ShippingCountry != oldMap.get(acc.Id).ShippingCountry || acc.ShippingCity != oldMap.get(acc.Id).ShippingCity || acc.ShippingPostalCode != oldMap.get(acc.Id).ShippingPostalCode)))))
            {
                acc.Pay_To_Region_Code__c = acc.ShippingState;
                acc.PayTo_Address1__c = acc.ShippingStreet;
                acc.Pay_To_Country_Code__c = acc.ShippingCountry;
                acc.Pay_To_Locality1__c = acc.ShippingCity;
                acc.Pay_To_Post_Code__c = acc.ShippingPostalCode;
            }
        } 
    }
    
    /*
This Method is used to populate the Branch Account based on the Branch Code available on Primary_SK_Branch__c 
Author: Sireesha
Date: 24th June, 2020*/
    public static void updatePrimaryBranchName(List<Account> newList,Map<Id,Account> oldMap){
        
        Set<String> branchCodes = new Set<String>();
        Map<String, Account> accByBranchCodeMap = new Map<String, Account>();
        List<Account> listToProcess = new List<Account>();
        
        for(Account acc : newList){
            
            if(oldMap == NULL || (acc.Primary_SK_Branch__c != oldMap.get(acc.Id).Primary_SK_Branch__c || acc.Primary_Aurora_Branch_Name__c == NULL)){
                if(acc.Primary_SK_Branch__c != NULL){
                    
                    branchCodes.add(acc.Primary_SK_Branch__c);
                    listToProcess.add(acc);
                }
            }
        }
        
        if(!branchCodes.isEmpty()){
            
            for(Account bObj : [Select Id, Name, Branch_Code__c from Account where RecordType.Name = 'Branch' AND Branch_Code__c IN : branchCodes]){
                
                accByBranchCodeMap.put(bObj.Branch_Code__c, bObj);
            }
            
            for(Account accObj : listToProcess){
                if(accByBranchCodeMap.containsKey(accObj.Primary_SK_Branch__c)){
                    
                    accObj.Primary_Aurora_Branch_Name__c = accByBranchCodeMap.get(accObj.Primary_SK_Branch__c).Name;
                }
            }
        }
    }
    
    /*
This Method is used to validate the Hybrid LOBs field value selection
Author: Sireesha
Date: 12th October, 2020*/
    public static void validateHybridLOB(List<Account> newList,Map<Id,Account> oldMap){
        
        Set<String> lobValues = new Set<String>();
        lobValues.addAll(System.Label.Hybrid_Buying_Decision_Values.split(','));
        for(Account obj : newList){
            if((obj.RecordTypeId == CORPORATE_ACCOUNT_TYPE || obj.RecordTypeId == CHAIN_ACCOUNT_TYPE) && obj.Buying_Decision__c == 'Hybrid'){
                
                Set<String> hybridCentral = new Set<String>();
                Set<String> hybridLocal = new Set<String>();
                Set<String> hybridLobAll = new Set<String>();
                
                if(obj.Hybrid_Central_LOBs__c != NULL){
                    hybridCentral.addAll(obj.Hybrid_Central_LOBs__c.split(';'));
                    hybridLobAll.addAll(obj.Hybrid_Central_LOBs__c.split(';'));
                }
                if(obj.Hybrid_Local_LOBs__c != NULL){
                    hybridLocal.addAll(obj.Hybrid_Local_LOBs__c.split(';'));
                    hybridLobAll.addAll(obj.Hybrid_Local_LOBs__c.split(';'));
                }
                
                if((hybridCentral.isEmpty() && hybridLocal.isEmpty()) || (hybridCentral == NULL && hybridLocal == NULL)){
                    obj.addError('Please select a value for either Central or Local Hybrid');
                }
                else {
                    Boolean errorLOB = FALSE;
                    for(String hybCen : hybridCentral){
                        if(hybridLocal.contains(hybCen)){
                            errorLOB = TRUE;
                            obj.addError('You are not allowed to select same values in both Central and Local Hybrid');
                        }
                    }
                    if(!errorLOB){
                        for(String lob : lobValues){
                            if(!hybridLobAll.contains(lob)){
                                obj.addError('Please select the value '+ lob + ' LOB either in Central or Local Hybrid');
                            }
                        }
                    }
                }
            }
        }
        
    }
	
	private static Boolean checkOtherExceptionConditionsToSkipWinValidate(String AgainstToField, Account accountRec, Map<Id, Account> oldMap) {
        return (AgainstToField == 'Lost_Reason__c' && (accountRec.Inactivate_Reactivate_In_Progress__c == true ||
                                                       (oldMap.get(accountRec.Id).Inactivate_Reactivate_In_Progress__c == true &&
                                                        accountRec.Inactivate_Reactivate_In_Progress__c == false))) ||
            accountRec.Last_Visit_Date__c != oldMap.get(accountRec.Id).Last_Visit_Date__c;
    } 
    
    public static void handleNonCriticalAndCriticalFieldsUpdate(List<Account> newAccountList, Map<Id,Account> oldMap){
        if(UserInfo.getName().contains('Integration User'))
         {
             return;
         }
            Set<ID> acctRecTypeIdsForAccountUpdateCaseCreation = new Set<ID>{
        	customerAccountRecordType, brokerAccountRecordType, customerLocationAccountRecordType, distributorAccountRecordType, CHAIN_ACCOUNT_TYPE, 
        	rfooAccountRecordType, competitorAccountRecordType, brokerLocationAccountRecordType, distributorLocationAccountRecordType, CustomerChainRecordType,CORPORATE_ACCOUNT_TYPE,CORP_RETIRED_ACCOUNT_RECORD_TYPE
        };
                    
        List<Company_Sync__mdt> companySyncMdtLst = AccountDAO.getCompanySyncMetadata();
        Boolean isBulkProcess=Accounts.checkIfBulkProcess();
        Set<String> allFieldsSync = new Set<String>();
		String newValue,oldValue; 
        
        for(Company_Sync__mdt comapnySyncRec : companySyncMdtLst){
            allFieldsSync.add(comapnySyncRec.Field_API__c);
        }
        
        if(!allFieldsSync.isEmpty()){ 
            for(Account accountRec : newAccountList){
			if(acctRecTypeIdsForAccountUpdateCaseCreation.contains(accountRec.recordtypeId)){
                if(accountRec.Win_Validate_New__c == true){
                    initialAccountIdsWithWinvalidatedTrue.add(accountRec.Id);
                } else{
                    for(String nonCriticalAndCriticalField : allFieldsSync){
						if(AccountCRUDHandler.checkOtherExceptionConditionsToSkipWinValidate(nonCriticalAndCriticalField, accountRec, oldMap)){
                            continue;
                        } 
                        newValue= String.valueof(accountRec.get(nonCriticalAndCriticalField));
                        newValue= newValue==null?'':newValue;   
                        oldValue= String.valueof(oldMap.get(accountRec.Id).get(nonCriticalAndCriticalField));
                        oldValue= oldValue==null?'':oldValue;
                        if(!newValue.equals(oldValue)
                            && (String.isNotBlank(accountRec.WIN_ID__c) ||(!String.isBlank(accountRec.dunbrdst__c) && (accountRec.RecordTypeId == CORPORATE_ACCOUNT_TYPE || accountRec.RecordTypeId == CORP_RETIRED_ACCOUNT_RECORD_TYPE) ))
                        ){
                            accountRec.Win_Validate_New__c = true;
                            accountRec.Validation_last_requested_by__c = userInfo.getUserId();
                            accountRec.Validation_last_requested_date__c = DateTime.Now();
                            if(!isBulkProcess  || Test.isRunningTest()){
                                accountRec.High_Priority__c = true;
                                lockAccountRecord(accountRec, false);
                            }
                            break;
                        }
                    }
                    
                }
            }
          }
        }
    }
  @TestVisible private static String getReviewerForParentCase(Id accountId) {
       Date threeDaysAgo = System.today().addDays(-3);   
       Id accountUpdateValidationsRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(CHConstants.CASE_RECORD_TYPE_ACCOUNT_UPDATE_VALIDATIONS).getRecordTypeId();
       List<Case> caseObj = [SELECT Id, AccountId, Status, MDM_Approver__c, Recordtypeid 
                      FROM Case 
                      WHERE AccountId = :accountId AND CreatedDate >= :threeDaysAgo
                      AND MDM_Approver__c !=null AND Recordtypeid =: accountUpdateValidationsRecordTypeId and (Status = 'In Progress' or Status = 'Complete - Rejected' or Status = 'Complete - Partially Approved')  Order by CreatedDate Asc Limit 1];
 
       Map<Id, Id> accountToReviewerMap = new Map<Id, Id>();
       if(!caseObj.isEmpty()){ 
                  
         for (Case savedCase : caseObj) {
           accountToReviewerMap.put(savedCase.AccountId, savedCase.MDM_Approver__c);
          }
       
        if(!accountToReviewerMap.isempty()){
           return accountToReviewerMap.get(AccountId);
       } 
    }
     return null;
  } 
    
    public static void createCaseForUpdateAccount(Map<Id, Account> newAccountMap, Map<Id,Account> oldMap){
        Id accountUpdateValidationsRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Account Update Validations').getRecordTypeId();
        Id childCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Field Change Request').getRecordTypeId();
         Boolean isBulkProcess=Accounts.checkIfBulkProcess();         
         Set<ID> acctRecTypeIdsForAccountUpdateCaseCreation = new Set<ID>{
        	customerAccountRecordType, brokerAccountRecordType, customerLocationAccountRecordType, distributorAccountRecordType, 
        	 brokerLocationAccountRecordType, distributorLocationAccountRecordType
        };
        Map<Id, Set<String>> accountCriticalFieldMap = new Map<Id, Set<String>>();
        Set<String> criticalFieldSet = new Set<String>();
		Set<Id> chainRecIds = new Set<Id>();
		Map<Id, Account> chainAccMap = new Map<Id, Account>();
        Map<Id, Case> accountCaseMap = new Map<Id, Case>();
        Map<Id, String> existAccountCaseMap = new Map<Id, String>();
        Set<String> shippingAccountAddressFields = new Set<String>();
        Set<String> billingAccountAddressFields = new Set<String>(); 
        List<Company_Sync__mdt> companySyncMetadataLst = AccountDAO.getCompanySyncMetadata();
        Map<String, String> criticalFieldsMap = new Map<String, String>();
        Boolean isShippingAddress = false;
        Boolean isBillingAddress = false;
		String newValue,oldValue;
        for(Company_Sync__mdt comapnySyncRec : companySyncMetadataLst){
            if(comapnySyncRec.isCriticalField__c){
                criticalFieldsMap.put(comapnySyncRec.Field_API__c, comapnySyncRec.Label);
                if(comapnySyncRec.isShippingAddressChanged__c){
                    shippingAccountAddressFields.add(comapnySyncRec.Field_API__c);
                }
                if(comapnySyncRec.isBillingAddressChanged__c){
                    billingAccountAddressFields.add(comapnySyncRec.Field_API__c);
                }
            }
        }      
         
         if(UserInfo.getName().contains('Integration User')){
             for(Account accountRec : newAccountMap.values()){
                 for(String criticalField : criticalFieldsMap.keySet()){
                     if(String.valueof(accountRec.get(criticalField)) != String.valueof(oldMap.get(accountRec.Id).get(criticalField))){
                         if(shippingAccountAddressFields.contains(criticalField)){
                             criticalField = CHConstants.ACCOUNT_SHIPPING_ADDRESS_CHANGED;
                         }else if(billingAccountAddressFields.contains(criticalField)){
                             criticalField =CHConstants.ACCOUNT_BILLING_ADDRESS_CHANGED;
                         }

                         if(accountCriticalFieldMap.containsKey(accountRec.Id)){
                             accountCriticalFieldMap.get(accountRec.Id).add(criticalField);
                         }else{
                             accountCriticalFieldMap.put(accountRec.Id, new Set<String>{criticalField});
                         }
                     }
                 }
             }
             
             if(!accountCriticalFieldMap.isEmpty()){
                 
                 Map<Id, List<Case>> casesTocChildCaseMap = new Map<Id, List<Case>>();
                 Set<Id> parentCaseAlreadyRejectOrApprovedIds = new Set<Id>();
                 
                 for(Case caseObj: [
                     SELECT Id, Status, Account_Field_Changed__c, AccountId , ParentId, Parent.AccountId
                     FROM Case
                     WHERE Parent.AccountId IN :accountCriticalFieldMap.keySet()
                     AND RecordTypeId = :childCaseRecordTypeId
                 ]){
                     
                     if(caseObj.Status == Case_Status_Awaiting_Manager_Approval){
                         Set<String> criticalFieldSets = accountCriticalFieldMap.get(caseObj.Parent.AccountId);
                         
                         if(criticalFieldSets.contains(caseObj.Account_Field_Changed__c))
                             caseObj.status= Case_Status_ClosedWINBackSync;
                         
                         if(casesTocChildCaseMap.containsKey(caseObj.ParentId)){
                             casesTocChildCaseMap.get(caseObj.ParentId).add(caseObj);
                         }else{
                             casesTocChildCaseMap.put(caseObj.ParentId, new List<Case>{caseObj});
                         }    
                     }else if(caseObj.Status != Case_Status_ClosedWINBackSync){
                         parentCaseAlreadyRejectOrApprovedIds.add(caseObj.ParentId);
                     }
                 }
                                  
                 List<Case> casesToUpdate = new List<Case>();
                 for(Id parentCaseId : casesTocChildCaseMap.keySet()){
                     Boolean isCloseParentCase = true;
                     Boolean isAnyCaseUpdated = false;
                     
                     for(Case caseRec : casesTocChildCaseMap.get(parentCaseId)){
                         if(caseRec.status == Case_Status_ClosedWINBackSync){
                             isAnyCaseUpdated = true;
                         	casesToUpdate.add(caseRec);
                         }else{
                             isCloseParentCase = false;
                         }
                     }
                     
                     if(isCloseParentCase && isAnyCaseUpdated && !parentCaseAlreadyRejectOrApprovedIds.contains(parentCaseId)){
                         casesToUpdate.add(new Case(Id=parentCaseId, status=Case_Status_ClosedWINBackSync));
                     }
                 }
                                 
                 List<Approval.ProcessWorkitemRequest> reqLst = new List<Approval.ProcessWorkitemRequest>();
                 for(ProcessInstanceWorkitem processInstanceRec : [
                     SELECT Id, ProcessInstanceId, ProcessInstance.TargetObjectId 
                     FROM ProcessInstanceWorkitem 
                     WHERE ProcessInstance.TargetObjectId IN :casesToUpdate
                 ]){
                     Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
                     req.setAction('Removed');       
                     req.setWorkitemId(processInstanceRec.Id);
                     reqLst.add(req);
                 }
                 
                 if(!reqLst.isEmpty())
                 	Approval.process(reqLst);
                 
                 if(!casesToUpdate.isEmpty()){
                 	update casesToUpdate;    
                 }
             }
         }else if(!isBulkProcess || Test.isRunningTest()){         
            
             for(Account accountRec : newAccountMap.values()){
                 if(!initialAccountIdsWithWinvalidatedTrue.contains(accountRec.id)){
                     for(String criticalField : criticalFieldsMap.keySet()){
                         newValue= String.valueof(accountRec.get(criticalField));
                         newValue= newValue==null?'':newValue;   
                         oldValue= String.valueof(oldMap.get(accountRec.Id).get(criticalField));
                         oldValue= oldValue==null?'':oldValue;
                         if(!newValue.equals(oldValue)
                            && String.isNotBlank(accountRec.WIN_ID__c) && acctRecTypeIdsForAccountUpdateCaseCreation.contains(accountRec.recordtypeId)
                           ){
							 if(criticalField == 'Chain__c'){
                                    if(String.valueof(accountRec.get(criticalField)) != NULL){
                                        chainRecIds.add(String.valueof(accountRec.get(criticalField)));
                                    }
                                    
                                    if(String.valueof(oldMap.get(accountRec.Id).get(criticalField)) != NULL){
                                        chainRecIds.add(String.valueof(oldMap.get(accountRec.Id).get(criticalField)));
                                    }
                                }

                                if(accountCriticalFieldMap.containsKey(accountRec.Id)){
                                    accountCriticalFieldMap.get(accountRec.Id).add(criticalField);
                                }else{
                                    accountCriticalFieldMap.put(accountRec.Id, new Set<String>{criticalField});
                                }
                                
                                if(!accountCaseMap.containsKey(accountRec.Id)){
                                    Case parentCaseRec = new Case();
                                    id caseReviewerid = getReviewerForParentCase (accountRec.Id);
                                    if(caseReviewerid!=null){
                                        parentCaseRec.MDM_Approver__c = caseReviewerid;
                                    }
                                    parentCaseRec.AccountId = accountRec.Id;
                                    parentCaseRec.RecordTypeId = accountUpdateValidationsRecordTypeId;  
                                    accountCaseMap.put(accountRec.Id, parentCaseRec);
                                }
                            }
                     }
                 }
             }
           if(!accountCriticalFieldMap.isEmpty()){            
             criticalFieldsMap.put(CHConstants.ACCOUNT_SHIPPING_ADDRESS_CHANGED, 'Shipping Address');
             criticalFieldsMap.put(CHConstants.ACCOUNT_BILLING_ADDRESS_CHANGED, 'Billing Address');
                          
             List<Case> cases = [
                 SELECT Id, Account_Field_Changed__c, parent.AccountId 
                 FROM Case 
                 WHERE parent.AccountId IN :accountCriticalFieldMap.keySet() 
                 AND Account_Field_Changed__c IN :criticalFieldsMap.keySet()
                 AND RecordTypeId = :childCaseRecordTypeId  
                 AND ( Status = :Case_Status_Awaiting_Manager_Approval)
             ];
                          
             for(Case caseRec : cases){
                 Set<String> accountCriticalFieldChangeSet = accountCriticalFieldMap.get(caseRec.parent.AccountId);
                 
                if(caseRec.Account_Field_Changed__c == CHConstants.ACCOUNT_SHIPPING_ADDRESS_CHANGED){
                     for(String accountFieldChange : accountCriticalFieldChangeSet){
                         if(shippingAccountAddressFields.contains(accountFieldChange)){
                             isShippingAddress = true;
                         }
                     }
                 }
                 
                if(caseRec.Account_Field_Changed__c == CHConstants.ACCOUNT_BILLING_ADDRESS_CHANGED){
                     for(String accountFieldChange : accountCriticalFieldChangeSet){
                         if(billingAccountAddressFields.contains(accountFieldChange)){
                             isBillingAddress = true;
                         }
                     }
                 }
                 
                 if((accountCriticalFieldChangeSet != NULL && accountCriticalFieldChangeSet.contains(caseRec.Account_Field_Changed__c)) 
                    || (isShippingAddress || isBillingAddress)){
                     if(!existAccountCaseMap.containsKey(caseRec.parent.AccountId)){
                         existAccountCaseMap.put(caseRec.parent.AccountId, CHConstants.CASE_MESSAGE);
                     }   
                 }
             }
             
             for(Id accountId : existAccountCaseMap.keySet()){
                 newAccountMap.get(accountId).addError(existAccountCaseMap.get(accountId));
             }
             
             if(!accountCaseMap.isEmpty()){
                 insert accountCaseMap.values();
             }
             
             List<Case> childCaseToInsert = new List<Case>();
             Map<String, Case> billingAndShippingCaseMap = new Map<String, Case>();
			 
			  if(!chainRecIds.isEmpty()) {
                 chainAccMap = new Map<Id, Account>([SELECT Id,Chain__c,name FROM Account WHERE Id IN :chainRecIds]);
                 }
             
             for(Id accountRecId : accountCriticalFieldMap.keyset()){
                 Account accountRec = newAccountMap.get(accountRecId);
                 Case parentCaseRec = accountCaseMap.get(accountRecId);
                 
                 for(String criticalField : accountCriticalFieldMap.get(accountRecId)){
					Boolean isShippingAddressChanged = shippingAccountAddressFields.contains(criticalField);
                    Boolean isBillingAddressChanged = billingAccountAddressFields.contains(criticalField);
                     
                     if(isShippingAddressChanged && billingAndShippingCaseMap.containsKey('S' + accountRec.Id)){
                         AccountCRUDHandler.setCaseFieldChange(criticalField, billingAndShippingCaseMap.get('S' + accountRec.Id),  String.valueOf(oldMap.get(accountRec.Id).get(criticalField)));
                     	continue;
                     }
                                            
                     if(isBillingAddressChanged && billingAndShippingCaseMap.containsKey('B' + accountRec.Id)){
                     	AccountCRUDHandler.setCaseFieldChange(criticalField, billingAndShippingCaseMap.get('B' + accountRec.Id), String.valueOf(oldMap.get(accountRec.Id).get(criticalField)));
                    	continue;
                     }
                     
                     Case childCase = new Case();
                     childCase.RecordTypeId = childCaseRecordTypeId;
                     childCase.Status = 'New';
                     childCase.parentID = parentCaseRec.Id;
                     childCase.Subject = 'Child Case';
                     
                     if(!(isShippingAddressChanged || isBillingAddressChanged)){
                         childCase.Account_Field_Changed__c = criticalField;
                         childCase.New_Value__c = String.valueOf(accountRec.get(criticalField));
                         childCase.Old_Value__c = String.valueOf(oldMap.get(accountRec.Id).get(criticalField));
						 if(criticalField == 'Chain__c'){
                             if(chainAccMap.containsKey(String.valueOf(accountRec.get(criticalField)))){
                                 childCase.New_Value__c = chainAccMap.get(childCase.New_Value__c).Name;
                                 
                             }
                             
                             if(chainAccMap.containsKey(String.valueOf(oldMap.get(accountRec.Id).get(criticalField)))){
                                 childCase.Old_Value__c = chainAccMap.get(childCase.Old_Value__c).Name;
                                 AccountCRUDHandler.setCaseFieldChange(criticalField, childCase, oldMap.get(accountRec.Id).Chain__c);
                             }
							 else
                             {
                                childCase.Old_Chain_Code_Name__c = NULL;
                              }
                         }
                     }else{
                         if(isShippingAddressChanged){
                             childCase.Account_Field_Changed__c = CHConstants.ACCOUNT_SHIPPING_ADDRESS_CHANGED;
                             childCase.New_Value__c = accountRec.shippingstreet + ' ' + accountRec.shippingcity + ' , ' + accountRec.shippingstate + ' ' + accountRec.shippingPostalCode + ' ' + accountRec.shippingCountry;
                             Account oldAcc = oldMap.get(accountRec.Id);
                             childCase.Old_Value__c = oldAcc.shippingstreet + ' ' + oldAcc.shippingcity + ' , ' + oldAcc.shippingstate + ' ' + oldAcc.shippingPostalCode + ' ' + oldAcc.shippingCountry;
                             billingAndShippingCaseMap.put('S' + accountRec.Id, childCase);
                             AccountCRUDHandler.setCaseFieldChange(criticalField, childCase,  String.valueOf(oldMap.get(accountRec.Id).get(criticalField)));
                         }else if(isBillingAddressChanged){
                             childCase.Account_Field_Changed__c = CHConstants.ACCOUNT_BILLING_ADDRESS_CHANGED;
                             childCase.New_Value__c = accountRec.billingstreet + ' ' + accountRec.billingcity + ' , ' + accountRec.billingstate + ' ' + accountRec.billingPostalCode + ' ' + accountRec.BillingCountry;
                             Account oldAcc = oldMap.get(accountRec.Id);
                             childCase.Old_Value__c = oldAcc.billingstreet + ' ' + oldAcc.billingcity + ' , ' + oldAcc.billingstate + ' ' + oldAcc.billingPostalCode + ' ' + oldAcc.BillingCountry;
                             billingAndShippingCaseMap.put('B' + accountRec.Id, childCase);
                             AccountCRUDHandler.setCaseFieldChange(criticalField, childCase,  String.valueOf(oldMap.get(accountRec.Id).get(criticalField)));
                         }
                     }
                     
                     childCaseToInsert.add(childCase);
                 }
             }
             
             if(!childCaseToInsert.isEmpty()){
                 insert childCaseToInsert;
				}
			}
		}
    }
    
    private static void setCaseFieldChange(String criticalFieldChange, Case caseRec,  String oldValue){
        if(String.isBlank(oldValue)){
            oldValue = AccountCRUDHandler.OldValueReplace;
        }
        
        switch on criticalFieldChange {
            when 'BillingStreet' {
                caseRec.Old_Billing_Street__c = oldValue;
            }
            when 'BillingState' {
                caseRec.Old_Billing_State__c = oldValue;
            }
            when 'BillingCity' {
                caseRec.Old_Billing_City__c = oldValue;
            }
            when 'BillingPostalCode' {
                caseRec.Old_Billing_Postal_Code__c = oldValue;
            }
            when 'BillingCountry' {
                caseRec.Old_Billing_Country__c = oldValue;
            }
            when 'ShippingStreet' {
                caseRec.Old_Corporate_Street__c = oldValue;
            }
            when 'ShippingState' {
                caseRec.Old_Corporate_State__c = oldValue;
            }
            when 'ShippingCity' {
                caseRec.Old_Corporate_City__c = oldValue;
            }
            when 'ShippingPostalCode' {
                caseRec.Old_Corporate_Postal_Code__c = oldValue;
            }
            when 'ShippingCountry' {
                caseRec.Old_Corporate_Country__c = oldValue;
            }
			when 'Chain__c'{
                  caseRec.Old_Chain_Code_Name__c = oldValue;
            }
        }
    }
    
    
    Public Static void InsertNewAccountCase (List<Account> newAccountList,Map<Id,Account> oldMap){
        Id newCustomerRequestRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('New Customer Request').getRecordTypeId();
        List<Case> insertCases = new List<Case>();
         Set<ID> acctRecTypeIdsForNewAccountCaseCreation = new Set<ID>{customerAccountRecordType, brokerAccountRecordType, customerLocationAccountRecordType, distributorAccountRecordType,
          CHAIN_ACCOUNT_TYPE, brokerLocationAccountRecordType};
        Boolean isEOCUser = false;
		List<PermissionSetAssignment> psaList = [SELECT PermissionSet.Name FROM PermissionSetAssignment WHERE AssigneeId = :UserInfo.getUserId() AND PermissionSet.Name = 'Emergency_Operations_Center' ];
        if (!psaList.isEmpty()) {
            isEOCUser = true;
        }
        for(Account A : newAccountList){ 
            if(acctRecTypeIdsForNewAccountCaseCreation.contains(a.recordtypeId) && A.New_Customer_validated__c == true && oldMap.get(a.id).New_Customer_validated__c == false && a.Inactivate_Reactivate_In_Progress__c == false){
                Case c = new Case ();
                c.AccountId = a.Id;
                c.RecordTypeId = newCustomerRequestRecordTypeId;
                c.New_EPA_ID__c = a.CS_EPA_ID__c;
                c.New_State_EPA_ID__c = a.State_EPA_ID__c;
                c.New_GenReg_Id__c = a.GENREG__c;
                c.OwnerId = UserInfo.getUserId();
				c.Duplicate_Reason__c = a.Duplicate_Reason__c;
                c.Duplicate_Justification__c = a.Duplicate_Justification__c;
				if(isEOCUser){
                    c.Priority = 'Critical';
                    c.EOC_Case__c = True;
                } 
                insertCases.add(c);
            }
        } 
        
        if(!insertCases.isEmpty()){
            insert insertCases;
        }
    }
    
    /*
* @method: AccountCRUDHandler.RollUpCustomerARtoCorp(accList)
* @description: Adds up the AR of all Customer Accounts and Displays on Parent(Corp). 
* Developer: Sireesha.
*/
    
    public static void RollUpCustomerARtoCorp(List<Account> accList, Map<Id, Account> oldMap){ 
        
        Id customerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        Set<Id> parentIds = new Set<Id>();
        List<Account> updateList = new List<Account>();
        Map<Id, List<Account>> childAccByParentIdMap = new Map<Id, List<Account>>();
        
        for(Account acc : accList){
            if(acc.AR_Dummy__c || (acc.RecordTypeId == customerRecordTypeId && (OldMap == NULL || acc.AR_Total_Due__c != oldMap.get(acc.Id).AR_Total_Due__c))){
                if(acc.ParentId != NULL){
                    parentIds.add(acc.ParentId);   
                }
            }
        }
        
        if(!parentIds.isEmpty()){
            for(Account childAcc : [Select Id, Name, AR_Total_Due_Corp__c, AR_Total_Due__c, ParentId from Account where ParentId IN : parentIds AND RecordTypeId =: customerRecordTypeId]){
                
                if(childAccByParentIdMap.containsKey(childAcc.ParentId)){
                    childAccByParentIdMap.get(childAcc.ParentId).add(childAcc);
                }
                else{
                    childAccByParentIdMap.put(childAcc.ParentId, new List<Account>{childAcc});
                }
            }
            
            for(Id parentAccId : parentIds){
                if(childAccByParentIdMap.containsKey(parentAccId)){
                    Double arTotal=0;
                    for(Account cAccount : childAccByParentIdMap.get(parentAccId)){
                        if(cAccount.AR_Total_Due__c != NULL){
                            arTotal += cAccount.AR_Total_Due__c;
                        }
                    }
                    Account pAcc = new Account(Id = parentAccId, AR_Total_Due_Corp__c = arTotal);
                    updateList.add(pAcc);
                }
            }
        }
        
        if(!updateList.isEmpty()){
            update updateList;
        }
    }
    
  
    public static void updateMissingContactType(List<Account> newRecMap, Map<Id, Account> oldRecMap){
        ContactCRUDHandler.updateAccountMissingTypesAccountFlow(newRecMap,oldRecMap);
    }
   
    public static void handleParentAccountChange(Map<Id, Account> newAccountMap, Map<Id, Account> oldAccountMap){
        Id customerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        Id corporateRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Corporate').getRecordTypeId();
        Map<Id, List<Account>> nonSalesPersonFilteredAccountMap = new Map<Id, List<Account>>();
        Map<Id, Territory_Master__c> territoryMasMap = new Map<Id, Territory_Master__c>();
        List<Territory__c> territorys = new List<Territory__c>();
        List<Account> updateAccLst = new List<Account>();
        Id currentUserId = UserInfo.getUserId();
        Set<Id> accountIdSet = new Set<Id>();
        Map<Id, Id> accountIdMap = new Map<Id, Id>();
        Map<Id, Id> accountIdsChangedParentIdsWithActiveStatusMap = new Map<Id, Id>(); 
        List<Account> parentAccountsToUpdateForContractStatus = new List<Account>(); 
        Set<Id> oldParentIds = new Set<Id>(); 
        Set<Id> oldParentParentIds = new Set<Id>(); 
        List<Account> contractAccounts = NULL; 
        Set<Id> parentIdsWithChildrenChecked = new Set<Id>();

        for(Id accountId : newAccountMap.keySet())
        { 
            Account newAccount = newAccountMap.get(accountId); 
            Account oldAccount = oldAccountMap.get(accountId); 
            if(newAccount.ParentId != oldAccount.ParentId)
            { 
                if(newAccount.ParentId == NULL && newAccount.RecordTypeId == customerRecordTypeId){
                    accountIdMap.put(oldAccount.ParentId, newAccount.Id);
                } 
                if(newAccount.Active_ER_Contract__c == true)
                { 
                    accountIdsChangedParentIdsWithActiveStatusMap.put(newAccount.Id,oldAccount.ParentId); 
                } 
             } 
        }
        if(!accountIdsChangedParentIdsWithActiveStatusMap.keySet().isEmpty())
        {
            contractAccounts = [SELECT Id,Active_ER_Contract__c,ParentId,Parent.Active_ER_Contract__c,Parent.ParentId, Parent.Parent.Active_ER_Contract__c from Account WHERE Id in:accountIdsChangedParentIdsWithActiveStatusMap.keySet()];
            for(Account acc: contractAccounts)
            {
                if(acc.Parent != null && acc.Parent.Active_ER_Contract__c == false)
                {
                    parentAccountsToUpdateForContractStatus.Add(new Account(Id= acc.ParentId,Active_ER_Contract__c = true));
                }
                if(acc.Parent.Parent!=null && acc.Parent.Parent.Active_ER_Contract__c== false)
                {
                    parentAccountsToUpdateForContractStatus.Add(new Account(Id= acc.Parent.ParentId,Active_ER_Contract__c = true));
                }
            }
            //Old ParentIds
            for(Id accId : accountIdsChangedParentIdsWithActiveStatusMap.keySet())
            {
                if(accountIdsChangedParentIdsWithActiveStatusMap.get(accId) != null)
                {
                    oldParentIds.Add(accountIdsChangedParentIdsWithActiveStatusMap.get(accId));
                }
            }
            if(!oldParentIds.isEmpty())
            {
                for(AggregateResult result: [SELECT COUNT(Id) RecordCount ,ParentId ParentId FROM Account WHERE ParentId in:oldParentIds AND Active_ER_Contract__c = true GROUP BY ParentId])
                {
                    parentIdsWithChildrenChecked.Add(Id.valueOf(String.valueOf(result.get('ParentId'))));
                }
                for(Id accId : oldParentIds)
                {
                    if(!parentIdsWithChildrenChecked.contains(accId))
                    {
                        parentAccountsToUpdateForContractStatus.Add(new Account(Id= accId,Active_ER_Contract__c = false));
                    }
                }
                for(Account acc :[SELECT ParentId from Account WHERE Id IN: oldParentIds and ParentId != null])
                {
                    oldParentParentIds.Add(acc.ParentId);
                }
                parentIdsWithChildrenChecked.clear();
                //Get other chidren
                for(AggregateResult result: [SELECT COUNT(Id) RecordCount ,ParentId ParentId FROM Account WHERE ParentId in:oldParentParentIds AND Active_ER_Contract__c = true GROUP BY ParentId]){
                    parentIdsWithChildrenChecked.Add(Id.valueOf(String.valueOf(result.get('ParentId'))));
                }
                for(Id accId : oldParentParentIds){
                    if(!parentIdsWithChildrenChecked.contains(accId)){
                        parentAccountsToUpdateForContractStatus.Add(new Account(Id= accId,Active_ER_Contract__c = false));
                    }
                }
            }
            if(!parentAccountsToUpdateForContractStatus.isEmpty()){
                update parentAccountsToUpdateForContractStatus;
            }
        }
       
        if(!accountIdMap.keySet().isEmpty()){
            User userRec = [
            SELECT Id, Sales_Person_Type__c, Profile.Name, Territory__c
            FROM User
            WHERE Id =:currentUserId
            ];  
        
            if(userRec.Territory__c != NULL){
                territorys = [
                    SELECT Id, Territory_OwnerID__c
                    FROM Territory__c
                    WHERE Name = :userRec.Territory__c
                ];
            }
            List<Account> copraccountLst = [SELECT Id FROM Account WHERE Id IN :accountIdMap.keySet() AND Buying_Decision__c = 'Central Buying'
                                            AND RecordTypeId = :corporateRecordTypeId];
            
            for(Account accountRec : copraccountLst){
                accountIdSet.add(accountIdMap.get(accountRec.Id));
            }  
            List<Account> accountLst = [
                SELECT Id, ZIP_Master__c, Primary_Service_Provider_New__c, Primary_Business__c, 
                (SELECT Id, ZIP_Master__c, Primary_Service_Provider_New__c, Primary_Business__c FROM ChildAccounts WHERE RecordTypeId = :customerLocationAccountRecordType
                AND (Primary_Service_Provider_New__c = 'SK ENV'
                    OR Primary_Service_Provider_New__c = 'SK BPS')
                AND ZIP_Master__c != NULL)
                FROM Account
                WHERE Id = :accountIdSet
                AND (Primary_Service_Provider_New__c = 'SK ENV'
                    OR Primary_Service_Provider_New__c = 'SK BPS')
                AND ZIP_Master__c != NULL
            ];
            
            for(Account newAccount : accountLst){
                if(nonSalesPersonFilteredAccountMap.containsKey(newAccount.ZIP_Master__c)){
                    nonSalesPersonFilteredAccountMap.get(newAccount.ZIP_Master__c).add(newAccount);
                }else{
                    nonSalesPersonFilteredAccountMap.put(newAccount.ZIP_Master__c, new List<Account>{newAccount});
                }
                
                for(Account childAcc : newAccount.ChildAccounts){
                    if(nonSalesPersonFilteredAccountMap.containsKey(childAcc.ZIP_Master__c)){
                        nonSalesPersonFilteredAccountMap.get(childAcc.ZIP_Master__c).add(childAcc);
                    }else{
                        nonSalesPersonFilteredAccountMap.put(childAcc.ZIP_Master__c, new List<Account>{childAcc});
                    }
                }
            }
            if(!nonSalesPersonFilteredAccountMap.isEmpty()){
                List<Territory_Master__c> territoryLst = [
                    SELECT Id, ZIP_Master__c, Territory_ID__r.Territory_OwnerID__c, Sales_Business_Unit__c, Name, Territory_ID__c
                    FROM Territory_Master__c
                    WHERE (
                        ZIP_Master__c IN :nonSalesPersonFilteredAccountMap.keySet()
                    )
                ];
                territoryMasMap = new Map<Id, Territory_Master__c>(territoryLst);
                for(Territory_Master__c territoryRec : territoryLst){
                    if(nonSalesPersonFilteredAccountMap.containsKey(territoryRec.ZIP_Master__c)){
                        for(Account accountRec : nonSalesPersonFilteredAccountMap.get(territoryRec.ZIP_Master__c)){
                            if(((accountRec.Primary_Service_Provider_New__c == 'SK ENV' || accountRec.Primary_Service_Provider_New__c == 'SK BPS')
                                && (territoryRec.Sales_Business_Unit__c == accountRec.Primary_Business__c ))
                            && !territoryRec.Name.endsWith('IS')){
                                
                                if(territoryRec.Territory_ID__c != NULL && territoryRec.Territory_ID__r.Territory_OwnerID__c != NULL
                                    && userRec.Sales_Person_Type__c != 'Senior Account Manager' && userRec.Sales_Person_Type__c != 'Account Manager' ){
                                        accountRec.OwnerId = territoryRec.Territory_ID__r.Territory_OwnerID__c;
                                        accountRec.Territory_Override__c = True;
                                        updateAccLst.add(accountRec);
                                    }else if(territorys.size() > 0){
                                        accountRec.OwnerId = UserInfo.getUserId();
                                        accountRec.Territory_Override__c = True;
                                        updateAccLst.add(accountRec);
                                    }
                                if(Trigger.isInsert) 
                                    AccountCRUDHandler.IS_RUN_AFTER_UPDATE = true;
                                else
                                    AccountCRUDHandler.IS_RUN_AFTER_UPDATE = false;
                            }
                        }
                    }
                }
            }
            if(updateAccLst.size() > 0){
                UPDATE updateAccLst;
            }
        }
    }
    
    public static void handleAccountOwnershipChanges(List<Account> newAccountMap, Map<Id, Account> oldAccountMap){
        Map<Id, List<Account>> nonSalesPersonFilteredAccountMap = new Map<Id, List<Account>>(); 
        if(SKIP_ONOwnerChangeBatch){
            return;
        }
        for(Account newAccountRec : newAccountMap){            
            if(!skippedAccountRecordTypesforOwnershipChanges.contains(newAccountRec.RecordtypeId)){
                if(oldAccountMap == null || (oldAccountMap != null && oldAccountMap.get(newAccountRec.Id).Status__c != 'Inactive' && newAccountRec.Status__c == 'Active')){                    
                    if(((Trigger.isInsert && newAccountRec.Key_Buying_Decision__c != 'Central Buying') || AccountCRUDHandler.IS_RUN_AFTER_UPDATE) || 
                        (newAccountRec.Key_Buying_Decision__c != 'Central Buying' && Trigger.isUpdate && 
                            (((oldAccountMap.get(newAccountRec.Id).ShippingPostalCode == NULL || oldAccountMap.get(newAccountRec.Id).ShippingPostalCode == '') && newAccountRec.ShippingPostalCode != NULL) || 
                                oldAccountMap.get(newAccountRec.Id).Primary_Business__c != newAccountRec.Primary_Business__c))){
                        if((newAccountRec.Primary_Service_Provider_New__c == 'SK ENV' || newAccountRec.Primary_Service_Provider_New__c == 'SK BPS')
                        && newAccountRec.ZIP_Master__c != NULL ){                          
                                if(nonSalesPersonFilteredAccountMap.containsKey(newAccountRec.ZIP_Master__c)){
                                    nonSalesPersonFilteredAccountMap.get(newAccountRec.ZIP_Master__c).add(newAccountRec);
                                }else{
                                    nonSalesPersonFilteredAccountMap.put(newAccountRec.ZIP_Master__c, new List<Account>{newAccountRec});
                                }                                                 
                        }
                    }
                }
            }   
            if(!nonSalesPersonFilteredAccountMap.isEmpty()){            
                assignAccountOwner(nonSalesPersonFilteredAccountMap);
            }
    	}
    }

    public static void updateSecondaryOwner(List<Account> newAccountMap, Map<Id, Account> oldAccountMap){
        set<id> ownerIdSet = new Set<id>();
        set<id> zipMasterIdSet = new Set<id>();
        Map<id,User> userMap = new Map<id,User>();
        Map<string, Territory_Master__c> territoryMasMap = new Map<string, Territory_Master__c>();
        for(Account newAccountRec : newAccountMap)
        {
            if(oldAccountMap == null)
            {
                if(newAccountRec.Primary_Service_Provider_New__c == 'SK ENV' || newAccountRec.Primary_Service_Provider_New__c == 'SK BPS' && newAccountRec.ZIP_Master__c != NULL)
                {
                    ownerIdSet.add(newAccountRec.OwnerId);
                    zipMasterIdSet.add(newAccountRec.ZIP_Master__c);
                } 
            }
            else
            {
                if((newAccountRec.Primary_Business__c != oldAccountMap.get(newAccountRec.id).Primary_Business__c
                    || newAccountRec.Primary_Service_Provider_New__c != oldAccountMap.get(newAccountRec.id).Primary_Service_Provider_New__c 
                    || newAccountRec.OwnerId != oldAccountMap.get(newAccountRec.id).OwnerId)
                   && (newAccountRec.Primary_Service_Provider_New__c == 'SK ENV' || newAccountRec.Primary_Service_Provider_New__c == 'SK BPS' && newAccountRec.ZIP_Master__c != NULL))
                {
                    ownerIdSet.add(newAccountRec.OwnerId);
                    zipMasterIdSet.add(newAccountRec.ZIP_Master__c);
                }
                else if((newAccountRec.Primary_Business__c != oldAccountMap.get(newAccountRec.id).Primary_Business__c
                         || newAccountRec.Primary_Service_Provider_New__c != oldAccountMap.get(newAccountRec.id).Primary_Service_Provider_New__c 
                         || newAccountRec.OwnerId != oldAccountMap.get(newAccountRec.id).OwnerId)
                        && (newAccountRec.Primary_Service_Provider_New__c != 'SK ENV' && newAccountRec.Primary_Service_Provider_New__c != 'SK BPS'))
                {
                    newAccountRec.Secondary_Owner__c = null;   
                }
            }
        }
        if(!ownerIdSet.IsEmpty() && !zipMasterIdSet.IsEmpty() ){
            userMap= new Map<id,user>([SELECT Id, Sales_Person_Type__c, Profile.Name, Territory__c FROM User where id in :ownerIdSet]);
            List<Territory_Master__c> territoryLst = [
                SELECT Id, ZIP_Master__c, Territory_ID__r.Territory_OwnerID__c, Sales_Business_Unit__c, Name, Territory_ID__c
                FROM Territory_Master__c
                WHERE ZIP_Master__c IN :zipMasterIdSet
            ];
            for(Territory_Master__c terMaster : territoryLst){
                if(!terMaster.Name.endsWith('-IS'))
                {
                    territoryMasMap.put(terMaster.ZIP_Master__c+terMaster.Sales_Business_Unit__c,terMaster);
                }
            }
            for(Account newAccountRec : newAccountMap){
                if(newAccountRec.Primary_Service_Provider_New__c == 'SK ENV' || newAccountRec.Primary_Service_Provider_New__c == 'SK BPS')
                {
                    if(newAccountRec.Primary_Service_Provider_New__c == 'SK BPS')
                    {
                        if(userMap.containsKey(newAccountRec.OwnerId) && userMap.get(newAccountRec.OwnerId).Territory__c != null)
                        {
                            if(userMap.get(newAccountRec.OwnerId).Territory__c.startsWith('BPS-IS') )
                            {
                                if(territoryMasMap.containsKey(newAccountRec.ZIP_Master__c+newAccountRec.Primary_Business__c))
                                {
                                    newAccountRec.Secondary_Owner__c = territoryMasMap.get(newAccountRec.ZIP_Master__c+newAccountRec.Primary_Business__c).Territory_ID__r.Territory_OwnerID__c;
                                } 
                                else
                                {
                                    newAccountRec.Secondary_Owner__c = null;
                                }
                            }
                        }
                        else
                        {
                            newAccountRec.Secondary_Owner__c = null;
                        }
                    }
                    else if(newAccountRec.Primary_Service_Provider_New__c == 'SK ENV')
                    {
                        if(userMap.containsKey(newAccountRec.OwnerId) && userMap.get(newAccountRec.OwnerId).Territory__c != null)
                        { 
                            if(userMap.get(newAccountRec.OwnerId).Territory__c.startsWith('INS-PUS'))
                            {
                                if(territoryMasMap.containsKey(newAccountRec.ZIP_Master__c+newAccountRec.Primary_Business__c))
                                {
                                    newAccountRec.Secondary_Owner__c = territoryMasMap.get(newAccountRec.ZIP_Master__c+newAccountRec.Primary_Business__c).Territory_ID__r.Territory_OwnerID__c;
                                } 
                                else
                                {
                                    newAccountRec.Secondary_Owner__c = null;
                                }
                            }
         
                        }
                        else
                        {
                            newAccountRec.Secondary_Owner__c = null;
                        }
                    }
                }
                else
                {
                    newAccountRec.Secondary_Owner__c = null;
                }
            }
        }
        if(oldAccountMap!=null && UserInfo.getName().contains('Integration User')){
            for(Account newAccountRec : newAccountMap){
                if(newAccountRec.Secondary_Owner__c==null && oldAccountMap.get(newAccountRec.id).Secondary_Owner__c!=null){
                    newAccountRec.Secondary_Owner__c= oldAccountMap.get(newAccountRec.id).Secondary_Owner__c;
                }
            }
        }
    }
    public static void handlePrBusinessHPCIndust(List<Account> accountLst, Map<Id, Account> oldAccountMap){
        for(Account accountRec : accountLst){
            if((Trigger.isInsert || 
                (Trigger.isUpdate && accountRec.Primary_Business__c != oldAccountMap.get(accountRec.Id).Primary_Business__c))
               && accountRec.Primary_Business__c == 'HPC Industrial'
              ){
                  if(String.isBlank(accountRec.Division__c)){
                      accountRec.Division__c = accountRec.ShippingCity;    
                  }
                  if(String.isBlank(accountRec.Site_ID__c)){
                      accountRec.Site_ID__c = accountRec.Name;    
                  }
                  
                  
                  accountRec.Primary_Service_Provider__c = 'HPC';
              }
        }
    }

    /**
    * @description 
    * @author Suresh Beniwal | 08-24-2022 
    * @param List<Account> listOfOrganzation 
    * @param Map<Id Account> oldMapOfOrganzation 
    **/
    public static void organizationCategoryMandatory(List<Account> listOfOrganzation, Map<Id, Account> oldMapOfOrganzation) {
        DuplicateValidationWrapper duplicateWrapperInstance = new DuplicateValidationWrapper();

        for(Account accountRecord : listOfOrganzation) { 
            if (accountRecord.recordTypeId == hrTalentPoolsAccountRecordType) {
                if (String.isBlank(accountRecord.Organization_Category__c) && !Test.isRunningTest()) {
                    accountRecord.Organization_Category__c.addError('Organization Category is mandatory');
                }

                if (oldMapOfOrganzation == null || (
                    oldMapOfOrganzation != null && (
                    accountRecord.Name != oldMapOfOrganzation.get(accountRecord.Id).Name
                    || accountRecord.ShippingCity != oldMapOfOrganzation.get(accountRecord.Id).ShippingCity
                    || accountRecord.ShippingState != oldMapOfOrganzation.get(accountRecord.Id).ShippingState
                    || accountRecord.ShippingCountry != oldMapOfOrganzation.get(accountRecord.Id).ShippingCountry
                    || accountRecord.ShippingStreet != oldMapOfOrganzation.get(accountRecord.Id).ShippingStreet
                    || accountRecord.ShippingPostalCode != oldMapOfOrganzation.get(accountRecord.Id).ShippingPostalCode
                    || accountRecord.Organization_Category__c != oldMapOfOrganzation.get(accountRecord.Id).Organization_Category__c
                    ))) {

                    duplicateWrapperInstance.setOfName.add(accountRecord.Name);
                    duplicateWrapperInstance.setOfCity.add(accountRecord.ShippingCity);
                    duplicateWrapperInstance.setOfState.add(accountRecord.ShippingState);
                    duplicateWrapperInstance.setOfCountry.add(accountRecord.ShippingCountry);
                    duplicateWrapperInstance.setOfStreet.add(accountRecord.ShippingStreet);
                    duplicateWrapperInstance.setOfPostalCode.add(accountRecord.ShippingPostalCode);
                    duplicateWrapperInstance.setOfOrganizationCategory.add(accountRecord.Organization_Category__c);
                }
            }
        }

        if (duplicateWrapperInstance != null && !duplicateWrapperInstance.setOfCity.isEmpty()) {
            Map<String, Account> mapOfAccount = new Map<String, Account>();
            for (Account accountRecord : [
                SELECT Id, Name, ShippingCity, ShippingState, ShippingCountry, ShippingStreet, ShippingPostalCode, Organization_Category__c
                FROM Account
                WHERE RecordTypeId =: hrTalentPoolsAccountRecordType
                    AND Name IN: duplicateWrapperInstance.setOfName
                    AND ShippingCity IN: duplicateWrapperInstance.setOfCity
                    AND ShippingState IN: duplicateWrapperInstance.setOfState
                    AND ShippingCountry IN: duplicateWrapperInstance.setOfCountry
                    AND ShippingStreet IN: duplicateWrapperInstance.setOfStreet
                    AND ShippingPostalCode IN: duplicateWrapperInstance.setOfPostalCode
                    AND Organization_Category__c IN: duplicateWrapperInstance.setOfOrganizationCategory]) {

                String key = accountRecord.Name + accountRecord.ShippingStreet + accountRecord.ShippingCity 
                        + accountRecord.ShippingState + accountRecord.ShippingCountry + accountRecord.ShippingPostalCode
                        + accountRecord.Organization_Category__c;
                key = key.toLowerCase();
                mapOfAccount.put(key, accountRecord);
            }

            for(Account accountRecord : listOfOrganzation) { 
                String key = accountRecord.Name + accountRecord.ShippingStreet + accountRecord.ShippingCity 
                        + accountRecord.ShippingState + accountRecord.ShippingCountry + accountRecord.ShippingPostalCode
                        + accountRecord.Organization_Category__c;
                key = key.toLowerCase();
                if (accountRecord.recordTypeId == hrTalentPoolsAccountRecordType && mapOfAccount.containsKey(key)) {
                    accountRecord.addError('Duplicate Account Exist with record Id ' + mapOfAccount.get(key).Id);
                }
            }
        }
    }

    public class DuplicateValidationWrapper {
        public Set<String> setOfName = new Set<String>();
        public Set<String> setOfCity = new Set<String>();
        public Set<String> setOfState = new Set<String>();
        public Set<String> setOfCountry = new Set<String>();
        public Set<String> setOfStreet = new Set<String>();
        public Set<String> setOfPostalCode = new Set<String>();
        public Set<String> setOfOrganizationCategory = new Set<String>();
    }

    
    /**
* @description 
* @author Suresh Beniwal | 05-26-2022 
* @param List<Account> listOfOrganzation 
* @param Map<Id Account> oldMapOfOrganzation 
**/
    public static void checkDraftStatusChangeForOrganization(List<Account> listOfOrganzation, Map<Id, Account> oldMapOfOrganzation) {
        Map<Id,Account> mapOrgs =new Map<Id,Account>([Select Id,RecordType.Name,Organization_Status__c,(select Id, Owner_Type__c FROM Organization_Owners__r),
        (Select Id FROM Departments__r),(Select Id FROM Organization_Job_Codes__r),
        (Select Id FROM Contacts ), (SELECT Id FROM Locations__r)  FROM Account where Id = :listOfOrganzation AND recordTypeId = :hrTalentPoolsAccountRecordType ]);
        for(Account acctRecord : listOfOrganzation){
            if (acctRecord.recordTypeId == hrTalentPoolsAccountRecordType) {
                Account allAcctInfo= mapOrgs.get(acctRecord.Id);
                Integer ownerCount = 0;
                for (Organization_Owners__c ownerRecord : allAcctInfo?.Organization_Owners__r) {
                    if (ownerRecord.Owner_Type__c == 'Partnership Owner' || ownerRecord.Owner_Type__c == 'Contributor' ) {
                        ++ownerCount;
                    }
                }
        
                if(acctRecord.Organization_Status__c!=CHConstants.ACCOUNT_DRAFT_STATUS  && oldMapOfOrganzation.get(acctRecord.Id).Organization_Status__c ==CHConstants.ACCOUNT_DRAFT_STATUS
                 && allAcctInfo!=null && (ownerCount < 2 || allAcctInfo.Departments__r.size()<1
                                          || allAcctInfo.Organization_Job_Codes__r.size()< 1 || allAcctInfo.Contacts.size()<1)){
                    acctRecord.Organization_Status__c.addError(System.label.HR_Talent_Pool_Org_Status_ErrorMsg); 
                }
            }
        }
    }
    /*
* @method: AccountCRUDHandler.retainTeamMemberOnOwnerChange(accountLst,oldAccountMap)
* @description: functionality to reinsert Account Team memebers after Account owner update. 
*/   
    
    public static void retainTeamMemberOnOwnerChange(List<Account> accounts, Map<Id, Account> oldAccountMap){
        Set<Id> accountIdsForChangeTracking = new Set<Id>();
        for(Account acc: accounts){
            if(acc.OwnerId != oldAccountMap.get(acc.Id).OwnerId){
                accountIdsForChangeTracking.add(acc.Id);                     
            }
        }
        if(!accountIdsForChangeTracking.isEmpty()){
            for(AccountTeamMember accTeamMem : [SELECT Id, AccountId, UserId, TeamMemberRole FROM AccountTeamMember Where AccountId in :accountIdsForChangeTracking])
            {
                accountTeamMembersOnOwnerChange.add(accTeamMem.clone());
            } 
        }
    }  
    public static void createAccountTeamMembers()
    {
        if(!accountTeamMembersOnOwnerChange.isEmpty()){
            Database.insert(accountTeamMembersOnOwnerChange, false);
            accountTeamMembersOnOwnerChange.clear();
        }
    }
    
    
    
    /************************************************************************************** 

* @Description  This method retain parentid for related parentid is regional account and if its beacon user

* @Param    AccountCRUDHandler.resetParentIdforcustAccountsMappedtoRegional(newAccounts,oldAccountMap); 

**************************************************************************************/   
    
    public static void resetParentIdforcustAccountsMappedtoRegional(List<Account> newAccounts, Map<Id, Account> oldAccountMap){
        String currentUserName = UserInfo.getName();    
        for(Account acc: newAccounts)
        {
            If(currentUserName == 'Beacon Integration User' && oldAccountMap.get(acc.Id).Parent_Account_Type__c =='Key Account' && oldAccountMap.get(acc.Id).ParentId !=null && acc.ParentId==null)
            {
                
                acc.ParentId = oldAccountMap.get(acc.Id).parentid;
                acc.Win_Validation_NonRollupAccount__c=true;  
                
            } 
            if(acc.Parent_Account_Type__c=='Key Account' && oldAccountMap.get(acc.Id).Parentid==null )
            {
                acc.Win_Validation_NonRollupAccount__c=true;  
                
            }  
        }
        
    }
    
    public static void handleUpdateShipGenRecordOnCustomerOwnerChange(List<Account> newLst, Map<Id, Account> oldAccMap){
        List<Id> accountIdToOwnerId = new List<Id>();
        List<Integration_process__c> integrationProcesses = new List<Integration_process__c>();
        for(Account accountObj : newLst){
            Account oldAcc = oldAccMap.get(accountObj.Id);
            if(accountObj.OwnerId != oldAcc.OwnerId 
                && accountObj.RecordTypeId == customerAccountRecordType
                && accountObj.Primary_Service_Provider_New__c == 'Clean Harbors ENV'
                && accountObj.Primary_Business__c != 'HEPACO'
                && accountObj.Status__c == 'Active'
            ){
                accountIdToOwnerId.Add(accountObj.Id); 
            }
        }
        if(!accountIdToOwnerId.isEmpty()){
                Set<Id> childAccountIds = new Set<Id>();
                for(Account acc : [select id from Account where ParentId in:accountIdToOwnerId and status__c='Active' and Primary_Service_Provider_New__c = 'Clean Harbors ENV' and Primary_Business__c != 'HEPACO']){
                    childAccountIds.Add(acc.Id);
                }
                if(!childAccountIds.isEmpty()){
                    integrationProcesses = [Select Id from Integration_process__c where Status__c = 'Pending' and
                                                                        Account__c in : childAccountIds and Process_Type__c =: CHConstants.Ownerupdate];
                    
                    for(Integration_process__c integrationProcess : integrationProcesses){
                        integrationProcess.Status__c='Ignored';
                    }
                    if(!integrationProcesses.isEmpty()){
                    update integrationProcesses;
                    }
                    integrationProcesses.clear();
                    for(Id accId: childAccountIds){
                        Integration_process__c  integProcess= new Integration_process__c();
                        integProcess.Status__c='Pending';
                        integProcess.Account__c= accId;
                        integProcess.Process_Type__c= CHConstants.Ownerupdate;
                        integrationProcesses.add(integProcess);     
                    }
                    if(!integrationProcesses.isEmpty())
                    {
                        insert integrationProcesses;
                    }
                } 
        }
    }
    	
	
	public static void handleUpdateRelatedChildRecords(List<Account> newLst, Map<Id, Account> oldAccMap){ 	
        List<Id> parentAccountIds = new List<Id>();	
        List<Integration_process__c> integrationProcesses = new List<Integration_process__c>();	
        Set<Id> childAccountIds = new Set<Id>();	
        for(Account accountObj : newLst){	
            Account oldAcc = oldAccMap.get(accountObj.Id);	
            if((oldAcc.recordtypeId == customerAccountRecordType && accountObj.RecordtypeId == brokerAccountRecordType) 	
                &&  accountObj.Primary_Service_Provider_New__c == 'Clean Harbors ENV'){	
                parentAccountIds.Add(accountObj.Id);	   	
            }	
        }	
        if(!parentAccountIds.isEmpty()){
            for(Account acc : [	
                SELECT id,WIN_Validated__c 	
                FROM account 	
                WHERE ParentId in:parentAccountIds AND RecordType.DeveloperName != 'Broker_Location' and Status__c='Active' 	
                and Primary_Service_Provider_New__c = 'Clean Harbors ENV'	
            ]){	
                childAccountIds.add(acc.id);	
            }	
                
            if(!childAccountIds.isEmpty()){	
                integrationProcesses = [Select Id from Integration_process__c where Status__c = 'Pending' and	
                                        Account__c in : childAccountIds and Process_Type__c =: CHConstants.BrokerRecordTypeUpdate];	
                    
                for(Integration_process__c integrationProcess : integrationProcesses){	
                    integrationProcess.Status__c='Ignored';	
                }	
                if(!integrationProcesses.isEmpty()){	
                    update integrationProcesses;	
                }	
                integrationProcesses.clear();	
                    
                for(Id accId: childAccountIds){	
                    Integration_process__c  integProcess= new Integration_process__c();	
                    integProcess.Status__c='Pending';	
                    integProcess.Account__c= accId;	
                    integProcess.Process_Type__c= CHConstants.BrokerRecordTypeUpdate;	
                    integrationProcesses.Add(integProcess);	
                }	
                    
                if(!integrationProcesses.isEmpty()){	
                    insert integrationProcesses;	
                }	
            }
        }	
    }
	
    /**
    * @param account   the account record that needs to be locked
    */
    @InvocableMethod(callout=true label='Lock Account By Id') 
    public static void lockAccountRecordbyId(List<ID> accID) {
        List<Approval.LockResult> lockResults= Approval.lock(accID); 
        List<Account> accountsToUpdate=new List<Account>();
        for(Approval.LockResult lockResult: lockResults){
            if(lockResult.isSuccess()){
                accountsToUpdate.Add(new Account(Is_Record_Locked__c= true, Id=lockResult.getId()));
            }
        }
        if(!accountsToUpdate.isEmpty()){
            update accountsToUpdate;
        }
    } 
       /************************************************************************************** 
 
        * @Description  This method tracks accounts participating in platform events - High and Low Priority

       * @Param    AccountCRUDHandler.trackAccountsForWinIdGeneration(newAccList,oldAccMap); 

       **************************************************************************************/  
    public static void trackAccountsForWinIdGeneration(List<Account> newAccList){
        List<Integration_Process__c> integrationRecordsToGenerateWinIds = new List<Integration_Process__c>();
        List<Integration_Process__c> integrationRecordsToGenerateWinIdsForLowPriority = new List<Integration_Process__c>();
        Set<Id> existingAccountIdsPendingForWinIdGeneration= new Set<Id>();
        List<Account> accountsRequiredForWinIdGeneration= new List<Account>();
       
        for(Account acc : newAccList){
            if(acc.Win_Validate_New__c == true && acc.getErrors().isEmpty() && String.isBlank(acc.WIN_ID__c) && acc.RecordTypeId !=CORPORATE_ACCOUNT_TYPE && acc.RecordTypeId != CORP_RETIRED_ACCOUNT_RECORD_TYPE){
                accountsRequiredForWinIdGeneration.Add(acc);
            }
        }
        if(!accountsRequiredForWinIdGeneration.isEmpty()){
            for(Integration_Process__c integrationProcess: [SELECT Id,Account__c from Integration_Process__c 
                WHERE Status__c= 'Pending' AND Process_Type__c=: CHConstants.ACCOUNT_WIN_VALIDATE_CREATE LIMIT 30000]){
                    existingAccountIdsPendingForWinIdGeneration.Add(integrationProcess.Account__c);                                                     
            }
            for(Account acc:accountsRequiredForWinIdGeneration){
                if(!existingAccountIdsPendingForWinIdGeneration.contains(acc.Id)){
                    Integration_Process__c integProcess=new Integration_Process__c();
                    integProcess.Status__c= 'Pending';
                    integProcess.Process_Type__c= CHConstants.ACCOUNT_WIN_VALIDATE_CREATE;
                    integProcess.Account__c= acc.Id;
                    if(acc.High_Priority__c){
                        integrationRecordsToGenerateWinIds.Add(integProcess);
                    }
                    else{
                        integrationRecordsToGenerateWinIdsForLowPriority.Add(integProcess);
                    }
                }
            }
            if(!integrationRecordsToGenerateWinIds.isEmpty()){
                insert integrationRecordsToGenerateWinIds;
                if(!Test.isRunningTest()){
                    System.enqueueJob(new CreateWinIdsAccountsQueuableJob(new Map<Id, Integration_Process__c>(integrationRecordsToGenerateWinIds).keySet()));
                }
            }
            if(!integrationRecordsToGenerateWinIdsForLowPriority.isEmpty()){
                insert integrationRecordsToGenerateWinIdsForLowPriority;
            }
        }
    }
  
      /************************************************************************************** 
 
        * @Description  This method creates account platform events from other sources
       * @Param    AccountCRUDHandler.createAccountPlatformEvents(); 
       **************************************************************************************/  
    public static List<Database.SaveResult> createAccountPlatformEvents(List<Account> newAccList) {
        List<Database.SaveResult> results= null;
		Set<Id> accIdsForHighPriority= new Set<Id>();
		Set<Id> accIdsForLowPriority= new Set<Id>();
		for(Account acc : newAccList){
		  if(acc.Win_Validate_New__c== true && ( !String.isBlank(acc.WIN_ID__c) || (!String.isBlank(acc.dunbrdst__c ) && (acc.RecordTypeId == CORPORATE_ACCOUNT_TYPE || acc.RecordTypeId== CORP_RETIRED_ACCOUNT_RECORD_TYPE) ))){
			   if(acc.High_Priority__c == true){
					accIdsForHighPriority.Add(acc.Id);
			   }
               else{
					accIdsForLowPriority.Add(acc.Id);
			   }
		  }
		}
        if(!accIdsForHighPriority.isEmpty()){
            results= Accounts.firePlatformEvents(accIdsForHighPriority, true);
        }
        if(!accIdsForLowPriority.isEmpty()){
            results= Accounts.firePlatformEvents(accIdsForLowPriority, false);
        }
        return results;
    }

	public static void toggleWinValidateFlagBasedOnAccountTypes(List<Account> newAccList){
        for(Account acc: newAccList){
        if(Trigger.isExecuting){
            acc.Origin__c= String.isBlank(acc.Origin__c)?'Salesforce':acc.Origin__c;
        }
        if(acc.WIN_Validated__c == true || acc.Win_Validate_New__c == true){
                acc.WIN_Validated__c= false;
                acc.Win_Validate_New__c= true;
            }
        }
    } 

    public static void setTerritoryOverrideFields(Map<Id,Account> newAccountMap, Map<Id, Account> oldAccountMap){
        Set<Id> userIds = new Set<Id>();
        Set<string> territoryNames = new Set<string>();
        Map<Id,User> userRecordMapping= new Map<Id,User>();
        Map<string,Id> territoryNameIdMapping = new Map<string,Id>();
        
        for(Account newAccountRec : newAccountMap.Values()){
            if(oldAccountMap == null || newAccountRec.ownerID != oldAccountMap.get(newAccountRec.id).ownerID){
                userIds.add(newAccountRec.ownerID);
            }
        }
         
        if(!userIds.isEmpty()){ 
            for(User u: [select id,territory__c from User where id IN : userIds]){
            	territoryNames.Add(u.territory__c);
                userRecordMapping.put(u.Id, u);
            }        
            List<Territory__c> territories = [select id,name from territory__c where name in:territoryNames];
            
            for(Territory__c territory: territories) 
            { 
                territoryNameIdMapping.put(territory.name,territory.Id); 
            }
            
            for(Account newAccountRec : newAccountMap.Values()){
                if(oldAccountMap == null || newAccountRec.ownerID != oldAccountMap.get(newAccountRec.id).ownerID){
                    if(userRecordMapping.get(newAccountRec.ownerId).Territory__c != null && territoryNameIdMapping.containsKey(userRecordMapping.get(newAccountRec.ownerId).Territory__c))
                    {
                        Id territoryId= Id.valueOf(territoryNameIdMapping.get(userRecordMapping.get(newAccountRec.ownerId).Territory__c));
                        newAccountRec.Territory_ID_AO__c = territoryId;
                        newAccountRec.Territory_ID_SK__c = territoryId;
                    }
                    else
                    {   
                        newAccountRec.Territory_ID_AO__c = null;
                        newAccountRec.Territory_ID_SK__c = null;
                    }             
                }
            }
        }        
    }
	
	public static void checkAndValidateAccountWithoutWinId(Map<Id, Account> accountMap, Map<Id, Account> oldAccountMap){
        Set<Id> accountRecIds = new Set<Id>();
                
        for(Account accountRec : accountMap.values()){
            if((oldAccountMap == null ||(!(accountRec.Active_ER_Contract__c != oldAccountMap.get(accountRec.Id).Active_ER_Contract__c ))) && String.isBlank(accountRec.WIN_ID__c) && (accountRec.Win_Validate_New__c || accountRec.WIN_Validated__c) && (accountRec.Status__c != 'Inactive'&& !accountRec.Inactivate_Reactivate_In_Progress__c)){
                accountRecIds.add(accountRec.Id);
            }
        }
        
        if(!accountRecIds.isEmpty()){ 
            Map<Id, String> accountIdErrorMessageMapping = Accounts.validateAccount(accountRecIds, false);
            
            for(Id accountId : accountIdErrorMessageMapping.keySet()){
                if(accountIdErrorMessageMapping.containsKey(accountId)){
                    accountMap.get(accountId).addError(accountIdErrorMessageMapping.get(accountId));
                }else {
                     Account account = accountMap.get(accountId);
                     account.WIN_Compliance_Errors__c = '';
                }
            }
        }
    }
      
	public static void checkAndValidateAccountWithWinId(Map<Id, Account> accountMap, Map<Id, Account> oldAccountMap){
        Set<Id> accountRecIds = new Set<Id>();
		set<Id> usersToSkip = new Set<id>();
        Boolean isBulkProcess=Accounts.checkIfBulkProcess();
		List<UsersToSkipWinComplianceValidations__mdt> skipUsersList = UsersToSkipWinComplianceValidations__mdt.getAll().values();
        For(UsersToSkipWinComplianceValidations__mdt skipConfig : skipUsersList){
            usersToSkip.add(skipConfig.User_Id__c);
        }
        
        for(Account accountRec : accountMap.values()){
            if((oldAccountMap == null ||(!(accountRec.Active_ER_Contract__c != oldAccountMap.get(accountRec.Id).Active_ER_Contract__c ))) && String.isNotBlank(accountRec.WIN_ID__c) && !usersToSkip.contains(UserInfo.getUserId())&& (accountRec.Win_Validate_New__c || accountRec.WIN_Validated__c || 
			(accountRec.Tax_Exemption_Type__c != oldAccountMap.get(accountRec.Id).Tax_Exemption_Type__c && accountRec.Tax_Exemption_Type__c == 'Tax Exempt' ) )){
				if(accountRec.Inactivate_Reactivate_In_Progress__c == false && oldAccountMap.get(accountRec.Id).Inactivate_Reactivate_In_Progress__c == false)
					if(!AccountCRUDHandler.accountsToggleMeToBypassMap.containsKey(accountRec.Id) ||
                        (AccountCRUDHandler.accountsToggleMeToBypassMap.get(accountRec.Id) == accountRec.Toggle_Me_to_Bypass_Validation__c)){
							accountRecIds.add(accountRec.Id); 
				}
			}
        }
       
        if(!accountRecIds.isEmpty()){
            
            Map<Id, String> accountIdErrorMessageMapping = Accounts.validateAccount(accountRecIds, !isBulkProcess);
            
            for(Id accountId : accountIdErrorMessageMapping.keySet()){
                if(accountIdErrorMessageMapping.containsKey(accountId)){
                    String errorMsg = accountIdErrorMessageMapping.get(accountId);
                    
                    if(errorMsg.contains('$$')){
                        errorMsg = errorMsg.split('\\$\\$')[0];
                    }
                    
                    accountMap.get(accountId).addError(errorMsg);
                }
            }
        }  
    }
    // This methos is to update corp address of new account same as Lead Address when Lead is converted as account. 
  
    public static void insertShippingAddressWhenLeadConverted(List<Account> acclist){ 
        for(Account acc : acclist){ 
            if(acc.LeadID__c != null && acc.BillingState != null && acc.BillingStreet != null && acc.BillingCountry != null && acc.BillingPostalCode != null && acc.BillingCity != null )
            {
                acc.ShippingState = acc.BillingState;
                acc.ShippingStreet = acc.BillingStreet;
                acc.ShippingCountry = acc.BillingCountry;
                acc.ShippingPostalCode = acc.BillingPostalCode;
                acc.ShippingCity = acc.BillingCity;
            }   
        }
    }

    private static void assignAccountOwner(Map<Id, List<Account>> nonSalesPersonFilteredAccountMap){
        List<Territory__c> userTerritoryList = new List<Territory__c>();
        List<Territory_Master__c> territoryMasterList = TerritoryMasterDAO.getTerritoryMasterBasedonZipMaster(nonSalesPersonFilteredAccountMap.keySet());
        User userRec = UserDAO.getUserTerritory(new Set<Id>{UserInfo.getUserId()})[0];
        List<User_Profile__mdt> userProfileCustomMetadata = User_Profile__mdt.getall().values();
        Map<String,User_Profile__mdt> userProfileMap = new Map<string,User_Profile__mdt>();
        for(User_Profile__mdt userProfile : userProfileCustomMetadata)
        {
            userProfileMap.put(userProfile.Profile_Name__c,userProfile);
        }
        if(userRec.Territory__c != NULL){
            userTerritoryList = TerritoryDAO.getUserTerritoryDetails(new Set<String>{userRec.Territory__c});
        }
        for(Territory_Master__c territoryRec : territoryMasterList){
            if(nonSalesPersonFilteredAccountMap.containsKey(territoryRec.ZIP_Master__c)){
                for(Account accountRec : nonSalesPersonFilteredAccountMap.get(territoryRec.ZIP_Master__c)){
                    if(Trigger.isInsert){
                        if(FeatureManagement.checkPermission('Retain_Account_OwnerShip')){
                            accountRec.OwnerId = UserInfo.getUserId();
                        }
                        else if((territoryRec.Sales_Business_Unit__c == accountRec.Primary_Business__c ) && territoryRec.Territory_ID__r.Territory_Type__c == 'Field'){
                            if(territoryRec.Territory_ID__c != NULL && territoryRec.Territory_ID__r.Territory_OwnerID__c != NULL){                                                              
                                accountRec.OwnerId = territoryRec.Territory_ID__r.Territory_OwnerID__c;
                                accountRec.Territory_Override__c = True;
                            }else if(!userTerritoryList.isEmpty()){
                                accountRec.OwnerId = UserInfo.getUserId();
                                accountRec.Territory_Override__c = True;
                            }
                        }
                    }
                    else if((territoryRec.Sales_Business_Unit__c == accountRec.Primary_Business__c ) && territoryRec.Territory_ID__r.Territory_Type__c == 'Field'){
                        if(territoryRec.Territory_ID__c != NULL && territoryRec.Territory_ID__r.Territory_OwnerID__c != NULL
                            && userRec.Sales_Person_Type__c != 'Senior Account Manager' && userRec.Sales_Person_Type__c != 'Account Manager'){                                                              
                            if(userProfileMap.containsKey(userRec.Profile.Name))
                            {
                                accountRec.OwnerId = UserInfo.getUserId();
                            }
                            else {
                                accountRec.OwnerId = territoryRec.Territory_ID__r.Territory_OwnerID__c;
                            }
                            accountRec.Territory_Override__c = True;
                        }else if(!userTerritoryList.isEmpty()){
                            accountRec.OwnerId = UserInfo.getUserId();
                            accountRec.Territory_Override__c = True;
                        }
                        if(Trigger.isInsert) 
                            AccountCRUDHandler.IS_RUN_AFTER_UPDATE = true;
                        else
                            AccountCRUDHandler.IS_RUN_AFTER_UPDATE = false;
                    }
                }
            }
        }
    }
    public static void updateWinValidateNewToTrue (List<Account> accList){
        Boolean isBulkProcess = Accounts.checkIfBulkProcess();
        for(Account acc : accList){
            if(acc.RecordTypeId == CORPORATE_ACCOUNT_TYPE){
                acc.Win_Validate_New__c = True;
                if(!isBulkProcess){
                    acc.High_Priority__c = True;
                }
            }
        }
    }
}