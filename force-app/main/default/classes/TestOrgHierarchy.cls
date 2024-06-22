/**
 * @description       : 
 * @author            : Irfan Khan
 * @group             : 
 * @last modified on  : 01-09-2023
 * @last modified by  : Irfan Khan
**/
@isTest(SeeAllData=true)
private class TestOrgHierarchy {
    
    @isTest static void runTest() {
        OrgHierarchyCtrl org = new OrgHierarchyCtrl();
        System.Assert(org.currentFocusUserId != null,'no current user');
        System.Assert(org.me != null,'no user node for current user');
        }
}