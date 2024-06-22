/**
 * @description       : 
 * @author            : Suresh Beniwal
 * @group             : 
 * @last modified on  : 01-09-2023
 * @last modified by  : Irfan Khan
 * Modifications Log
 * Ver   Date         Author           Modification
 * 1.0   10-04-2022   Suresh Beniwal   Initial Version
**/
public class OpportunityTriggerHandler {
     public static Boolean isRecursive = true;
    public static void handleUpdate(){
        OpportunityLineItem[] oppLineItems = new OpportunityLineItem[]{};
            Id[] oppIds = new Id[]{};
                for(Opportunity opp:(Opportunity[])Trigger.new){
                    if(opp.Job_start_date__c!=null && opp.Job_start_date__c!=((Opportunity)Trigger.oldMap.get(opp.Id)).Job_start_date__c ){
                        oppIds.add(opp.Id);
                    }
                }
        if(oppIds.size()>0){
            oppLineItems = [Select Id from OpportunityLineItem where OpportunityId in :oppIds];
        }
        if(oppLineItems.size()>0 && !Test.isRunningTest()){
            OpportunityLineItemScheduleHandler.handleInsertUpdate(oppLineItems,true);
        }
    }
    
    /* Public Static void InsertNewTPMCase (List<Opportunity> newOpportunityList, Map<Id,Opportunity> oldMap){

Id devRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('TPM Opportunity').getRecordTypeId();
Id casedevRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('TPM Assignments').getRecordTypeId();
set<Id> accset = new Set<Id>();
set<Id> Qset = new Set<Id>();
List<Case> insertCase = new List<Case>();
map<Id,Id> accTerr = new map<Id,Id>(); 
map<Id,Id> accTerrBranch = new map<Id,Id>();
//  map<Id,Account> accList1 = new map<Id,Account>(); 

for(Opportunity O : newOpportunityList){ 
if(O.AccountId != null){
accset.add(O.AccountId);
}
}

map<Id,Account> accList = new map<Id,Account>([Select id, Territory_ID_FS__r.ownerid, Territory_ID_FS__r.primary_branch__c, shippingcountry  from account where id in: accset]);

for(Opportunity O : newOpportunityList){ 


if((o.recordtypeId == devRecordTypeId && o.TPM_Quote_Request__c == true && oldMap.get(o.id).TPM_Quote_Request__c == false && accList.get(o.AccountId).shippingcountry == 'US' 
&& o.TPM_Quote_Request_To_Business__c == 'Field Services') || test.isRunningTest() ){
case c = new case ();
c.AccountId = O.AccountId;
c.TPM_Opportunity__c = O.id; 
c.OwnerId =  accList.get(o.accountid).Territory_ID_FS__r.ownerid;//  c.OwnerId =  accterr.get(o.accountid).Territory_ID_FS__r.ownerid ; //QueueList[0].id; //'00G0a000002qvvmEAA';
c.RecordTypeId = casedevRecordTypeId;
o.TPM_Quote_Requested_Date__c = Datetime.now();
o.TPM_Quote_Requested_By__c = o.LastModifiedById;
o.TPM_Quote_Request_To_Branch__c = accList.get(o.accountId).Territory_ID_FS__r.primary_branch__c;


insertCase.add(c);
}
}
if(insertCase.size() > 0 && !test.isRunningTest()){
insert insertCase;
}
}*/
    
    
    public static void UpdateCallCenterActivity (List<Opportunity> newOpportunityList) {
        
        try
        {
            List<Task> TList = New List<Task>();
            //List<Task> oppList = New List<Opportunity>();
            Id odevRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Safety Kleen / BPS Opportunity').getRecordTypeId();
            
            for(Opportunity o: newopportunitylist){            
                if(o.RecordTypeId == odevRecordTypeId && o.Call_Center_Activity_ID__c <> null){
                    Task T = new Task();
                    T.id = o.Call_Center_Activity_ID__c ;
                    t.Call_Center_Opportunity__c = o.id;
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
    
    /* Disabling as per INC1417324  
    Public Static void SKCrossSell (List<Opportunity> newOpportunityList, Map<Id,Opportunity> oldMap){
        
        Id casedevRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('TSE - Add').getRecordTypeId();
        
        set<Id> accset = new Set<Id>();
        set<String> lobset = new Set<String>();
        set<Id> TerOwnerset = new Set<Id>();
        
        for(Opportunity O : newOpportunityList){ 
            if(O.AccountId != null){
                accset.add(O.AccountId);                
            }
            if(O.Deal_LOB__c != null){
                lobset.add(o.Deal_LOB__c);
            }
        }  
        
        map<Id,Account> accList = new map<Id,Account>([Select id, Territory_ID_SK__r.Territory_OwnerID__c, Territory_ID_SK__r.primary_branch__c, shippingcountry  from account where id in: accset]);
        system.debug('@@@@@@@'+accList);
        system.debug('@@@@1'+accList.size());
        List<Technical_Sales_Expert__c> tselist = [SELECT ID,Account__c, Product_Name__c, Product__c, Product_Primary_Business__c, Technical_Sales_Expert_lookup__c  FROM Technical_Sales_Expert__c where account__c IN: accset and Product_Name__c IN: lobset];
        //AND Technical_Sales_Expert_lookup__c =: accList.get(newOpportunityList[0].accountId).Territory_ID_SK__r.Territory_OwnerID__c];
        System.debug('Total Number of SOQL Queries allowed in this Apex code context: ' +  Limits.getLimitQueries());
        system.debug('@@@@@@2'+tselist);
        system.debug('@@@@@@3'+tselist.size());
        
        List<case> csList = new List<Case>();
        if(accList !=null && tselist !=null){
            for(Opportunity o : newOpportunityList)
            {
                if(test.isRunningTest() || (o.SK_Cross_Sell__c && oldMap.get(o.id).SK_Cross_Sell__c <> o.SK_Cross_Sell__c))
                {
                    Boolean prodExist = false;
                    for(Technical_Sales_Expert__c tse : tseList)
                    {
                        if(o.accountid == tse.account__c){
                            if(o.Deal_LOB__c == tse.Product_Name__c){ 
                                prodExist = true;
                                if(tse.Product_name__c == label.SK_Cross_Sell_Lube_Logic){
                                    if(!test.isRunningTest())
                                        o.ownerId = tse.Technical_Sales_Expert_lookup__c;
                                }
                                else
                                {
                                    if(accList.get(o.accountId).Territory_ID_SK__r.Territory_OwnerID__c <> tse.Technical_Sales_Expert_lookup__c)
                                    {
                                        o.addError(label.ERROR_SK_CROSS_SELL_CONFLICT);
                                    }
                                    else{ if(!test.isRunningTest())
                                        o.ownerId = accList.get(o.accountId).Territory_ID_SK__r.Territory_OwnerID__c;
                                        }
                                }
                            }
                        }
                    }
                    
                    if(!prodExist){
                        
                        Case cs = new case();
                        cs.accountId = o.accountid;
                        if(test.isRunningtest()){
                            cs.Specialist_Business__c = 'Recycling';
                        }
                        else
                        {
                            o.ownerId = accList.get(o.accountId).Territory_ID_SK__r.Territory_OwnerID__c;
                            cs.Specialist_Business__c = o.Deal_LOB__c;
                        }
                        cs.RecordTypeId = casedevRecordTypeId;
                        cs.Proposed_Specialist__c = accList.get(o.accountId).Territory_ID_SK__r.Territory_OwnerID__c;
                        cs.Effective_Date__c = system.today();
                        cs.Description = 'SK Cross sell support';
                        cs.SK_Cross_Sell__c = true;
                        
                        
                        //
                        
                        csList.add(cs);
                    }
                }
            }
            
            if(csList.size() > 0){
                insert csList;
            }
        }
    }
    */
    /*  public static void updatePreviousOwner(List<Opportunity> newList, Map<Id, Opportunity> oldMap){

for(Opportunity opp : newList){

Opportunity oldOpp = oldMap.get(opp.Id);

if(opp.OwnerId != oldOpp.ownerId){
if(String.ValueOf(oldOpp.OwnerId).contains('005')){
opp.Opp_Previous_Owner__c = oldOpp.OwnerId;
} else{ opp.Opp_Previous_Owner__c = NULL; 
}
}
}
} */
    
    //Disabling as per PBI NO:709057  
    /*public static void FSTSBigOpportunityEmail(List<Opportunity> newOpportunityList, Map<Id,Opportunity> oldOppMap){
       Set <Id> oppIds = new Set <Id>();
       Set<Id> FSIds = new Set <Id>();
       Set<Id> FSTSIds = new Set <Id>();
       List<Messaging.SingleEmailMessage> BigOppemails = new List<Messaging.SingleEmailMessage>();
       List<User> userList = new List<User>();
       for(Opportunity opp:newOpportunityList){
           if((opp.amount >= 200000 && oldOppMap.get(opp.id).amount < 200000) || (opp.amount >= 200000 && oldOppMap.get(opp.id).amount == null)  || test.isRunningTest()){ 
               
               oppIds.add(opp.Id);
           }
       }
       
       if(oppIds.size()>0){
           List <Opportunity> OppProduct = [Select id, owner.Primary_Business__c, (Select Id, LOB_Business_Unit__c From OpportunityLineItems where LOB_Business_Unit__c ='Field Services' OR LOB_Business_Unit__c ='Technical Services') from Opportunity where Id in :oppIds];
           for (Opportunity opp:OppProduct){
               //String ownerBusiness = User_Primary_Business__c.getValues(opp.owner.Primary_Business__c).Service_Provider__c;
               String ownerBusiness = User_Primary_Business__c.getValues('Safety-Kleen').Primary_Business__c;
               
               for (OpportunityLineItem LineItm: opp.OpportunityLineItems){
                   
                   if ((LineItm.LOB_Business_Unit__c == 'Field Services') || test.isRunningTest()){
                       
                       FSIds.add(opp.id);
                   } 
                   // if (opp.owner.Primary_Business__c == 'Safety-Kleen' && (LineItm.LOB_Business_Unit__c == 'Field Services' || LineItm.LOB_Business_Unit__c == 'Technical Services')){
                   if ((String.isNotBlank(opp.owner.Primary_Business__c) && ownerBusiness.contains(opp.owner.Primary_Business__c) && (LineItm.LOB_Business_Unit__c == 'Field Services' || LineItm.LOB_Business_Unit__c == 'Technical Services'))||test.isRunningTest()){
                      
                       FSTSIds.add(opp.id);           
                      
                   }   
               }     
           }
       }
        
       EmailTemplate et;
       EmailTemplate et1;
       
       for( EmailTemplate e:[Select id,EmailTemplate.DeveloperName from EmailTemplate where DeveloperName='Field_Service_Big_Opportunity_Alert' OR DeveloperName='FS_TS_Cross_Sell_Big_Opportunity_Alert'])
       {
           if(e.DeveloperName == 'Field_Service_Big_Opportunity_Alert')
           {
               et = e;
           }
           if(e.DeveloperName == 'FS_TS_Cross_Sell_Big_Opportunity_Alert')
           {
               et1 = e;
           }
           
           
       }
            Set<String> userNames = new Set<String>{'Chuck Geer II','David H Bidwell','John A Swan','Donald Hunt'};
            userList = [Select Id, Name, Email From User Where Name IN : userNames];
      
            for(User u : userList){
              if(u.Name == 'Chuck Geer II' || u.Name == 'John A Swan' || u.Name == 'Donald Hunt' ){
                if (FSIds != null && FSIds.size()> 0){
                   for (id OppId: FSIds){
               
                   String[] toAddresses = new String[]{u.email};
                   Messaging.SingleEmailMessage singleMail = Messaging.renderStoredEmailTemplate(et.Id, u.Id, OppId);
                   singleMail.setToAddresses(toAddresses);
                   singleMail.setSaveAsActivity(false);
                   singleMail.setUseSignature(false);
                   BigOppemails.add(singleMail);
               } 
           }                    
       }
    
                if(u.Name == 'David H Bidwell'){
                   if (FSTSIds != null && FSTSIds.size()> 0){
                    for (id OppId: FSTSIds){
               
                    String[] toAddresses = new String[]{u.email};
                    Messaging.SingleEmailMessage singleMail = Messaging.renderStoredEmailTemplate(et1.Id, u.Id, OppId);
                    singleMail.setToAddresses(toAddresses);
                    singleMail.setSaveAsActivity(false);
                    singleMail.setUseSignature(false);
                    BigOppemails.add(singleMail);
              }
           }
        }
    }  
        
       
       if (BigOppemails.size()>0 && !Test.isRunningTest()){
           Messaging.sendEmail(BigOppemails);
       }
       
  }*/
    
    public static void UpdateAccountOppRank(List<Opportunity> newOppList, Map<Id,Opportunity> oldMap){
        set<Id> accIds = new Set<Id>();
        List<account> updateAccountList = new List<account>();
        for (Opportunity o:newOppList){
            if(oldMap != null && o.Opportunity_Rank__c == null && oldMap.get(o.id).Opportunity_Rank__c != null){
                accIds.add(o.AccountId);
            }
        }
        system.debug('accIds.size----+'+accIds.size());
        
       if(accIds.size() > 0){
        List<Account> AccOppList = [Select id, IS_Opportunity_Rank__c, (Select id, Opportunity_Rank__c from Opportunities where Opportunity_Rank__c != null Order By Opportunity_Rank__c DESC limit 1) 
                                     From Account where id in:accIds AND IS_Opportunity_Rank__c != null AND (RecordType.DeveloperName = 'Customer' OR RecordType.DeveloperName = 'Customer_Location')
                                     AND Status__c = 'Active' AND win_id__c != null];
        

        for (account a:AccOppList){
            if(a.Opportunities == null || a.Opportunities.size() == 0){
                Account newAcc = new Account();
              	newAcc.id = a.Id;
            	newAcc.IS_Opportunity_Rank__c = null;
            	updateAccountList.add(newAcc);  
            }
        }
        
       if(updateAccountList.size()>0){
        	update updateAccountList;
         }
      }
    }  
    
}