public class ContactRelatedListController {
    public Id navConId{get;set;}
    public Boolean showMessage {get;set;}
    public Boolean hideContactVerified {get;set;}
    public Boolean hasMainContact {get;set;}
    public Boolean hasAPContact {get;set;}
    public Boolean hasPOContact {get;set;}
    public Integer daysSinceMainContVerified {get;set;}
    public Integer daysSinceAPContVerified {get;set;}
    public Integer daysSincePOContVerified {get;set;}
    public List<contact> contacts{get;set;} 
    public List<ContactWrap> contactsWrap{get;set;}
    public Boolean isMANIRequire{get;set;}
    public Boolean isAPRequire{get;set;}
    public Boolean isPORequire{get;set;}
    public Boolean hasContacts{get;set;}
    public List<contact> contactsO{get;set;} 
    public List<contactWrap> contactsOWrap{get;set;} 
    public Boolean hasContactsO{get;set;}
    public Set<string> contactTypes{get;set;}
    public String missingConTypesString{get;set;} 
    public string emailAddressFromAPI{get;set;}
    //public list<Contact> contactslst{get; set;}
    public Account accounts {get;set;} 
   // public string unconType{get;set;} 
    public Account acc {get;set;} 
     public Contact con {get; set;}
     public Contact account {get; set;}
    public ApexPages.StandardController sctrl;
    
    //Contact Type Definitions fields
    public Boolean showContactTypeDef{get;set;}
    public Map<String, String> conTypeDescMap;
    public Map<String, String> conTypeDefnitionMap;
    public List<ContactTypeDef> conTypeDefList{get;set;}
    public Boolean hasConTypeDef{get;set;}
    public List<String> additionalContactTypes {get;set;}
    public List<String> primaryContactTypes {get;set;}
    public String newContactTypeValue {get;set;}
    public Boolean showVerifiedButton {get;set;}
    
     
    
    //Constructor 
   
    public ContactRelatedListController(ApexPages.StandardController controller) {
    
        this.showMessage = true;
        this.hideContactVerified = true;
        this.hasMainContact = false;
        this.hasAPContact = false;
        this.hasPOContact = false;
        this.daysSinceMainContVerified = 0;
        this.daysSinceAPContVerified = 0;
        this.daysSincePOContVerified = 0;
        this.hasContacts = false;
        this.hasContactsO = false;        
        this.missingConTypesString = '';        
        this.sctrl = controller;
        contactTypes = new Set<string>();
        contacts = new list<Contact>();
        contactsWrap = new list<ContactWrap>();
        contactsO = new List<Contact>();
        contactsOWrap = new List<ContactWrap>();
        contactTypes.add('MAIN');
        contactTypes.add('PO');
        contactTypes.add('AP');
        contactTypes.add('MANI');
        
        //contact type deifnition fields
        this.hasConTypeDef = false;
        this.showContactTypeDef = false;
        this.conTypeDefList = new List<ContactTypeDef>();
        this.conTypeDescMap = new Map<String, String>();
        this.conTypeDefnitionMap = new Map<String, String>();
        this.additionalContactTypes = new List<String>();
        this.primaryContactTypes = new List<String>();
        
        acc = (account)controller.getRecord(); 
        set<string> mani = new set<string>();
        mani.add('MANI');
        
        Message_Settings__c msgSetting = Message_Settings__c.getInstance();
        showMessage = msgSetting.Display_MAIN_Contact_Message__c;
        
        for(Contact_Type_Definition__mdt conTypeDef : [select MasterLabel, DeveloperName, Contact_Description__c, Order__c,Definition__c from Contact_Type_Definition__mdt ORDER BY Order__c ASC]){
            ContactTypeDef ctd = new ContactTypeDef();
            ctd.contactType = conTypeDef.MasterLabel;
            ctd.description = conTypeDef.Contact_Description__c;
            ctd.definition = conTypeDef.Definition__c;
            conTypeDefList.add(ctd);
            conTypeDescMap.put(conTypeDef.MasterLabel, conTypeDef.Contact_Description__c);
            conTypeDefnitionMap.put(conTypeDef.MasterLabel, conTypeDef.Definition__c);
            
            if(contactTypes.contains(conTypeDef.MasterLabel)){
                primaryContactTypes.add(conTypeDef.MasterLabel);
            }
            else{
                additionalContactTypes.add(conTypeDef.MasterLabel);
            }
            
        }
        
        if(!conTypeDefList.isEmpty()){
            hasConTypeDef = true;
        }
        
             
        getAccountInfo();
            
        getContactRealtedLists();
        
     
    } 
    
    private void getAccountInfo(){
        accounts = [SELECT id,Name,CS_EPA_ID__c,Missing_Contact_Type__c, RecordType.DeveloperName, Main_Contact_Verified_Date__c, AP_Contact_Verified_Date__c, PO_Contact_Verified_Date__c, Days_Since_Main_Contact_Verified__c, Days_Since_AP_Contact_Verified__c, Days_Since_PO_Contact_Verified__c, WIN_ID__c FROM account WHERE id=: acc.id LIMIT 1]; 
        hasMainContact = accounts.Main_Contact_Verified_Date__c == NULL? false : true;
        hasAPContact = accounts.AP_Contact_Verified_Date__c == NULL? false : true;
        hasPOContact = accounts.PO_Contact_Verified_Date__c == NULL? false : true;
        daysSinceMainContVerified = accounts.Days_Since_Main_Contact_Verified__c == NULL ? 0 : Integer.valueOf(accounts.Days_Since_Main_Contact_Verified__c);
        daysSinceAPContVerified = accounts.Days_Since_AP_Contact_Verified__c == NULL ? 0 : Integer.valueOf(accounts.Days_Since_AP_Contact_Verified__c);
        daysSincePOContVerified = accounts.Days_Since_PO_Contact_Verified__c == NULL ? 0 : Integer.valueOf(accounts.Days_Since_PO_Contact_Verified__c);
        isMANIRequire = false;

        
        /*if(String.isBlank(accounts.CS_EPA_ID__c)){
            isMANIRequire = true;
            
        }
        else*/ if(String.isNotBlank(accounts.CS_EPA_ID__c) && !accounts.CS_EPA_ID__c.equalsIgnoreCase('PENDING') && 
                !accounts.CS_EPA_ID__c.equalsIgnoreCase('NONEREQUIRED') &&
                   !accounts.CS_EPA_ID__c.equalsIgnoreCase('CESQG') &&
                !((accounts.CS_EPA_ID__c.Endswith('CESQG') || accounts.CS_EPA_ID__c.Endswith('cesqg'))  && 
                accounts.CS_EPA_ID__c.length()==7) &&
                !accounts.CS_EPA_ID__c.equalsIgnoreCase('FCCANADA'))
        {
            isMANIRequire = true;
        }
        
        isAPRequire = false;
        isPORequire = false;
        if(accounts.RecordType.DeveloperName == 'Customer' || accounts.RecordType.DeveloperName == 'Distributor'  ||
           accounts.RecordType.DeveloperName == 'Broker')
        {
            isAPRequire = true;
            isPORequire = true;
        }   
        
        
                
    }
        
    private void getContactRealtedLists(){
        this.hasContacts = false;
        this.hasContactsO = false;
        contacts = new list<Contact>();
        contactsWrap = new list<ContactWrap>();
        contactsO = new List<Contact>();
        contactsOWrap = new List<ContactWrap>();
        
        
        List<Contact> accContactList =  [SELECT id,Name,Accountid, Phone,LastModifiedDate,Contact_Type__c,Expired__c,CS_Ecomm__c,CS_Emailed_Invoices__c,text_indcr__c,email_indcr__c,Title,mobilephone, email,
                           Account.Main_Contact_Verified_Date__c, Contact_Definition__c,LastModifiedById, Account.RecordType.DeveloperName FROM Contact 
                           WHERE accountid = :accounts.id and Expired__c=false];
          
        populateContactListBySection('primary', accContactList);
        populateContactListBySection('additional', accContactList);
        
        populateMissingContactTypes(accContactList);
       
        if(!contactsWrap.isEmpty()){
           
            hasContacts = true;
            } 
        
        if(!contactsOWrap.isEmpty()){
            hasContactsO = true;                                           
        }
        
        
    }
    
    private void populateMissingContactTypes(List<Contact> accContactList){
        
        Boolean hasMAIN = false;
        Boolean hasPO = false;
        Boolean hasAP = false;
        Boolean hasMANI = false;
        
        //identify missing contact types
        for(Contact con : accContactList)
        {                    
            String[] selectedConTypes;
            if(String.isNotBlank(con.Contact_Type__c)){
              selectedConTypes = con.Contact_Type__c.split(';');
                for(String conType :  selectedConTypes){
                    conType = conType.trim();
                   
                
                    if(conType == 'MAIN'){
                        hasMAIN = true;
                    }
                    
                    if(conType == 'AP'){
                        hasAP = true;                        
                    }
                    
                    if(conType == 'PO'){
                        hasPO = true;
                    }
                                       
                    if(conType == 'MANI'){
                        hasMANI = true;
                    }
                    
                }//end for
            }//end if        
            
        }//end for
        
        List<String> missingContactTypes = new List<String>();
        
        if(!hasMAIN){
            missingContactTypes.add('MAIN');
        }
        
        if(isAPRequire && !hasAP){
            missingContactTypes.add('AP');
        }
        
       if(isPORequire && !hasPO){
            missingContactTypes.add('PO');
        }               
        
        System.debug('isMANIRequire:'+isMANIRequire);
        System.debug('hasMANI:'+hasMANI);
        if(isMANIRequire && !hasMANI){
            missingContactTypes.add('MANI');
        }
        
        missingConTypesString = String.join(missingContactTypes, ', ');
        
        System.debug('missingConTypesString: '+missingConTypesString);
        
    }//end populateMissingContactTypes()
    
    private void populateContactListBySection(String contactSection, List<Contact> accContactList){
        System.debug('populateContactListBySection: '+contactSection);
        
        List<SelectOption> contactOptions = new List<SelectOption>();
        contactOptions.add(new SelectOption('', '--None--'));
        for(Contact con : accContactList){
            contactOptions.add(new SelectOption(con.Id, con.Name));
        }
        
        List<String> contactTypeList;
        
        if(contactSection == 'primary'){
            contactTypeList = primaryContactTypes;
        }
        else{
            contactTypeList = additionalContactTypes;
        }
        
        for(String contactType : contactTypeList){
            Boolean hasContactType = false;
            for(Contact con : accContactList){
                if(String.isNotBlank(con.Contact_Type__c)){
                    Set<String> selectedConTypes = new Set<String>(con.Contact_Type__c.split(';'));
                    if(selectedConTypes.contains(contactType)){
                        hasContactType = true;
                        ContactWrap cw = new ContactWrap();
                        cw.con = con;
                        cw.conType = contactType;
                        cw.conDesc = conTypeDescMap.containsKey(contactType)?conTypeDescMap.get(contactType):contactType;
                        cw.conDef = conTypeDefnitionMap.containsKey(contactType)?conTypeDefnitionMap.get(contactType):contactType;               
                        if(contactSection == 'primary'){                            
                            contactsWrap.add(cw);
                        }
                        else{
                            contactsOWrap.add(cw);
                        }
                    }
                }//end if
            }//end - contact loop
            if(!hasContactType && contactSection == 'primary'){
        ContactWrap cw = new ContactWrap();
                cw.contactOptions = contactOptions;
                cw.conType = contactType;
                cw.conDesc = conTypeDescMap.containsKey(contactType)?conTypeDescMap.get(contactType):contactType;
                cw.conDef = conTypeDefnitionMap.containsKey(contactType)?conTypeDefnitionMap.get(contactType):contactType; 
                Boolean addToPrimarySection = true;
                if(contactType == 'AP' && !isAPRequire){
                    addToPrimarySection = false;  
                }
                else if(contactType == 'PO' && !isPORequire){
                    addToPrimarySection = false;  
                }
                else if(contactType == 'MANI' && !isMANIRequire){
                    addToPrimarySection = false;  
                }
                
                if(addToPrimarySection){
                  contactsWrap.add(cw);  
                }
            }
        }//end - primary contact type loop
    }
    @TestVisible 
    private String getContactDesc(Contact con){
        String conDesc = '';
        String[] selectedConTypes;
        if(String.isNotBlank(con.Contact_Type__c)){
            selectedConTypes = con.Contact_Type__c.split(';');
            for(String conType : selectedConTypes){
                if(String.isNotBlank(conDesc) && conTypeDescMap.containsKey(conType)){
                    conDesc += ', ';
                }
                
                conDesc +=  conTypeDescMap.containsKey(conType)? conTypeDescMap.get(conType):  '';
            }
        }
        
        return conDesc;
        
    }

    
    public void showHideConTypeDef(){
        showContactTypeDef = !showContactTypeDef;
    }
    
    public pageReference newContact(){  
        String encodedAccName = EncodingUtil.urlEncode(accounts.name, 'UTF-8');
        pageReference pageRef = new pageReference(URL.getSalesforceBaseUrl().toExternalForm() + '/003/e?con4='+encodedAccName+'&con4_lkid='+accounts.id+'&con4_mod=1'+'&retURL=' + accounts.id);
       // Account acc = (Account) controller.getRecord();
       
        return pageRef;

    } 
    
    public pageReference createNewContactType(){ 
       String encodedAccName = EncodingUtil.urlEncode(accounts.name, 'UTF-8');
    PageReference pageRef = new PageReference(URL.getSalesforceBaseUrl().toExternalForm() + '/003/e?con4='+encodedAccName+'&con4_lkid='+accounts.id+'&con4_mod=1'+'&00N4Q00000AuGbB='+newContactTypeValue+'&retURL=' + accounts.id);
       // Account acc = (Account) controller.getRecord();
       
        return pageRef;
    }
	
    public PageReference save() {
    List<Contact> contactLst = new List<Contact>();
    Map<Id, String> contactRecTypeMap = new Map<Id, String>();
    
    for (ContactWrap contactWrapper : contactsWrap) {
        if (contactWrapper.isUpdated) {
            contactWrapper.isUpdated = false;
            if (contactWrapper.con != null) {
                contactLst.add(contactWrapper.con);
            } else if (String.isNotBlank(contactWrapper.selectedContactId)) {
                contactRecTypeMap.put(contactWrapper.selectedContactId, contactWrapper.conType);
                contactWrapper.selectedContactId = null;
            }
        }
        if (contactsOWrap.contains(contactWrapper) && contactWrapper.con != null && contactWrapper.isUpdated) {
            contactLst.add(contactWrapper.con);
        }
    }
    
    for (Contact exCon : [SELECT Id, Contact_Type__c FROM Contact WHERE Id IN :contactRecTypeMap.keySet()]) {
        Set<String> exContTypeSet = new Set<String>();
        
        if (String.isNotBlank(exCon.Contact_Type__c)) {
            exContTypeSet = new Set<String>(exCon.Contact_Type__c.split(';'));
        }
        
        String conType = contactRecTypeMap.get(exCon.Id);
        
        if (!exContTypeSet.contains(conType)) {
            exContTypeSet.add(conType);
            String conTypes = String.join(new List<String>(exContTypeSet), ';');
            contactLst.add(new Contact(Id=exCon.Id, Contact_Type__c = conTypes));
        }
    }
    
    if (!contactLst.isEmpty()) {
        try {
            update contactLst;
        } catch (Exception ec) {
            if(!ec.getMessage().contains('The entered email address is associated with an existing contact')){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ec.getMessage()));
            } 
        }
    }
                
    getAccountInfo();
    getContactRealtedLists();
    
    return null;           
}
    
   public pageReference cancel(){  
      PageReference cancel = sctrl.cancel();
        return cancel;
    } 
    
    public void verifyContact(){
        
            Account updAcc = new Account();
            updAcc.Id = acc.Id;
            DateTime currTime = System.now();
            if(hasMainContact){
                updAcc.Main_Contact_Verified_Date__c = currTime;
            }
            if(hasAPContact){
                updAcc.AP_Contact_Verified_Date__c = currTime;
            }
            if(hasPOContact){
                updAcc.PO_Contact_Verified_Date__c = currTime;
            }
        
            Bypass_Account_Validation__c accountValidation = Bypass_Account_Validation__c.getOrgDefaults();
            if(hasMainContact || hasAPContact || hasPOContact)
                accountValidation.Bypass_Account_Country_Validation__c = true; 
        
            UPDATE accountValidation;
            update updAcc;
            
            daysSinceMainContVerified = 0;
            daysSinceAPContVerified = 0;
            daysSincePOContVerified = 0;
            this.hideContactVerified = false;
            
            
    }
    
    
    public class ContactTypeDef{
        public String contactType{get;set;}
        public String description{get;set;}
        public String definition{get;set;}
    }
    
    public class ContactWrap{
        public Boolean isUpdated {get;set;}
        public Contact con {get;set;}
        public String conType{get;set;}
        public String conDesc{get;set;}
        public String conDef{get;set;}
        public List<SelectOption> contactOptions {get;set;}
        public Id selectedContactId {get;set;}
        
        public ContactWrap(){
            this.isUpdated = false;
            this.contactOptions = new List<SelectOption>();
        }
    }
    
    public void getEmailAddressAPI(){
        
        System.debug('--- Account WIN ID '+accounts.WIN_ID__c);
        if(accounts.WIN_ID__c != NULL){
            try{
                String endPointURL = '?companycode='+accounts.WIN_ID__c;
                Http http = new Http();
                HttpRequest request = new HttpRequest(); 
                request.setHeader('Content-Type', 'text/plain');
                request.setEndpoint('callout:Email_Address_API_URL_NC'+endPointURL);
                request.setMethod('GET');
                request.setHeader('AuthToken', '{!$Credential.Password}');
                HttpResponse response = http.send(request);
                
                emailAddressFromAPI = 'Primary e-mail address not found';
                if(response.getStatusCode() == 200 && response.getBodyDocument() != NULL){
                    Dom.Document doc = response.getBodyDocument();
                    if(doc.getRootElement().getText() != ''){
                        emailAddressFromAPI = doc.getRootElement().getText();   
                    }               
                }
            }
            Catch(Exception e){
                System.debug('---Error Message: '+e.getMessage());
            }
        }
    }
    
}