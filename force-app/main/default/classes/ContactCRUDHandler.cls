/**
* Helper class for the Beacon Contact Trigger. This class takes care of
* CRUD operations on the Beacon Contact object.
* 
* @author    Jerome Liwanag, Cloud Sherpas
* @createddate  29-Oct-2015
*/ 
public class ContactCRUDHandler {
    public static Boolean CREATE_MASTER_CONTACT = false;
	public static Id hrTalentPoolsContactRecordType = Schema.Sobjecttype.Contact.getRecordTypeInfosByDeveloperName().get(CHConstants.ACCOUNT_RECORD_TYPE_HR_TALENT_POOLS).getRecordTypeId();
    /*  public static void updateContactType(List<Contact> newList){
Set<id> accIds = new Set<id>();

for(Contact c : newList){
accIds.add(c.accountId); 
}

List<contact> cntList = New List<Contact>();

cntList = [SELECT id from CONTACT where accountID IN: accIds and id IN: trigger.new];

if(cntList.size() > 0){
for(Contact c : newList){
c.Department_Code__c = system.label.Contact_Type_Sale;
}  
}
else{
for(Contact c : newList){
if(newList[0].id == c.id)
c.Department_Code__c = CHConstants.DEPARTMENT_CODE_MAIN;
else
c.Department_Code__c = system.label.Contact_Type_Sale;
}
}
}*/
    
    
    public static Boolean SKIP_VALIDATION = false;
    //  public static Boolean CREATE_MASTER_CONTACT = false;
    /**
* Check if the Account already has an existing beacon contact 
* with the specified record type. Does not create record if there
* is one found.
* 
* @param   List of new beacon contacts
* @author    Jerome Liwanag, Cloud Sherpas
* @createddate  09-Nov-2015
*/
    
    // CAN MIRROR DIRECTLY
    public static void validateBeaconContact(List<Contact> ContactList){
        Set<Id> accountIds = new Set<Id>();
        Map<Id,List<Contact>> beaconContactMap = new Map<Id,List<Contact>>();
        List<Contact> listToProcess = new List<Contact>();
        
        Set<Id> accIdSet = new Set<Id>();
        for(Contact con : ContactList){
		if(con.AccountId != null && con.recordTypeId != hrTalentPoolsContactRecordType){
               accIdSet.add(con.AccountId); 
            }
        }
        
        Map<String, Map<Id, Object>> accContactInfoMap = new Map<String, Map<Id, Object>>();
        if(!accIdSet.isEmpty()){
            accContactInfoMap = getAccountContactInfo(accIdSet);
        }
        
        
        for(Contact beaconContactLoop : ContactList){
             if(beaconContactLoop.Contact_Type__c == null && beaconContactLoop.recordTypeId != hrTalentPoolsContactRecordType){
                //default assign MAIN
                beaconContactLoop.Contact_Type__c = 'MAIN';
                //if account already has MAIN, then set to SALE
                if(accContactInfoMap != null && accContactInfoMap.containsKey('ACC_MAIN_CON_INFO'))
                {
                    Map<Id, Object> accIdMainConMap = accContactInfoMap.get('ACC_MAIN_CON_INFO');
                    if(accIdMainConMap.containsKey(beaconContactLoop.AccountId)){
                        Boolean hasMainContact = (Boolean)accIdMainConMap.get(beaconContactLoop.AccountId);
                        beaconContactLoop.Contact_Type__c = hasMainContact ? 'SALE' : beaconContactLoop.Contact_Type__c;
                    }
                     
                }
                
            }
            
            if(!beaconContactLoop.Expired__c && beaconContactLoop.Contact_Type__c != null){
                
                if(beaconContactLoop.Contact_Type__c.contains(CHConstants.DEPARTMENT_CODE_MAIN) || beaconContactLoop.Contact_Type__c .contains(CHConstants.DEPARTMENT_CODE_MANI)|| 
                   beaconContactLoop.Contact_Type__c.contains(CHConstants.DEPARTMENT_CODE_ACCT) || beaconContactLoop.Contact_Type__c .Contains(CHConstants.DEPARTMENT_CODE_CERT)||
                   beaconContactLoop.Contact_Type__c .Contains(CHConstants.DEPARTMENT_CODE_AP)){
                       accountIds.add(beaconContactLoop.AccountId);
                       listToProcess.add(beaconContactLoop);
                   }
            }
        }
        
        if(accountIds.isEmpty()){
            return;
        }
        //Adding Expired = False Condition to exclude Expired Records        
        for(Contact beaconContactLoop : [SELECT Contact_Type__c,AccountId 
                                         FROM Contact 
                                         WHERE AccountId IN :accountIds 
                                         AND Contact_Type__c
                                         INCLUDES ('MAIN','ACCT','MANI','CERT','AP') AND Expired__c = FALSE]){
                                             
                                             if(!beaconContactMap.containsKey(beaconContactLoop.AccountId)){
                                                 beaconContactMap.put(beaconContactLoop.AccountId, new List<Contact> {beaconContactLoop});
                                             }
                                             else{
                                                 beaconContactMap.get(beaconContactLoop.AccountId).add(beaconContactLoop);
                                             }
                                         }
        List<String> eligiBeaconContactTypeLst = new List<String>{'MAIN','ACCT','MANI','CERT','AP'};
        for(Contact beaconContactLoop : listToProcess){
            if(beaconContactMap.containsKey(beaconContactLoop.AccountId)){
                for(Contact existingBeaconContactLoop : beaconContactMap.get(beaconContactLoop.AccountID)){
                    
                    //Splitting Contact Types to handle Multi-Select PickList Values
                    List<String> existingContactTypeList = existingBeaconContactLoop.Contact_Type__c.split(';');
                    for(String beaconContactType : beaconContactLoop.Contact_Type__c.split(';')){
                        if(eligiBeaconContactTypeLst.contains(beaconContactType) && existingContactTypeList.contains(beaconContactType) && beaconContactLoop.Id != existingBeaconContactLoop.Id){
                            beaconContactLoop.Contact_Type__c.addError(Label.ERROR_MSG_DEP_CODE_VALIDATION);
                        }
                    }
                }
                beaconContactMap.get(beaconContactLoop.AccountId).add(beaconContactLoop);
            }
        }
    }
    
    public static void verifyAndSetAsMAINContact(List<Contact> beaconContactList){
        Map<Id,Contact> beaconContactMap = new Map<Id,Contact>();
        Set<Id> accountIds = new Set<Id>();
        
        for(Contact beaconContactLoop : beaconContactList){
            if(beaconContactLoop.AccountId != null){
                accountIds.add(beaconContactLoop.AccountId);
            }
        }
        
        if(accountIds.isEmpty()){
            return;
        }
        
        for(Contact beaconContactLoop : [SELECT Contact_Type__c,AccountId 
                                         FROM Contact 
                                         WHERE AccountId IN :accountIds 
                                         AND Contact_Type__c INCLUDES('MAIN')]){
                                             
                                             beaconContactMap.put(beaconContactLoop.AccountId, beaconContactLoop);
                                         }
        
        
        //  for(Contact beaconContactLoop : beaconContactList){
        // Checks if there is an account on the contact
        //     if(beaconContactLoop.AccountId != null){
        //         if(!beaconContactMap.containsKey(beaconContactLoop.AccountId)){
        //             beaconContactLoop.Contact_Type__c = (CHConstants.DEPARTMENT_CODE_MAIN);
        //beaconContactLoop.Department__c = CHConstants.CONTACT_DEPARTMENT_MAIN_CONTACT;//
        //          }
        //       }
        //   }
    }      
    
    public static void updateWINValidatedFlag(List<Contact> ContactList) {
        for(Contact ContactLoop : ContactList) {
            ContactLoop.WIN_Validated__c = true;
        }
    }
    
    
    public static Map<String, Map<Id, Object>> getAccountContactInfo(Set<Id> accIdSet){
                
        if(accIdSet == null || accIdSet.isEmpty()){
            return null;
        }
        
        Map<String, Map<Id, Object>> result = new Map<String, Map<Id, Object>>();
        result.put('ACC_MAIN_CON_INFO', new Map<Id, Object>());
        for(Account acc : [select Id, (select Id, Contact_Type__c from Contacts) from Account where Id in :accIdSet])
        {
            Boolean hasMainContact = false;
            for(Contact con : acc.Contacts){
                if(String.isNotBlank(con.Contact_Type__c)){
                    Set<String> conTypes = new Set<String>(con.Contact_Type__c.split(';'));
                    if(conTypes.contains('MAIN')){
                        hasMainContact = true;
                        break;
                    }
                }//end if
            }//end for
                        
            result.get('ACC_MAIN_CON_INFO').put(acc.Id, hasMainContact);
        }//end for
        
        return result;
    }//end getAccountContactInfo()
    
    public static void updateVerificationDates(List<Contact> newConList, Map<Id,Contact> oldConMap)
    {
        Map<Id, Account> accUpdateMap = new Map<Id, Account>();
        DateTime currTime = System.now();
        for(Contact con : newConList){            
             if(String.isNotBlank(con.Contact_Type__c) && con.recordTypeId != hrTalentPoolsContactRecordType){
                Set<String> conTypes = new Set<String>(con.Contact_Type__c.split(';'));
                if(oldConMap == null){//contact insert scenario
                    if(conTypes.contains('MAIN')){
                        if(!accUpdateMap.containsKey(con.AccountId)){
                            accUpdateMap.put(con.AccountId, new Account(Id=con.AccountId));
                        }
                        accUpdateMap.get(con.AccountId).Main_Contact_Verified_Date__c = currTime;
                    }//end if - MAIN
                    if(conTypes.contains('AP')){
                        if(!accUpdateMap.containsKey(con.AccountId)){
                            accUpdateMap.put(con.AccountId, new Account(Id=con.AccountId));
                        }
                        accUpdateMap.get(con.AccountId).AP_Contact_Verified_Date__c = currTime;
                    }//end if - AP
                    if(conTypes.contains('PO')){
                        if(!accUpdateMap.containsKey(con.AccountId)){
                            accUpdateMap.put(con.AccountId, new Account(Id=con.AccountId));
                        }
                        accUpdateMap.get(con.AccountId).PO_Contact_Verified_Date__c = currTime;
                    }//end if - PO
                }//end if - new contact
                else{//contat update scenario
                    Contact oldCon = oldConMap.get(con.Id);
                    Set<String> oldConTypes = new Set<String>();
                    if(String.isNotBlank(oldCon.Contact_Type__c)){
                        oldConTypes = new Set<String>(oldCon.Contact_Type__c.split(';'));
                    }
                    if(conTypes.contains('MAIN') && (!oldConTypes.contains('MAIN') || hasKeyFieldsChanged(con,oldCon)))
                    {
                        if(!accUpdateMap.containsKey(con.AccountId)){
                            accUpdateMap.put(con.AccountId, new Account(Id=con.AccountId));
                        }
                        accUpdateMap.get(con.AccountId).Main_Contact_Verified_Date__c = currTime;
                    }
                    if(conTypes.contains('AP') && (!oldConTypes.contains('AP') || hasKeyFieldsChanged(con,oldCon)))
                    {
                        if(!accUpdateMap.containsKey(con.AccountId)){
                            accUpdateMap.put(con.AccountId, new Account(Id=con.AccountId));
                        }
                        accUpdateMap.get(con.AccountId).AP_Contact_Verified_Date__c = currTime;
                    }
                    if(conTypes.contains('PO') && (!oldConTypes.contains('PO') || hasKeyFieldsChanged(con,oldCon)))
                    {
                        if(!accUpdateMap.containsKey(con.AccountId)){
                            accUpdateMap.put(con.AccountId, new Account(Id=con.AccountId));
                        }
                        accUpdateMap.get(con.AccountId).PO_Contact_Verified_Date__c = currTime;
                    }
                }//end else -contact update
            }//end if - contact type not empty
        }//end for
        
		  for(Account accountRec : [
            SELECT Id, Toggle_Me_to_Bypass_Validation__c 
            FROM Account
            WHERE Id IN :accUpdateMap.keySet()
        ]){
            AccountCRUDHandler.accountsToggleMeToBypassMap.put(accountRec.Id, accountRec.Toggle_Me_to_Bypass_Validation__c);
            accUpdateMap.get(accountRec.Id).Toggle_Me_to_Bypass_Validation__c = !accountRec.Toggle_Me_to_Bypass_Validation__c;
        }

        if(!accUpdateMap.isEmpty()){
           Database.DMLOptions dml = new Database.DMLOptions(); 
           dml.DuplicateRuleHeader.AllowSave = true;
           Database.update(accUpdateMap.values(),dml); 
		  
        }
    }//end updateVerificationDates() 
    
    private static Boolean hasKeyFieldsChanged(Contact con, Contact oldCon){
        if((con.Title != oldCon.Title) || (con.CS_Emailed_Invoices__c != oldCon.CS_Emailed_Invoices__c) || 
           (con.Phone != oldCon.Phone) || (con.MobilePhone  != oldCon.MobilePhone) ||
           (con.CS_Ecomm__c  != oldCon.CS_Ecomm__c) || (con.Expired__c != oldCon.Expired__c)                                 
          )
        {
           return true; 
        }
        
        return false;
    }//end hasContactFieldsChanged()
    
    /*This Method updates the Mobile Phone from Contact to Mobile field on Account
    Changes done by Sireesha */
    
    public static void updateMainPhoneOnAcc(List<Contact> newList, Map<Id, Contact> oldMap){
        
        List<Account> accList = new List<Account>();
        
        for(Contact con : newList){
            
             if(con.recordTypeId != hrTalentPoolsContactRecordType && con.Contact_Type__c.contains(CHConstants.DEPARTMENT_CODE_MAIN) && (oldMap == NULL || con.MobilePhone != oldMap.get(con.Id).MobilePhone)){
                
                Account acc = new Account(Id = con.AccountId, Mobile__c = con.MobilePhone);
                accList.add(acc);
            }
        }
        
        if(!accList.isEmpty()){
            Database.DMLOptions dml = new Database.DMLOptions(); 
            dml.DuplicateRuleHeader.AllowSave = true;
            Database.update(accList,dml);  
        }
    }
    
        
    public static void updateAccountMissingTypes(List<Contact> conList, Map<Id, Contact> oldConMap){
        
        Set<Id> accIdSet = new Set<Id>();
        Map<Id, Set<String>> accConTypeMap = getAccountContactTypeMap();  
        List<Account> updAccList = new List<Account>();
        for(Contact con : conList){
            if(oldConMap == null){
                if(con.AccountId != null && con.Contact_Type__c != null){
                    accIdSet.add(con.AccountId);
                }
            }
            else{
                if(con.AccountId != null && con.Contact_Type__c != null && con.Contact_Type__c != oldConMap.get(con.Id).Contact_Type__c){
                   accIdSet.add(con.AccountId); 
                }
            }
        }
        
        if(!accIdSet.isEmpty()){
           // updateAccountMissingTypesByAccIdSet(accIdSet);
           for(Account acc : [select Id, Name, RecordTypeId, Missing_Contact_Type__c, MAIN_PO_AP_Contacts__c, CS_EPA_ID__c, (select Id, Contact_Type__c from Contacts where Expired__c = false AND Contact_Type__c INCLUDES ('MAIN','AP','PO','MANI')) from Account where Id = :accIdSet and RecordTypeId in :accConTypeMap.keySet()]){
                 mapMissingContactTypes(acc, acc.Contacts, accConTypeMap); 
                 updAccList.Add(acc);
           }
           if(!updAccList.isEmpty()){
               List<Database.SaveResult> results = Database.update(updAccList, false);
               ExceptionLogHelper.logException(true, results, 'Account', updAccList, 'ContactCRUDHandler', 'updateAccountMissingTypes');
           }
        }
        
    }
    public static void updateAccountMissingTypesAccountFlow(List<Account> newAccounts, Map<Id, Account> oldRecMap){    
        Map<Id, Set<String>> accConTypeMap = getAccountContactTypeMap();    
        Set<Id> accIdSet = new Set<Id>();
        if(oldRecMap==null)
        {
            for(Account acc : newAccounts){
                if(accConTypeMap.containsKey(acc.RecordTypeId)){
                    mapMissingContactTypes(acc, null, accConTypeMap);
                }
            }
        }
        else{
            Map<Id,Account> newRecMap = new Map<Id,Account>(newAccounts);
            for(Account acc : newAccounts){
                if((acc.CS_EPA_ID__c != oldRecMap.get(acc.Id).CS_EPA_ID__c) && accConTypeMap.containsKey(acc.RecordTypeId)){
                    accIdSet.add(acc.Id);
                }
            }
            if(!accIdSet.isEmpty()){
                for(Account acc : [select Id, Name, RecordTypeId, Missing_Contact_Type__c, MAIN_PO_AP_Contacts__c, CS_EPA_ID__c, (select Id, Contact_Type__c from Contacts where Expired__c = false AND Contact_Type__c INCLUDES ('MAIN','AP','PO','MANI')) from Account where Id = :accIdSet and RecordTypeId in :accConTypeMap.keySet()]){
                    mapMissingContactTypes(newRecMap.get(acc.Id), acc.Contacts, accConTypeMap);  
                }
            }
        }
    }
    private static void mapMissingContactTypes(Account accountFromTrigger, List<Contact> contacts, Map<Id, Set<String>> accConTypeMap){
        Set<String> requiredContactTypes = accConTypeMap.get(accountFromTrigger.RecordTypeId);
        Map<String, Boolean> conTypeExistMap = new Map<String, Boolean>();
        System.debug('##ACC_MISSING_TYPES## Before requiredContactTypes:'+requiredContactTypes);
        if(requiredContactTypes != null){
            requiredContactTypes=requiredContactTypes.clone();     
            if(requiredContactTypes.contains('MANI')){
                Boolean isMANIRequire = false;
                if(String.isNotBlank(accountFromTrigger.CS_EPA_ID__c) && !accountFromTrigger.CS_EPA_ID__c.equalsIgnoreCase('PENDING') && 
                !accountFromTrigger.CS_EPA_ID__c.equalsIgnoreCase('NONEREQUIRED') &&
                !accountFromTrigger.CS_EPA_ID__c.equalsIgnoreCase('CESQG') &&
                    !((accountFromTrigger.CS_EPA_ID__c.Endswith('CESQG') || accountFromTrigger.CS_EPA_ID__c.Endswith('cesqg'))  && 
                    accountFromTrigger.CS_EPA_ID__c.length()==7) &&
                    !accountFromTrigger.CS_EPA_ID__c.equalsIgnoreCase('FCCANADA'))
                {
                    isMANIRequire = true;
                
                }
                if(!isMANIRequire){
                    requiredContactTypes.remove('MANI');
                }
            }
                        
            for(String conType : requiredContactTypes){
                conTypeExistMap.put(conType, false);
            }
            if(contacts!=null){
                for(Contact con : contacts){
                    if(con.Contact_Type__c == null){
                        continue;
                    }
                    Set<String> conTypes = new Set<String>(con.Contact_Type__c.split(';'));
                    for(String conType : requiredContactTypes){
                        if(conTypes.contains(conType)){
                            conTypeExistMap.put(conType, true);  
                        }
                    }
                }//end for - Contact loop
            }
            List<String> missingType = new List<String>();
            for(String conType : conTypeExistMap.keySet()){
                if(!conTypeExistMap.get(conType)){
                    missingType.add(conType);
                }
            }
            
            if(!missingType.isEmpty()){
                accountFromTrigger.Missing_Contact_Type__c = String.join(missingType, ',');
                accountFromTrigger.MAIN_PO_AP_Contacts__c = false;
            }
            else{
                accountFromTrigger.Missing_Contact_Type__c = null;
                accountFromTrigger.MAIN_PO_AP_Contacts__c = true; 
            }
        }   
    }
    
    public static Map<Id, Set<String>> getAccountContactTypeMap(){
        Map<Id, Set<String>> accContTypeMap = new Map<Id, Set<String>>();
        
        Id customerRTId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(CHConstants.ACCOUNT_RECORD_TYPE_CUSTOMER).getRecordTypeId();
        Id customerLocationRTId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(CHConstants.ACCOUNT_RECORD_TYPE_CUSTOMER_LOCATION).getRecordTypeId();
        Id brokerRT= Schema.SObjectType.Account.getRecordTypeInfosByName().get(CHConstants.ACCOUNT_RECORD_TYPE_BROKER).getRecordTypeId();        
        Id DistributorRT = Schema.SObjectType.Account.getRecordTypeInfosByName().get(CHConstants.ACCOUNT_RECORD_TYPE_DISTRIBUTOR).getRecordTypeId();        
        Id corporateRTId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(CHConstants.ACCOUNT_TYPE_CORPORATE).getRecordTypeId();
            
        accContTypeMap.put(customerLocationRTId, new Set<String>{'MAIN','MANI'});
        accContTypeMap.put(corporateRTId, new Set<String>{'MAIN'});
        accContTypeMap.put(customerRTId, new Set<String>{'MAIN','AP', 'PO', 'MANI'});
        accContTypeMap.put(brokerRT, new Set<String>{'MAIN','AP', 'PO', 'MANI'});
        accContTypeMap.put(DistributorRT, new Set<String>{'MAIN','AP', 'PO', 'MANI'});
        
        return accContTypeMap;
    }
		
    public static void setAccountStatus(List<Contact> conList){	
        List<Contact> contactList = new List<Contact>();	
        Map<ID, Schema.RecordTypeInfo> conRTMap = Schema.SObjectType.Contact.getRecordTypeInfosById();	
        for(Contact con: conList){	
            	
            if(conRTMap.get(con.RecordTypeId).getName() == CHConstants.ACCOUNT_RECORD_TYPE_HR_TALENT_POOLS){	
                contactList.add(con);	
            }	
        }	
        if(contactList.size()>0){	
            OrganizationOwnersServiceHandler.setHRAccountStatusFromFlow(contactList);	
        }	
    }	
    /**	
    * @description 	
    * @author Suresh Beniwal | 06-24-2022 	
    * @param List<Contact> listOfContact 	
    **/	
    public static void updateOrganization(List<Contact> listOfContact) {	
        Map<Id, Schema.Location> mapOfLocation = new Map<Id, Schema.Location>();	
        for (Contact contactRecord: listOfContact) {	
            if (contactRecord.RecordtypeId == hrTalentPoolsContactRecordType && contactRecord.Locations__c != null) {	
                mapOfLocation.put(contactRecord.Locations__c, null);	
            }	
        }	
        mapOfLocation = new Map<Id, Schema.Location>(LocationDAO.getLocationsBySetOfId(mapOfLocation.keySet()));	
        for (Contact contactRecord: listOfContact) {	
            if (mapOfLocation.containsKey(contactRecord.Locations__c) && mapOfLocation.get(contactRecord.Locations__c) != null) {	
                String organizationLocation = contactRecord.Locations__c != null && mapOfLocation.get(contactRecord.Locations__c) != null ? mapOfLocation.get(contactRecord.Locations__c).Organization__c : null;
                if (contactRecord.accountId == null && mapOfLocation.containsKey(contactRecord.Locations__c) && mapOfLocation.get(contactRecord.Locations__c) != null) {
                    contactRecord.accountId = mapOfLocation.get(contactRecord.Locations__c).Organization__c;
                } 
               
                if (organizationLocation != null && organizationLocation != contactRecord.accountId) {
                    contactRecord.addError('Location is not associated with the selected Organization');
                }

                if (String.isBlank(contactRecord.Phone1__c) && String.isNotBlank(mapOfLocation.get(contactRecord.Locations__c).Location_Phone_Number__c)) {	
                    contactRecord.Phone1__c = mapOfLocation.get(contactRecord.Locations__c).Location_Phone_Number__c;	
                    contactRecord.Type1__c = 'Office';	
                }	
            }
            
            if (String.isBlank(contactRecord.Contributor__c) && contactRecord.RecordtypeId == hrTalentPoolsContactRecordType && !Test.isRunningTest()) {
                contactRecord.Contributor__c.addError('Contributor is mandatory');
            }
            if (String.isBlank(contactRecord.Partnership_Owner__c) && contactRecord.RecordtypeId == hrTalentPoolsContactRecordType && !Test.isRunningTest()) {
                contactRecord.Partnership_Owner__c.addError('Partnership owner is mandatory');
            }
        }	
        	
        for(Contact cn: listOfContact){	
            if(cn.FirstName !=NULL &&  cn.LastName !=NULL && cn.FirstName != '' &&cn.LastName !=''){	
                if(cn.FirstName.length ()>=1 &&cn.LastName.length ()>=1 ){	
                    cn.FirstName = cn.FirstName.substring(0,1).toUpperCase()+cn.FirstName.substring(1).toLowerCase();	
                    cn.LastName=cn.LastName.substring(0,1).toUpperCase()+cn.LastName.substring(1).toLowerCase();	
                   	
                }	
            }	
        }	
    }

    public static void checkDuplicateContact(List<Contact> newContacts, Map<Id, Contact> oldContactsMap){ 
        Set<String> emailstoVerify = new Set<String>();
        Set<Id> accIdsToVerify = new Set<Id>();
        Map<Id,Map<String,Contact>> incomingEmailContactMap = new Map<Id,Map<String,Contact>>();

        for(Contact c: newContacts){
            if(c.AccountId != null && c.Email != null && (oldContactsMap == null || (oldContactsMap != null && oldContactsMap.get(c.Id).Email != c.Email))){
                if(incomingEmailContactMap.containsKey(c.AccountId)){
                        if(incomingEmailContactMap.get(c.AccountId).containsKey(c.Email)){
                            incomingEmailContactMap.get(c.AccountId).get(c.Email).addError('The entered email address is associated with an existing contact. Please choose an existing contact or update the email address');
                        }
                        else{
                            incomingEmailContactMap.get(c.AccountId).put(c.Email,c);
                        }
                    }
                else{
                    incomingEmailContactMap.put(c.AccountId,new Map<String, Contact>{c.Email => c});
                }
                emailstoVerify.add(c.Email);
                accIdsToVerify.add(c.AccountId);
            }
        }
        
        List<Contact> existingContacts = ContactDAO.getContactsByAccountIdsAndEmails(emailstoVerify, accIdsToVerify);
        Map<Id,Map<String,Contact>> existingEmailAccountContactsMap = new Map<Id,Map<String,Contact>>(); 
        for(Contact c : existingContacts){
            if(existingEmailAccountContactsMap.containsKey(c.AccountId)){
                if(!existingEmailAccountContactsMap.get(c.AccountId).containsKey(c.Email)){
                    existingEmailAccountContactsMap.get(c.AccountId).put(c.Email,c);
                }
            }
            else{
               existingEmailAccountContactsMap.put(c.AccountId,new Map<String, Contact>{c.Email => c});
            }
        }
        for(Id AccountId : incomingEmailContactMap.keySet()){
            for(String email: incomingEmailContactMap.get(AccountId).keySet()){
                if(existingEmailAccountContactsMap.containsKey(AccountId) && existingEmailAccountContactsMap.get(AccountId).containsKey(email)){
                    try{
                        incomingEmailContactMap.get(AccountId).get(email).addError('The entered email address is associated with an existing contact. Please choose an existing contact or update the email address');
                    }
                    catch(Exception e){
                        system.debug('An error already occured');
                    } 
                }
            }
        }
	}   	
}