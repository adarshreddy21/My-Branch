public with sharing class CreateWinIdsAccountsQueuableJob implements Queueable, Database.AllowsCallouts {
    private static Accounts accountsObject= new Accounts();
    private Set<Id> integrationProcessIds;
    public CreateWinIdsAccountsQueuableJob(Set<Id> integrationProcessIds) {
        this.integrationProcessIds= integrationProcessIds;
    }

    public void execute(QueueableContext context) {
       List<Integration_Process__c>  integrationProcessRecords=[select Account__c,Account__r.Name, Account__r.Type,  Account__r.RecordTypeId, Account__r.Win_Id__c, Account__r.WIN_ID_Sequence_Number__c,Account__r.Primary_Business__c, Account__r.Parent.WIN_ID__c, Account__r.CS_EPA_ID__c, Attempts__c from Integration_Process__c where Status__c='Pending' and Process_Type__c=:CHConstants.ACCOUNT_WIN_VALIDATE_CREATE and Id in:integrationProcessIds order by Createddate ASC];
       accountsObject.processIntegrationRecordsToCreateWinId(integrationProcessRecords);
    }
}