public without sharing class GroupDAO {
    public static List<GroupMember> getGroupMembersById(Set<Id> groupMemIds) {
        return [SELECT Id, GroupId, UserOrGroupId FROM GroupMember where GroupId = :groupMemIds];
    }
}