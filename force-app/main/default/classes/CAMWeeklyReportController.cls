public class CAMWeeklyReportController {
   List<Account> corpAcc = new List<Account>();
    set<id> corpAccId = new set<id>();
    public Opportunity dateFrom {get;set;}
    public Opportunity dateTo {get;set;}
    Public List<Sales_Manager_Summary_Note__c>SNList= new List<Sales_Manager_Summary_Note__c>();
    List<Sales_Manager_Summary_Note__c>UpdateSNList= new List<Sales_Manager_Summary_Note__c>();
    map<id,List <Sales_Manager_Summary_Note__c>> AccSNMap = new map<id,List <Sales_Manager_Summary_Note__c>>();
    Public List<Opportunity> WonOppList = new List<Opportunity>();
    Public List<Opportunity> LostOppList = new List<Opportunity>();
    DateTime createdFromDate;
    DateTime createdToDate;
    Time createdFromTime = Time.newInstance(0,0,0,0);
    Time createdToTime = Time.newInstance(23,59,59,0);
    String urlCurrentPg;
    Id loginUserRoleId;
    Set<Id> allSubRoleIds;
    public CAMWeeklyReportController(ApexPages.StandardSetController stdcontr){
        dateFrom = new Opportunity();
        dateTo = new Opportunity();
        String dayToday = System.now().format('EEEE');
        if(dayToday == 'Sunday'){
           dateFrom.CloseDate = Date.Today().toStartOfWeek()-6;
        } else{
            dateFrom.CloseDate = Date.Today().toStartOfWeek().addDays(1);
        } 

        dateTo.CloseDate = dateFrom.CloseDate.addDays(6);
        
        createdFromDate = dateTime.newInstance(dateFrom.CloseDate, createdFromTime);
        createdToDate = dateTime.newInstance(dateTo.CloseDate, createdToTime);

        urlCurrentPg = ApexPages.currentPage().geturl();
        if(urlCurrentPg.contains('CAMWeeklyReport')){
        corpAcc = [Select id,name,Corp_Budget_Q1__c,Corp_Budget_Q2__c,Corp_Budget_Q3__c,Corp_Budget_Q4__c, (Select id,Account__c, Note__c,Issues_Obstacles__c,Forecast__c,Variance__c, Budget__c from Corporate_Account_Report_Note__r where Type__c = 'Sales Summary' AND CreatedDate >= :createdFromDate AND CreatedDate <= :createdToDate) 
                   from Account where RecordType.DeveloperName = 'Corporate' And ownerId =:UserInfo.getUserId() ORDER By Name];
        }else if (urlCurrentPg.contains('ViewMyCAMTeamWeeklyReport')){
            loginUserRoleId = UserInfo.getUserRoleId();
             //Get all of the roles below the user
            allSubRoleIds = getAllSubRoleIds(New Set<ID>{loginUserRoleId});
            allSubRoleIds.add(loginUserRoleId);
        }
    }
    
    //Get all Parent Roles.
    private static Set<ID> getAllSubRoleIds(Set<ID> loginUserRoleId) {
         
        Set<ID> subRoleIds = new Set<ID>();
         
        //Get all of the roles below the passed roles
        for(UserRole userRole :[SELECT Id from UserRole Where ParentRoleId In:loginUserRoleId AND ParentRoleID != null]){
            subRoleIds.add(userRole.Id);
        }
         
        //Fetch more rolls
        if(subRoleIds.size() > 0){
            subRoleIds.addAll(getAllSubRoleIds(subRoleIds));
        }     
        return subRoleIds;   
    }
    
    public void EndDate(){
        dateTo.CloseDate = dateFrom.CloseDate.addDays(6);
    }
   
    public List<Sales_Manager_Summary_Note__c> getSummaryNotes(){
        if(System.now() >= createdFromDate && System.now() <= createdToDate && SNList.size() == 0 && urlCurrentPg.contains('CAMWeeklyReport')){
            for(Account acc:corpAcc){
                List<Sales_Manager_Summary_Note__c> SNMapList = new List<Sales_Manager_Summary_Note__c>();
                if (acc.Corporate_Account_Report_Note__r.size() > 0){
                    SNList.addAll(acc.Corporate_Account_Report_Note__r);
                    for (Sales_Manager_Summary_Note__c SNMap:acc.Corporate_Account_Report_Note__r){
                        SNMapList.add(SNMap.clone(true,true,false,false));
                    }
                    AccSNMap.put(acc.id,SNMapList);
                }else{
                    Integer Month = Date.Today().Month();
                    Decimal Budget;
                    switch on Month {
                        when 1, 2, 3 {
                            Budget = acc.Corp_Budget_Q1__c;
                        }
                        when 4, 5, 6 {
                            Budget = acc.Corp_Budget_Q2__c;
                        }
                        when 7,8,9 {
                            Budget = acc.Corp_Budget_Q3__c;
                        }
                        when 10,11,12 {
                            Budget = acc.Corp_Budget_Q4__c;
                        }
                    }     
                    Sales_Manager_Summary_Note__c SN = new Sales_Manager_Summary_Note__c(Budget__c = Budget, Account__c = acc.id);
                    SNList.add(SN);
                    SNMapList.add(SN.clone(true,true,false,false));
                    AccSNMap.put(acc.id,SNMapList);
                }
                corpAccId.add(acc.id);               
            }
        }else if (System.now() >= createdFromDate && System.now() <= createdToDate && SNList.size() == 0 && urlCurrentPg.contains('ViewMyCAMTeamWeeklyReport')){
           SNList = [Select id, Account__c, Account__r.owner.name, Note__c,Issues_Obstacles__c,Forecast__c,Variance__c,Budget__c From Sales_Manager_Summary_Note__c 
                     where (Account__r.RecordType.DeveloperName = 'Corporate' And Account__r.owner.UserRoleId In:allSubRoleIds AND 
                     Type__c = 'Sales Summary' AND CreatedDate >= :createdFromDate AND CreatedDate <= :createdToDate) ORDER By Account__r.name];
            
        }
        return SNList;     
    }
    
    
    public List<Opportunity> getWonOpportunities(){
        if(WonOppList.size() == 0 && urlCurrentPg.contains('CAMWeeklyReport')){
            WonOppList = [Select Id, name,Account.name, Account.WIN_ID__c,Amount,CloseDate From Opportunity where (Key_Account__c in :corpAccId And StageName Like '%Won%' AND CloseDate >= :dateFrom.CloseDate AND CloseDate <= :dateTo.CloseDate AND Amount > 0) ORDER By Amount DESC Limit 10];
        } else if (WonOppList.size() == 0 && urlCurrentPg.contains('ViewMyCAMTeamWeeklyReport')){
            WonOppList = [Select Id, name,Account.name, Account.owner.name, Account.WIN_ID__c,Amount,CloseDate From Opportunity where (Key_Account__r.owner.UserRoleId In:allSubRoleIds And StageName Like '%Won%' AND CloseDate >= :dateFrom.CloseDate AND CloseDate <= :dateTo.CloseDate AND Amount > 0) ORDER By Amount DESC Limit 10];
        }
        return WonOppList;
    }
    
    public List<Opportunity> getLostOpportunities(){
        if(LostOppList.size() == 0 && urlCurrentPg.contains('CAMWeeklyReport')){
            LostOppList = [Select Id, name,Account.name, Account.WIN_ID__c,Amount,CloseDate From Opportunity where (Key_Account__c in :corpAccId And StageName Like '%Lost%' AND CloseDate >= :dateFrom.CloseDate AND CloseDate <= :dateTo.CloseDate AND Amount > 0) ORDER By Amount DESC Limit 10];
        }else if (LostOppList.size() == 0 && urlCurrentPg.contains('ViewMyCAMTeamWeeklyReport')){
            LostOppList = [Select Id, name,Account.name, Account.owner.name, Account.WIN_ID__c,Amount,CloseDate From Opportunity where (Key_Account__r.owner.UserRoleId In:allSubRoleIds And StageName Like '%Lost%' AND CloseDate >= :dateFrom.CloseDate AND CloseDate <= :dateTo.CloseDate AND Amount > 0) ORDER By Amount DESC Limit 10];
        }
        return LostOppList;
    }
    
    public void SearchRecords (){
        SNList.clear();
        WonOppList.clear();
        LostOppList.clear();
        AccSNMap.clear();
        createdFromDate = dateTime.newInstance(dateFrom.CloseDate, createdFromTime);
        createdToDate = dateTime.newInstance(dateTo.CloseDate, createdToTime);
        if (!(System.now() >= createdFromDate && System.now() <= createdToDate) && urlCurrentPg.contains('CAMWeeklyReport')){
            SNList = [Select id, Account__c, CreatedDate,Note__c,Issues_Obstacles__c,Forecast__c,Variance__c,Budget__c From Sales_Manager_Summary_Note__c where (Account__r.RecordType.DeveloperName = 'Corporate' And Account__r.ownerId =:UserInfo.getUserId() AND Type__c = 'Sales Summary' AND CreatedDate >= :createdFromDate AND CreatedDate <= :createdToDate) ORDER By Account__r.name];
            for(Sales_Manager_Summary_Note__c SN: SNList){
                if(!AccSNMap.containsKey(SN.Account__c)){
                    List<Sales_Manager_Summary_Note__c> SNMapList = new List<Sales_Manager_Summary_Note__c>();
                    SNMapList.add(SN.clone(true,true,false,false));
                    AccSNMap.put(SN.Account__c,SNMapList);
                }else{
                    AccSNMap.get(SN.Account__c).add(SN.clone(true,true,false,false));
                }      
            }
        }else if (!(System.now() >= createdFromDate && System.now() <= createdToDate) && urlCurrentPg.contains('ViewMyCAMTeamWeeklyReport')){
            SNList = [Select id, Account__c, Account__r.owner.name, Note__c,Issues_Obstacles__c,Forecast__c,Variance__c,Budget__c From Sales_Manager_Summary_Note__c 
                     where (Account__r.RecordType.DeveloperName = 'Corporate' And Account__r.owner.UserRoleId In:allSubRoleIds AND 
                     Type__c = 'Sales Summary' AND CreatedDate >= :createdFromDate AND CreatedDate <= :createdToDate) ORDER By Account__r.name];
        }
    }     
    
    public PageReference CustomSave()
    {
        try{            
            for(Sales_Manager_Summary_Note__c SN:SNList){
                List <Sales_Manager_Summary_Note__c> existingSNList = AccSNMap.get(SN.Account__c);
                for (Sales_Manager_Summary_Note__c existingSN:existingSNList){
                    if(SN.id == existingSN.id){
                        Boolean SNChanged = existingSN.Note__c != SN.Note__c || existingSN.Issues_Obstacles__c != SN.Issues_Obstacles__c || existingSN.Forecast__c != SN.Forecast__c;
                        if (SNChanged) {
                            Sales_Manager_Summary_Note__c updateSN = new Sales_Manager_Summary_Note__c();
                            if(existingSN.Note__c != SN.Note__c){
                                updateSN.Note__c = SN.Note__c;
                            }
                            if(existingSN.Issues_Obstacles__c != SN.Issues_Obstacles__c){
                                updateSN.Issues_Obstacles__c = SN.Issues_Obstacles__c;
                            }
                            
                            if(existingSN.Forecast__c != SN.Forecast__c){
                                updateSN.Forecast__c = SN.Forecast__c;
                            }
                            if (SN.id == null){
                                updateSN.Account__c = SN.Account__c;
                                updateSN.Type__c = 'Sales Summary';
                                updateSN.Budget__c = SN.Budget__c;
                                UpdateSNList.add(updateSN);
                            }else{
                                updateSN.id = SN.id;
                                UpdateSNList.add(updateSN);
                            }
                        } 
                    }
                }
            }
            
            if(UpdateSNList.size()>0){
                Database.UpsertResult[] srList = Database.upsert(UpdateSNList, false);
            }
            PageReference pageRef = new PageReference('/home/home.jsp');
            pageRef.setRedirect(true);
            return pageRef;
        }
        catch(Exception ex)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Summary Notes could not be saved or partially saved'));
            return null;
        }
        
    } 
}