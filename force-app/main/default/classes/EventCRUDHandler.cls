public class EventCRUDHandler {
 Public Static void InsertNewCallNote (List<Event> newEvntList){
        
        // Id taskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Activity').getRecordTypeId();
        Id callNoteRecordTypeId = Schema.SObjectType.Beacon_Call_Notes__c.getRecordTypeInfosByName().get('Call Note').getRecordTypeId();
        
        set<Id> accIdSet = new Set<Id>();
        Id currUserId = userinfo.getUserId(); 
        List<Beacon_Call_Notes__c> callNoteList = new List<Beacon_Call_Notes__c>(); 
        
        for(Event e : newEvntList){ 
            if(e.whatId != null){ 
                accIdSet.add(e.WhatId);
            }
        }
        
        map<Id,Account> accMap = new map<Id,Account>([Select id, Name, OwnerId from account where id in: accIdSet]); 
        for(Event e : newEvntList)
        { 
            if(e.WhatId != null && e.Event_Type__c=='Face to Face' || e.Event_Type__c=='Virtual (Webex)' || e.Event_Type__c=='Call')
            {
                if(!accMap.isEmpty() && accMap.containskey(e.WhatId))
                {
                    Account acc = accMap.get(e.WhatId);
                    if(acc.OwnerId == currUserId)
                    {
                        Beacon_Call_Notes__c callNote = new Beacon_Call_Notes__c();
                        callNote.recordTypeId=callNoteRecordTypeId;
                        callNote.Assigned_To__c = e.OwnerId;
                        callNote.Call_Note_Account__c = e.WhatId;
                        callNote.Description__c = e.Subject;
                        callNote.Work_Note__c=e.Description;
                        //callNote.Contact_Method__c=e.Event_Type__c;
                        if(e.Event_Type__c== 'Face to Face' || e.Event_Type__c=='Virtual (Webex)')
                        {
                            callNote.Type__c = 'Visit';
                            callNote.Contact_Method__c='Face to Face';
                        }else
                            if(e.Event_Type__c=='Call')
                        {
                            callNote.Type__c='Phone';
                            callNote.Contact_Method__c='Phone';
                        }
                        callnote.Color__c = 'Green - Status Quo';
                        callnote.WIN_Validated__c = true;
                        callnote.Next_Action__c = 'None';
                        callNoteList.add(callnote);
                    }
                }
                
            }
        }
        if(callNoteList != null && callNoteList.size()>0)
        {
            insert callNoteList;
        }
        
    }
    
    //For Inside Sales Account Ranking Consideration: Latest sales event related to IS account, contact, opportunity
    Public Static void UpdateLatestSalesEventDate (List<Event> newEvntList,Map<Id, Event> oldEvntMap){
        List<Account> accUpdateList = new List<Account>();
        set<Id> tempaccIdSet = new Set<Id>();
        set<Id> accIdSet = new Set<Id>();
        set<Id> ownerIdSet = new Set<Id>();
        Map<id, User> ownerMap= new Map<id, User>();
        Map <id, account> AccountActivityMap = new Map <id, account>();
        for (Event Evt:newEvntList){
            ownerIdSet.add(Evt.OwnerId);
            tempaccIdSet.add(Evt.AccountId); 
            
            if(oldEvntMap != null && Evt.AccountId != oldEvntMap.get(Evt.id).AccountId){
            	tempaccIdSet.add(oldEvntMap.get(Evt.id).AccountId); 
        	}
        }

        if (ownerIdSet!= null && ownerIdSet.size()>0){
            ownerMap = new Map<id, User>([ Select id, Profile.Name From User where Id IN: ownerIdSet]);
        }
        
       	AccountActivityMap = new Map <id, account>([Select id, Latest_Sales_Event_Date_for_IS_Rank__c from Account where
                                                    id in :tempaccIdSet 
                                                    And (owner.UserRole.DeveloperName = 'SK_INS_BPS_AM' OR owner.UserRole.DeveloperName = 'SK_INS_SKE_AM')
                                                    And (RecordType.DeveloperName = 'Customer' OR RecordType.DeveloperName = 'Customer_Location')
                                                    AND Status__c = 'Active' AND win_id__c != null]);
        
        string salesProfile = [SELECT Profile_Names__c FROM Sales_Profile__mdt where DeveloperName = 'Sales_Profile_for_IS_Ranking'].Profile_Names__c;
        
        for (Event evt:newEvntList){
            Boolean SalesOwnedActivity = salesProfile.containsIgnoreCase(ownerMap.get(evt.OwnerId).Profile.Name);
            Boolean AccountRelatedActivity = (evt.WhatId != null && (evt.Whatid.getsObjectType() == Account.sObjectType || evt.Whatid.getsObjectType() == Opportunity.sObjectType))||(evt.WhoId != null && evt.Whoid.getsObjectType() == Contact.sObjectType); 
            Boolean RelatedAccIdChanged = oldEvntMap != null && evt.AccountId != oldEvntMap.get(evt.id).AccountId;
            Boolean ActivityDateChanged = oldEvntMap != null && evt.ActivityDate != oldEvntMap.get(evt.id).ActivityDate;
            Boolean SalesEventType = evt.Event_Type__c != 'Internal Discussion' && evt.Event_Type__c != 'Security Response';
            Boolean ISAMNewAccount = AccountActivityMap.size() > 0 && AccountActivityMap.containskey(evt.AccountId);
            Boolean ISAMOldAccount = RelatedAccIdChanged && AccountActivityMap.size() > 0 && AccountActivityMap.containskey(oldEvntMap.get(evt.id).AccountId);
            system.debug('SalesOwnedActivity'+SalesOwnedActivity);
            
            if(ISAMNewAccount && AccountRelatedActivity && SalesOwnedActivity && SalesEventType && (oldEvntMap == null || ActivityDateChanged || RelatedAccIdChanged)){
                   accIdSet.add(evt.AccountId);
               }
            
            if(ISAMOldAccount && AccountRelatedActivity && SalesOwnedActivity && SalesEventType && oldEvntMap.get(evt.id).AccountId != null){
                   accIdSet.add(oldEvntMap.get(evt.id).AccountId);
               }   
        }
        
        System.debug('accIdSet.size'+accIdSet.size());
        
        if (accIdSet != null && accIdSet.size() >0){
            Map<Id, Date> MaxActivityDateMap = new Map<Id, Date>();
            set<string> salesProfileSet = new set<string>();
            salesProfileSet.addAll(salesProfile.split('@'));

            List<AggregateResult> AggregateResultList = [Select accountId, Max(Event_Start_Date__c)maxActivityDate From Event 
                                                         where accountId in:accIdSet
                                                         AND (Owner.Profile.Name in:salesProfileSet) 
                                                         And (Who.Type='Contact' Or What.Type IN ('Account', 'Opportunity'))
                                                         AND (Event_Type__c != 'Internal Discussion' AND Event_Type__c != 'Security Response')
                                                         And (account.owner.UserRole.DeveloperName = 'SK_INS_BPS_AM' OR account.owner.UserRole.DeveloperName = 'SK_INS_SKE_AM')
                                                         And (account.RecordType.DeveloperName = 'Customer' OR account.RecordType.DeveloperName = 'Customer_Location')
                                                         AND account.Status__c = 'Active' AND account.win_id__c != null
                                                         Group By accountId];
            
            if(AggregateResultList != null && AggregateResultList.size() > 0){ 
                for(AggregateResult aggr:AggregateResultList){
                        MaxActivityDateMap.put((id)aggr.get('accountId'),(date)aggr.get('maxActivityDate'));
                }
            }
            
            for (Id accId:accIdSet){
                if (MaxActivityDateMap != null && MaxActivityDateMap.size() > 0 && MaxActivityDateMap.containskey(accId) 
                    && MaxActivityDateMap.get(accId) != AccountActivityMap.get(accId).Latest_Sales_Event_Date_for_IS_Rank__c){
                    Account a = new Account();
               		a.id = accId;
                    a.Latest_Sales_Event_Date_for_IS_Rank__c = MaxActivityDateMap.get(accId);
                    accUpdateList.add(a);
                }else if (MaxActivityDateMap.size() == 0
                          || (MaxActivityDateMap != null && MaxActivityDateMap.size() > 0 && !MaxActivityDateMap.containskey(accId))
                          && AccountActivityMap.get(accId).Latest_Sales_Event_Date_for_IS_Rank__c != null){
                              Account a = new Account();
                              a.id = accId;
                              a.Latest_Sales_Event_Date_for_IS_Rank__c = null;
                              accUpdateList.add(a);
                          }      
            }
            
            if(accUpdateList != null && accUpdateList.size()>0)
            {
                update accUpdateList;
            }
            
        }        
    }
    public static void PopulateContactName(List<Event> Events) {
        Set<Id> contactIds = new Set<Id>();
        for (Event E : Events) {
            if (E.WhoId != null && E.WhoId.getSObjectType() == Contact.SObjectType) {
                contactIds.add(E.WhoId);
            }
        }
        Map<Id, Contact> contactsMap = new Map<Id, Contact>([SELECT Id, Name FROM Contact WHERE Id IN :contactIds]);
        for (Event E : Events) {
            if (contactsMap.containsKey(E.WhoId)) {
                Contact associatedContact = contactsMap.get(E.WhoId);
                E.Contact_Name__c = associatedContact.Name;
            }
        }
        
    }
    public static void validateEvents(List<Event> events) {
        Set<Id> accountIds = new Set<Id>();
        for(Event eventObj : events) {
            if(eventObj.WhatId != null && String.valueOf(eventObj.WhatId.getSObjectType()) == 'Account') {
                accountIds.add(eventObj.WhatId);
            }
        }
        Map<Id, Account> accountsMap = new Map<Id, Account>([SELECT Id, Status__c FROM Account WHERE Id IN :accountIds]);
        for(Event eventObj : events) {
            if(eventObj.WhatId != null && String.valueOf(eventObj.WhatId.getSObjectType()) == 'Account') {
                Account relatedAccount = accountsMap.get(eventObj.WhatId);
                if(relatedAccount.Status__c == 'Archive') {
                    eventObj.addError('Activities cannot be created on archived accounts. Please use a different account or create a new one for this work.');
                }
            }
        }
    }
    

}