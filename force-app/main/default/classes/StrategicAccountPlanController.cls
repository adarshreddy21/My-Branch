/**
 * @description       : 
 * @author            : Irfan Khan
 * @group             : 
 * @last modified on  : 01-09-2023
 * @last modified by  : Irfan Khan
**/
public class StrategicAccountPlanController {
    public Strategic_Account_Plan__c strplan {get;set;}
    Account acc{get;set;}
    
    List<Strategy_Plan_Forecast_Competitor_Info__c> ForecastList = new List<Strategy_Plan_Forecast_Competitor_Info__c>();
    List<Strategy_Plan_Forecast_Competitor_Info__c> updateFrCmpList = new List<Strategy_Plan_Forecast_Competitor_Info__c>();
    List<Strategy_Plan_Forecast_Competitor_Info__c> CmptrList = new List<Strategy_Plan_Forecast_Competitor_Info__c>();
    List<cObject> RemoveContact = new List<cObject>();
    List<cObject> RemoveOpportunity = new List<cObject>();
    List<cObject> RemoveSN = new List<cObject>();
    map<String, Id> FrCmpRdTy = new map<String, Id> ();
    Public String forecastCmptr{get;set;}
    String urlCurrent;
    Id accId;
    public boolean errormsg=false;
    Public String objectType{get;set;}
    String urlCurrentObj;
    public List<cObject> objList {get; set;}
    Public List<cObject> selectedContactsDisplay = new List<cObject>();
    Map<Id, Map <String,String>> ExistingCon = new Map<Id, Map <String,String>>();
    public Set<Id> selectedPropertyIds {get;set;}
    public String contextItem {get;set;}
    public Boolean selectedAllProperties {get;set;}
    public Integer size {get;set;}
    public Integer noOfRecords{get; set;}
    List<cObject> selobjsList = new List<cObject>(); 
    Map<id,cObject> selObjMap = new Map<id,cObject>();
    Public List<cObject> selectedOpportunityDisplay = new List<cObject>();
    Boolean oppAdded = False;
    set<id> ExistingOppId = new set<id>();
    Public List<cObject> selectedSummaryNotesDisplay = new List<cObject>();
    set<id> ExistingSNId = new set<id>();
    DateTime queryContactTime;
    DateTime queryOppTime;
    DateTime querySNTime;
    public static final Integer QUERY_LIMIT = 10000;
    
    public String alphaSearch{get;set;}
    public String alphaAll{get;set;}
    public String SearchbyField{get;set;}
    private String ContactQuery;
    private String OppQuery;
    private String SNQuery;
    private String sortDirection;
    private String sortExp;
    
    
    
    public StrategicAccountPlanController(ApexPages.StandardController stdcontr){ 
        this.strplan = (Strategic_Account_Plan__c)stdcontr.getRecord();
        urlCurrent = ApexPages.currentPage().geturl();
        this.selectedPropertyIds = new Set<Id>();
        size = 20;
        alphaSearch = 'All';
        alphaAll = 'All';
        
        if(urlCurrent.contains('EditStrategicAccountPlan')){ 
            for(Contact C: [select id, Name,Title,Contact_Type__c, Buying_Role__c, Relationship_Strength__c, Relationship_Development_Plan__c, Strategic_Account_Plan__c,Frequency__c,Account.name from Contact where Strategic_Account_Plan__c =:strplan.id]){
                selectedContactsDisplay.add(new cObject(c));
                Map <String,String> Relationship = new Map <String,String>();
                Relationship.put('Relationship_Strength__c', c.Relationship_Strength__c);
                Relationship.put('Relationship_Development_Plan__c', c.Relationship_Development_Plan__c);
                Relationship.put('Buying_Role__c', c.Buying_Role__c);
                Relationship.put('Frequency__c', c.Frequency__c);
                ExistingCon.put(c.id,Relationship);
            }
            for(Opportunity O:[select id, Name, Owner.Name,Amount,CloseDate,Job_Start_Date__c,StageName,Description,Next_Action__c,Strategic_Account_Plan__c,Account.id,Account.name,(Select id, Product2.Name from OpportunityLineItems) from Opportunity where Strategic_Account_Plan__c =:strplan.id]){
                selectedOpportunityDisplay.add(new cObject(O));
                ExistingOppId.add(o.id);
            }
            for(Sales_Manager_Summary_Note__c SN:[select Name, Account__c,Opportunity__c,Budget__c,Forecast__c,Variance__c,Note__c,Type__c,Strategic_Account_Plan__c from Sales_Manager_Summary_Note__c where Strategic_Account_Plan__c =:strplan.id]){
                selectedSummaryNotesDisplay.add(new cObject(SN));
                ExistingSNId.add(SN.id);
            } 
        }
        
        if(urlCurrent.contains('EditStrategicAccountPlan') || urlCurrent.contains('StrategicAccountPlanForecast')){
            ForecastList = [select Line_of_Business__c, FY_Current_Spend__c, Current_New_LOB__c, FY_White_Space__c, Current_Year_Forecast__c,Current_Year_plus_1_Forecast__c,FY_Total_Wallet__c, Percentage_of_Wallet__c,Strategic_Account_Plan__c from Strategy_Plan_Forecast_Competitor_Info__c where (Strategic_Account_Plan__c =:strplan.id AND RecordType.DeveloperName in('Strategy_Plan_Forecast') ) ORDER BY Current_New_LOB__c];
            updateFrCmpList.addAll(ForecastList);           
            
            CmptrList = [select Line_of_Business__c, Competitor__c, Competitor_percentage_of_Wallet__c, Strength_Weaknesses__c, Strategic_Account_Plan__c from Strategy_Plan_Forecast_Competitor_Info__c where (Strategic_Account_Plan__c =:strplan.id AND RecordType.DeveloperName in('Competitor_Information') ) ORDER BY Line_of_Business__c];
            updateFrCmpList.addAll(CmptrList);
        }
        
        if(urlCurrent.contains('EditStrategicAccountPlan')){
            accId = strplan.Account__c;  
        }else if (urlCurrent.contains('StrategicAccountPlan') && !(urlCurrent.contains('StrategicAccountPlanForecast'))){
            //String str = System.currentPageReference().getParameters().get('retURL').substring(1,16);
            //accId = (Id)str;
            accId = strplan.Account__c;
        }
    }
    
    public list<String> alphabet{
        get{                                                                                                                     
            alphabet = new list<string>{'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z','All'};
                return alphabet;         
        }
        set;
    }
    
    /* Wrapper class to contain record and a boolean flag */   
    public class cObject
    {
        public sObject obj {get; set;}
        public Boolean selected {get; set;}
        public cObject(sObject sobj)
        {            
            this.obj = sobj;
            this.selected = false;
        }     
        public Boolean equals(Object objt) {
            if (objt instanceof cObject) {
                cObject p = (cObject)objt;
                return ((obj.id==p.obj.id) );
            }
            return false;
        } 
        public Integer hashCode() {
            return System.hashCode(String.valueOf(obj.Id));
        }	
    }
    /* end of Wrapper class */
    
    Public Account getAccountName(){
        acc = [select Name,RecordType.name from account where id =:accId];
        return acc;
    }
    
    public PageReference AddRecords(){
        alphaSearch = 'All';
        SearchbyField = '';
        sortDirection = 'ASC';
        sortExp = 'name';
        getalphaSearch();
        if(objectType == 'Contact'){
            PageReference newPage = new PageReference('/apex/StratergicAccountPlanContacts');
            newPage.setRedirect(false);
            return newPage;
        }else if(objectType == 'Opportunity'){
            PageReference newPage = new PageReference('/apex/StrategicAccountPlanOpportunities');     
            newPage.setRedirect(false); 
            return newPage;
        }else if(objectType == 'SummaryNotes'){
            PageReference newPage = new PageReference('/apex/StratergicAccountPlanSummaryNotes');     
            newPage.setRedirect(false); 
            return newPage;
        }else{
            return null;
        }       
    }
    
    public String sortExpression
    {
        get
        {
            return sortExp;
        }
        set
        {
            if (value == sortExp)
                sortDirection = (sortDirection == 'ASC')? 'DESC' : 'ASC';
            else
                sortDirection = 'ASC';
            sortExp = value;
        }
    }
    
    public String getSortDirection()
    {
        return sortDirection;  
    }
    
    public void setSortDirection(String value)
    {  
        sortDirection = value;
    }
    
    
    public void getSearchByFilter(){
        alphaSearch = SearchbyField;
        getalphaSearch();
    }
    
    public void getalphaSearch(){
        selObjMap.clear();
        selobjsList.clear();
        this.selectedPropertyIds.clear();
        if(objectType == 'Contact'){
            setCon = null;
        }else if(objectType == 'Opportunity'){
            setOpp = null;
        }else if(objectType == 'SummaryNotes'){
            setSN = null;
        }
    }
    
    public List <cObject> getAllObject(){
        urlCurrentObj = ApexPages.currentPage().geturl();
        List<sObject> objRecords = new List<sObject>();
        objList = new List<cObject>();
        Integer selectedPropertyNumber = 0;
        if(urlCurrentObj.contains('StratergicAccountPlanContacts')){  
            objRecords = new List<sObject>(setCon.getRecords());
        }else if (urlCurrentObj.contains('StrategicAccountPlanOpportunities')){
            objRecords = new List<sObject>(setOpp.getRecords());      
        }else if (urlCurrentObj.contains('StratergicAccountPlanSummaryNotes')){
            objRecords = new List<sObject>(setSN.getRecords());
        }
        
        for(sObject sobjs:objRecords){
            cObject currentobj = new cObject(sobjs);
            if(this.selectedPropertyIds != null) 
            {
                if(this.selectedPropertyIds.contains(sobjs.Id)){
                    currentobj.selected = true;
                    selectedPropertyNumber ++; //show the checkbox selected count
                    selObjMap.put(sobjs.id,currentobj);
                }
                else{
                    currentobj.selected = false;
                    if(selObjMap.containsKey(sobjs.id)){
                        selObjMap.remove(sobjs.id);
                    }
                }
            }
            objList.add(currentobj);
            
        }
        
        if(selObjMap.size()>0 ){
            selobjsList = selObjMap.values();
        }
        if(objList.size() > 0){
            selectedAllProperties = selectedPropertyNumber == objList.size() ? true: false;
        }  
        return objList;
    }
    
    public ApexPages.StandardSetController setCon {
        get {
            if(setCon == null || queryContactTime < DateTime.now().addMinutes(-10)) {
                BuildQuery();
                setCon = new ApexPages.StandardSetController(Database.getQueryLocator(ContactQuery));
                setCon.setpageNumber(1);
                setCon.setPageSize(size);
                noOfRecords = setCon.getResultSize();
                queryContactTime = DateTime.now();
            }
            return setCon;
        }
        set;
    }
    
    public ApexPages.StandardSetController setOpp {
        get {
            if(setOpp == null || queryOppTime < DateTime.now().addMinutes(-10)) {   
                BuildQuery();
                setOpp = new ApexPages.StandardSetController(Database.getQueryLocator(OppQuery));
                setOpp.setpageNumber(1);
                setOpp.setPageSize(size);
                noOfRecords = setOpp.getResultSize();
                queryOppTime = DateTime.now();
            }
            return setOpp;
        }
        set;
    }
    
    public ApexPages.StandardSetController setSN {
        get {
            if(setSN == null || querySNTime < DateTime.now().addMinutes(-10)) {  
                BuildQuery();
                setSN = new ApexPages.StandardSetController(Database.getQueryLocator(SNQuery));
                // sets the number of records to show in each page view
                setSN.setpageNumber(1);
                setSN.setPageSize(size);
                noOfRecords = setSN.getResultSize();
                querySNTime = DateTime.now();
            }
            return setSN;
        }
        set;
    }
    
    private string BuildQuery() {
        if(objectType == 'Contact'){ 
            if(acc.RecordType.name == 'Corporate'){
                ContactQuery = 'select id, Name,Title,Contact_Type__c, Buying_Role__c, Relationship_Strength__c, Relationship_Development_Plan__c, Strategic_Account_Plan__c,Frequency__c,Account.name from Contact'+
                    ' where (Account.id =:accId OR Account.ParentId =:accId OR Account.Parent.ParentId =:accId) AND (Account.RecordType.name = \'Corporate\' OR Account.RecordType.name = \'Customer\' OR Account.RecordType.name = \'Customer Location\') AND Account.status__c = \'Active\' And Expired__c = False';                                                                         
            }else if(acc.RecordType.name == 'Customer'){
                ContactQuery = 'select id, Name,Title,Contact_Type__c, Buying_Role__c, Relationship_Strength__c, Relationship_Development_Plan__c, Strategic_Account_Plan__c,Frequency__c,Account.name from Contact'+ 
                    ' where Account.id =:accId AND Account.status__c = \'Active\' And Expired__c = False';
            }
            if (alphaSearch != 'All'){
                string tempVar = '\''+alphaSearch  + '%\'';
                String QueryWhere = ' AND lastName Like '+tempVar;
                ContactQuery += QueryWhere;
            }
            string sortFullExp = sortExpression  + ' ' + sortDirection;
            String QueryOrder = ' ORDER By ' +sortFullExp +' Limit :QUERY_LIMIT';
            ContactQuery += QueryOrder;
            system.debug('ContactQuery++'+ContactQuery);
            return ContactQuery;
        }else if(objectType == 'Opportunity'){
            if(acc.RecordType.name == 'Corporate'){
                OppQuery = 'select id, Name, Owner.Name,Amount,CloseDate,Job_Start_Date__c,StageName,Description,Next_Action__c,Strategic_Account_Plan__c,Account.id,Account.name,(Select id, Product2.Name from OpportunityLineItems) from Opportunity'+
                    ' where Key_Account__c =:accId And Account.status__c = \'Active\' And (Not(StageName Like \'%Lost%\'))';                                                                         
            }else if(acc.RecordType.name == 'Customer'){
                OppQuery = 'select id, Name, Owner.Name,Amount,CloseDate,Job_Start_Date__c,StageName,Description,Next_Action__c,Strategic_Account_Plan__c,Account.id,Account.name,(Select id, Product2.Name from OpportunityLineItems) from Opportunity'+ 
                    ' where Account.id =:accId And Account.status__c = \'Active\' And (Not(StageName Like \'%Lost%\'))';
            }
            if (alphaSearch != 'All'){
                string tempVar = '\'%'+alphaSearch  + '%\'';
                String QueryWhere = ' AND Account.name Like '+tempVar;
                OppQuery += QueryWhere;
            }
            string sortFullExp = sortExpression  + ' ' + sortDirection;
            String QueryOrder = ' ORDER By ' +sortFullExp +' Limit :QUERY_LIMIT';
            OppQuery += QueryOrder;
            system.debug('OppQuery++'+OppQuery);
            return OppQuery;
        }else if(objectType == 'SummaryNotes'){
            if(acc.RecordType.name == 'Corporate'){
                SNQuery = 'select Name, Account__c,Opportunity__c,Budget__c,Forecast__c,Variance__c,Note__c,Type__c,Strategic_Account_Plan__c from Sales_Manager_Summary_Note__c'+
                    ' where (Account__c =:accId OR Account__r.ParentId =:accId OR Account__r.Parent.ParentId =:accId) And Account__r.status__c = \'Active\'';                                                                         
            }else if(acc.RecordType.name == 'Customer'){
                SNQuery = 'select Name, Account__c,Opportunity__c,Budget__c,Forecast__c,Variance__c,Note__c,Type__c,Strategic_Account_Plan__c from Sales_Manager_Summary_Note__c'+ 
                    ' where Account__c =:accId AND Account__r.status__c = \'Active\'';
            }
            if (alphaSearch != 'All'){
                string tempVar = '\'%'+alphaSearch  + '%\'';
                String QueryWhere = ' AND Account__r.name Like '+tempVar;
                SNQuery += QueryWhere;
            }
            string sortFullExp = sortExpression  + ' ' + sortDirection;
            String QueryOrder = ' ORDER By ' +sortFullExp +' Limit :QUERY_LIMIT';
            SNQuery += QueryOrder;
            system.debug('SNQuery++'+SNQuery);
            return SNQuery;
            
        }else{
            return null;
        }
    }
    
    /** handle item selected */
    public void doSelectItem()
    { 
        this.selectedPropertyIds.add(this.contextItem);
    }
    
    /** handle item deselected */
    public void doDeselectItem()
    {
        this.selectedPropertyIds.remove(this.contextItem);
    }
    
    public void isSelectedAll()
    {
        List<sObject> recordList = new List<sObject>();
        urlCurrentObj = ApexPages.currentPage().geturl();
        if(urlCurrentObj.contains('StratergicAccountPlanContacts')){
            recordList = this.setCon.getRecords();
        }else if (urlCurrentObj.contains('StrategicAccountPlanOpportunities')){
            recordList = this.setOpp.getRecords();
        }else if (urlCurrentObj.contains('StratergicAccountPlanSummaryNotes')){
            recordList = this.setSN.getRecords();
        }
        for (sObject record : recordList){
            if(selectedAllProperties){
                this.selectedPropertyIds.add(record.id);
            }else{
                this.selectedPropertyIds.remove(record.id);
            }
        }
    }
    
    /* Method to process the selected records */
    public PageReference processSelectedRecords()
    {
        List<cObject> selectedRecords = new List<cObject>();
        if (selobjsList!= null)
        {
            for(cObject cObj : selobjsList){
                if(cObj.selected == true){
                    cObj.selected = false;
                    selectedRecords.add(cObj);
                }
            }
            if(objectType == 'Contact'){
                if (selectedContactsDisplay.isEmpty()){
                    selectedContactsDisplay=selectedRecords;
                }else{
                    for (cObject conSel: selectedRecords){
                        if(!selectedContactsDisplay.contains(conSel)){
                            selectedContactsDisplay.add(conSel);
                        }    
                    }
                }             
            }else if(objectType == 'Opportunity'){
                if (selectedOpportunityDisplay.isEmpty()){
                    selectedOpportunityDisplay=selectedRecords;
                } else{
                    for (cObject oppSel: selectedRecords){
                        if(!selectedOpportunityDisplay.contains(oppSel)){
                            selectedOpportunityDisplay.add(oppSel);
                        }    
                    }
                }
            }else if(objectType == 'SummaryNotes'){
                if (selectedSummaryNotesDisplay == null){
                    selectedSummaryNotesDisplay=selectedRecords;
                } else{
                    for (cObject SNSel: selectedRecords){
                        if(!selectedSummaryNotesDisplay.contains(SNSel)){
                            selectedSummaryNotesDisplay.add(SNSel);
                        }    
                    }
                }
                
            }      
        }
        /* return error message if no record is selected */
        if (selectedRecords.size()==0)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Select atleast one Record'));
            return null;
        }
        else
        {
            errormsg=false;
            Pagereference p=new Pagereference ('/apex/StrategicAccountPlan');
            return p;
        }
    }
    
    public List <cObject> getAllSelectedContacts(){
        return selectedContactsDisplay;        
    }
    
    public List <cObject> getAllSelectedOpportunity(){
        oppAdded = true;
        return selectedOpportunityDisplay;
    } 
    
    public List <cObject> getAllSelectedSummaryNotes(){
        return selectedSummaryNotesDisplay;
    }
    
    /* Method to process the removed records */
    public void processRemovedRecords(){
        if(objectType == 'Contact'){
            for(Integer i = (selectedContactsDisplay.size()-1) ; i>= 0 ; i--){
                if(selectedContactsDisplay[i].selected == true){
                    if(!RemoveContact.contains(selectedContactsDisplay[i])){
                        RemoveContact.add(selectedContactsDisplay[i]);
                    }
                    selectedContactsDisplay.remove(i);
                }
            }
        }else if (objectType == 'Opportunity'){
            for(Integer i = (selectedOpportunityDisplay.size()-1) ; i>= 0 ; i--){
                if(selectedOpportunityDisplay[i].selected == true){
                    if(!RemoveOpportunity.contains(selectedOpportunityDisplay[i])){
                        RemoveOpportunity.add(selectedOpportunityDisplay[i]);
                    }
                    selectedOpportunityDisplay.remove(i);
                }
            }
        }else if (objectType == 'SummaryNotes'){
            for(Integer i = (selectedSummaryNotesDisplay.size()-1) ; i>= 0 ; i--){
                if(selectedSummaryNotesDisplay[i].selected == true){
                    if(!RemoveSN.contains(selectedSummaryNotesDisplay[i])){
                        RemoveSN.add(selectedSummaryNotesDisplay[i]);
                    }
                    selectedSummaryNotesDisplay.remove(i);
                }
            }
        }
    }
    
    //White Space and Competitor Information
    public List<Strategy_Plan_Forecast_Competitor_Info__c> getforcastplan(){
        if(oppAdded == true){   
            return ForecastList;
        }else{
            if(urlCurrent.contains('EditStrategicAccountPlan') || urlCurrent.contains('StrategicAccountPlanForecast')){
                return ForecastList;
            }else{
                for(integer i = 0; i< 5; i++){
                    Strategy_Plan_Forecast_Competitor_Info__c forcst = new Strategy_Plan_Forecast_Competitor_Info__c();
                    ForecastList.add(forcst);     
                }
                return ForecastList; 
            }
        }       
    }
    
    public List<Strategy_Plan_Forecast_Competitor_Info__c> getcmptrPlan(){
        if(oppAdded == true){   
            return CmptrList;
        }else{
            if(urlCurrent.contains('EditStrategicAccountPlan') || urlCurrent.contains('StrategicAccountPlanForecast')){
                return CmptrList;
            }else{
                for(integer i = 0; i< 5; i++){
                    Strategy_Plan_Forecast_Competitor_Info__c cmptr = new Strategy_Plan_Forecast_Competitor_Info__c();
                    CmptrList.add(cmptr);     
                }
                return CmptrList; 
            }
        }       
    }
    
    public PageReference AddRowforcastplan(){ 
        Strategy_Plan_Forecast_Competitor_Info__c forcstCmpr = new Strategy_Plan_Forecast_Competitor_Info__c();
        if(forecastCmptr == 'Forecast'){
            ForecastList.add(forcstCmpr); 
        }else if (forecastCmptr == 'Competitor'){
            CmptrList.add(forcstCmpr);
        }
        return null;
    }
    
    //pagination Methods
    public Boolean hasNext {
        get {
            if(objectType == 'Contact'){
                return setCon.getHasNext();
            }else if (objectType == 'Opportunity') {
                return setOpp.getHasNext();
            }else if (objectType == 'SummaryNotes') {
                return setSN.getHasNext();
            }else{
                return null;
            }
        }
        set;
    }
    
    public Boolean hasPrevious {
        get {
            if(objectType == 'Contact'){
                return setCon.getHasPrevious();
            }else if (objectType == 'Opportunity') {
                return setOpp.getHasPrevious();
            }else if (objectType == 'SummaryNotes') {
                return setSN.getHasPrevious();
            }else{
                return null;
            }
        }
        set;
    }
    
    public Integer pageNumber {
        get {
            if(objectType == 'Contact'){
                return setCon.getPageNumber();
            }else if (objectType == 'Opportunity') {
                return setOpp.getPageNumber();
            }else if (objectType == 'SummaryNotes') {
                return setSN.getPageNumber();
            }else{
                return null;
            }
        }
        set;
    }
    
    public Integer totalPageNumber {
        get {
            Decimal totalSize;
            Decimal pageSize;
            if(objectType == 'Contact'){
                totalSize = this.setCon.getResultSize();
                pageSize = this.setCon.getPageSize();
            }else if (objectType == 'Opportunity') {
                totalSize = this.setOpp.getResultSize();
                pageSize = this.setOpp.getPageSize();
            }else if (objectType == 'SummaryNotes') {
                totalSize = this.setSN.getResultSize();
                pageSize = this.setSN.getPageSize();
            }  
            Decimal pages = totalSize/pageSize;
            return (Integer)pages.round(System.RoundingMode.CEILING);
        }
        set;
    }
    
    public void first() {
        if(objectType == 'Contact'){
            setCon.first();
        }else if (objectType == 'Opportunity') {
            setOpp.first();
        }else if (objectType == 'SummaryNotes') {
            setSN.first();
        }
    }
    
    public void last() {
        if(objectType == 'Contact'){
            setCon.last();
        }else if (objectType == 'Opportunity') {
            setOpp.last();
        }else if (objectType == 'SummaryNotes') {
            setSN.last();
        }
    }
    
    public void previous() {
        if(objectType == 'Contact'){
            setCon.previous();
        }else if (objectType == 'Opportunity') {
            setOpp.previous();
        }else if (objectType == 'SummaryNotes') {
            setSN.previous();
        }
    }
    
    public void next() {
        if(objectType == 'Contact'){
            setCon.next();
        }else if (objectType == 'Opportunity') {
            setOpp.next();
        }else if (objectType == 'SummaryNotes') {
            setSN.next();
        }
    }
    
    public PageReference CustomSave()
    {
        try{
            List<Contact> UpdateContacts = new List<Contact>();
            List<Opportunity> UpdateOpportunity = new List<Opportunity>();
            List<Sales_Manager_Summary_Note__c> UpdateSN = new List<Sales_Manager_Summary_Note__c>(); 
                        
            //Stratergic Plan           
            if(urlCurrent.contains('EditStrategicAccountPlan')){
                update strplan;
            }else if (strplan.Id == null){
                insert strplan;      
            }
            system.debug('strplan Id --'+strplan.Id);
            
            // White Space and Competitor Info 
            
            List <RecordType> frctRd = [Select Id,DeveloperName From RecordType Where SobjectType ='Strategy_Plan_Forecast_Competitor_Info__c'];
            for(RecordType rd:frctRd){
                FrCmpRdTy.put(rd.DeveloperName, rd.Id);
            } 
            
            for (Strategy_Plan_Forecast_Competitor_Info__c forcasttoupdate:ForecastList){
                if(forcasttoupdate.Line_of_Business__c != null && forcasttoupdate.Strategic_Account_Plan__c == null){
                    forcasttoupdate.RecordTypeId = FrCmpRdTy.get('Strategy_Plan_Forecast');
                    forcasttoupdate.Strategic_Account_Plan__c = strplan.Id;
                    updateFrCmpList.add(forcasttoupdate);
                }
            }
            
            for (Strategy_Plan_Forecast_Competitor_Info__c cmptrtoupdate:CmptrList){
                if(cmptrtoupdate.Line_of_Business__c != null && cmptrtoupdate.Strategic_Account_Plan__c == null){
                    cmptrtoupdate.RecordTypeId = FrCmpRdTy.get('Competitor_Information');
                    cmptrtoupdate.Strategic_Account_Plan__c = strplan.Id;
                    updateFrCmpList.add(cmptrtoupdate);
                }
            }
            upsert updateFrCmpList;
            
            //Contact, Opportunity and SN 
            if(urlCurrent.contains('EditStrategicAccountPlan')){
                for(cObject rmovecon:RemoveContact){
                    if(!selectedContactsDisplay.contains(rmovecon) && ExistingCon.containsKey(rmovecon.obj.id)){
                        Contact c = new Contact();
                        c.id = rmovecon.obj.id;
                        c.Strategic_Account_Plan__c = null;
                        UpdateContacts.add(c);
                    }
                }
                
                for(cObject rmoveopp:RemoveOpportunity){                                     
                    if(!selectedOpportunityDisplay.contains(rmoveopp) && ExistingOppId.contains(rmoveopp.obj.id)){
                        Opportunity o = new Opportunity();
                        o.id = rmoveopp.obj.id;
                        o.Strategic_Account_Plan__c = null;
                        UpdateOpportunity.add(o);
                    }
                }
                for(cObject rmoveSN:RemoveSN){
                    if(!selectedSummaryNotesDisplay.contains(rmoveSN) && ExistingSNId.contains(rmoveSN.obj.id)){
                        Sales_Manager_Summary_Note__c SN = new Sales_Manager_Summary_Note__c();
                        SN.id = rmoveSN.obj.id;
                        SN.Strategic_Account_Plan__c = null;
                        UpdateSN.add(SN);
                    }
                }
            }
            
            if (!selectedContactsDisplay.isEmpty()){
                for(cObject cObj: selectedContactsDisplay){
                    if(ExistingCon.isEmpty()||(!ExistingCon.isEmpty() && !ExistingCon.containsKey(cObj.obj.id))){
                        Contact c = new Contact();
                        c.id = cObj.obj.id;
                        c.Relationship_Strength__c = (String)cObj.obj.get('Relationship_Strength__c');
                        c.Relationship_Development_Plan__c = (String)cObj.obj.get('Relationship_Development_Plan__c');
                        c.Buying_Role__c = (String)cObj.obj.get('Buying_Role__c');
                        c.Frequency__c = (String)cObj.obj.get('Frequency__c');
                        c.Strategic_Account_Plan__c = strplan.Id;
                        UpdateContacts.add(c);
                    }else if (!ExistingCon.isEmpty() && ExistingCon.containsKey(cObj.obj.id)){    
                        Map <String,String> conRelation = ExistingCon.get(cObj.obj.id);
                        if(conRelation.get('Relationship_Strength__c') !=(String)cObj.obj.get('Relationship_Strength__c') ||
                           conRelation.get('Relationship_Development_Plan__c') !=(String)cObj.obj.get('Relationship_Development_Plan__c') ||
                           conRelation.get('Buying_Role__c') !=(String)cObj.obj.get('Buying_Role__c') ||
                           conRelation.get('Frequency__c') !=(String)cObj.obj.get('Frequency__c')){
                               Contact c = new Contact();
                               c.id = cObj.obj.id;
                               c.Relationship_Strength__c = (String)cObj.obj.get('Relationship_Strength__c');
                               c.Relationship_Development_Plan__c = (String)cObj.obj.get('Relationship_Development_Plan__c');
                               c.Buying_Role__c = (String)cObj.obj.get('Buying_Role__c');
                               c.Frequency__c = (String)cObj.obj.get('Frequency__c');
                               UpdateContacts.add(c);
                           }
                    }
                }  
            }
            
            if (!selectedOpportunityDisplay.isEmpty()){
                for(cObject cObj: selectedOpportunityDisplay){
                    if(ExistingOppId.isEmpty()||(!ExistingOppId.isEmpty() && !ExistingOppId.contains(cObj.obj.id))){
                        Opportunity o = new Opportunity();
                        o.id = cObj.obj.id;
                        o.Strategic_Account_Plan__c = strplan.Id;
                        UpdateOpportunity.add(o);
                    }
                }
            }
            if (!selectedSummaryNotesDisplay.isEmpty()){
                for(cObject cObj: selectedSummaryNotesDisplay){
                    if(ExistingSNId.isEmpty()||(!ExistingSNId.isEmpty() && !ExistingSNId.contains(cObj.obj.id))){
                        Sales_Manager_Summary_Note__c SN = new Sales_Manager_Summary_Note__c();
                        SN.id = cObj.obj.id;
                        SN.Strategic_Account_Plan__c = strplan.Id;
                        UpdateSN.add(SN);
                    }
                }
            }
            
            update UpdateSN;
            
            update UpdateContacts;
            
            update UpdateOpportunity;         
            
            PageReference pg = new PageReference('/'+strplan.Id);
            pg.setRedirect(true);
            return pg;
        }
        catch(Exception ex)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Strategic Account Plan partially saved without Contacts/Opportunities. Hit cancel and please update Contacts/Opportunities records related to error instructions mentioned above and try to attached with Strategic Plan again.'));
            return null;
        }
    }
    public PageReference CustomCancel(){
        Pagereference p=new Pagereference ('/apex/StrategicAccountPlan');
        return p;
    }
}