public with sharing class TokeniseAccountFieldsBatch implements Database.Batchable<sObject>, Database.Stateful, Schedulable{
    private Integer hours;
    private DateTime nHoursAgo;
    @TestVisible
    private String shippingStreetMock;
    public TokeniseAccountFieldsBatch(Integer hours){
        DateTime rightNow =  DateTime.now();
        this.nHoursAgo = rightNow.addHours(-hours);
    }
    public TokeniseAccountFieldsBatch(){
    }
    public Database.QueryLocator start(Database.BatchableContext BC){
      
       string query =  'select id,OldValue,NewValue,accountId from AccountHistory where field in (\'ShippingStreet\',\'ShippingPostalCode\') and createddate>=:nHoursAgo order by createddate desc';
       //string query = 'SELECT id,shippingstreet from account where status__c in (\'active\',\'inactive\')  and shippingstreet<>null';
       return Database.getQueryLocator(query);  
    }
    
    public void execute(Database.BatchableContext BC, List<sObject> scope){
       processRecords((List<AccountHistory>)scope);
    }
    
    public void finish(Database.BatchableContext BC){
    }

    public void execute(SchedulableContext sc) {
        Database.executeBatch(new TokeniseAccountFieldsBatch(1), 50);
    }	
    
    @TestVisible
    private void processRecords(List<AccountHistory> accountHistoryRecords){
        List<AbbreviationMapping__mdt> abbrList = AbbreviationMapping__mdt.getAll().values();
        List<AccountTokenisation__c> recordsToInsert= new List<AccountTokenisation__c>();
        List<AccountTokenisation__c> recordsToUpdate= new List<AccountTokenisation__c>();
        Map<Id,AccountTokenisation__c> accountAccountTokenisationMap =new Map<Id,AccountTokenisation__c>();
       
       // List<AccountHistory> accountHistoryRecords= (List<AccountHistory>)scope;
        Set<Id> accIdsToCheck= new Set<Id>();
        String shippingStreet;
        for(AccountHistory accHistoryRecord: accountHistoryRecords){
          accIdsToCheck.Add(accHistoryRecord.AccountId);
        }
        List<AccountTokenisation__c> accountTokenisationRecords=[SELECT Id, TokenisedStreet__c, Account__c from AccountTokenisation__c where Account__c in :accIdsToCheck];
        for(AccountTokenisation__c accTokenisationRecord: accountTokenisationRecords){
              accountAccountTokenisationMap.put(accTokenisationRecord.Account__c, accTokenisationRecord);
        }
        List<Account> accountRecords = [SELECT Id,ShippingPostalcode,ShippingStreet,ShippingCity,Shippingcountry,name FROM Account where id in :accIdsToCheck];
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
}