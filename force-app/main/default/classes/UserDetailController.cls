public class UserDetailController {
	@AuraEnabled
    public static User getUserDetails(){
        return [
            SELECT Id, EmployeeNumber 
            FROM User
            WHERE Id = :UserInfo.getUserId()
        ];
    }
}