public class DuplicateAccountTackingHandler {
    public static final string errorMessage = 'there ia already a duplicate record';
    public static void checkDuplicateAccount(List<Duplicate_Account_Tracking__c> dATList)
    {
        Set<id> accountIds = new Set<id>();
        Set<String> accountConcatIds = new Set<String>();
        for(Duplicate_Account_Tracking__c dAT :  dATList)
        {
            accountIds.add(dAT.Account__c);
            accountIds.add(dAT.Matched_Account__c);
        }
        
        if(!accountIds.IsEmpty())
        {
            List<Duplicate_Account_Tracking__c> duplicateAccList = [Select id,Account__c,Matched_Account__c from Duplicate_Account_Tracking__c where Account__c in :accountIds or Matched_Account__c in :accountIds];
            if(!duplicateAccList.IsEmpty())
            {
                for(Duplicate_Account_Tracking__c dAT :  duplicateAccList)
                {
                    accountConcatIds.add(dAT.Account__c+''+dAT.Matched_Account__c);
                    accountConcatIds.add(dAT.Matched_Account__c+''+dAT.Account__c);
                }
            }
        }
         for(Duplicate_Account_Tracking__c dAT :  dATList)
        {
            if(accountConcatIds.contains(dAT.Matched_Account__c+''+dAT.Account__c))
            {
                dAT.addError(errorMessage);
            }
        }
    }
    
}