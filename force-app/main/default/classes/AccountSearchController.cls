/**
 * @description       : 
 * @author            : Irfan Khan
 * @group             : 
 * @last modified on  : 01-12-2023
 * @last modified by  : Irfan Khan
**/
global class AccountSearchController { 
    public List<contact> contacts{get;set;} 
    public List<contact> relContactList{get;set;} 
    public List<Opportunity> relOpportunityList{get;set;}  
    public List<case> relCaseList{get;set;} 
    public List<Task> relTaskList{get;set;}  
    public List<Beacon_Call_Notes__c> relcallList{get;set;} 
    public List<Accounts_Receivable__c> accRecList{get;set;} 
    public List<AccountWrapper> accWrapLst{get;set;}
    public Account accounts {get;set;} 
    public Account accs {get;set;}
    public List<wrapper> taskactivityWrapperList{get;set;}
    public STring accId{get;set;}
    public integer count{get;set;}  
   
    public Account acct{get;set;}
    public String errorMessage {get;set;}
   public list<account> acc {get;set;}   
    public Account accRec {get;set;}
    public Boolean showDataTable {get;set;}
    public Boolean showDetail {get;set;}
    public Boolean showNextButton {get;set;}
    public Boolean showPrevButton {get;set;}
    public Id currAccId {get;set;}
    public Boolean hasNextAcc {get;set;}
    public Boolean hasPrevAcc {get;set;}
    public Id nextAccId {get;set;}
    public Id prevAccId {get;set;}
    public Map<Id, Integer> childAccountsCount{get;set;}
     private final Account account;
    
    public Decimal aggCustRevenue2021 {get;set;}
    public Decimal aggCustRevenuePreviousYear {get;set;}
    public Decimal aggCustRevenueCurrentYear {get;set;}
    public Decimal aggARtotal {get;set;}
    public Decimal aggARover {get; set;}
   
   public AccountSearchController(ApexPages.StandardController controller) {
       
       aggCustRevenue2021 = 0;
       aggCustRevenuePreviousYear = 0;
       aggCustRevenueCurrentYear = 0;
       aggARtotal = 0;
       aggARover = 0;
       accs = (account)controller.getRecord();
      // String accId = ApexPages.currentPage().getParameters().get('id');
        accRecList = new List<Accounts_Receivable__c>();
       accRec = new Account();
       accRec.Status__c = null;
       showDataTable = true;
       showDetail = false;
       hasNextAcc = false;
       hasPrevAcc = false;
       showNextButton = false;
       showPrevButton = false;
       childAccountsCount = new Map<Id,Integer>();
       relContactList = new List<Contact>();
         relOpportunityList = new List<Opportunity>();
         relCaseList = new List<Case>();
      relTaskList= new List<Task> ();
       relcallList=new List<Beacon_Call_Notes__c>(); 
       acct = new account();
       accId = '';
    
   }
    
    public String ownerId{get;set;}
    
    
   public void search(){
       showDataTable = true;
       showDetail = false;
       if(accRec.OwnerId == null){
           return;
       }
       
       Id ownerId = accRec.OwnerId;
       String status = '';
       String city = '';
       String state = '';
       
       String filters =  ' where Account.OwnerId = :ownerId and Type != \'ShipTo/Gen\'  and Status__c = \'Active\'';
       if(String.isNotBlank(accRec.Status__c)){
           status = accRec.Status__c;
           filters += ' and Status__c = :status';
       }
        
       if(String.isNotBlank(accRec.ShippingCity)){
           city = accRec.ShippingCity;
           filters += ' and ShippingCity = :city';
       }
       
       if(String.isNotBlank(accRec.ShippingState)){
           state = accRec.ShippingState;
           filters += ' and ShippingState = :state';
       }
       
       string searchquery='select name,id,WIN_ID__c, Status__c, Previous_Year_Customer_Revenue__c,Current_Year_Customer_Revenue__c, ShippingCity, AR_91_120__c,ShippingState, Type, fax,phone,AR_Total_Due__c,City__c, RecordType.DeveloperName,y2023_Customer_Revenue__c from account'+ filters+' and Type IN(\'Customer\',\'Prospect cust\') limit 1000';  
       acc= Database.query(searchquery);
       Set<Id> custAccSet = new Set<Id>();
       String searchQueryforAgg = 'select SUM(Previous_Year_Customer_Revenue__c) tocustomer2, SUM(Current_Year_Customer_Revenue__c) tocustomer3, SUM(AR_Total_Due__c) toar, SUM(AR_91_180_Days__c) toArover from account'+ filters+' and Type IN(\'Customer\',\'Prospect cust\')  ';  
      System.debug('searchQueryforAgg  : ' + searchQueryforAgg);
       AggregateResult[] results = Database.query(searchQueryforAgg);
       for (AggregateResult ar : results)  {
      
           
           aggCustRevenuePreviousYear = (Decimal)ar.get('tocustomer2');
           aggCustRevenueCurrentYear = (Decimal)ar.get('tocustomer3');
           aggARtotal = (Decimal)ar.get('toar');
           aggARover= (Decimal)ar.get('toArover');
      }  
       
       Map<Id, Beacon_Call_Notes__c> mostRecentCallNotes = new Map<Id, Beacon_Call_Notes__c>();
       for(Beacon_Call_Notes__c callNoteRec : [
           SELECT Id, CreatedDate, Account__c 
           FROM Beacon_Call_Notes__c 
           WHERE Account__c IN :acc
           AND RecordType.DeveloperName = 'Call_Note'
       ]){ 
           if(mostRecentCallNotes.containsKey(callNoteRec.Account__c) && mostRecentCallNotes.get(callNoteRec.Account__c).CreatedDate < callNoteRec.CreatedDate){
               mostRecentCallNotes.put(callNoteRec.Account__c, callNoteRec);
           }else if(!mostRecentCallNotes.containsKey(callNoteRec.Account__c)){
               mostRecentCallNotes.put(callNoteRec.Account__c, callNoteRec);
           }    
       }
       
       Map<Id, Task> mostRecentTask = new Map<Id, Task>();
       for(Task taskRec : [
           SELECT Id, CreatedDate, WhatId 
           FROM Task 
           WHERE WhatId IN :acc
       ]){ 
           if(mostRecentTask.containsKey(taskRec.WhatId) && mostRecentTask.get(taskRec.WhatId).CreatedDate < taskRec.CreatedDate){
               mostRecentTask.put(taskRec.WhatId, taskRec);
           }else if(!mostRecentTask.containsKey(taskRec.WhatId)){
               mostRecentTask.put(taskRec.WhatId, taskRec);
           }    
       }
       
       Map<Id, Event> mostRecentEvent = new Map<Id, Event>();
       for(Event eventRec : [
           SELECT Id, CreatedDate, WhatId 
           FROM Event 
           WHERE WhatId IN :acc
       ]){ 
           if(mostRecentEvent.containsKey(eventRec.WhatId) && mostRecentEvent.get(eventRec.WhatId).CreatedDate < eventRec.CreatedDate){
               mostRecentEvent.put(eventRec.WhatId, eventRec);
           }else if(!mostRecentEvent.containsKey(eventRec.WhatId)){
               mostRecentEvent.put(eventRec.WhatId, eventRec);
           }    
       }
       
       Set<Id> relatedAccountIds = new Set<Id>();
       for(Id accId : mostRecentTask.keySet()){
           relatedAccountIds.add(accId);
       }
       
       for(Id accId : mostRecentEvent.keySet()){
           relatedAccountIds.add(accId);
       }
       
       
       
       Map<Id, Date> mostRecentActivity = new Map<Id, Date>();
       for(Id accountRecId : relatedAccountIds){
           Date recentDate;
           
           if(mostRecentTask.containsKey(accountRecId) && mostRecentEvent.containsKey(accountRecId)){
               recentDate = mostRecentTask.get(accountRecId).CreatedDate > mostRecentEvent.get(accountRecId).CreatedDate
                   ? mostRecentTask.get(accountRecId).CreatedDate.date() : mostRecentEvent.get(accountRecId).CreatedDate.date();                       
           }else if(mostRecentTask.containsKey(accountRecId) && !mostRecentEvent.containsKey(accountRecId)){
               recentDate = mostRecentTask.get(accountRecId).CreatedDate.date();
           }else if(!mostRecentTask.containsKey(accountRecId) && mostRecentEvent.containsKey(accountRecId)){
               recentDate = mostRecentEvent.get(accountRecId).CreatedDate.date();
           }
           
           if(recentDate != NULL){
               if(mostRecentActivity.containsKey(accountRecId)){
                   mostRecentActivity.put(accountRecId, recentDate);
               }else{
                   mostRecentActivity.put(accountRecId, recentDate);
               }
           }
       }
       
       accWrapLst = new List<AccountWrapper>();
       for(Account a1 : acc){
           AccountWrapper accWrap = new AccountWrapper();
           accWrap.accountRec = a1;
           if(mostRecentCallNotes.containsKey(a1.Id))
            accWrap.callNoteRec = mostRecentCallNotes.get(a1.Id);
           if(mostRecentActivity.containsKey(a1.Id))
               accWrap.recentDate = mostRecentActivity.get(a1.Id);
           accWrapLst.add(accWrap);
           childAccountsCount.put(a1.Id, 0);
           if(a1.RecordType.DeveloperName == 'Customer' || a1.recordType.DeveloperName=='Prospect'){
               custAccSet.add(a1.Id);
           }
       }
       
       if(custAccSet.isEmpty()){
           return;
       }
       
       for(Account a2 : [select name,id,ParentId,WIN_ID__c, Status__c, Type, fax,phone,AR_Total_Due__c,City__c,ShippingAddress,ShippingCity,
                 ShippingCountry,ShippingPostalCode,ShippingState,ShippingStreet,Account_ID_18__c, RecordType.DeveloperName from account where ParentId = :custAccSet and Type IN ('Prospect Gen','ShipTo/Gen') and Status__c='Active'  order by Name asc limit 1000])
       
       {
          
           Integer accCount = childAccountsCount.get(a2.ParentId);
           accCount += 1;
           childAccountsCount.put(a2.ParentId, accCount);
       }//end for - child accounts
   }
    
   public void clear(){  
       acc.clear();
       accRec = new Account();
   }  
    
    public void showDetail(){
        System.debug('showDetail');
        
        showDataTable = false;
        showDetail = true;
        acct = [SELECT Name, Industry,OwnerId,Owner.name,Primary_Business__c,AR_Total__c,Type,Parent.Name,Missing_Contact_Type__c,Account_ID_18__c,
                ShippingAddress,ShippingCity,ShippingCountry,ShippingPostalCode,ShippingState,ShippingStreet,ADP__c,Credit_Terms__c,Credit_Status__c,recordType.Name,WIN_ID__c FROM Account WHERE id=:currAccId LIMIT 1];
        accRecList = [Select Id, Name, AR_Current__c, AR_1_30__c, AR_31_60__c, AR_61_90__c, AR_91_180__c, AR_181_365__c, AR_Over_365__c,AR_Total__c,Win_Id__c from Accounts_Receivable__c where Account__c =: currAccId];
        relContactList = [SELECT Id,Name,FirstName,LastName,Email,Contact_Type__c,title,Phone FROM contact WHERE AccountId=:currAccId  and Expired__c=false AND Contact_Type__c includes ('MAIN','AP','PO','MANI')];
        relopportunityList = [SELECT Id,Name,CloseDate,StageName,Amount,OwnerId,Owner.name FROM Opportunity WHERE AccountId=:currAccId  Order by closedate desc LIMIT 5];
         relcaseList = [SELECT Id,CaseNumber,Recordtype.Name,CreatedDate,Owner.Name,OwnerId,Subject,Status,ClosedDate FROM Case WHERE AccountId=:currAccId   LIMIT 5];
        relTaskList = [SELECT Id, Subject FROM Task WHERE WhatId=:currAccId Order by CreatedDate desc LIMIT 5];
        taskactivityWrapperList = getdataforWrapper(currAccId); 
        relcallList = [SELECT Id,Name,Call_Note__c,Color__c,Type__c,Services_Discussed__c,Assigned_To__c,Update_Date__c,Update_By__c,LastModifiedBy.Name,LastModifiedById,LastModifiedDate,Work_Note_Last_Modified_Date__c,Description__c  FROM Beacon_Call_Notes__c WHERE Account__c=:currAccId AND RecordType.DeveloperName = 'Call_Note'];
        System.debug('accRecList : ' + accRecList);
        if(hasNextAcc){
            System.debug('hasNextAcc');
            showNextButton = true;
        }
        else{
            showNextButton = false;
        }
        if(hasPrevAcc){
            System.debug('hasPrevAcc');
            showPrevButton = true;
        }
        else{
            showPrevButton = false;
        }
    }
    
    public void nextAccount(){
        System.debug('currAccId:'+currAccId);
        currAccId = nextAccId;
        if(!test.isRunningTest())
        {
         acct = [SELECT Name, Industry,OwnerId,Owner.name,Primary_Business__c,AR_Total__c,Type,Parent.Name,Missing_Contact_Type__c,ShippingAddress,ShippingCity,
                 ShippingCountry,ShippingPostalCode,ShippingState,ShippingStreet,recordType.Name,WIN_ID__c,Account_ID_18__c FROM Account WHERE id=:currAccId LIMIT 1];
        }
        else
        {
              acct = [SELECT Name, Industry,OwnerId,Owner.name,Primary_Business__c,AR_Total__c,Type,Parent.Name,Missing_Contact_Type__c,ShippingAddress,ShippingCity,
                 ShippingCountry,ShippingPostalCode,ShippingState,ShippingStreet,recordType.Name,WIN_ID__c,Account_ID_18__c FROM Account LIMIT 1];
        }
         relContactList = [SELECT Id,Name,FirstName,LastName,Email,Contact_Type__c,title,Phone FROM contact WHERE AccountId=:currAccId  and Expired__c=false AND Contact_Type__c includes ('MAIN','AP','PO','MANI')];
        relopportunityList = [SELECT Id,Name,CloseDate,StageName,Amount,Ownerid,Owner.name FROM Opportunity WHERE AccountId=:currAccId  Order by closedate desc LIMIT 5];
         relcaseList = [SELECT Id,CaseNumber,Recordtype.Name,CreatedDate,Owner.Name,OwnerId,Subject,Status,ClosedDate FROM Case WHERE AccountId=:currAccId   LIMIT 5];
        taskactivityWrapperList = getdataforWrapper(currAccId); 
        relTaskList = [SELECT Id, Subject FROM Task WHERE WhatId=:currAccId  Order by CreatedDate desc LIMIT 5];
        relcallList = [SELECT Id,Name,Call_Note__c,Color__c,Type__c,Services_Discussed__c,Assigned_To__c,Update_Date__c,Update_By__c,LastModifiedBy.Name,LastModifiedById,LastModifiedDate,Work_Note_Last_Modified_Date__c,Description__c  FROM Beacon_Call_Notes__c WHERE Account__c=:currAccId AND RecordType.DeveloperName = 'Call_Note'];
    }
    public Account getAccount() {
        return account;
    }
 
    public PageReference save() {
        try{
        update account;
        }
        catch(exception e)
        {
            System.debug('Something went wrong' +e.getLineNumber());
        }
        return null;
    }
    
    @RemoteAction
    global static List<Account> getChildAccounts(Id parentAccId){
         return [select Name,Id,ParentId,WIN_ID__c, Status__c, Type, fax,phone,AR_Total_Due__c,City__c,ShippingAddress,ShippingCity,
                 ShippingCountry,ShippingPostalCode,ShippingState,ShippingStreet, RecordType.DeveloperName from account where ParentId = :parentAccId and Type IN ('Prospect Gen','ShipTo/Gen') and Status__c='Active'  order by Name asc limit 1000];
    }  
    public class wrapper{
       public String Idstring{get;set;}
        public string owners{get; set;}
       
      public  String SubjectString{get;set;}
        public string  Eventtype{get;set;}
        public string CallTypes{get;set;}
        public string teName{get; set;}
        public String Relatedto{get;set;}
        public String Assignedto{get;set;}
        public Datetime TEdate{get;set;}
       
    }
    public static List<Wrapper> getdataforWrapper(String currAccId)
    {
        List<Wrapper> wrList = new List<Wrapper>();
        
         for(Task t: [SELECT Id, Subject,WhoId,who.Name,CallType,WhatId,What.Name,OwnerId,Owner.Name,CreatedDate FROM Task WHERE WhatId=:currAccId  Order by CreatedDate desc LIMIT 5])
         {
             wrapper w = new wrapper();
             w.IdSTring =t.Id;
             w.SubjectString = t.Subject;
             w.CallTypes=t.CallType;
            w.teName=t.Who.Name;
             w.Relatedto=t.What.Name;
             w.Assignedto=t.Owner.Name;
             w.owners=t.owner.id;
             w.TEdate=t.CreatedDate;
             wrList.add(w);
    
         }
        for(Event t: [SELECT Id, Subject,Event_Type__c,WhoId,Who.Name,WhatId,What.Name,CreatedDate,OwnerId,Owner.Name FROM Event WHERE WhatId=:currAccId  Order by CreatedDate desc LIMIT 5])
         {
             wrapper w = new wrapper();
             w.IdSTring =t.Id;
             w.SubjectString = t.Subject;
              w.Eventtype=t.Event_Type__c;
             w.teName=t.Who.Name;
             w.Relatedto=t.what.Name;
              w.Assignedto=t.Owner.Name;
             w.TEdate=t.CreatedDate;
             w.owners=t.owner.id;
             wrList.add(w); 
         }
        
        return wrList; 
         
    } 
    public void deletedata() {
      Beacon_Call_Notes__c bcall = new Beacon_Call_Notes__c();
           System.debug('accId' + accId);
        bcall.Id = accId;
     nextAccId=  currAccId  ;
        delete bcall;
        nextAccount();
    }
    public void deletecontact() {
      contact cont = new contact();
           System.debug('accId' + accId);
        cont.Id = accId;
     nextAccId=  currAccId  ;
        delete cont;
        nextAccount();
    } 
     public void deleteopp() { 
      opportunity oppt = new opportunity(); 
           System.debug('accId' + accId);
        oppt.Id = accId;
     nextAccId=  currAccId  ;
        delete oppt;
        nextAccount();
    }
    public void deletecase() {
      case cse = new Case();
           System.debug('accId' + accId);
        cse.Id = accId;
     nextAccId=  currAccId  ; 
        delete cse;
        nextAccount();
    }
     public void delettask() {
          try{
             task tsk = new task(); 
             tsk.Id = accId;
             nextAccId=  currAccId  ;
             delete tsk;
              nextAccount();
         }
          catch(exception e)
        {
             event evt=new event(); 
             evt.id=accId;
              nextAccId=  currAccId  ;
              delete evt;
        nextAccount();
        }       
       
    }
    
    public class AccountWrapper{
        public Account accountRec{get;set;}
        public Date recentDate{get;set;}
        public Beacon_Call_Notes__c callNoteRec{get;set;}
    }
}