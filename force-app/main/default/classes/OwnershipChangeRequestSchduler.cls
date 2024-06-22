public class OwnershipChangeRequestSchduler implements Schedulable{  
     String query = '';
    public OwnershipChangeRequestSchduler(String query)
    {
        this.query = query;
    }
    public void execute(SchedulableContext SC) {
        if(query=='')
        {
            query = 'SELECT Id, Name, Account__c, Account_Owner_del__c,Account_Operating_Segment_Text__c,Requested_Owner_Territory_Id__c, Account_Operating_Segment__c,Account_Primary_Service_Provider_Text__c, Account_Primary_Service_Provider__c,'+
                'Current_Account_Owner__c, Requested_Account_Owner__c, New_Owner__c, Justification__c, New_Owner_s_Manager__c, New_Owner_s_VP__c, Existing_Owner_s_Manager__c, Existing_Owner_s_VP__c, Effective_Date__c, Status__c, New_Operating_Segment__c, New_Primary_Service_Provider__c, Prior_year_s_revenue__c, Need_Existing_Manager_Approval__c, Account_Owner_Managers_Same__c,'+
                'Account_Owner_Vps_Same__c,  Reason_for_Change__c FROM Ownership_Change_Request__c where Status__c = \'Approved-Pending\'  AND Intra_Quarter_Flip__c =true';
        }
        AccountOwnershipChangeBatch accountOwnerShipChangeBatchObj = new AccountOwnershipChangeBatch(query); 
        Database.executeBatch(accountOwnerShipChangeBatchObj, 150);
    }
}