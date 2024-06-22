/**
 * @description       : 
 * @author            : Suresh Beniwal
 * @group             : 
 * @last modified on  : 11-29-2022
 * @last modified by  : Suresh Beniwal
 * Modifications Log
 * Ver   Date         Author           Modification
 * 1.0   10-31-2022   Suresh Beniwal   Initial Version
**/
public class LeadHandler{
    public static Boolean isFirstTime = true;
    public static void updateZipMaster(List<Lead> newLeadList){
        
        set<String> pcSet = new Set<String>();
        for(Lead l : newLeadList){ 
            if(l.PostalCode != null && l.PostalCode.length() > 3){
                
                if(l.Country == 'US' || l.Country == 'United States') {
                    pcSet.add(l.PostalCode.trim().left(5));
                } else if(l.Country == 'CA' || l.Country == 'Canada' ){
                    String s1 = l.PostalCode.trim().substring(0,3);
                    String s2 = l.PostalCode.trim().substring(3,6);
                    pcSet.add(s1.rightpad(4)+s2);
                }
            }
        }
        Map<String,ID> zmMap = new Map<String,ID>();
        if(pcSet.size() > 0){
            List<ZIP_Master__c> zipMasterList = [SELECT id,zip__c FROM ZIP_Master__c where zip__c in: pcSet];
            if(zipMasterList.size()>0 ) {
                for(ZIP_Master__c zpM : zipMasterList){
                    zmMap.put(zpM.zip__c,zpM.id);
                }
                //Populates the Zip Master records on account if the there is a match.
                for(Lead ld : newLeadList){
                    if(ld.PostalCode != null && ld.PostalCode.length() > 3 ) {
                        
                        if(ld.Country == 'US' || ld.Country == 'United States') {
                            ld.ZIP_Master_Lookup__c = zmMap.get(ld.PostalCode.trim().left(5));
                        }
                        else if(ld.Country == 'CA' || ld.Country == 'Canada'){
                            String s1 = ld.PostalCode.trim().substring(0,3).toUpperCase();
                            String s2 = ld.PostalCode.trim().substring(3,6).toUpperCase();
                            ld.ZIP_Master_Lookup__c = zmMap.get(s1.rightpad(4)+s2);
                        }
                    }
                }
            }
        } 
    }
    
    
    public static void updateTerritoryMaster(List<Lead> newLeadList){
        
        set<String> pcSet = new Set<String>();
        set<String> pbSet = new Set<String>();
        set<Id> nullPBList = new Set<Id>();
        for(Lead l : newLeadList){
            if(l.PostalCode != null && l.PostalCode.length() > 3 ){
                if(l.Country == 'US' || l.Country == 'United States') {
                    pcSet.add(l.PostalCode.trim().left(5));
                } else if(l.Country == 'CA' || l.Country == 'Canada'){
                    String st1 = l.PostalCode.trim().substring(0,3).toUpperCase();
                    String st2 = l.PostalCode.trim().substring(3,l.PostalCode.length()).toUpperCase();
                    pcSet.add(st1.rightpad(4)+st2.trim());
                }
            }
            
            if(l.primary_business__c != null){
                pbSet.add(l.primary_business__c);
            }
            else{
                nullPBList.add(l.ownerid);
            }
        }
        
        if( nullPBList.size() > 0 ){
            List<user> pbList = [SELECT Primary_Business__c FROM user WHERE id IN: nullPBList];
            nullPBList.clear();
            for(user u : pbList){
                if(u.primary_business__c != null && u.primary_business__c == 'Safety-Kleen'){
                    pbSet.add(u.primary_business__c);
                    nullPBList.add(u.id);
                }
            }
        }
        
        Map<String,String> tmMapId = new Map<String,String>();
        
        if(pcSet.size() > 0){
            List<Territory_Master__c> tMasterList = [SELECT id,ZIP_Code__c,Territory_code__c,Sales_business_unit__C FROM Territory_Master__c 
                                                     where ZIP_Code__c in: pcSet AND Sales_business_unit__C in : pbSet];
            
            if(tMasterList.size() > 0){
                for(Territory_Master__c tmMap : tMasterList){
                    tmMapId.put(tmMap.ZIP_Code__c+tmMap.Sales_business_unit__C,tmMap.id);
                    
                }
                for(Lead l : newLeadList){
                    
                    if(l.postalcode != null && l.primary_business__c != null && l.PostalCode.length() > 3){
                        if(l.Country == 'US' || l.Country == 'United States') {
                            l.Territory_Master_Lookup__c = tmMapId.get(l.PostalCode.trim().left(5) +l.primary_business__c);
                        }
                        else if(l.Country == 'CA' || l.Country == 'Canada'){
                            String st1 = l.PostalCode.trim().substring(0,3).toUpperCase();
                            String st2 = l.PostalCode.trim().substring(3,l.PostalCode.length()).toUpperCase();
                            l.Territory_Master_Lookup__c = tmMapId.get(st1.rightpad(4)+st2.trim() +l.primary_business__c);
                        }
                    }
                    else if(l.postalcode != null && l.primary_business__c == null && nullPBList.contains(l.Ownerid)){
                        if(l.Country == 'US' || l.Country == 'United States') {
                            l.Territory_Master_Lookup__c = tmMapId.get(l.PostalCode.trim().left(5) +'Safety-Kleen');
                        }
                        else if(l.Country == 'CA' || l.Country == 'Canada'){
                            String st1 = l.PostalCode.trim().substring(0,3).toUpperCase();
                            String st2 = l.PostalCode.trim().substring(3,l.PostalCode.length()).toUpperCase();
                            l.Territory_Master_Lookup__c = tmMapId.get(st1.rightpad(4)+st2.trim() +'Safety-Kleen');
                        }
                        //l.Territory_Master_Lookup__c = tmMapId.get(l.postalcode+'Safety-Kleen');
                    }
                }
            }
        }
    }
    
    public static void updateExistingAccount(List<Lead> newLeadList){
        
        set<String> winSet = new Set<String>();
        for(Lead l : newLeadList){
            
            if(l.WIN_ID_reference__c != null){
                
                winSet.add(l.WIN_ID_reference__c);
                l.WIN_ID_reference__c = l.WIN_ID_reference__c.touppercase();
            }
            
        }
        Map<String,ID> accMap = new Map<String,ID>();
        if(winSet.size() > 0){
            List<Account> AccountList = [SELECT id,WIN_ID__c FROM Account where WIN_ID__c in: winSet];
            if(AccountList.size()>0 )   {
                for(Account acc : AccountList){
                    accMap.put(acc.WIN_ID__c,acc.id);
                    
                }
                
                for(Lead l : newLeadList){
                    if(l.WIN_ID_reference__c != null )
                        l.Existing_Account__c = accMap.get(l.WIN_ID_reference__c.toUpperCase());
                    
                    
                }
            }
        } 
    }
    public static void updateSICinfo(List<Lead> newLeadList){
        
        set<String> sicset = new Set<String>();
        for(Lead l : newLeadList){
            sicset.add(l.SIC__c);
        }
        
        if(sicset.size() > 0){
            Map<String,SIC_Codes__c> sicMapList = new Map<String,SIC_Codes__c>();
            List<SIC_Codes__c> sicList= [SELECT Class__c,SIC_Code__c, Vertical__c FROM SIC_Codes__c where SIC_Code__c in: sicset];
            for(SIC_Codes__c sc : sicList){
                sicMapList.put(sc.SIC_Code__c,sc);
            }
            if(sicMapList.size() > 0){
                for(Lead l : newLeadList){
                    if(l.SIC__c != null ){
                        if(sicMapList.ContainsKey(l.SIC__c)){
                            l.Industry_Segment__c = sicMapList.get(l.SIC__c).Vertical__c;
                            l.Class__c            = sicMapList.get(l.SIC__c).Class__c;
                        }
                    }
                }
            }          
        }
    }   

    public static void CLHWebLeadMapping (List<Lead> newLeadList,Boolean IsInsert){
        
        
        set<String> wsrSet = new Set<String>();
        for(Lead l : newLeadList){ 
            if(l.CLH_Website_Service_Requested__c != null ){    
                wsrSet.add(l.CLH_Website_Service_Requested__c);
            }
            if(wsrSet.size()>0 && !wsrSet.IsEmpty()){                                  
                List<CLH_Website_Lead_Mapping__c> CLHWebsiteLeadMappingList = [SELECT id,Name,CH_Queue_Id__c,SK_Queue_Id__c,CLH_Website_Lead_Recipient_1__c,CLH_Website_Lead_Recipient_2__c,CLH_Website_Send_Lead_to_Territory_Owner__c,CLH_Website_Service_Request__c,Primary_Business__c FROM CLH_Website_Lead_Mapping__c where CLH_Website_Service_Request__c in: wsrSet];
                for(CLH_Website_Lead_Mapping__c wlm: CLHWebsiteLeadMappingList)
                    for(lead ld : newLeadList){ 
                        String tempWsr;
                        if(ld.CLH_Website_Service_Requested__c != null && ld.CLH_Website_Service_Requested__c == wlm.CLH_Website_Service_Request__c ){    
                            tempWsr = ld.CLH_Website_Service_Requested__c;
                            Boolean assignedToQueue = false;
                            if(tempWsr != Null){
                                ld.Primary_Business__c = wlm.Primary_Business__c;
                                if(ld.Primary_Business__c != null && wlm.SK_Queue_Id__c != null){
                                    if(IsInsert==true){
                                        ld.OwnerId=wlm.SK_Queue_Id__c;
                                         ld.SK_Queue_Id__c=wlm.SK_Queue_Id__c;
                                        assignedToQueue = true;
                                        ld.Lead_Run_Assignment__c=true;
                                    } 
                                }
                                if(ld.Primary_Business__c != null && wlm.CH_Queue_Id__c != null){
                                    if(IsInsert==true){
                                        ld.OwnerId=wlm.CH_Queue_Id__c;
                                        ld.CH_Queue_Id__c=wlm.CH_Queue_Id__c;
                                        assignedToQueue = true;
                                        ld.Lead_Run_Assignment__c=true;
                                    }
                                }
                                System.debug('&^%%' +wlm.Primary_Business__c);
                                System.debug('*&^$' + ld.Primary_Business__c);
                                if((ld.Country == 'US' || ld.Country == 'United States') && wlm.CLH_Website_Lead_Recipient_1__c !=null){
                                    ld.CLH_Website_Lead_Recipient_1__c = wlm.CLH_Website_Lead_Recipient_1__c;
                                    if(IsInsert==true && !assignedToQueue){
                                    ld.OwnerId=wlm.CLH_Website_Lead_Recipient_1__c;
                                      //ld.CLH_Website_Lead_Recipient_1__c=wlm.CLH_Website_Lead_Recipient_1__c;
                                    ld.Lead_Run_Assignment__c=true;
                                }
                                }
                                else
                                if((ld.Country == 'CA' || ld.Country == 'Canada') && wlm.CLH_Website_Lead_Recipient_2__c !=null){
                                    ld.CLH_Website_Lead_Recipient_2__c = wlm.CLH_Website_Lead_Recipient_2__c;
                                    if(IsInsert==true && !assignedToQueue){
                                        ld.OwnerId=wlm.CLH_Website_Lead_Recipient_2__c;
                                       // ld.CLH_Website_Lead_Recipient_2__c=wlm.CLH_Website_Lead_Recipient_2__c;
                                        ld.Lead_Run_Assignment__c=true;
                                        
                                    }
                                }
                                else
                                if( wlm.CLH_Website_Lead_Recipient_1__c !=null){
                                ld.CLH_Website_Lead_Recipient_1__c = wlm.CLH_Website_Lead_Recipient_1__c;
                                    if(IsInsert==true && !assignedToQueue){
                                   ld.OwnerId=wlm.CLH_Website_Lead_Recipient_1__c;
                                      //ld.CLH_Website_Lead_Recipient_1__c=wlm.CLH_Website_Lead_Recipient_1__c;  
                                   ld.Lead_Run_Assignment__c=true;
                                }
                                }
                                ld.CLH_Website_Send_Lead_to_Territory_Owner__c = wlm.CLH_Website_Send_Lead_to_Territory_Owner__c;
                            }                      
                        }  
                    }
            }
        }
    }
    public static void UpdateCallCenterActivity (List<Lead> newLeadList) {
        
        try
        {
            List<Task> TList = New List<Task>();
            //List<Task> oppList = New List<Opportunity>();
            Id ldevRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Call Center Lead').getRecordTypeId();
            
            for(Lead l: newleadlist){            
                if(l.RecordTypeId == ldevRecordTypeId && l.Call_Center_Activity__c <> null){
                    Task T = new Task();
                    T.id = l.Call_Center_Activity__c ;
                    t.Call_Center_Lead__c = l.id;
                    TList.add(t);           
                }
            } 
            
            if(TList.size() > 0) {
                update TList;
            
            }
        }
        catch(Exception e)
        {
            system.debug('Exception while update activity -->'+e.getMessage());
        }
    }
    
        Public Static void UpdateLeadOwnerSalesBranch (List<Lead> newLeadList){
        
        set<string> OwnSet = new Set<String>();
        set<string> USet = new Set<String>();
        set<string> TerrSet = new Set<String>();
        
        for(Lead l : newLeadList){
            if(l.OwnerId != null){
                OwnSet.add(l.OwnerId);
            }
        }
        Map<id,string> userMap = new Map<id,string>();   
        List<User> UserList = [Select id, Sales_Branch__c, Territory__c  From User WHERE id in: OwnSet];
        for(User u : UserList){
            if(u.Sales_Branch__c != null){
                userMap.put(u.id,u.Sales_Branch__c);
                USet.add(u.Sales_Branch__c);
            } 
            if(u.Territory__c != null){               
                TerrSet.add(u.Territory__c);
            }
            
        }
        Id recTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Branch').getRecordTypeId();
        Map<string,id> branchCodeMap = new Map<string,id>(); 
        List<Account> branchAcc = [SELECT id,Branch_Code__c FROM Account WHERE recordtypeid =: recTypeId and Branch_Code__c in: uset];
        for(Account BAcc : branchAcc){
            branchCodeMap.put(BAcc.Branch_Code__c,BAcc.id);
        }
       system.debug('TerrSet---->'+TerrSet.size()+'::::'+TerrSet);
        Map<string,id> TerrCodeMap = new Map<string,id>();
        if(TerrSet.size() > 0){
            List<Territory__c> terrList = [SELECT ID,name FROM Territory__c where name IN: TerrSet];
            for(Territory__c ter : terrList){
                TerrCodeMap.put(ter.name,ter.id);
            }
        }
        
            for(Lead l : newLeadList){
            l.Lead_Owner_Sales_Branch__c = branchCodeMap.get(userMap.get(l.OwnerId));
            if(TerrCodeMap.containsKey(l.Owner_Territory__c)){
                l.Lead_Owner_Territory__c = TerrCodeMap.get(l.Owner_Territory__c);                            
            }    
        }
   
        }  
    

/******************* Not found any references so commented the method **************************/
/*
    public static void LeadConvert(List<Lead> newList, Map<Id, Lead> oldMap){
        
        List<Account> accList = new List<Account>();
        Id accountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId();
        
        for(Lead obj : newList){
            if(obj.IsConverted && !oldMap.get(obj.Id).IsConverted){
                
                Account acc = new Account(Id = obj.ConvertedAccountId, RecordTypeId = accountRecordTypeId, Type = 'Prospect Cust');
                accList.add(acc);
            }
        }
        
        if(!accList.isEmpty()){
            update accList;
        }
    } */  
}