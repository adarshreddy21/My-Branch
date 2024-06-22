public class UpdateRelatedAccountRecordsBatch implements Database.Batchable<sObject>, Database.Stateful {
  private string processType;
  public UpdateRelatedAccountRecordsBatch(string processType) {
    this.processType = processType;
  }
  public Database.QueryLocator start(Database.BatchableContext BC) {
    Bypass_Account_Validation__c accountValidation = Bypass_Account_Validation__c.getOrgDefaults();
    accountValidation.Bypass_Manifest_Address_Requirement__c = true;
	AccountCRUDHandler.isValidationDisable = false;
    update accountValidation;
    AccountCRUDHandler.SKIP_VALIDATION = TRUE;
    string processType = this.processType; 
    String query = 'select Account__c, Status__c,Process_Type__c,account__r.parent.OwnerId from Integration_Process__c where Status__c=\'Pending\' and Process_Type__c=:processType order by Createddate ASC';
    return Database.getQueryLocator(query);
  }
  public void execute(Database.BatchableContext BC, List<Integration_Process__c> scope) {
    Map<Id, Integration_Process__C> accountIntegrationProcessMap = new Map<Id, Integration_Process__C>();
    if (processType == CHConstants.Ownerupdate) {
      List<Account> accountsToUpdate = new List<Account>();

      for (Integration_Process__c integProcess : scope) {
        Account accRec = new Account(Id = integProcess.Account__c, OwnerId = integProcess.Account__r.Parent.OwnerId, Win_Validate_New__c = true);

        if (!accountIntegrationProcessMap.containsKey(integProcess.Account__c)) {
          accountIntegrationProcessMap.put(integProcess.Account__c, integProcess);
        }

        accountsToUpdate.Add(accRec);
      }

      if (!accountsToUpdate.isEmpty()) {
        updateIntegrationProcessRecords(accountIntegrationProcessMap, accountsToUpdate);
      }
    } else if (processType == CHConstants.BrokerRecordTypeUpdate) {
      Id brokerLocationRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Broker_Location').getRecordTypeId();
      List<Account> childAccountsToBeUpdated = new List<Account>();
      for (Integration_Process__c integProcess : scope) {
        Account accRec = new Account();
        accRec.Id = integProcess.Account__c;
        accRec.RecordTypeId = brokerLocationRecordTypeId;
        accRec.Type = 'Brok/Gen';
        accRec.Win_Validate_New__c = true;
        childAccountsToBeUpdated.add(accRec);
        if (!accountIntegrationProcessMap.containsKey(integProcess.Account__c)) {
          accountIntegrationProcessMap.put(integProcess.Account__c, integProcess);
        }
      }

      if (!childAccountsToBeUpdated.isEmpty()) {
        updateIntegrationProcessRecords(accountIntegrationProcessMap, childAccountsToBeUpdated);
      }
    }
  }
  private void updateIntegrationProcessRecords(Map<Id, Integration_Process__C> accountIntegrationProcessMap, List<Account> accountsToUpdate) {
    List<Database.SaveResult> saveResultLst = Database.update(accountsToUpdate, false);
    for (Database.SaveResult saveResultObj : saveResultLst) {
      if (!saveResultObj.isSuccess()) {
        String errorMsg = '';
        for (Database.Error err : saveResultObj.getErrors()) {
          errorMsg += err.getMessage() + '\n';
        }

        if (errorMsg.length() > 0) {
          errorMsg = errorMsg.substring(0, errorMsg.length() - 2);
        }
        accountIntegrationProcessMap.get(saveResultObj.Id).Status__c = 'Error';
        accountIntegrationProcessMap.get(saveResultObj.Id).Error_Message__c = errorMsg;
      } else {
        accountIntegrationProcessMap.get(saveResultObj.Id).Status__c = 'Processed';
      }
    }
    update accountIntegrationProcessMap.values();
  }
  public void finish(Database.BatchableContext BC) {
    Bypass_Account_Validation__c accountValidation = Bypass_Account_Validation__c.getOrgDefaults();
    accountValidation.Bypass_Manifest_Address_Requirement__c = false;
	AccountCRUDHandler.isValidationDisable = true;
    update accountValidation;
  }
}