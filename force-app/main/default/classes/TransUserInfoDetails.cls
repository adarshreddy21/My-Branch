global class TransUserInfoDetails
{
    webService static String getUserDetails()
    {    
        SFUser usr = new SFUser();
        usr.userId = UserInfo.getUserId();
        usr.userName = UserInfo.getUserName();
        usr.userOrg = UserInfo.getOrganizationName();
        
        return JSON.serialize(usr);   
    }
    
    webService static String saveOrUpdateUserInfo(String sfUsername, String xeraLogin, String password, String tenant)
    {
        boolean upateRec = true;
        TranseraUser__c xeraUser;
        try {
            xeraUser = [Select SalesforceUsername__c, LoginName__c, Password__c, Tenant__c From TranseraUser__c Where SalesforceUsername__c = :sfUsername limit 1];
        } catch (Exception e) {
            upateRec = false;
        }

        if (xeraUser == null) {
            xeraUser = new TranseraUser__c(SalesforceUsername__c = sfUsername, LoginName__c = xeraLogin, Password__c = EncodingUtil.base64Encode(Blob.valueOf(password)), Tenant__c = tenant);
            upateRec = false;
        }
        
        
        if (upateRec) {
            update xeraUser;
        } else {
            insert xeraUser;
        }

        return 'success';
    }

    webService static String getTranseraUserDetails(String sfUsername)
    {
        System.Debug('getTranseraUserDetails method invoked ' + sfUsername);
        TranseraUser__c usr = [Select SalesforceUsername__c, LoginName__c, Password__c, Tenant__c From TranseraUser__c Where SalesforceUsername__c = :sfUsername limit 1];
        if(usr != null){
            TranseraUserModel userModel = new TranseraUserModel(usr.SalesforceUsername__c, usr.LoginName__c, usr.Password__c, usr.Tenant__c);
            return JSON.serialize(userModel);
        }
        return '{}';
    }
    
    public class SFUser{
        public String userId {get;set;}
        public String userName {get;set;}
        public String userOrg {get;set;}
    }
}