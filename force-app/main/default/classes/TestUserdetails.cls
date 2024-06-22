@isTest
public class TestUserdetails {
 
static testMethod void testuserdetails() {
    System.assertEquals(UserInfo.getUserId(), UserDetailController.getUserDetails().Id, 'got the right user');
}
}