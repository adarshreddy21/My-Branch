trigger CaseTrigger on Case (after insert, before insert, before update, after Update, before delete){
    
    if(Trigger.isAfter){
        if(Trigger.isInsert ){
            Id devRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer PO Case').getRecordTypeId();
            
            List<Id> casesIds = new List<Id>();
            for(Case c: trigger.new){
                if(c.RecordTypeId == devRecordTypeId){
                    casesIds.add(c.Id);
                }
            }
            CaseCRUDHandler.AutoCloseCase(casesIds);
            CaseCRUDHandler.insertSupportTSE(trigger.new, null);
            CaseCRUDHandler.autoSubmissionApprovalProcess(trigger.new);
           // CaseCRUDHandler.insertcaseteam(trigger.new); 
            CaseCRUDHandler.UpdateCallCenterActivity(trigger.new);
            CaseCRUDHandler.updateAccountCaseRank(trigger.new, null);
			 CaseCRUDHandler.updateChildCaseCount(trigger.new);
        }  
        if(Trigger.isUpdate ){  
            CaseCRUDHandler.caseAfterUpdateHandler(trigger.new,trigger.oldMap);
            CaseCRUDHandler.sendCaseDetailsToWIN(trigger.new,trigger.oldMap);
            CaseCRUDHandler.insertSupportTSE(trigger.new,trigger.oldMap);
            CaseCRUDHandler.updateAccountCaseRank(trigger.new, trigger.oldMap);
            CaseCRUDHandler.removeAccountRelatedContactsfromCadence(Trigger.New,Trigger.oldMap);
        }
    }
    if(Trigger.isBefore){ 
        if(Trigger.isInsert ){  
            CaseCRUDHandler.insertBeaconMainContact(trigger.new);
            CaseCRUDHandler.updateExistingAccount(trigger.new);
			CaseCRUDHandler.AutoPopulateBranch(trigger.new);
            CaseCRUDHandler.validateTSECase(trigger.new, null);
        }
        
        if(Trigger.isUpdate ){  
            CaseCRUDHandler.insertBeaconMainContact(trigger.new);
            CaseCRUDHandler.caseCommentsMandatory(trigger.New, trigger.OldMap);
            CaseCRUDHandler.checkUserMemberofPOQueue(trigger.New,trigger.OldMap);
            CaseCRUDHandler.checkInactivationAccountCriteria(trigger.New, trigger.OldMap);
            CaseCRUDHandler.validateTSECase(trigger.new, trigger.OldMap);
			CaseCRUDHandler.validateCPGCaseSubmission(trigger.New);
            //   CaseCRUDHandler.InsertNewCaseLead(trigger.new,trigger.oldMap);
        }
		if(trigger.isDelete){
            CaseCRUDHandler.updateChildCaseCount(trigger.old);
        }
        
    }
    
}