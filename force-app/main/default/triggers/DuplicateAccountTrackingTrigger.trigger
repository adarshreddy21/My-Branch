trigger DuplicateAccountTrackingTrigger on Duplicate_Account_Tracking__c (before insert,before update) {
    
    if(Trigger.IsInsert)
    {
        DuplicateAccountTackingHandler.checkDuplicateAccount(Trigger.New);
    }

}