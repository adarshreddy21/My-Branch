/**
 * @description       : 
 * @author            : Irfan Khan
 * @group             : 
 * @last modified on  : 01-09-2023
 * @last modified by  : Irfan Khan
**/
global class TerritoryOwnerUpdateBatch implements Database.Batchable<sobject>, Database.Stateful{
    
    global Set<Id> territoryIds;
    global Map<Id, Territory__c> terrMap;
    
    global List<Account> failedAccounts;

    global TerritoryOwnerUpdateBatch(Set<Id> terrIds){
        
        territoryIds = new Set<Id>();
        territoryIds = terrIds;
        failedAccounts = new List<Account>();
        terrMap = new Map<Id, Territory__c>([Select Id, OwnerId, Territory_OwnerID__c, Primary_Business__c from Territory__c where ID IN : territoryIds]);
    }
    
    // Start Batch
    global database.querylocator start(Database.BatchableContext bc){
        
        Set<String> statusSet = new Set<String>();
        statusSet.add('Active');
        Id CORPORATE_ACCOUNT_TYPE = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get(CHConstants.ACCOUNT_RECORD_TYPE_CORPORATE).getRecordTypeId();
        return database.getQuerylocator('Select Id, Name, RecordTypeId, Territory_ID_SK__c, WIN_ID__c, Primary_Business__c from Account where Status__c IN : statusSet AND Territory_ID_SK__c IN : territoryIds AND RecordTypeId != :CORPORATE_ACCOUNT_TYPE');
    }
    
    global void execute(Database.BatchableContext bc, list<Account> accList){
        
        AccountCRUDHandler.IS_SKIP_TRIGGER = TRUE;
        List<Account> updateList = new List<Account>();
        
        for(Account acc : accList){
            if(terrMap.containsKey(acc.Territory_ID_SK__c) && terrMap.get(acc.Territory_ID_SK__c).Primary_Business__c == acc.Primary_Business__c){
                acc.OwnerId = terrMap.get(acc.Territory_ID_SK__c).Territory_OwnerID__c;
                updateList.add(acc);
            }
        }
        
        if(!updateList.isEmpty() && updateList.size() > 0){
            
            Database.SaveResult[] SaveResultList = Database.update(updateList,false);
            
            for(integer i =0; i<updateList.size();i++){
               If(!SaveResultList[i].isSuccess()){
                    Database.Error error = SaveResultList.get(i).getErrors().get(0);
                    String failedDML = error.getMessage();
                    System.debug('-----Error'+failedDML);
					System.debug('-----Acc'+updateList.get(i).Id);					
                    failedAccounts.add(updateList.get(i));
                    
                }
            } 
        }
        AccountCRUDHandler.IS_SKIP_TRIGGER = FALSE;
    }
    
    global void finish(Database.BatchableContext bc){

        if(!failedAccounts.isEmpty() && failedAccounts.size() > 0){

			sendEmail();
            
        }        
    }
    
    public void sendEmail(){
        
        String OrgEmailId;
        
        String orgUrl = URL.getSalesforceBaseUrl().toExternalForm();
        System.debug('-----inside email');
        for(OrgWideEmailAddress owa : [select DisplayName, id, Address from OrgWideEmailAddress]) {
            if(owa.DisplayName.contains('CRMSupport')) {
                OrgEmailId = owa.id;
                break;
            }
        }
        
        String wordBreak = '"white-space: nowrap;"';
        String wordBreakWithStyle = '"white-space: nowrap;background-color:blue; color:white;"';
        
        list<Messaging.SingleEmailMessage> lstSendEmails = new list<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new List<String>{userInfo.getUserEmail(), 'bezawada.balaji@cleanharbors.com'});
        mail.setCcAddresses(new List<String>{'bezawada.balaji@cleanharbors.com'});
        mail.setSubject('Email Notification for Territory Owner Update - Failed Accounts');
        mail.setBccSender(false);
        mail.setUseSignature(false);
        mail.setOrgWideEmailAddressId(OrgEmailId);
        mail.setSaveAsActivity(false);
        
        String emailBody = 'Hi,<br/>Please find below the failed accout records for Territory Owner Update	,<br/><br/>';
        emailBody += '<table border="1" style="border-collapse: collapse;border: 1px solid #000;width:100%;" cellspacing="3" cellpadding="3">';
        emailBody += '<tr><th style='+wordBreakWithStyle+'>Account Name</th><th style='+wordBreakWithStyle+'>WIN ID</th>';
        System.debug('-----inside email size'+failedAccounts.size());
        for(Account acc : failedAccounts){
            
            emailBody += '<tr><td style='+wordBreak+'><a href ="'+orgURL+'/'+acc.Id+'">'+acc.Name+'</a></td><td style='+wordBreak+'>'+acc.WIN_ID__c+'</td>';                
        }
        
        emailBody += '</table><br/><br/>Regards,<br/>Salesforce Team';
        mail.setHtmlBody(emailBody);
        lstSendEmails.add(mail);
	    if(!Test.isRunningTest() && orgUrl.contains('-sandbox')) {
        List<Messaging.SendEmailResult> results = Messaging.sendEmail(lstSendEmails);
        set<Id> setIds = new set<Id>();
        for(Messaging.SendEmailResult rr:results){
            system.debug('----rr'+rr.IsSuccess());
            if(!rr.IsSuccess()){
                setIds.add(rr.getErrors()[0].getTargetObjectId());
				}
			}
        system.debug('****setIds******'+setIds);
		}
	}
}