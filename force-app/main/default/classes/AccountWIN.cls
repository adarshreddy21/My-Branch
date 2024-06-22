public with sharing class AccountWIN {
@AuraEnabled
    public static String returnAccount(Id Id)
    {
        system.debug(Id);
        string accountId;
        List<Account> acc= [select Id,Name,WIN_ID__c from Account where Id=: Id];
        for(Account a: acc)
        {
            accountId = a.WIN_ID__c;
        }
        return accountId;
    }
    
  }