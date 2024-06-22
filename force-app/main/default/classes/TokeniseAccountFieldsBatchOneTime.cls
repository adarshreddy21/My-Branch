public with sharing class TokeniseAccountFieldsBatchOneTime implements Database.Batchable<sObject>, Database.AllowsCallOuts, Schedulable{
    private Set<Id> integrationProcessIds = new Set<Id>();
    private Boolean isHighPriority = false;
    private static Accounts accountsObject= new Accounts();
    public TokeniseAccountFieldsBatchOneTime(){
    }
    public Database.QueryLocator start(Database.BatchableContext BC){
       //string query =  'select id,OldValue,NewValue,accountId from AccountHistory where field=\'ShippingStreet\' and createddate=yesterday order by createddate asc';
       //string query = 'SELECT id,shippingstreet from account where status__c in (\'active\',\'inactive\')  and shippingstreet<>null';
       string query='SELECT Id,shippingpostalcode,shippingstreet,ShippingCity,shippingcountry,name FROM Account where  status__c in (\'active\',\'inactive\')  and ShippingStreet <>null and ShippingPostalCode<> null and ShippingCountry<>null';
       return Database.getQueryLocator(query);  
    }
    
    public void execute(Database.BatchableContext BC, List<sObject> scope){
      List<AbbreviationMapping__mdt> abbrList = AbbreviationMapping__mdt.getAll().values();
      List<Account> accountRecords=  ((List<Account>)scope);
      List<AccountTokenisation__c> recordsToInsert= new List<AccountTokenisation__c>();
      List<AccountTokenisation__c> recordsToUpdate= new List<AccountTokenisation__c>();
      Map<Id,Account> accountMap =new Map<Id,Account>(accountRecords);
      Map<Id,AccountTokenisation__c> accountAccountTokenisationMap =new Map<Id,AccountTokenisation__c>();
      List<AccountTokenisation__c> accountTokenisationRecords=[SELECT Id, TokenisedStreet__c,Account__c, TokenisedShippingPostalCode__c from AccountTokenisation__c where Account__c in :accountMap.keySet()];
      for(AccountTokenisation__c accTokenisationRecord: accountTokenisationRecords){
            accountAccountTokenisationMap.put(accTokenisationRecord.Account__c, accTokenisationRecord);
      }
      
                for(Account acc:accountRecords){
                    AccountTokenisation__c accountTokenisationRecord;
                    string tokenisedValue= Accounts.tokeniseAccountFields(acc.ShippingStreet, abbrList); 
					string tokenisedPostalCodeValue= acc.ShippingPostalCode.normalizeSpace().trim();
					if(acc.ShippingCountry.equalsIgnoreCase('US') && tokenisedPostalCodeValue.contains('-')){
					    tokenisedPostalCodeValue= tokenisedPostalCodeValue.split('-')[0];
                    }					
                            if(!accountAccountTokenisationMap.containsKey(acc.Id)){
                                    accountTokenisationRecord= new AccountTokenisation__c();
                                    accountTokenisationRecord.Account__c=acc.Id;
                                    accountTokenisationRecord.TokenisedStreet__c=tokenisedValue;
									accountTokenisationRecord.TokenisedShippingPostalCode__c= tokenisedPostalCodeValue;
                                    recordsToInsert.Add(accountTokenisationRecord);
                                }
                                else{
                                    accountTokenisationRecord= accountAccountTokenisationMap.get(acc.Id);
                                    accountTokenisationRecord.TokenisedStreet__c=tokenisedValue;
									accountTokenisationRecord.TokenisedShippingPostalCode__c= tokenisedPostalCodeValue;
                                    recordsToUpdate.Add(accountTokenisationRecord);              
							}
                    
                }
                if(!recordsToInsert.isempty()){
                    insert recordsToInsert;
                }
                if(!recordsToUpdate.isempty()){
                    update recordsToUpdate;
                }
    }
    
    public void finish(Database.BatchableContext BC){
    }

    public void execute(SchedulableContext sc) {
        Database.executeBatch(new TokeniseAccountFieldsBatchOneTime(), 100);
    }	
}