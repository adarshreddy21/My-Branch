@isTest
public class SurfaceBranchListOnBranchAccountTests {
    @testSetup 
    private static void setup(){
        Group testGroup = new Group(Name='queu', Type='Regular');
        insert testGroup;
        Group testGroup1 = new Group(Name='sque', Type='Queue');
        insert testGroup1;
        System.runAs(new User(Id=UserInfo.getUserId())){
            List<QueueSobject> qs = new List<QueueSobject>();            
            qs.add(new QueueSobject (
                SobjectType='Case',
                QueueId = testGroup1.Id
            ));            
            Database.insert( qs );
            GroupMember queMem = new GroupMember();
            queMem.GroupId = testGroup1.Id;
            queMem.UserOrGroupId = UserInfo.getUserId();
            INSERT queMem;
            GroupMember queMem1 = new GroupMember();
            queMem1.GroupId = testGroup1.Id;
            queMem1.UserOrGroupId = testGroup.Id;
            INSERT queMem1;            
        }        
        Branch_Queue_Map__c branchQueueMap = new Branch_Queue_Map__c();
        branchQueueMap.Name = 'AA123';
        branchQueueMap.Branch_Queue__c = 'queu';
        INSERT branchQueueMap;        
        Branch_Queue_Map__c branchQueueMap1 = new Branch_Queue_Map__c();
        branchQueueMap1.Name = 'S123';
        branchQueueMap1.Branch_Queue__c = 'sque';
        INSERT branchQueueMap1;
        Id branchRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Branch').getRecordTypeId();
        Account a = new Account(Name='Test Account',RecordTypeId=branchRecTypeId,Branch_Opportunity_Allowed__c =true,Branch_Code__c ='S123' ,AccountSource='Web',Rank__c='CH A Large >200K',Industry_Segment__c='Other',Phone='5555555555',CS_EPA_ID__c='100',Generator_Status__c='Small Quantity Generator',Branch_Call_Origin_Flag__c=TRUE,CurrencyIsoCode='USD');
        insert a;
    }
    @isTest
    private static void getSurfaceBranchListOnBranchAccountTest(){
        List<Account> acc = [Select id from account where name='Test Account'];
        List<User> users = SurfaceBranchListOnBranchAccount.getSurfaceBranchListOnBranchAccount(acc[0].Id);
        System.assertNotEquals(null, users, 'No users found for the Branch Account.');
    }
    
}