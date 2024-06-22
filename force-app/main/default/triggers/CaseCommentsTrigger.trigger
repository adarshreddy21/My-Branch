trigger CaseCommentsTrigger on CaseComment (after insert, after update) {
    
    if(Trigger.isAfter){
        if(Trigger.isInsert || Trigger.isUpdate){
            
            CaseCommentsHandler.sendCaseDetailstoWIN(Trigger.new);
            
        }
        
    }    
    
}