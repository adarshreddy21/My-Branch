@isTest(SeeAllData=true)
private class TestTransUserInfoDetails {
    private static testMethod void testGetUserDetails() {
        String result = TransUserInfoDetails.getUserDetails();
        System.assert(result != null, 'User info can not be empty');
    }

    private static testMethod void testSaveOrUpdateUserInfo() {
        String result = TransUserInfoDetails.saveOrUpdateUserInfo('salesforce@transerainc.com', 'salesforce', 'sunil~1', 'Transera');
        System.assertNotEquals(result, '', 'Could not save the data');
    }

    private static testMethod void testGetTransUserDetails() {
        String salesforceId = 'salesforce';
        TranseraUser__c user = new TranseraUser__c(SalesforceUsername__c = salesforceId , LoginName__c = 'sales', Password__c = EncodingUtil.base64Encode(Blob.valueOf('pass')), Tenant__c = 'transera');
        
        insert user ;
        
        try {
            System.assertNotEquals(TransUserInfoDetails.getTranseraUserDetails(salesforceId),'','The salesforce user does not exist');
        } finally {
            delete user;
        }
    }
}