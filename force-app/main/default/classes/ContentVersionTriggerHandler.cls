/**
 * @description       : 
 * @author            : Suresh Beniwal
 * @group             : 
 * @last modified on  : 11-28-2022
 * @last modified by  : Suresh Beniwal 
 * Modifications Log
 * Ver   Date         Author           Modification
 * 1.0   11-28-2022   Suresh Beniwal   Initial Version
**/
public class ContentVersionTriggerHandler {
    
    public static void sendTaxEmail(List<ContentVersion> newList){
        
        List<ContentVersion> listToProcess = new List<ContentVersion>();
        Set<Id> conDocIds = new Set<Id>();
        
        for(ContentVersion cv : newList){
            if(cv.FileType == 'SNOTE' && cv.IsLatest && cv.VersionData != NULL){
                
                conDocIds.add(cv.ContentDocumentId);
                listToProcess.add(cv);
            }
        }
        
        if(!conDocIds.isEmpty()){
            
            Set<Id> linkedIds = new Set<Id>();
            Map<Id, ContentDocumentLink> conDocLink = new Map<Id, ContentDocumentLink>();
            for(ContentDocumentLink cdl : [Select Id, ContentDocumentId, LinkedEntityId from ContentDocumentLink where ContentDocumentId IN : conDocIds]){
                if(String.ValueOf(cdl.LinkedEntityId).startsWith('a3p')){
                    
                    conDocLink.put(cdl.ContentDocumentId, cdl);
                    linkedIds.add(cdl.LinkedEntityId);
                }
            }
            
            if(!linkedIds.isEmpty() && linkedIds.size() > 0){
                Map<Id, Tax_Document__c> taxMap = new Map<Id, Tax_Document__c>([Select Id, OwnerId, name, Owner.Email from Tax_Document__c where ID IN : linkedIds]);
                
                List<String> queueEmailAddress = new List<String>();
                for(User us : [Select Id, Email from User where IsActive = TRUE AND ID IN (Select UserOrGroupId FROM GroupMember WHERE Group.DeveloperName = 'My_Group')]){
                    queueEmailAddress.add(us.Email);
                }
                
                String OrgEmailId;
                list<Messaging.SingleEmailMessage> lstSendEmails = new list<Messaging.SingleEmailMessage>();
                
                System.debug('-----inside email');
                for(OrgWideEmailAddress owa : [select DisplayName, id, Address from OrgWideEmailAddress]) {
                    if(owa.DisplayName.contains('CRMSupport')) {
                        OrgEmailId = owa.id;
                        break;
                    }
                }
                
                for(ContentVersion cv : listToProcess){
                    if(conDocLink.containsKey(cv.ContentDocumentId)){
                        if(taxMap.containsKey(conDocLink.get(cv.ContentDocumentId).LinkedEntityId)){
                            
                            Tax_Document__c taxObj = taxMap.get(conDocLink.get(cv.ContentDocumentId).LinkedEntityId);
                            
                            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                            List<String> emailAddress = new List<String>{taxObj.Owner.Email, 'Uppala.Sireesha@cleanharbors.com'};
                                if(!queueEmailAddress.isEmpty()){
                                    emailAddress.addAll(queueEmailAddress);
                                }    
                            mail.setToAddresses(emailAddress);
                            //mail.setCcAddresses(new List<String>{'Uppala.Sireesha@cleanharbors.com'});
                            mail.setSubject('New Note has been added to the Tax Document');
                            mail.setBccSender(false);
                            mail.setUseSignature(false);
                            mail.setOrgWideEmailAddressId(OrgEmailId);
                            mail.setSaveAsActivity(false);
                            
                            String emailBody = 'Hi,<br/>Please find below note that has been added to the Tax Document '+taxObj.Name+',<br/><br/>';
                            emailBody += '<b>Title:</b> '+cv.Title+'<br/><br/>';
                            emailBody += '<b>Content:</b> <br/>';
                            emailBody += cv.VersionData.toString();
                            emailBody += '<br/><br/>Regards,<br/>Salesforce Team';
                            mail.setHtmlBody(emailBody);
                            lstSendEmails.add(mail);
                        }
                    }
                }
                
                if(!lstSendEmails.isEmpty() && !Test.isRunningTest()){
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
    } 
}