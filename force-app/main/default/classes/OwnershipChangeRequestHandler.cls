/**
* @description       : 
* @author            : Vikram Simha
* @group             : 
* @last modified on  : 02-16-2022
* @last modified by  : Adarsh Reddy
* Modifications Log
* Ver   Date         Author           Modification
* 1.0   11-25-2022   Vikram Simha   Initial Version
* 2.0   02-16-2023   Adarsh Reddy   
**/  
public class OwnershipChangeRequestHandler { 
    private final String CHENV='Clean Harbors ENV';
    private final String CHEOG='CHES Oil and Gas';
    private final String CHEI='CHES Industrial';
    private final String SKENV='SK ENV';
    private final String SKBPS='SK BPS';
    private final String SKKPP='SK KPP';
    private final String VP= System.Label.Jonathan_Riley;
	private final String profiletoDeleteOCR = 'IT Super User,Integration,Premier Support User,System Administrator';
    public void setUserLookupFields(List<Ownership_Change_Request__c> newList)
    {
        Map<String,string> PBMap = new Map<string,string>();
        Set<id> accountids = new Set<id>();
        set<id> userIds = new set<id>();
        Map<id,id> userIdManagerId = new Map<id,id>();
        Map<id,id> userIdManagerVP = new Map<id,id>();
        Map<String,String> SVPOperatingSegmentId = new Map<String,String>();
        List<String> VpList= Label.SVP_Approval_User_Mapping.Split(',');
        for(string vpos : VpList)
        {
            SVPOperatingSegmentId.put(vpos.Split(':')[0],vpos.Split(':')[1]); 
        }
        //get the data from the custom metadata and put in a map
        List<User_Field_Mapping__mdt> segmentCustomMetadata = User_Field_Mapping__mdt.getAll().Values();
        Map<String,User_Field_Mapping__mdt> PrimaryserviceProviderMap = new Map<string,User_Field_Mapping__mdt>();
        for(User_Field_Mapping__mdt pBO : segmentCustomMetadata)
        {
            PrimaryserviceProviderMap.put(pBO.Primary_Business__c,pBO);
        }
        Map<id,id> userIdVpId = new Map<id,id>();
        for(Ownership_Change_Request__c ocr: newList)
        {
            accountids.add(ocr.Account__c);
            userIds.add(ocr.New_Owner__c);
        }
        String query = 'Select id,ownerid,Primary_Business__c,Primary_Service_Provider_New__c, ShippingCountry, RecordTypeId,Previous_Year_Customer_Revenue__c  from Account where id in :accountIds';
        Map<id,Account> accountMap= new Map<id,Account>((List<Account>)Database.query(query));
        for(Account acc : AccountMap.Values())
        {
            userIds.add(acc.ownerid);
        }
        Map<id,user> userMap = new Map<id,user>([select id,name,ManagerId,Manager.ManagerId,Sales_SVP__c,Primary_Business__c,Sales_Branch__c,Sales_Person_Type__c from user where id in : userIds]);
        for(Id userId : userMap.keyset())
        {
            userIdManagerId.put(userId,userMap.get(userId).ManagerId);
            userIdVpId.put(userId,userMap.get(userId).Manager.ManagerId);
        }
        for(Ownership_Change_Request__c ocr: newList)
        {
            ocr.Account_Owner_del__c = accountMap.get(ocr.Account__c).ownerid;
            ocr.Status__c = 'Draft';
           if(accountMap.ContainsKey(ocr.Account__c) && (accountMap.get(ocr.Account__c).Primary_Service_Provider_New__c == SKENV || accountMap.get(ocr.Account__c).Primary_Service_Provider_New__c == SKBPS || accountMap.get(ocr.Account__c).Primary_Service_Provider_New__c == SKKPP))
            {
                if(userMap.get(ocr.Account_Owner_del__c).Sales_Branch__c == 'PUS' && userMap.get(ocr.Account_Owner_del__c).Sales_Person_Type__c== 'ISAM'){
                ocr.Existing_Owner_s_Manager__c = VP;
            }
              else {
                ocr.Existing_Owner_s_Manager__c = userIdManagerId.get(ocr.Account_Owner_del__c);
            }
            }
             else if (userIdManagerId.ContainsKey(ocr.Account_Owner_del__c) ){
                ocr.Existing_Owner_s_Manager__c = userIdManagerId.get(ocr.Account_Owner_del__c);
            } 
            if(accountMap.ContainsKey(ocr.Account__c) && (accountMap.get(ocr.Account__c).Primary_Service_Provider_New__c == SKENV || accountMap.get(ocr.Account__c).Primary_Service_Provider_New__c == SKBPS || accountMap.get(ocr.Account__c).Primary_Service_Provider_New__c == SKKPP))
            {
                if(userMap.get(ocr.Account_Owner_del__c).Sales_Branch__c == 'PUS' && userMap.get(ocr.Account_Owner_del__c).Sales_Person_Type__c== 'ISAM'){
                ocr.Existing_Owner_s_VP__c = null;
            }
              else {
                ocr.Existing_Owner_s_VP__c = userIdVpId.get(ocr.Account_Owner_del__c);
            }
            }
            else if(userIdVpId.ContainsKey(ocr.Account_Owner_del__c)){
                ocr.Existing_Owner_s_VP__c = userIdVpId.get(ocr.Account_Owner_del__c);
            } 
            
                if(ocr.New_Owner__c!=null){
                    if(accountMap.ContainsKey(ocr.Account__c) && (accountMap.get(ocr.Account__c).Primary_Service_Provider_New__c == SKENV || accountMap.get(ocr.Account__c).Primary_Service_Provider_New__c == SKBPS || accountMap.get(ocr.Account__c).Primary_Service_Provider_New__c == SKKPP))
            {
                if(userMap.get(ocr.New_Owner__c).Sales_Branch__c == 'PUS' && userMap.get(ocr.New_Owner__c).Sales_Person_Type__c == 'ISAM'){
                    ocr.New_Owner_s_Manager__c = VP;
                }
                
                 else {
                    ocr.New_Owner_s_Manager__c = userIdManagerId.get(ocr.New_Owner__c);
                }
            }
                 else   if(userIdManagerId.ContainsKey(ocr.New_Owner__c)){
                    ocr.New_Owner_s_Manager__c = userIdManagerId.get(ocr.New_Owner__c);
                }
                
            if(accountMap.ContainsKey(ocr.Account__c) && (accountMap.get(ocr.Account__c).Primary_Service_Provider_New__c == SKENV || accountMap.get(ocr.Account__c).Primary_Service_Provider_New__c == SKBPS || accountMap.get(ocr.Account__c).Primary_Service_Provider_New__c == SKKPP))
            {
                if(userMap.get(ocr.New_Owner__c).Sales_Branch__c == 'PUS' && userMap.get(ocr.New_Owner__c).Sales_Person_Type__c == 'ISAM'){
                  ocr.New_Owner_s_VP__c = null;
                }
               else  {
                    ocr.New_Owner_s_VP__c = userIdVpId.get(ocr.New_Owner__c);
                }
            }
                 else if(userIdVpId.ContainsKey(ocr.New_Owner__c)){
                    ocr.New_Owner_s_VP__c = userIdVpId.get(ocr.New_Owner__c);
                } 

                if(userMap.containsKey(ocr.New_Owner__c) && userMap.get(ocr.New_Owner__c).Primary_Business__c != null && PrimaryserviceProviderMap.containskey(userMap.get(ocr.New_Owner__c).Primary_Business__c)){
                    ocr.New_Operating_Segment__c = PrimaryserviceProviderMap.get(userMap.get(ocr.New_Owner__c).Primary_Business__c).Operating_Segment__c;
                    if(PrimaryserviceProviderMap.get(userMap.get(ocr.New_Owner__c).Primary_Business__c).Primary_Service_Provider__c != 'SK ENV'){
                        ocr.New_Primary_Service_Provider__c = PrimaryserviceProviderMap.get(userMap.get(ocr.New_Owner__c).Primary_Business__c).Primary_Service_Provider__c;
                    }
                    else{
                        ocr.New_Primary_Service_Provider__c = 'Safety-Kleen';
                    }
                }
            }
            ocr.Prior_year_s_revenue__c =accountMap.get(ocr.Account__c).Previous_Year_Customer_Revenue__c;
            if(accountMap.ContainsKey(ocr.Account__c) && (accountMap.get(ocr.Account__c).Primary_Service_Provider_New__c == CHENV || accountMap.get(ocr.Account__c).Primary_Service_Provider_New__c == CHEOG || accountMap.get(ocr.Account__c).Primary_Service_Provider_New__c == CHEI) && accountMap.get(ocr.Account__c).Previous_Year_Customer_Revenue__c <100000 )
            {
                ocr.New_Owner_s_VP__c = null;
                ocr.Existing_Owner_s_VP__c = null;
            }
            else if(accountMap.ContainsKey(ocr.Account__c) && (accountMap.get(ocr.Account__c).Primary_Service_Provider_New__c == SKENV || accountMap.get(ocr.Account__c).Primary_Service_Provider_New__c == SKBPS || accountMap.get(ocr.Account__c).Primary_Service_Provider_New__c == SKKPP)  && accountMap.get(ocr.Account__c).Previous_Year_Customer_Revenue__c <10000)
            {
                ocr.Existing_Owner_s_VP__c = null;
                ocr.New_Owner_s_VP__c = null;
            }
            if(accountMap.ContainsKey(ocr.Account__c) && (accountMap.get(ocr.Account__c).Primary_Service_Provider_New__c != null))
            {
                ocr.Account_Operating_Segment_Text__c =  accountMap.get(ocr.Account__c).Primary_Service_Provider_New__c;
            }
            if(accountMap.ContainsKey(ocr.Account__c) && (accountMap.get(ocr.Account__c).Primary_Business__c != null))
            {
                ocr.Account_Primary_Service_Provider_Text__c = accountMap.get(ocr.Account__c).Primary_Business__c;
            }
        } 
    } 
    public void updateNewOwnerUserLookupFields(List<Ownership_Change_Request__c> newList,Map<id,sObject> oldMap)  
    {
        List<id> userIds = new List<id>();
        for(sObject oCR : newList)
        {
            Ownership_Change_Request__c OCRobj = (Ownership_Change_Request__c) OCR;
            if(!oldMap.isEmpty()){
                Ownership_Change_Request__c OCROldobj = (Ownership_Change_Request__c) oldMap.get(OCRobj.id);
                if(OCRobj.New_Owner__c != OCROldobj.New_Owner__c)
                {
                    userIds.add(OCRobj.New_Owner__c);
                }
            }
            else
            {
                userIds.add(OCRobj.New_Owner__c);
            }
        }
        if(!userIds.IsEmpty()){
            Map<String,User_Field_Mapping__mdt> PrimaryserviceProviderMap = new Map<string,User_Field_Mapping__mdt>();
            List<User_Field_Mapping__mdt> segmentCustomMetadata = User_Field_Mapping__mdt.getAll().Values();
            for(User_Field_Mapping__mdt pBO : segmentCustomMetadata)
            {
                PrimaryserviceProviderMap.put(pBO.Primary_Business__c,pBO);
            }
            Map<id,user> userMap = new Map<id,user>([select id,name,ManagerId,Manager.ManagerId,Sales_SVP__c,Primary_Business__c,Sales_Branch__c, Sales_Person_Type__c from user where id in : userIds]);
            for(Ownership_Change_Request__c OCRobj : newList)
            {
               
                if(OCRobj.New_Owner__c != null && userMap.containsKey(OCRobj.New_Owner__c))
                {
                    if(userMap.get(OCRobj.New_Owner__c).Primary_Business__c !=null &&PrimaryserviceProviderMap.containskey(userMap.get(OCRobj.New_Owner__c).Primary_Business__c) ){
                        OCRobj.New_Operating_Segment__c = PrimaryserviceProviderMap.get(userMap.get(OCRobj.New_Owner__c).Primary_Business__c).Operating_Segment__c;
                        if(PrimaryserviceProviderMap.get(userMap.get(OCRobj.New_Owner__c).Primary_Business__c).Primary_Service_Provider__c != 'SK ENV'){
                            OCRobj.New_Primary_Service_Provider__c = PrimaryserviceProviderMap.get(userMap.get(OCRobj.New_Owner__c).Primary_Business__c).Primary_Service_Provider__c;
                        }
                        else{
                            OCRobj.New_Primary_Service_Provider__c = 'Safety-Kleen';
                        }
                    }
                    else if(userMap.get(OCRobj.New_Owner__c).Primary_Business__c == null)
                    {
                         OCRobj.addError(Label.RequestedOSandPSPRequired);
                    } 
                    else
                    {
                        OCRobj.New_Operating_Segment__c ='';
                        OCRobj.New_Primary_Service_Provider__c ='';
                    }
                    OCRobj.New_Owner_s_VP__c=userMap.get(OCRobj.New_Owner__c).Manager.ManagerId;
                    OCRobj.New_Owner_s_Manager__c=userMap.get(OCRobj.New_Owner__c).ManagerId;
                   
                    if(OCRobj.New_Owner__c!=null){
                if(userMap.get(OCRobj.New_Owner__c).Sales_Branch__c == 'PUS' && userMap.get(OCRobj.New_Owner__c).Sales_Person_Type__c == 'ISAM'){
                    OCRobj.New_Owner_s_Manager__c = VP;
					OCRobj.New_Owner_s_VP__c = null;
                } 
                    }
                }
            }
        } 
    }
    public void checkDuplicateOwnershipRecord(Map<id,sObject> newMap,Map<id,sObject> oldMap)
    {
        List<Id> accountIds = new List<Id>();
        Map<Id,Ownership_Change_Request__c> accountIdOwnershipMap = new Map<Id,Ownership_Change_Request__c>();
        for(sObject oCR : newMap.values())
        {
            Ownership_Change_Request__c OCRobj = (Ownership_Change_Request__c) OCR;
            Ownership_Change_Request__c OCROldobj = (Ownership_Change_Request__c) oldMap.get(OCRobj.id);
            if(OCRobj.Status__c != OCROldobj.Status__c &&  OCRobj.Status__c == 'Submitted'){
                accountIds.add(OCRobj.Account__c);
            }
        }
        List<Ownership_Change_Request__c> changeRecords =[select id,Account__c from Ownership_Change_Request__c where Account__c in : accountIds and Status__c != 'Executed' and Status__c != 'Draft' and Status__c != 'Rejected' and Status__c != 'Failed'];
        for(Ownership_Change_Request__c changeRecord : changeRecords)
        {
            accountIdOwnershipMap.put(changeRecord.Account__c,changeRecord);
        }
        for(sObject pBO : newMap.values())
        {
            Ownership_Change_Request__c OCRobj = (Ownership_Change_Request__c) pBO;
            if(accountIdOwnershipMap.ContainsKey(OCRobj.Account__c))
            {
                OCRobj.addError(Label.Accountownershipchangehasalreadybeensubmitted);
            } 
        }
    }
    public void checkOperatingSegmentChange(Map<id,sObject> newMap,Map<id,sObject> oldMap)
    {
        List<id> accountIds = new List<id>();
        List<string> chesOperatingSegment = new List<string>{CHENV,CHEOG,CHEI};
            for(sObject oCR : newMap.values())
        {
            Ownership_Change_Request__c OCRobj = (Ownership_Change_Request__c) OCR;
            Ownership_Change_Request__c OCROldobj = (Ownership_Change_Request__c) oldMap.get(OCRobj.id);
            if(OCRobj.Status__c != OCROldobj.Status__c &&  OCRobj.Status__c == 'Submitted' 
               && (OCROldobj.Account_Operating_Segment__c == CHENV || OCROldobj.Account_Operating_Segment__c == CHEOG || OCROldobj.Account_Operating_Segment__c == CHEI) 
               && (OCRobj.New_Operating_Segment__c == SKENV || OCRobj.New_Operating_Segment__c == SKBPS || OCRobj.New_Operating_Segment__c == SKKPP) )
            {
                //check if there is child and throw error
                accountIds.add(OCRobj.Account__c);
            }
        }
        List<Account> accounts =[select id,Primary_Service_Provider_New__c,parentid from account where parentid in :accountIds and Type ='ShipTo/Gen'];
        Map<id,Account> parentIdAccountMap = new Map<id,Account>();
        for(Account acc : accounts)
        {
            parentIdAccountMap.put(acc.parentid,acc);
        }
        for(sObject oCR : newMap.values())
        {
            Ownership_Change_Request__c OCRobj = (Ownership_Change_Request__c) OCR;
            if(parentIdAccountMap.containsKey(OCRobj.Account__c))
            {
                oCR.addError(Label.CHES_to_SKE_not_eligible);
            }
        }
    } 
    public void checkDuplicateOwnershipRequest(List<Ownership_Change_Request__c> newList)
    {
        List<Id> accountIds = new List<Id>();
        Map<Id,Ownership_Change_Request__c> accountIdOwnershipMap = new Map<Id,Ownership_Change_Request__c>();
        for(Ownership_Change_Request__c pBO : newList)
        {
            accountIds.add(pBO.Account__c);
        }
        List<Ownership_Change_Request__c> changeRecords =[select id,Account__c from Ownership_Change_Request__c where Account__c in : accountIds and Status__c != 'Executed' and Status__c != 'Draft' and Status__c != 'Rejected' and Status__c != 'Failed'];
        for(Ownership_Change_Request__c changeRecord : changeRecords)
        {
            accountIdOwnershipMap.put(changeRecord.Account__c,changeRecord);
        }
        for(Ownership_Change_Request__c pBO : newList)
        {
            if(accountIdOwnershipMap.ContainsKey(pBO.Account__c))
            {
                pBO.addError(Label.Accountownershipchangehasalreadybeensubmitted);
            } 
        }
    }
    @InvocableMethod(label = 'Update Next Approver on OCR' Description= 'Update Next Approver on OCR Apex Method')
    public static void updateNextApproveronOCR(List<id> oCRId)
    {
        if(!oCRId.IsEmpty()){
            List<ProcessInstance> pendingApproverLst = [select id, targetobjectid, (SELECT actor.name,originalactorid,StepStatus FROM StepsAndWorkitems) 
                                                        from ProcessInstance where targetobjectid in :oCRId];
            Ownership_Change_Request__c oCRObj = new Ownership_Change_Request__c();
            boolean isApproved = true;
            if(!pendingApproverLst.isEmpty()){
                oCRObj.id = oCRId[0];
                for(ProcessInstance p: pendingApproverLst){
                    for(ProcessInstanceHistory h: p.StepsAndWorkitems){
                        if(h.StepStatus == 'Pending'){
                            oCRObj.Next_Approver__c = h.OriginalActorId;
                            isApproved = false;
                        }
                    }
                }
            }
            if(isApproved)
            {
                oCRObj.Next_Approver__c = null;
            } 
                update oCRObj;
        }
    }
    public void checkSKRoutetoBPS(List<Ownership_Change_Request__c> newList,Map<id,sObject> oldMap)
    {
        List<String> territoryName = new List<String>();
        List<id> accountIds = new List<id>();
        List<id> requestedOwnerIds = new List<id>();
        for(Ownership_Change_Request__c OCRobj : newList)
        {
            Ownership_Change_Request__c OCROldobj = (Ownership_Change_Request__c) oldMap.get(OCRobj.id);
            if(OCRobj.Status__c != OCROldobj.Status__c &&  OCRobj.Status__c == 'Submitted' )
            {
                accountIds.add(OCRobj.Account__c);
                requestedOwnerIds.add(OCRobj.New_Owner__c);
            }
        }
        Map<id,Account> accountsMap =new Map<id,Account>([select id,ZIP_Master__c,ZIP_Master__r.Name,Primary_Service_Provider_New__c,parentid from account where id in :accountIds]);
        Map<id,user> userMap = new Map<id,user>([select id,name,Territory__c from user where id in : requestedOwnerIds]);
        for(Ownership_Change_Request__c OCRobj : newList)
        {
            
            Ownership_Change_Request__c OCROldobj = (Ownership_Change_Request__c) oldMap.get(OCRobj.id);
            if(OCRobj.Status__c != OCROldobj.Status__c &&  OCRobj.Status__c == 'Submitted'  
               && (OCRobj.New_Operating_Segment__c == SKENV || OCRobj.New_Operating_Segment__c == SKBPS) )
            {
                if(userMap.containsKey(OCRobj.New_Owner__c) && accountsMap.containsKey(OCRobj.Account__c) && userMap.get(OCRobj.New_Owner__c).Territory__c != null && accountsMap.get(OCRobj.Account__c).ZIP_Master__c != null)
                {
                    if(userMap.get(OCRobj.New_Owner__c).Territory__c != null && (userMap.get(OCRobj.New_Owner__c).Territory__c.contains('INS-PUS') || userMap.get(OCRobj.New_Owner__c).Territory__c.contains('BPS-IS')))
                    {
                        if(OCRobj.New_Operating_Segment__c == SKENV)
                        {
                            territoryName.add(accountsMap.get(OCRobj.Account__c).ZIP_Master__r.Name+'-SKE-IS');
                        }
                        else if(OCRobj.New_Operating_Segment__c == SKBPS)
                        {
                            territoryName.add(accountsMap.get(OCRobj.Account__c).ZIP_Master__r.Name+'-BPS-IS');
                        }
                    }
                    else if(userMap.get(OCRobj.New_Owner__c).Territory__c != null && userMap.get(OCRobj.New_Owner__c).Territory__c.contains('AM') && !userMap.get(OCRobj.New_Owner__c).Territory__c.contains('ISAM'))
                    {
                        if(OCRobj.New_Operating_Segment__c == SKENV)
                        {
                            territoryName.add(accountsMap.get(OCRobj.Account__c).ZIP_Master__r.Name+'-Safety-Kleen');
                        }
                        else if(OCRobj.New_Operating_Segment__c == SKBPS)
                        {
                            territoryName.add(accountsMap.get(OCRobj.Account__c).ZIP_Master__r.Name+'-BPS');
                        }
                    }
                    else if(userMap.get(OCRobj.New_Owner__c).Territory__c != null && userMap.get(OCRobj.New_Owner__c).Territory__c.contains('SR'))
                    {
                        if(OCRobj.New_Operating_Segment__c == SKENV){
                            territoryName.add(accountsMap.get(OCRobj.Account__c).ZIP_Master__r.Name+'-Safety-Kleen');
                        }
                        else if(OCRobj.New_Operating_Segment__c == SKBPS)
                        {
                            territoryName.add(accountsMap.get(OCRobj.Account__c).ZIP_Master__r.Name+'-BPS');
                        }
                    }
                    else
                    {
                        if(OCRobj.New_Operating_Segment__c == SKENV)
                        {
                            territoryName.add(accountsMap.get(OCRobj.Account__c).ZIP_Master__r.Name+'-Safety-Kleen');
                        }
                        else if(OCRobj.New_Operating_Segment__c == SKBPS)
                        {
                            territoryName.add(accountsMap.get(OCRobj.Account__c).ZIP_Master__r.Name+'-BPS');
                        }
                    }
                    OCRobj.Requested_Owner_Territory_Id__c = userMap.get(OCRobj.New_Owner__c).Territory__c;
                }
                else if(userMap.containsKey(OCRobj.New_Owner__c) && userMap.get(OCRobj.New_Owner__c).Territory__c == null)
                {
                    OCRobj.addError('Territory Id on New Account Owner is not populated.');
                }
            }
            else if (OCRobj.Status__c != OCROldobj.Status__c &&  OCRobj.Status__c == 'Submitted' && userMap.containsKey(OCRobj.New_Owner__c) && userMap.get(OCRobj.New_Owner__c).Territory__c != null)
            {
                OCRobj.Requested_Owner_Territory_Id__c = userMap.get(OCRobj.New_Owner__c).Territory__c;
            }
            else if(userMap.containsKey(OCRobj.New_Owner__c) && userMap.get(OCRobj.New_Owner__c).Territory__c == null)
            {
                OCRobj.addError('Territory Id on New Account Owner is not populated.');
            }
        }
        List<Territory_Master__c> terMasterList = [select id, Name, Territory_ID__c,Branch_Account__c, Territory_ID__r.Name, ZIP_Master__c, ZIP_Master__r.Name from Territory_Master__c where Name in :territoryName];
        Map<string,Territory_Master__c> TerMasterNameMap = new Map<string,Territory_Master__c>();
        for(Territory_Master__c terMaster : terMasterList)
        {
            TerMasterNameMap.put(terMaster.Name,terMaster);
        }
        for(Ownership_Change_Request__c OCRobj : newList)
        {
             Ownership_Change_Request__c OCROldobj = (Ownership_Change_Request__c) oldMap.get(OCRobj.id);
            if(OCRobj.Status__c != OCROldobj.Status__c &&  OCRobj.Status__c == 'Submitted'  
               && (OCRobj.New_Operating_Segment__c == SKENV || OCRobj.New_Operating_Segment__c == SKBPS) )
            {
                if(userMap.containsKey(OCRobj.New_Owner__c))
                {
                    if(userMap.get(OCRobj.New_Owner__c).Territory__c != null && (userMap.get(OCRobj.New_Owner__c).Territory__c.contains('INS-PUS') || userMap.get(OCRobj.New_Owner__c).Territory__c.contains('BPS-IS')))
                    {
                        if(OCRobj.New_Operating_Segment__c == SKENV && accountsMap.get(OCRobj.Account__c).ZIP_Master__c !=null && TerMasterNameMap.ContainsKey(accountsMap.get(OCRobj.Account__c).ZIP_Master__r.Name+'-SKE-IS'))
                        {
                          OCRobj.To_Be_Territory_ID__c =  TerMasterNameMap.get(accountsMap.get(OCRobj.Account__c).ZIP_Master__r.Name+'-SKE-IS').Territory_ID__r.Name;
                        }
                        else if(OCRobj.New_Operating_Segment__c == SKBPS && accountsMap.get(OCRobj.Account__c).ZIP_Master__c !=null && TerMasterNameMap.ContainsKey(accountsMap.get(OCRobj.Account__c).ZIP_Master__r.Name+'-BPS-IS'))
                        {
                            OCRobj.To_Be_Territory_ID__c = TerMasterNameMap.get(accountsMap.get(OCRobj.Account__c).ZIP_Master__r.Name+'-BPS-IS').Territory_ID__r.Name;
                        }
                    }
                    else if(userMap.get(OCRobj.New_Owner__c).Territory__c != null && userMap.get(OCRobj.New_Owner__c).Territory__c.contains('AM') && !userMap.get(OCRobj.New_Owner__c).Territory__c.contains('ISAM'))
                    {
                        if(OCRobj.New_Operating_Segment__c == SKENV && accountsMap.get(OCRobj.Account__c).ZIP_Master__c !=null && TerMasterNameMap.ContainsKey(accountsMap.get(OCRobj.Account__c).ZIP_Master__r.Name+'-Safety-Kleen'))
                        {
                            OCRobj.To_Be_Territory_ID__c = TerMasterNameMap.get(accountsMap.get(OCRobj.Account__c).ZIP_Master__r.Name+'-Safety-Kleen').Territory_ID__r.Name;
                        }
                        else if(OCRobj.New_Operating_Segment__c == SKBPS && accountsMap.get(OCRobj.Account__c).ZIP_Master__c !=null && TerMasterNameMap.ContainsKey(accountsMap.get(OCRobj.Account__c).ZIP_Master__r.Name+'-BPS'))
                        {
                            OCRobj.To_Be_Territory_ID__c = TerMasterNameMap.get(accountsMap.get(OCRobj.Account__c).ZIP_Master__r.Name+'-BPS').Territory_ID__r.Name;
                        }
                    }
                    else if(userMap.get(OCRobj.New_Owner__c).Territory__c != null && userMap.get(OCRobj.New_Owner__c).Territory__c.contains('SR'))
                    {
                        if(OCRobj.New_Operating_Segment__c == SKENV && accountsMap.get(OCRobj.Account__c).ZIP_Master__c !=null && TerMasterNameMap.ContainsKey(accountsMap.get(OCRobj.Account__c).ZIP_Master__r.Name+'-Safety-Kleen')){
                           OCRobj.To_Be_Territory_ID__c = TerMasterNameMap.get(accountsMap.get(OCRobj.Account__c).ZIP_Master__r.Name+'-Safety-Kleen').Territory_ID__r.Name;
                        }
                        else if(OCRobj.New_Operating_Segment__c == SKBPS && accountsMap.get(OCRobj.Account__c).ZIP_Master__c !=null && TerMasterNameMap.ContainsKey(accountsMap.get(OCRobj.Account__c).ZIP_Master__r.Name+'-BPS'))
                        {
                            OCRobj.To_Be_Territory_ID__c = TerMasterNameMap.get(accountsMap.get(OCRobj.Account__c).ZIP_Master__r.Name+'-BPS').Territory_ID__r.Name;
                        }
                    }
                    
                    
                }
            }
        }
        set<string> terrNames = new set<string>(); 
        for(Ownership_Change_Request__c OCRobj : newList)
        {   
            if(userMap.containsKey(OCRobj.New_Owner__c) && userMap.get(OCRobj.New_Owner__c).Territory__c != null && userMap.get(OCRobj.New_Owner__c).Territory__c.contains('AM') && !userMap.get(OCRobj.New_Owner__c).Territory__c.contains('ISAM'))
            {
                if(OCRobj.To_Be_Territory_ID__c != OCRobj.Requested_Owner_Territory_Id__c )  
                {   
                    terrNames.add(OCRobj.Requested_Owner_Territory_Id__c);
                }
            } 
        }
        if(!terrNames.isEmpty()){
            List<Territory__c> territoryList =  [SELECT Id,Name,Primary_Branch__c FROM Territory__c WHERE Name in :terrNames];
            Map<string,string> territoryMap = new Map<string,string>();
            for(Territory__c terr : territoryList)
            {
                territoryMap.put(terr.Name, terr.Primary_Branch__c);
            }
            for(Ownership_Change_Request__c OCRobj : newList)
            {
                if(userMap.get(OCRobj.New_Owner__c).Territory__c != null && userMap.get(OCRobj.New_Owner__c).Territory__c.contains('AM') && !userMap.get(OCRobj.New_Owner__c).Territory__c.contains('ISAM'))
                {
                    if(OCRobj.To_Be_Territory_ID__c != OCRobj.Requested_Owner_Territory_Id__c )  
                    {  
                        String branchId = '';
                        if(OCRobj.New_Operating_Segment__c == SKENV && accountsMap.get(OCRobj.Account__c).ZIP_Master__c !=null && TerMasterNameMap.ContainsKey(accountsMap.get(OCRobj.Account__c).ZIP_Master__r.Name+'-Safety-Kleen'))
                        {
                            branchId = TerMasterNameMap.get(accountsMap.get(OCRobj.Account__c).ZIP_Master__r.Name+'-Safety-Kleen').Branch_Account__c;
                        }
                        else if(OCRobj.New_Operating_Segment__c == SKBPS && accountsMap.get(OCRobj.Account__c).ZIP_Master__c !=null && TerMasterNameMap.ContainsKey(accountsMap.get(OCRobj.Account__c).ZIP_Master__r.Name+'-BPS'))
                        {
                            branchId = TerMasterNameMap.get(accountsMap.get(OCRobj.Account__c).ZIP_Master__r.Name+'-BPS').Branch_Account__c;
                        }
                        String branchidterr = territoryMap.get(OCRobj.Requested_Owner_Territory_Id__c);
                        if(branchId==branchidterr)
                        {
                            OCRobj.IS_Am_Flag__c = true;
                        }
                    }
                }
            }
        }
    }
    public void allowDeleteifDraftandCreatedBy(Map<id,sObject> oldMap)
    {
        Set<Id> profileIds = new Set<Id>();
        List<Profile> profilesAllowDelete = [select id from Profile where Name in : profiletoDeleteOCR.split(',')];
        for(Profile profileRec : profilesAllowDelete)
        {
            profileIds.add(profileRec.Id);
        }
        for(sObject ocrObj :oldMap.Values())
        {
            Ownership_Change_Request__c OCROldobj = (Ownership_Change_Request__c) oldMap.get(ocrObj.id);
            if(OCROldobj.Status__c == 'Draft' && OCROldobj.CreatedById != UserInfo.getUserId() &&  !profileIds.contains(UserInfo.getProfileId()))
            {
                ocrObj.addError('You dont access to perform delete operation.');
            }
        }
        
    }
	
	public void updateOCRQuarterFlipEligibility(List<Ownership_Change_Request__c> ownerShipChangeLst){
        Map<Id, Ownership_Change_Request__c> accountMap = new Map<Id, Ownership_Change_Request__c>();
        
        for(Ownership_Change_Request__c ownerShipChangeRequestRec : ownerShipChangeLst){
            if(ownerShipChangeRequestRec.Account__c != NULL){
                accountMap.put(ownerShipChangeRequestRec.Account__c, ownerShipChangeRequestRec);
            }
        }
              
        List<AggregateResult> financialRecords = [
            SELECT Account__c, SUM(Customer_Amount__c), SUM(Amount__c), SUM(Customer_Oil_Gallons_Collected__c), SUM(Location_Oil_Gallons_Collected__c) 
            FROM Financials__c 
            WHERE Account__c IN :accountMap.keySet()
            AND Month__c >= LAST_N_MONTHS:12
            GROUP BY Account__c
        ];
        
        Set<Id> accountsWithRecords = new Set<Id>();
        for (AggregateResult record : financialRecords) {
            Decimal totalCustomerRevenue = (Decimal)record.get('expr0') != null ? (Decimal)record.get('expr0') : 0;
            Decimal totalLocationRevenue = (Decimal)record.get('expr1') != null ? (Decimal)record.get('expr1') : 0;
            Decimal totalCustomerGallonRevenue = (Decimal)record.get('expr2') != null ? (Decimal)record.get('expr2') : 0;
            Decimal totalLocationGallonRevenue = (Decimal)record.get('expr3') != null ? (Decimal)record.get('expr3') : 0;
            
            accountsWithRecords.add((Id)record.get('Account__c'));
            Ownership_Change_Request__c changeRequest = accountMap.get((Id)record.get('Account__c'));
            if (totalCustomerRevenue == 0 && totalCustomerGallonRevenue == 0 &&
                totalLocationRevenue == 0 && totalLocationGallonRevenue == 0) {
                    changeRequest.EligibileForIntraQuarterFlip__c = true;
                }
                else{
                    changeRequest.EligibileForIntraQuarterFlip__c = false;
                }
        }
        
        for (Id accountId : accountMap.keySet()) {
            if (!accountsWithRecords.contains(accountId)) {
                Ownership_Change_Request__c changeRequest = accountMap.get(accountId);
                changeRequest.EligibileForIntraQuarterFlip__c = true;
            }
            
        }
    }

    public void validateNewAccountOwnerOCR(List<Ownership_Change_Request__c> ownerShipChangeRequestLst, Map<Id,sObject> oldMap){
    	Set<Id> userIds = new Set<Id>();
        Set<Id> accountIds = new Set<Id>();
        Set<String> territoryNames = new Set<String>();
        Map<String, Territory__c> territoryMap = new Map<String, Territory__c>();

        for(Ownership_Change_Request__c ocrRequest : ownerShipChangeRequestLst){
            userIds.add(ocrRequest.New_Owner__c);
            accountIds.add(ocrRequest.Account__c);
        }
        
        Map<Id,Account> accountsMap = new Map<Id,Account>(AccountDAO.getAccountTerritoryId(accountIds));
        Map<Id,User> userMap = new Map<Id,User>(UserDAO.getUserTerritory(userIds));
        
        for(User user : userMap.values()){
            if(user.Territory__c != null){
                territoryNames.add(user.Territory__c);
            }
        }
        
        for(Territory__c territory : TerritoryDAO.getUserTerritoryDetails(territoryNames)){
            territoryMap.put(territory.Name, territory);
        }
        
        for(Ownership_Change_Request__c ocr : ownerShipChangeRequestLst){
            User user = userMap.get(ocr.New_Owner__c);
            Account account = accountsMap.get(ocr.Account__c);
            if(user != null && territoryMap.containsKey(user.Territory__c)){
                Territory__c territory = territoryMap.get(user.Territory__c);
                if(account.Territory_ID_SK__r.Territory_Language__c == 'French' && territory.Territory_Language__c == 'English' && 
                  	(territory.Territory_Type__c == 'BDR' || territory.Territory_Type__c == 'ISAM')){
                	ocr.addError('This account is assigned to a territory that requires a French speaking salesperson. You are not eligible to own this account.');
                }
            }
        }
    }
}