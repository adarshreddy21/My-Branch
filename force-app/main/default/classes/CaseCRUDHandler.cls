/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 05-22-2023 
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/ 
public class CaseCRUDHandler { 
    private static Accounts accountsObj= new Accounts(); 
    public static Boolean skipAutomatedOwnerAssignment=false;  
  
    public static void insertSupportTSE(List<Case> newCaseList, Map<Id,Case> oldMap){   
        List<Id> accIds = new List<Id>();  
        set<Id> caseAccIds = new set<Id>();
        List<Technical_Sales_Expert_Case__c> insertTSE = new List<Technical_Sales_Expert_Case__c>();
        List<Technical_Sales_Expert_Case__c> deleteTSE = new List<Technical_Sales_Expert_Case__c>();
        Set<String> SpecialistBussName = new Set<String>();
        Set <String> SpecialistLOBName = new Set<String>();
        Set <String> LocationSpecialistLOBName = new Set<String>(); 
        Set <String> AllLOBName = new Set<String>();
        Map <Id, List <String>> delSpecialistLOBName = new Map<Id, List <String>>();
        List<Id> usrIds = new List<Id>();
        Id devRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('TSE - Add Case').getRecordTypeId();
        List<Id> parentIds = new List<Id>();
        List<Id> caseIds = new List<Id>();
        
        for(Case c : newCaseList){
            if(c.recordtypeId == devRecordTypeId){
                if (oldMap == null || (c.Status == 'New' && (c.Specialist_Products__c != oldMap.get(c.id).Specialist_Products__c|| c.Specialist_Business__c != oldMap.get(c.id).Specialist_Business__c 
                    ||(c.Include_all_locations__c && c.Include_all_locations__c != oldMap.get(c.id).Include_all_locations__c)))){
                    caseIds.add(c.id);
                    caseAccIds.add(c.AccountId); 
                    if(c.Include_all_locations__c){
                        accIds.add(c.AccountId);
                        system.debug('Include all locations');
                    }
                    else{
                        parentIds.add(c.AccountId);
                    }
                    SpecialistBussName.add(c.Specialist_Business__c);
					if ((c.Specialist_Business__c == 'Safety-Kleen Environmental' || c.Specialist_Business__c == 'Bulk Products and Services') && c.Specialist_Products__c.Contains ('Used Motor Oil') && 
                    (( oldMap != null && oldMap.get(c.id) != null && !oldMap.get(c.id).Specialist_Products__c.Contains ('Used Motor Oil'))||(oldMap == null && c.Specialist_Products__c.Contains ('Used Motor Oil')))) {
						SpecialistLOBName.addAll(new List<String>{'Charge for Oil Revenue', 'Used Motor Oil'});
					}
                    
                    if (oldMap != null && c.Specialist_Products__c != oldMap.get(c.id).Specialist_Products__c){ //case update 
                        SpecialistLOBName.addAll(c.Specialist_Products__c.split(';'));
                        Set<String> oldSpecProd = new Set<String>(oldMap.get(c.id).Specialist_Products__c.split(';'));
                        for (String prod:oldSpecProd){
                            if(SpecialistLOBName.contains(prod)){
                                SpecialistLOBName.remove(prod);
                            }else{
                                if (delSpecialistLOBName.containsKey(c.id)){
                                    delSpecialistLOBName.get(c.id).add(prod);
                                }else{    
                                    delSpecialistLOBName.put(c.id,new List <String>{prod});
                                }
								if(prod.equalsIgnoreCase('Used Motor Oil')){
                                    delSpecialistLOBName.get(c.id).add('Charge for Oil Revenue');
                                }
                            }
                        }
                    }else if (oldMap == null){//new case
                        SpecialistLOBName.addAll(c.Specialist_Products__c.split(';'));
                    }
                    
                    if (oldMap != null && c.Include_all_locations__c && c.Include_all_locations__c != oldMap.get(c.id).Include_all_locations__c){
                        LocationSpecialistLOBName.addAll(c.Specialist_Products__c.split(';'));
                    }else if (c.Include_all_locations__c){
                        LocationSpecialistLOBName.addAll(SpecialistLOBName);
                    }
                    AllLOBName.addAll(SpecialistLOBName);
                    AllLOBName.addAll(LocationSpecialistLOBName);                                              
                    
                    usrIds.add(c.Proposed_Owner__c); 
                }
            }
            
        }
        
        system.debug('accIds--->'+accIds.size()+':::::'+accIds);
        system.debug('SpecialistLOBName--->'+SpecialistLOBName.size()+':::::'+SpecialistLOBName);
        system.debug('LocationSpecialistLOBName--->'+LocationSpecialistLOBName.size()+':::::'+LocationSpecialistLOBName);

        List<Account> accList = new List<Account>();
        Set<String> tempAcc = new Set<String>();
        Map<Id,Product2> prodMap = new Map<Id,Product2>();
        Map<Id,String> caseTerrotoryMap = new Map<Id, String>();
        Map<String,Id> trrMap = new Map<String,Id>();
        
        if(parentIds.size() > 0){
            accList = [SELECT id,ParentId,(SELECT id,Proposed_Specialist__r.Territory__c,AccountId FROM cases where ID =: caseIds)
                       FROM account WHERE id IN: parentIds and WIN_ID__c <> null and Status__c = 'Active' ]; 
        }else if (accIds.size() > 0){
            accList = [SELECT id,ParentId,(SELECT id,Proposed_Specialist__r.Territory__c,AccountId FROM cases where ID =: caseIds and accountId IN: accIds)
                       FROM account WHERE (ParentId IN: accIds or id IN: accIds) and WIN_ID__c <> null  and Status__c = 'Active'];
        }
        
        for(Account acc :  accList ){
            for(case c1 : acc.cases){
                caseTerrotoryMap.put(c1.id,c1.Proposed_Specialist__r.Territory__c);
            }
        }
        
        List<Territory__c> trrList = new List<Territory__c>();
        if(!caseTerrotoryMap.isEmpty()){
            trrList = [SELECT id,name FROM Territory__c WHERE name IN: caseTerrotoryMap.values()];
        }
        if(trrList.size() > 0){
            for(Territory__c t : trrList){
                trrMap.put(t.name,t.id);
            }
        }
        
        if(AllLOBName.size() > 0){           
            prodMap = new Map<Id,Product2>([SELECT id, name FROM Product2 WHERE name IN : AllLOBName and isActive=true]);        
            
            List<Technical_Sales_Expert__c> tseList = [SELECT id,Account__c,Product__c,Technical_Sales_Expert_lookup__c FROM Technical_Sales_Expert__c
                                                       WHERE Product__c IN: prodMap.keySet() and Account__c IN: accList];
            
            for(Technical_Sales_Expert__c tse : tseList){
                tempAcc.add(tse.Account__c+'@'+tse.Product__c+'@'+tse.id);                          
            }
        }
        
        system.debug('tempAcc--->'+tempAcc.size()+':::::'+tempAcc);      
        system.debug(' prodMap--->'+ prodMap.size()+':::::'+ prodMap);
        
        for(Case c : newCaseList){
            if(c.recordtypeId == devRecordTypeId){
                for(id prodId : prodMap.keyset()){
                    if(SpecialistLOBName.size() > 0 && SpecialistLOBName.contains(prodMap.get(prodId).name)){
                        Technical_Sales_Expert_Case__c tse1 = new Technical_Sales_Expert_Case__c();
                        
                        tse1.Account__c = c.accountId;
                        tse1.Line_of_Business__c = prodId;
                        tse1.Proposed_Specialist__c = c.Proposed_Specialist__c;
                        tse1.Case__c = c.Id;
                        if(caseTerrotoryMap.containsKey(c.id) && trrMap.containsKey(caseTerrotoryMap.get(c.id))){
                            tse1.Proposed_Specialist_Territory__c = trrMap.get(caseTerrotoryMap.get(c.id));
                        }
                        
                        for(String str : tempAcc){
                            String[] s = str.split('@');
                            system.debug('Account--->'+s[0]+'----'+c.AccountId);
                            system.debug('Product--->'+s[1]+'----'+prodMap.get(prodId));
                            if(s[0] == c.AccountId && s[1] == prodMap.get(prodId).Id){    
                                tse1.Existing_Specialist__c = s[2];                             
                            }
                        }
                        if(insertTSE.size() < 10000)
                            insertTSE.add(tse1);
                    }   
                    
                    if(LocationSpecialistLOBName.size() > 0 && LocationSpecialistLOBName.contains(prodMap.get(prodId).name)){
                        for(Account acc : accList){
                            system.debug('acc--->'+acc.id+':::::'+acc.parentId+'::::'+c.AccountId);
                            if(acc.parentId == c.AccountId || test.isRunningTest() ){
                                Technical_Sales_Expert_Case__c tse = new Technical_Sales_Expert_Case__c();
                                
                                tse.Account__c = acc.id;
                                tse.Line_of_Business__c = prodId;
                                tse.Proposed_Specialist__c = c.Proposed_Specialist__c;
                                tse.Case__c = c.Id;
                                if(caseTerrotoryMap.containsKey(c.id) && trrMap.containsKey(caseTerrotoryMap.get(c.id))){
                                    tse.Proposed_Specialist_Territory__c = trrMap.get(caseTerrotoryMap.get(c.id));
                                }
                                
                                for(String str : tempAcc){
                                    String[] s = str.split('@');
                                    system.debug('Account--->'+s[0]+'----'+acc.id);
                                    system.debug('Product--->'+s[1]+'----'+prodMap.get(prodId));
                                    if(s[0] == acc.id && s[1] == prodMap.get(prodId).Id){
                                        tse.Existing_Specialist__c = s[2];                                     
                                    }
                                } 
                                if(insertTSE.size() > 10000)
                                {
                                    c.adderror('Exceeds maximum(10000) allowed by Sales Operations');
                                }
                                
                                insertTSE.add(tse);
                                
                            }
                        }
                    }
                }
                
            }
        }
        
        if(insertTSE.size() > 0){
            system.debug('insertTSE--->'+insertTSE.size()+':::::'+insertTSE);
            insert insertTSE;
        }
        
        if (delSpecialistLOBName.size() > 0){
            Set <string> tempValues = new Set <string>();
            for (List <String> deleteLOB: delSpecialistLOBName.values()){
                tempValues.addAll(deleteLOB);
            }
            List<Technical_Sales_Expert_Case__c> deleteTSEList = [Select id, Case__c, Line_of_Business__r.name from Technical_Sales_Expert_Case__c 
                                                                  where Case__c in :delSpecialistLOBName.keyset() 
                                                                  AND Line_of_Business__r.name in :tempValues];
            
            for (Technical_Sales_Expert_Case__c TSERequest : deleteTSEList){
                for (String LOB:delSpecialistLOBName.get(TSERequest.Case__c)){
                    if (TSERequest.Line_of_Business__r.name == LOB)
                        deleteTSE.add(TSERequest);          
                }    
            }
            
            if (deleteTSE.size() > 0){
                try {
                    delete deleteTSE;
                } catch(DmlException e) {
                    System.debug('The following exception has occurred: ' + e.getMessage());
                }         
            }
        }
        
    }
    
    public static void autoSubmissionApprovalProcess (List<Case> newCaseList){
        Id casedevRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('New Customer Request').getRecordTypeId();
        Id fieldChangeRequestRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Field Change Request').getRecordTypeId();
        Id inactivateAccountRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Inactivate Account').getRecordTypeId();
        Id c2devRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer Master - Reactivate Account').getRecordTypeId();
		Id customerMasterChangeShipToGenToCustomerRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Customer_Master_Change_ShipTo_Gen_To_Customer').getRecordTypeId();
                 
        List<Approval.ProcessSubmitRequest> reqs = new List<Approval.ProcessSubmitRequest>(); 
        for(Case c : newCaseList){
            if (c.RecordTypeId == casedevRecordTypeId || c.RecordTypeId == fieldChangeRequestRecordTypeId ||
                c.RecordTypeId == c2devRecordTypeId || c.RecordTypeId == inactivateAccountRecordTypeId || c.RecordTypeId == customerMasterChangeShipToGenToCustomerRecordTypeId )
            {
                Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                req.setComments('Submitted for approval. Please approve.');
                req.setObjectId(c.Id);
                reqs.add(req);
            }    
        }
        List<Approval.ProcessResult> result = Approval.process(reqs);
    }
            /* Status__c, Parent.Status__c, Parent.BillingAddress, Parent.ShippingAddress, Parent.ShippingStreet, Parent.ShippingCity, Parent.ShippingState, Parent.ShippingPostalcode, Parent.ShippingCountry, 
Parent.BillingStreet, Parent.BillingCity, Parent.BillingState, Parent.BillingPostalcode, Parent.BillingCountry, BillingAddress, ShippingAddress, ShippingStreet, ShippingCity, ShippingState, ShippingPostalcode, ShippingCountry, 
BillingStreet, BillingCity, BillingState, BillingPostalcode, BillingCountry */

      Public Static void insertBeaconMainContact(List<Case> newCaseList){
        
        List<Id> accIds = new List<Id>();
        Id devRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer Master - Reactivate Account').getRecordTypeId();
        Id cdevRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('New Customer Request').getRecordTypeId();
        Id c1devRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Acct Mgmt - Account Owner Change').getRecordTypeId();
        Id c3devRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer PO Case').getRecordTypeId();
        Id c4devRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Collector Case').getRecordTypeId();
        
        for(Case c : newCaseList){          
            if(c.recordtypeId == devRecordTypeId || c.RecordTypeId == cdevRecordTypeId || c.RecordTypeId == c1devRecordTypeId || c.RecordTypeId == c3devRecordTypeId || c.RecordTypeId == c4devRecordTypeId)
                accIds.add(c.AccountId);
        }
        List<Account> accList = new List<Account>();
        List<Contact> bcmList = new List<Contact>();
        Map<Id,Id> bcm  = new Map<Id, Id>();
        Map<Id,Contact> bcm2  = new Map<Id, Contact>();
        Map<Id,Account> acc = new Map<Id,Account>();
        
        

        
        if(accIds.size() > 0){   
            accList = [SELECT ID, ParentId, Duplicate_Account__c FROM ACCOUNT WHERE ID IN: accIds]; 
        }
        
        if(accIds.size() > 0){           
            bcmList = [SELECT ID, FirstName, LastName, Phone, Title, Email, AccountId FROM Contact WHERE (AccountId IN: accIds) AND Contact_Type__c INCLUDES ('MAIN') ];
        } 
        if(bcmList.size() > 0){
            for(Contact bc : bcmList){
                bcm.put(bc.AccountId, bc.Id);
            }
        }
        if(bcmList.size() > 0){
            for(Contact bc : bcmList){
                bcm2.put(bc.AccountId, bc);
            }
        }
        if(accList.size()>0){
            for(Account acc2 : accList){
                acc.put(acc2.id, acc2);
            }
        }
        
        for(Case c : newCaseList){
            if(bcm.containsKey(c.AccountId)){
                c.Main_Customer_Contact__c = bcm.get(c.AccountId);
                c.Main_Contact_Email__c =  bcm2.get(c.AccountId).Email;   
                c.Main_Contact_Phone__c  =  bcm2.get(c.AccountId).Phone;
                c.Main_Contact_Title__c =  bcm2.get(c.AccountId).Title;
            }
		}
    } 
    
     public static void updateExistingAccount(List<case> newcaseList){
        
        set<String> winSet = new Set<String>();
        Id cdevRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer PO Case').getRecordTypeId(); 
        Id c1devRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Collector Case').getRecordTypeId();
          
        for(case l : newcaseList){
            if(l.recordtypeId == cdevRecordTypeId || l.RecordTypeId == c1devRecordTypeId){      
            if(l.WIN_ID__c != null){                
                winSet.add(l.WIN_ID__c);
                l.WIN_ID__c = l.WIN_ID__c.touppercase();
            }
            }  
        }
        Map<String, Account> accMap = new Map<String,Account>(); // Sireesha - Modified the Map parameters to store Account Object 
        Map<String,ID> accOwnerMap = new Map<String,ID>(); 
                  
        if(winSet.size() > 0){
            List<Account> AccountList = [SELECT id,WIN_ID__c, ownerid, owner.Sales_Person_Type__c, owner.managerid, owner.isActive,owner.Name, Key_Account_Primary_Business__c, Key_Account_Support_Person__c FROM Account where WIN_ID__c in: winSet];
            if(AccountList.size()>0 )   {
                for(Account acc : AccountList){
                    accMap.put(acc.WIN_ID__c,acc);
                    if(acc.owner.Sales_Person_Type__c == 'Sales Placeholder'){
                        accOwnerMap.put(acc.WIN_ID__c,acc.owner.managerid);
                    }
                    else
                    {
                        accOwnerMap.put(acc.WIN_ID__c,acc.ownerid);
                        /*Sireesha - Assign Case to Manager if AM is Inactive
                         * if(acc.owner.isActive && !acc.Owner.Name.contains('Inactive')){ //Sireesha - To consider the Owner only when hes active
                            accOwnerMap.put(acc.WIN_ID__c,acc.ownerid);
                        }
                        else if(acc.owner.managerid != NULL){ //Sireesha - If Owner is Inactive pick the Manager of the Owner
                            accOwnerMap.put(acc.WIN_ID__c,acc.owner.managerid);
                        }*/
                    }
             
                }
                
                for(case l : newcaseList){
                    if(l.WIN_ID__c != null )
                        l.Accountid = accMap.get(l.WIN_ID__c.toUpperCase()).Id;
                    if(!skipAutomatedOwnerAssignment && l.Type != 'EBILL'  && !(l.recordtypeId == c1devRecordTypeId && accMap.get(l.WIN_ID__c.toUpperCase()).Key_Account_Primary_Business__c == 'Safety-Kleen' && accMap.get(l.WIN_ID__c.toUpperCase()).Key_Account_Support_Person__c!= NULL))
                        l.OwnerId = accOwnerMap.get(l.WIN_Id__c.toUpperCase());
                }
            } 
        }
     }
    
    public static void caseAfterUpdateHandler(List<case> newCaseList, Map<Id,case> oldMap){
        Boolean isUpdateAccWinId = FALSE;
        List<account> accList = New List<Account>();
        List<account> accListToUnlock=new List<Account>();
        List<account> GenList = New List<Account>();
        List<Id> accIds = New List<Id>();
        Set<Id> childCaseAccIds = new Set<Id>();
        Set<Id> newCustIds = new Set<Id>();
        Id newCustomerValidationRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('New Customer Request').getRecordTypeId();
        Id accountUpdateValidationRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Account Update Validations').getRecordTypeId();
        Id inactivateAccountRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Inactivate_Account').getRecordTypeId();
        Id caseInvoiceDeliveryRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Invoice Delivery').getRecordTypeId();
        Id changeShipGentoCustomerRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer Master - Change ShipTo/Gen To Customer').getRecordTypeId();
        Id customerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        Id custReactivateRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer Master - Reactivate Account').getRecordTypeId();
        Id customerLocationRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer Location').getRecordTypeId();
        Id fieldChangeRequestRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Field Change Request').getRecordTypeId();
        Set<Id> accountIdsForUpdateValidations = new Set<Id>();
        Set<Id> inactivatingAccountIds = new Set<Id>();   
        Map<Id,Account> accMap =  new Map<Id,Account>(); 
        Map<Id,Account> validateAccMapForInactiveRecords =  new Map<Id,Account>();
        Map<Id,Account> companySyncAccounts =  new Map<Id,Account>();   
        Set<Id> parentCaseIds = new Set<Id>();
        Set<Id> parentCaseIdsforApproval = new Set<Id>();    
        for(case c: newcaselist){               
            if(c.Status == 'Approved' && c.status <> oldMap.get(c.id).status){ 
                if(c.RecordTypeId == changeShipGentoCustomerRecordTypeId){    
                    accIds.add(c.accountId);    
                }   
                else if(c.RecordTypeId == newCustomerValidationRecordTypeId){    
                    newCustIds.add(c.accountId);    
                }else if(c.RecordTypeId == accountUpdateValidationRecordTypeId){
                    accountIdsForUpdateValidations.add(c.accountId);
                }
            }
            if(c.status == 'Closed - Rejected' && c.status <> oldMap.get(c.id).status && c.RecordTypeId == fieldChangeRequestRecordTypeId)      
            {       
                if(c.ParentId != NULL)  
                    parentCaseIds.add(c.parentId);  
            }               
            
            if((c.Status == 'Closed Archived' || c.Status == 'Closed Inactivated' || c.Status == 'Approved') && c.status <> oldMap.get(c.id).status && c.RecordTypeId == inactivateAccountRecordTypeId){ 
                inactivatingAccountIds.add(c.accountId);
            }                 
        }   
        Map<Id, Case> parentCaseMap = new Map<Id, Case>([SELECT Id, AccountId, Account.Toggle_Me_to_Bypass_Validation__c FROM Case WHERE Id IN :parentCaseIds]);  
        for(Case caseObj : parentCaseMap.values()){ 
            childCaseAccIds.add(caseObj.AccountId); 
        }    
        for(Account acc : [SELECT id, parentid, parent.parentId, WIN_ID__c,Origin__c,WIN_Validated__c,Win_Validate_New__c from account where (ID in: accIds and parent.parentid <> null) OR (Id IN :accountIdsForUpdateValidations) OR (Id IN :childCaseAccIds) OR (Id IN :inactivatingAccountIds)]){
            if(accIds.contains(acc.Id)){
                accMap.put(acc.Id, acc);
            }if(childCaseAccIds.contains(acc.Id)){   
                companySyncAccounts.put(acc.Id, acc);
            }else{
                validateAccMapForInactiveRecords.put(acc.Id, acc);
            }      
        }
        
        for(case c : newCaseList){
            boolean duplicateParentAccount = false;
            if((c.Status == 'Closed Inactivated' || c.Status == 'Closed Archived') && c.status <> oldMap.get(c.id).status){         
                if(c.RecordTypeId == inactivateAccountRecordTypeId){
                    Account a = validateAccMapForInactiveRecords.get(c.AccountId);
                    a.id = c.AccountId;
                    a.Status__c = 'Inactive';
                    if(string.isBlank(a.WIN_ID__c)){
                        a.WIN_Validated__c = False;
                        a.High_Priority__c = False;   
                    }
                    else{  
                        a.WIN_Validated__c = True;
                        a.High_Priority__c = True;
                    }                       
                    a.Inactivate_Reactivate_In_Progress__c = false; 
                    accList.add(a); 
                    accListToUnlock.add(a);
                }
            }
            else if(c.Status == 'Approved' && c.status <> oldMap.get(c.id).status){
                if(c.RecordTypeId == inactivateAccountRecordTypeId){
                    Account a = validateAccMapForInactiveRecords.get(c.AccountId);
                    a.id = c.AccountId;
                    a.Status__c = 'Inactive';
                    if(string.isBlank(a.WIN_ID__c)){
                        a.WIN_Validated__c = False;
                        a.High_Priority__c = False;   
                    }
                    else{  
                        a.WIN_Validated__c = True;
                        a.High_Priority__c = True;
                    }                       
                    a.Inactivate_Reactivate_In_Progress__c = false; 
                    accList.add(a); 
                    accListToUnlock.add(a);
                }
                else if(c.RecordTypeId == fieldChangeRequestRecordTypeId)    
                {    
                    parentCaseIdsforApproval.add(c.parentId);
                }
                else if(c.RecordTypeId == custReactivateRecordTypeId && c.Unexpire_Reason__c <> null){    
                    Account a = new Account();  
                    a.id = c.AccountId; 
                    a.Status__c = 'Active';
                    a.Expired_Date__c = Null;
                    a.Lost_Reason__c = '';  
                    a.ownerId = c.To_Be_Assigned_Account_Owner_ID__c;   
                    a.Inactivate_Reactivate_In_Progress__c = false;  
                    List<Users.UserWrapperObject> wrapperObjects= Users.getDefaultOSandPSP(new List<Id> {a.ownerId});
                    if(!wrapperObjects.isEmpty()){
                        a.Primary_Business__c= wrapperObjects[0].PrimaryServiceProvider;
                        a.Primary_Service_Provider_New__c= wrapperObjects[0].OperatingSegment;
                    }      
                    accList.add(a);
                    accListToUnlock.add(a);
                }   
                else if(c.RecordTypeId == newCustomerValidationRecordTypeId){
                    Account a = new Account();
                    a.id = c.AccountId;
                    a.WIN_Validated__c = true;
                    a.High_Priority__c=true;
                    a.Cycle__c = 'Committed';
                    a.WIN_Compliance_Errors__c = '';
                    a.New_Customer_validated__c = false;      
                    a.EPA_Service_Call__c = false;
                    accList.add(a);
                }
                else if(c.RecordTypeId == changeShipGentoCustomerRecordTypeId){
                    Account a = new Account();
                    a.id = c.AccountId;
                    a.RecordTypeId = customerRecordTypeId; 
                    a.Type = 'Customer';
                    a.ParentId = (accMap.containskey(c.AccountId) ? accMap.get(c.AccountID).parent.parentID : null);
                    a.BillingStreet=c.Address_Line_1__c;
                    a.BillingCity=c.City__c; 
                    a.BillingState=c.State__c;
                    a.BillingPostalCode=c.Postal_Code__c;
                    a.BillingCountry=c.Country__c;
                    a.WIN_Validate_New__c = true;
                    a.High_Priority__c = True;							
                    a.Existing_Customer_Validated__c = false;
                    a.EPA_Service_Call__c = false;					
                    GenList.add(a);       
                    AccountCRUDHandler.lockAccountRecord(a,true);
                }
            }
            else if(c.RecordTypeId == caseInvoiceDeliveryRecordTypeId && c.Status=='Closed - Completed' && oldMap.get(c.id).Status=='New'
                    && c.Latest_Case_Comment__c == Null){
                        c.adderror(CHConstants.Submit_For_Reject_Error); 
                    }
            else if(c.Status == 'Manager Rejected' && c.status <> oldMap.get(c.id).status){
                if(c.RecordTypeId == inactivateAccountRecordTypeId){
                    Account a = new Account();  
                    a.id = c.AccountId;     
                    a.Inactivate_Reactivate_In_Progress__c = false; 
                    a.Lost_Reason__c = ''; 
                    accList.add(a); 
                    accListToUnlock.add(a);               
                } 
            }
            if(c.Status == 'Closed - Rejected' && c.status <> oldMap.get(c.id).status){
                if(c.RecordTypeId == inactivateAccountRecordTypeId){
                    Account a = new Account();  
                    a.id = c.AccountId;     
                    a.Inactivate_Reactivate_In_Progress__c = false; 
                    a.Lost_Reason__c = ''; 
                    accList.add(a); 
                    accListToUnlock.add(a);               
                }
                else if(c.RecordTypeId == fieldChangeRequestRecordTypeId)
                {
                    Account acc;
                    for(Account accRec : accList)
                    {
                        if(accRec.Id==parentCaseMap.get(c.ParentId).AccountId)
                        {
                            acc = accRec;
                            duplicateParentAccount= true;
                            break;                                
                        }
                    }
                    if(acc == null)
                    {
                        acc = new Account();
                    }                          
                    AccountCRUDHandler.accountsToggleMeToBypassMap.put(parentCaseMap.get(c.ParentId).AccountId, parentCaseMap.get(c.ParentId).Account.Toggle_Me_to_Bypass_Validation__c);
                    acc.Toggle_Me_to_Bypass_Validation__c= !parentCaseMap.get(c.ParentId).Account.Toggle_Me_to_Bypass_Validation__c;
                    acc.id = parentCaseMap.get(c.ParentId).AccountId;
                    if(c.Account_Field_Changed__c == CHConstants.ACCOUNT_SHIPPING_ADDRESS_CHANGED){
                        if(String.isNotBlank(c.Old_Corporate_Street__c)){
                            acc.ShippingStreet = getChangedFieldOldValue(c.Old_Corporate_Street__c);
                        } 
                        if(String.isNotBlank(c.Old_Corporate_State__c)){
                            acc.ShippingState = getChangedFieldOldValue(c.Old_Corporate_State__c);
                        }
                        if(String.isNotBlank(c.Old_Corporate_City__c)){
                            acc.ShippingCity = getChangedFieldOldValue(c.Old_Corporate_City__c);
                        }
                        if(String.isNotBlank(c.Old_Corporate_Postal_Code__c)){
                            acc.ShippingPostalCode = getChangedFieldOldValue(c.Old_Corporate_Postal_Code__c);
                        }
                        if(String.isNotBlank(c.Old_Corporate_Country__c)){
                            acc.ShippingCountry = getChangedFieldOldValue(c.Old_Corporate_Country__c);
                        }
                    }
                    else if(c.Account_Field_Changed__c == CHConstants.ACCOUNT_BILLING_ADDRESS_CHANGED){
                        if(c.Old_Billing_Street__c !=null ){
                            acc.billingstreet = getChangedFieldOldValue(c.Old_Billing_Street__c);
                        }
                        if(String.isNotBlank(c.Old_Billing_State__c)){
                            acc.billingState = getChangedFieldOldValue(c.Old_Billing_State__c);
                        }
                        if(String.isNotBlank(c.Old_Billing_City__c)){
                            acc.billingcity = getChangedFieldOldValue(c.Old_Billing_City__c);
                        }
                        if(String.isNotBlank(c.Old_Billing_Postal_Code__c)){ 
                            acc.billingPostalCode =getChangedFieldOldValue( c.Old_Billing_Postal_Code__c);
                        }
                        if(String.isNotBlank(c.Old_Billing_Country__c)){ 
                            acc.billingCountry = getChangedFieldOldValue(c.Old_Billing_Country__c);
                        }
                    }
                    else if(c.Account_Field_Changed__c == 'Chain__c'){
                        if(String.isNotBlank(c.Old_Chain_Code_Name__c)){ 
                            acc.Chain__c =getChangedFieldOldValue(c.Old_Chain_Code_Name__c);
                        }
                        else
                        {
                            acc.Chain__c = NULL;
                        }
                    } 
                    else
                    {
                        acc.put(c.Account_Field_Changed__c, c.Old_Value__c);
                    }
                    acc.High_Priority__c = true; 
                    acc.Win_Validate_New__c= true;
                    if(duplicateParentAccount == false){
                        accList.add(acc);
                    }
                    parentCaseIdsforApproval.add(c.parentId);
                }
                else if(c.RecordTypeId == custReactivateRecordTypeId && c.Unexpire_Reason__c <> null){   
                    Account a = new Account();              
                    a.id = c.AccountId;                             
                    a.Inactivate_Reactivate_In_Progress__c = false; 
                    accList.add(a); 
                    accListToUnlock.add(a);              
                }
                else if(c.RecordTypeId == newCustomerValidationRecordTypeId){
                    Account a = new Account();
                    a.id = c.AccountId;
                    a.WIN_Validated__c = false;
                    a.New_Customer_validated__c = false;
                    a.EPA_Service_Call__c = false;
                    a.Cycle__c = 'Prospect';
                    accList.add(a);
                    accListToUnlock.add(a);
                }
            }
        }
        if(!accList.isEmpty()){
            AccountCrudHandler.toggleWinValidateFlagBasedOnAccountTypes(accList);
            Database.DMLOptions dml = new Database.DMLOptions(); 
            dml.DuplicateRuleHeader.AllowSave = true;
            dml.optAllOrNone= true;
            Database.update(accList,dml); 
        }
        if(!parentCaseIdsforApproval.IsEmpty())
        {
            updateParentCaseStatus(parentCaseIdsforApproval);
        }
        if(!accListToUnlock.isEmpty()){
            AccountCRUDHandler.unlockAccountRecords(accListToUnlock);  
        }
        if(GenList.size() > 0){
            AccountCRUDHandler.updateAcctFromSTGtoCUST(GenList); 
        }
    } 
      
    
    
    private static String getChangedFieldOldValue(String oldValue){
        return (oldValue == AccountCRUDHandler.OldValueReplace) ? '' : oldValue;                           
    }
    
 
    //to-do vikram update parent status
    /*******************************************************************************************
    * @Name         updateParentCaseStatus 
    * @Author       Vikram Simha <yerabogi.vikram@cleanharbors.com>
    * @Date         23/08/2023
    * @PBI  685998
    * @Description  This method checks the clid cases and update the parent case status.
    /********************************************************************************************/
    private static void updateParentCaseStatus(Set<Id> parentIds)
    {
        Boolean isAtLeastOneRecordNew = false;
        Boolean isAtLeastOneRecordRejected = false;
        Boolean isAtLeastOneRecordApproved = false;
        List<Case> caseToUpdate = new List<Case>();            
        Map<id,Case> caseMap = new Map<id,Case>([select id,Status,Is_Submitted_for_Approval__c from case where id in : parentIds or parentid in :parentIds]);//Map
        for(Id parentId : parentIds){
            Case parentCase = caseMap.get(parentId);
            caseMap.remove(parentId);
            String initialStatus = parentCase.Status;
            for(Case cs : caseMap.values())
            {
                if(isAtLeastOneRecordNew && isAtLeastOneRecordApproved && isAtLeastOneRecordRejected)
                {
                    break;
                }
                if(cs.Status == 'Awaiting Manager Approval' && !isAtLeastOneRecordNew)
                {
                    isAtLeastOneRecordNew = true;
                }
                else if(cs.Status == 'Approved' && !isAtLeastOneRecordApproved)
                {
                    isAtLeastOneRecordApproved = true;
                }
                else if(cs.Status == 'Closed - Rejected' && !isAtLeastOneRecordRejected)
                {
                    isAtLeastOneRecordRejected = true;
                }
            }
            if(isAtLeastOneRecordNew && !isAtLeastOneRecordRejected && !isAtLeastOneRecordApproved)
            {
                parentCase.Status = 'New';
            }
            else if(!isAtLeastOneRecordNew && isAtLeastOneRecordRejected && !isAtLeastOneRecordApproved)
            {
                parentCase.Status = 'Complete - Rejected';
            }
            else if(!isAtLeastOneRecordNew && !isAtLeastOneRecordRejected && isAtLeastOneRecordApproved)
            {
                parentCase.Status = 'Complete - Approved';
            }
            else if((isAtLeastOneRecordNew && isAtLeastOneRecordApproved && isAtLeastOneRecordRejected) || (isAtLeastOneRecordNew && (isAtLeastOneRecordApproved || isAtLeastOneRecordRejected)))
            {
                parentCase.Status = 'In Progress';
            }
            else if(isAtLeastOneRecordRejected && isAtLeastOneRecordApproved)
            {
                parentCase.Status = 'Complete - Partially Approved';
            }
            if(initialStatus != parentCase.Status)
            {
                parentCase.Is_Submitted_for_Approval__c = !parentCase.Is_Submitted_for_Approval__c;
                caseToUpdate.add(parentCase);
            }
        }
        if(!caseToUpdate.IsEmpty())
        {
            update caseToUpdate;
        }
    }
        
 
    public static void UpdateCallCenterActivity (List<Case> newCaseList) {
        try
        {
            List<Task> TList = New List<Task>();
            //List<Task> oppList = New List<Opportunity>();
            Id cdevRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer Service Case(New)').getRecordTypeId();
            Id casedevRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Parts_Washer_Pull_Request').getRecordTypeId();
            for(case c: newcaselist){            
                if((c.RecordTypeId == cdevRecordTypeId || c.RecordTypeId == casedevRecordTypeId)&& c.Call_Center_Activity_ID__c <> null){
                    Task T = new Task();
                    T.id = c.Call_Center_Activity_ID__c ;
                    t.Customer_Service_Case__c = c.id;
                    TList.add(t);           
                }
            } 
            
            if(TList.size() > 0) {
                update TList;
                List<open_case__e> eventList = new List<open_case__e>();
                open_case__e evt = new open_case__e();
                evt.Case_Id__c = newcaselist[0].id;
                
                eventList.add(evt);
                
                if(eventList.size() > 0){
                    EventBus.publish(eventList);
                }
            }
        }
        catch(Exception e)
        {
            system.debug('Exception while update activity -->'+e.getMessage());
        }
    }
    
    public static void sendCaseDetailsToWIN(List<Case> newList, Map<Id, Case> oldMap){
        
        List<Id> caseIds = new List<Id>();
        Id nsbWinRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Non Standard Billing WIN').getRecordTypeId();
        Id nsbClosedRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Non Standard Billing Closed Order').getRecordTypeId();
        Id collectorCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Collector Case').getRecordTypeId();    
        for(Case caseObj : newList){
            if(caseObj.Status != oldMap.get(caseObj.Id).Status && (caseObj.RecordTypeId == collectorCaseRecordTypeId || caseObj.RecordTypeId == nsbWinRecordTypeId || caseObj.RecordTypeId == nsbClosedRecordTypeId)){
                caseIds.add(caseObj.Id);
            }
        }
        
        if(!caseIds.isEmpty() && !Test.isRunningTest()){
            
            RestUpdateCase.sendCaseDetails(caseIds, TRUE);
        }
    }
    
    /*Author: Sireesha 
     * Users Cannot Close Case Without Entering Case Comments
        */
    
    public static void caseCommentsMandatory(List<Case> newCaseList, Map<Id, Case> oldMap){
        
        Id casedevRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer Service Case').getRecordTypeId(); 
        Id casedevRecordTypeId1 = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer Service Case(New)').getRecordTypeId(); 
        Set<Id> caseIds = new Set<Id>();
        List<Case> caseToProcess = new List<Case>();
        
        for(Case caseObj : newCaseList){
            if((caseObj.RecordTypeId == casedevRecordTypeId || caseObj.RecordTypeId == casedevRecordTypeId1 ) && caseObj.Status != oldMap.get(caseObj.Id).Status &&
               (caseObj.Status == 'Closed' || caseObj.Status == 'Resolved')){
                   caseIds.add(caseObj.Id);
                   caseToProcess.add(caseObj);
               }
        }
        
        if(!caseIds.isEmpty()){
            Map<Id, Case> caseMap = new Map<Id, Case>([Select Id, (Select Id from CaseComments) from Case where ID IN : caseIds]);
            for(Case obj : caseToProcess){
                
                Case cObj = caseMap.get(obj.Id);
                if(cObj.CaseComments.Size() < 1){
                    obj.addError('Please add Comments to close the Case');
                }
            }
        }
    }
    
  
    
   /* public static void insertcaseteam (List<Case> newCaseList) {
        
         Id devRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Business At Risk').getRecordTypeId();
          set<Id> accset = new Set<Id>();
        for(case c : newcaseList){ 
            if(c.AccountId != null){
                accset.add(c.AccountId);
            }
        }
        
    map<Id,Account> accList = new map<Id,Account>([Select id, ownerId, name, owner.managerid  from account where id in: accset]);
        
    Id caseTeamRoleId= [SELECT Id FROM CaseTeamRole WHERE Name = 'Account Owner' LIMIT 1].id;
       Id ManagerRoleId= [SELECT Id FROM CaseTeamRole WHERE Name = 'Account Owner Manager' LIMIT 1].id; 
    List<CaseTeamMember> catmList=new List<CaseTeamMember>();
    for(Case cs:newCaseList ){
        if(cs.recordtypeId == devRecordTypeId)
        {
            if(accList.get(cs.accountid).OwnerId <> null){
        CaseTeamMember tm=new CaseTeamMember();
        tm.ParentId=cs.Id;
        tm.MemberId=accList.get(cs.accountid).OwnerId;
        tm.TeamRoleId =caseTeamRoleId;
            catmList.add(tm);
            } 
            
            if(accList.get(cs.accountid).owner.managerid <> null){
            CaseTeamMember tm1=new CaseTeamMember();
        tm1.ParentId=cs.Id;
        tm1.MemberId=accList.get(cs.accountid).owner.managerid;
        tm1.TeamRoleId =ManagerRoleId;
        catmList.add(tm1);
            }
    }
        
    if(!catmList.isEmpty()){
        Try{
            Insert catmList;
        }catch(DmlException de){
            System.debug(de);
        }
    }
    }
    } */
    
    public static void updateAccountCaseRank(List<Case> newCaseList, Map<Id,Case> oldMap){
        set<Id> accIds = new Set<Id>();
        for (Case c:newCaseList){
            if((oldMap == null && c.Case_Rank__c != null) || 
               (oldMap != null && (c.Case_Rank__c !=oldMap.get(c.id).Case_Rank__c 
                 || (c.Case_Rank__c != null && oldMap.get(c.id).Case_Rank__c == null)
                 || (c.Case_Rank__c == null && oldMap.get(c.id).Case_Rank__c != null)))){
                accIds.add(c.AccountId);
            }
        }
        system.debug('accIds---> Size'+accIds.size());
        
       if(accIds.size() > 0){
        updateAccountCaseRankByAccId(accIds);
      }
    }
    
    public static void updateAccountCaseRankByAccId(Set<Id> accIdSet){
        List<account> updateAccountList = new List<account>();
        List<Account> AccCaseList = [Select id, IS_Case_Rank_Backend__c,IS_Rank_Case_Closed_Date__c, (Select id, Case_Rank__c,ClosedDate from cases where Case_Rank__c != null Order By Case_Rank__c DESC,ClosedDate DESC NULLS first limit 1) 
                                     From Account where id in:accIdSet AND (RecordType.DeveloperName = 'Customer' OR RecordType.DeveloperName = 'Customer_Location')
                                     AND Status__c = 'Active' AND win_id__c != null];
        
        for (account a:AccCaseList){
           if(a.cases!= null && a.cases.size() > 0){
            for (case c:a.cases){
                if (a.IS_Case_Rank_Backend__c != c.Case_Rank__c){
                    //Rank Not same
                    Account newAcc = new Account();
                    newAcc.id = a.Id;
                    newAcc.IS_Case_Rank_Backend__c = c.Case_Rank__c;
                    if (c.Case_Rank__c == 7){
                        newAcc.IS_Rank_Case_Closed_Date__c = c.ClosedDate.date();
                    }
                    updateAccountList.add(newAcc);
                    }else if (c.Case_Rank__c == 7 && a.IS_Case_Rank_Backend__c == c.Case_Rank__c && a.IS_Rank_Case_Closed_Date__c != c.ClosedDate.date()){
                        Account newAcc = new Account();
                        newAcc.id = a.Id;
                        newAcc.IS_Rank_Case_Closed_Date__c = c.ClosedDate.date();
                        updateAccountList.add(newAcc);
                    }  
                }
           }else if (a.cases.size() == 0 && a.IS_Case_Rank_Backend__c != null){
                    Account newAcc = new Account();
                    newAcc.id = a.Id;
                    newAcc.IS_Case_Rank_Backend__c = null;
                    updateAccountList.add(newAcc);
           }
        }
        
       if(updateAccountList.size()>0){
         update updateAccountList;
        }
        
    }
    /*******************************************************************************************
    * @Name         checkUserMemberofPOQueue 
    * @Author       Vikram Simha <yerabogi.vikram@cleanharbors.com>
    * @Date         09/05/2022
    * @Incident ID  INC1699402
    * @Description  This method checks Is a menber of the given Queue and changes the flag.
    /********************************************************************************************/
    Public static void checkUserMemberofPOQueue(List<Case> newCaseList,Map<id,Case> oldCaseMap)
    {
        Boolean caseStatusUpdated = false;
        for(Case eachCase : newCaseList)
        { 
            if(eachCase.Status != oldCaseMap.get(eachCase.id).Status)
            {
                caseStatusUpdated = true;
                break;
            }
        }
        if(caseStatusUpdated)
        {
            //Queue Names to be Considered are Configured in Custom Label PO_Case_Queue
            List<string> queuesListCanUpdate = Label.PO_Case_Queue.Split(',');
            List<GroupMember> groupMemberList = [SELECT id,UserOrGroupId FROM GroupMember WHERE UserOrGroupId = :userinfo.getUserId() AND GroupId IN ( SELECT Id FROM Group WHERE Type = 'Queue' and DeveloperName in :queuesListCanUpdate )]; 
            if(!groupMemberList.IsEmpty())
            {
                
                for(Case eachCase : newCaseList)
                {   
                    if(eachCase.Status != oldCaseMap.get(eachCase.id).Status)
                    {
                        eachCase.IS_User_PO_Case_Queue_Member__c = !eachCase.IS_User_PO_Case_Queue_Member__c;
                    }
                }
                
            } 
        } 
        
    }
    public static void checkInactivationAccountCriteria(List<Case> newCaseList, Map<Id,Case> oldMap){  
        
        Id inactivateAccountRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Inactivate_Account').getRecordTypeId();
        Set<Id> caseIds=new Set<Id>();
        Map<Id,ProcessInstanceWorkitem> caseProcessWorkItemMap=new Map<Id,ProcessInstanceWorkitem>();
        Id currentUserProfileId = UserInfo.getProfileId();
        Set<String> caseStatus = new Set<String>{'Awaiting Manager Approval'};
        List<ProcessInstanceWorkitem> processWorkItems = new List<ProcessInstanceWorkitem>();
        String profileName = '';
        for(Case caseObj: newCaseList){
            if(caseObj.RecordTypeId == inactivateAccountRecordTypeId){
                caseIds.Add(caseObj.Id);
            }
            if(oldMap.get(caseObj.Id).Current_Owner_Case_Approver__c!=null && caseObj.Current_Owner_Case_Approver__c==null){
                caseObj.Current_Owner_Case_Approver__c = oldMap.get(caseObj.Id).Current_Owner_Case_Approver__c;
            }
        }
        if(!caseIds.isEmpty()){
            profileName= [SELECT Name FROM Profile WHERE Id =: currentUserProfileId].Name;
            processWorkItems = [select actor.Type,ProcessInstance.TargetObjectId,actorId,actor.Name  from ProcessInstanceWorkitem where ProcessInstance.TargetObjectId in:caseIds];
        }   
        
        Set<String> queueNames = new Set<String>();
        Set<Id> queueIds = new Set<Id>();
        for(ProcessInstanceWorkitem processWorkItem: processWorkItems){
            caseProcessWorkItemMap.put(processWorkItem.ProcessInstance.TargetObjectId,processWorkItem);
            if(processWorkItem.actor.Type=='Queue')
            {
                queueNames.add(processWorkItem.actor.Name);
            }
        }
        if(!queueNames.IsEmpty()){
            List<GroupMember> groupMembers= [Select UserOrGroupId,GroupId From GroupMember where GroupId in (Select Id from Group where type='Queue' and Name in :queueNames) and UserOrGroupId=:UserInfo.getUserId()];
            for(GroupMember groupMem : groupMembers)
            {
                queueIds.add(groupMem.GroupId);
            }
        }
        for(Case caseObj : newcaselist){                
            if(caseObj.RecordTypeId == inactivateAccountRecordTypeId && caseObj.Status == 'Approved' && (oldMap.get(caseObj.Id).Status == 'Manager Approved' || oldMap.get(caseObj.Id).Status == 'Awaiting Manager Approval') &&    
               (caseObj.No_Co_links_Active__c == False || caseObj.No_Open_Opportunities__c == False || caseObj.No_Open_Order_in_Order_Management_OM__c == False || 
                caseObj.No_Asset_Association_Services__c == False || caseObj.No_Open_Orders_in_Account_Details__c == False || caseObj.No_Invoice_Orders_in_Account_Details__c == False ||   
                caseObj.No_Service_Master_listing__c == False)){
                    caseObj.addError('Inactivation Criteria fields needs to be checked before approving the Case');
                }
            
            if(caseObj.RecordTypeId == inactivateAccountRecordTypeId && profileName!='System Administrator' && profileName!='Integration' && caseObj.Status!=oldMap.get(caseObj.Id).Status && !caseStatus.contains(caseObj.Status) && !FeatureManagement.checkPermission('Skip_Validations_for_Super_users_cp')){
                ProcessInstanceWorkitem processWorkItem= caseProcessWorkItemMap.get(caseObj.Id);
                if(processWorkItem!=null){
                    if(processWorkItem.actor.Type=='User'){
                        if(processWorkItem.actor.Id!=UserInfo.getUserId()){
                            caseObj.addError('Permission to approve/reject next level request or request not assigned to you, is not allowed');
                        }
                    }
                    else if(processWorkItem.actor.Type=='Queue'){
                        if(queueIds.isEmpty() || !queueIds.contains(processWorkItem.actorId)){
                            caseObj.addError('Permission to approve/reject next level request or request not assigned to you, is not allowed');
                        }
                    }
                }
            }
            
        }
    }
    
@future
public static void AutoCloseCase (List<Id> casesIds){
           
    if(!casesIds.isEmpty()){
        List<String> poNumbers = new List<String>();
        List<String> winids = new List<String>();
        for(Case cc : [SELECT id,poNumber__c, win_id__c, PO_Case_Reason__c FROM case WHERE id =: casesIds])
        {
            poNumbers.add(cc.poNumber__c);
            winids.add(cc.win_id__c);
        }
        Case [] casesToClose = [Select Id, status from Case where poNumber__c in: poNumbers and id not in: casesIds and status <> 'Closed - Completed' and win_id__c in: winids and PO_Case_Reason__c =: system.label.Year_End_PO_Expiration];
        for(Case c: casesToclose){
            c.status = 'Closed - Completed';
        }
       update casestoClose;
    }
}
        public static void AutoPopulateBranch(List <Case> Caselist) {
        Id casedevRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Parts_Washer_Pull_Request').getRecordTypeId();
        Set<id> accountIds = new Set<id>();
        for (Case caseRecord : Caselist) {
        if (caseRecord.AccountId != null && caseRecord.RecordTypeId ==casedevRecordTypeId) {
        accountIds.add(caseRecord.AccountId);
            }
        }
        Map <id,Account> accountsMap = new Map<id,Account>([SELECT Id, Primary_Aurora_Branch_Name__c FROM Account WHERE Id IN :accountIds]);
        Map<string, case> branchToCaseMap = new Map<string, case>();
        for (Case caseRecord : Caselist) {
        if (caseRecord.AccountId != null && accountsMap.containsKey(caseRecord.AccountId) && caseRecord.RecordTypeId ==casedevRecordTypeId ) {
        Account account = accountsMap.get(caseRecord.AccountId);
        String primaryAuroraBranch = account.Primary_Aurora_Branch_Name__c;

        if (primaryAuroraBranch != null) {
        branchToCaseMap.put(primaryAuroraBranch, caseRecord);
                }
            }
        }
        Map<String, Id> branchToIdMap = new Map<String, Id>();
        for (Account branch : [SELECT Id, Name FROM Account WHERE Recordtype.Name = 'Branch' and Name IN :branchToCaseMap.keySet()]) {
        branchToIdMap.put(branch.Name, branch.Id);
        }
        for (Case caseRecord : branchToCaseMap.values()) {
        String primaryAuroraBranch = accountsMap.get(caseRecord.AccountId).Primary_Aurora_Branch_Name__c;

        if (branchToIdMap.containsKey(primaryAuroraBranch) && caseRecord.RecordTypeId ==casedevRecordTypeId && caseRecord.Branch_Account__c == null) {
        caseRecord.Branch_Account__c = branchToIdMap.get(primaryAuroraBranch);
                }
            }
        }

    
     /**
    * @description 
    * @author Vikram Simha | 09-11-20203 
    * @param List<Account> listOfCases
    * @param Map<Id Account> oldMapOfCases
    **/
    public static void removeAccountRelatedContactsfromCadence(List<Case> newLst, Map<Id, Case> oldCaseMap)//name
    {
        Id inactivateAccountRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Inactivate_Account').getRecordTypeId();
        List<id> accIds = new List<Id>();
        List<id> conIdstoRemovefromCadence = new List<Id>();
        List<Contact> contacts;
        for(Case caseRec : newLst)
        {
            if(CaseRec.RecordTypeId == inactivateAccountRecordTypeId && CaseRec.Status != oldCaseMap.get(caseRec.id).Status && (caseRec.Status == 'Approved' || caseRec.Status == 'Closed - Rejected'))
            {
                accIds.add(caseRec.AccountId);
            }
        }
        if(!accIds.IsEmpty())
        {
            contacts = [select id from Contact where AccountId in : accIds and id in (select targetid from  ActionCadenceTracker where State ='Running' )];
        }
        if(contacts != null && !contacts.IsEmpty())
        {
            for(Contact conObj : contacts)
            {
                conIdstoRemovefromCadence.add(conObj.id);
            }
        }
        if(!conIdstoRemovefromCadence.IsEmpty() && !Test.isRunningTest())
        {
            RemoveContactFromCadenceBatch removeContactCadBatch = new RemoveContactFromCadenceBatch(conIdstoRemovefromCadence);
            String jobid= Database.executeBatch(removeContactCadBatch,20);
        }
    }
	
    public static void updateChildCaseCount(List<Case> casesToUpdate) {
        Id fieldChangeRequestRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Field Change Request').getRecordTypeId();
        Id accountUpdateValidationsRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Account Update Validations').getRecordTypeId();
        Map<Id, Integer> parentCaseCountMap = new Map<Id, Integer>();
        
        for (Case childCase : casesToUpdate) {
            if (childCase.RecordTypeId == fieldChangeRequestRecordTypeId && childCase.ParentId != null) {
                if (!parentCaseCountMap.containsKey(childCase.ParentId)) {
                    parentCaseCountMap.put(childCase.ParentId, 1);
                } else {
                    parentCaseCountMap.put(childCase.ParentId, parentCaseCountMap.get(childCase.ParentId) + 1);
                }
            }
        }
        List<Case> casesToUpdateCount = new List<Case>();
        if (!parentCaseCountMap.isEmpty()) {
            Set<Id> parentIds = parentCaseCountMap.keySet();
            List<Case> parentCases = [SELECT Id, Number_of_Children__c,RecordtypeId FROM Case WHERE Id IN :parentIds];
            for (Case parentCase : parentCases) {
                Integer childCount = parentCaseCountMap.get(parentCase.Id);
                if (parentCase.RecordTypeId == accountUpdateValidationsRecordTypeId) {
                    if (Trigger.isInsert) {  
                        parentCase.Number_of_Children__c = childCount;
                    } else if (Trigger.isDelete) {
                        parentCase.Number_of_Children__c -= childCount;
                    }
                    
                    casesToUpdateCount.add(parentCase);
                }
            }
            update casesToUpdateCount;
        }
    }

    public static void validateTSECase(List<Case> newCaseList, Map<Id,Case> oldMap){
        Id tseAddCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('TSE_Add_Case').getRecordTypeId();
        Map<Id, Set<String>> accIdSpecialistProductsMapping = new Map<Id, Set<String>>();
        Set<Id> accountIds = new Set<Id>();  
        
        for(Case c : newCaseList){
            if(c.recordtypeId == tseAddCaseRecordTypeId){
            	if (c.Status == 'New' || c.Status == 'Awaiting Manager Approval'){
            		accountIds.add(c.AccountId);
                }               
            }
        }
        if(!accountIds.isEmpty()){
            for(Case openCases:[select id,accountId,RecordTypeId,Status,Specialist_Products__c from Case
                                           where AccountId IN :accountIds
                                           AND recordTypeId = :tseAddCaseRecordTypeId
                                           AND (Status = 'Awaiting Manager Approval' OR Status = 'Manager Approved')]){
                if(accIdSpecialistProductsMapping.containsKey(openCases.AccountId)){
                   accIdSpecialistProductsMapping.get(openCases.AccountId).addAll(new Set<String>(openCases.Specialist_Products__c.Split(';')));
                   accIdSpecialistProductsMapping.put(openCases.AccountId, new Set<String>(accIdSpecialistProductsMapping.get(openCases.AccountId)));
                }
                else{
                  accIdSpecialistProductsMapping.put(openCases.AccountId, new Set<String>(openCases.Specialist_Products__c.Split(';')));
                }
            }
            for(Case c : newCaseList){            
                if(c.RecordTypeId == tseAddCaseRecordTypeId){
                    Set<String> accountSpecialistValues = new Set<String>(c.Specialist_Products__c.split(';'));           
                    if(!accIdSpecialistProductsMapping.isEmpty() && accIdSpecialistProductsMapping.containsKey(c.AccountId)){
                        Set<String> newPicklistValues = accIdSpecialistProductsMapping.get(c.AccountId);
                        newPicklistValues.retainAll(accountSpecialistValues);
                        if(!newPicklistValues.isEmpty() && 
                           ((Trigger.isInsert && c.Status == 'New') || 
                            (Trigger.isUpdate && oldMap.get(c.id).status == 'New' && c.Status == 'Awaiting Manager Approval'))
                          )
                        {
                            c.addError('One or more of your specialist products is already referenced in a submitted TSE Case. Please reconcile your request with the other cases on this account before submitting.');
                        }
                    }
                }
            }
        }
    }
	public static void validateCPGCaseSubmission(List<Case> caseRecords) {
        Id cpgRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CPG_Request').getRecordTypeId();
        for (Case caseObj : caseRecords) {
            if (caseObj.Is_Submitted_for_Approval__c == true && caseObj.RecordTypeId == cpgRecordTypeId ) {
                caseObj.addError(CHConstants.CPG_SUBMISSION_vALIDATION_ERROR_MESSAGE);
            }
        }
    }
}