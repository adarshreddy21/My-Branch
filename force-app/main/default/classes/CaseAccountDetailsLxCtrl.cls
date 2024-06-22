public class CaseAccountDetailsLxCtrl {
	@AuraEnabled
    public static List<Case> getCaseDetails(String caseId){
        return [SELECT Id, AccountId FROM Case WHERE Id = :caseId];
    }
}