public class CaseCommentsHandler {
    
    public static void sendCaseDetailstoWIN(List<caseComment> newList ){
        
        List<Id> caseIds = new List<Id>();
        
        for(CaseComment comments : newList){
            
            caseIds.add(comments.ParentId);  
        }
        
        if(!caseIds.isEmpty()){
            RestUpdateCase.sendCaseDetails(caseIds, FALSE);
        }
    }
    
}