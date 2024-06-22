public class SurfaceBranchListOnBranchAccount {
    
    @AuraEnabled 
    public static List<User> getSurfaceBranchListOnBranchAccount(Id accountId) {
        set<id> accountIds = new Set<id>{accountId};
        List<Account> branchAccounts = AccountDAO.getAccountsByIds(accountIds);
        List<GroupMember> level2GroupMembers = new List<GroupMember>();
        List<User> users =new List<User>();
        if(!branchAccounts.isEmpty())
        {
            List<Branch_Queue_Map__c> branchQueueList =[SELECT Id, Name, Branch_Queue__c FROM Branch_Queue_Map__c where Name = :branchAccounts[0].Branch_Code__c];
            if(!branchQueueList.isEmpty())
            {
                List<Group> groups = [SELECT Id FROM Group where name = :branchQueueList[0].Branch_Queue__c];
                if(!groups.isEmpty())
                {
                    Set<Id> userIds = new Set<Id>();
                    Set<Id> groupIds = new Set<Id>();
                    groupIds.add(groups[0].id);
                    List<GroupMember> GroupMembers = GroupDAO.getGroupMembersById(groupIds);
                    groupIds.Remove(groups[0].id);
                    for(GroupMember groupMem : GroupMembers)
                    {
                        Id userOrGroupId = groupMem.UserOrGroupId;
                        String userOrGroupName = userOrGroupId.getSObjectType().getDescribe().getName();
                        if(userOrGroupName == 'User')
                        {
                            userIds.add(groupMem.UserOrGroupId);
                        }
                        else
                        {
                            groupIds.add(groupMem.UserOrGroupId);
                        }
                    }
                    if(!groupIds.IsEmpty())
                    {
                        level2GroupMembers = GroupDAO.getGroupMembersById(groupIds);
                    }
                     for(GroupMember groupMem : level2GroupMembers)
                    {
                        userIds.add(groupMem.UserOrGroupId);
                    }
                    if(!userIds.IsEmpty())
                    {
                        users = UserDAO.getUserDetailsByUserId(userIds); 
                    }                    
                }
            }            
        }
        return users;
    }
    
}