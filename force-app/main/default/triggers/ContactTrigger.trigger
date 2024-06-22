/**	
 * Class contains custom application exceptions	
 * 	
 * @author    Jerome Liwanag, Cloud Sherpas	
 * @createddate  29-Oct-2015	
 */ 	
 trigger ContactTrigger on Contact (after insert, after update, before insert, before update, before delete ,after delete, after undelete) {
    String userName = UserInfo.getName();	
    	
    if(Trigger.isBefore){
        if(Trigger.isInsert){	
            if(!userName.contains(CHConstants.NOT_ELIGIBLE_INTEGRATION_USER)) {	
            //  ContactCRUDHandler.updateContactType(trigger.new);	
                if(!ContactCRUDHandler.SKIP_VALIDATION){	
                    ContactCRUDHandler.validateBeaconContact(Trigger.new);	
                }	
                ContactCRUDHandler.updateWINValidatedFlag(Trigger.new);	
                ContactCRUDHandler.verifyAndSetAsMAINContact(Trigger.new);	
                ContactCRUDHandler.updateOrganization(Trigger.new);	
                ContactCRUDHandler.checkDuplicateContact(Trigger.new, null);
            }	
        }	
    if(Trigger.isUpdate){	
     //   ContactCRUDHandler.updateRelatedBeaconContacts(Trigger.new,Trigger.oldMap);	
          if(!userName.contains(CHConstants.NOT_ELIGIBLE_INTEGRATION_USER)) {	
               ContactCRUDHandler.updateWINValidatedFlag(Trigger.new);	
               ContactCRUDHandler.validateBeaconContact(Trigger.new);	
			   ContactCRUDHandler.updateOrganization(Trigger.new);	
               ContactCRUDHandler.checkDuplicateContact(Trigger.new, Trigger.oldMap);
            }	
        }   	
    }	
     /* Checks Main, PO, AP contact type for Account and if not available displays which contact type is not available out of three 	
   @author Reeta Gaokar Created date 04/06/2020*/	
 	
    if(Trigger.isAfter){	
        if(Trigger.isInsert || Trigger.isUpdate || Trigger.isUndelete){	
            //ContactCRUDHandler.CheckForContactType(Trigger.new);         	
        }else if(Trigger.isDelete){	
            //ContactCRUDHandler.CheckForContactType(Trigger.old);	
            ContactCRUDHandler.updateAccountMissingTypes(Trigger.old, null);	
                
        }         	
    }	
     	
     if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUndelete)){	
         ContactCRUDHandler.updateAccountMissingTypes(Trigger.new, null);	
		 ContactCRUDHandler.setAccountStatus(Trigger.new);	
     }	
     	
     if(Trigger.isAfter && Trigger.isUpdate){	
         ContactCRUDHandler.updateAccountMissingTypes(Trigger.new, Trigger.oldMap);	
     }	
     	
     if(Trigger.isAfter && Trigger.isDelete){	
         ContactCRUDHandler.updateAccountMissingTypes(Trigger.old, null);	
     }	
     	
     if(Trigger.isAfter && Trigger.isInsert){	
         ContactCRUDHandler.updateVerificationDates(Trigger.new, null);	
         ContactCRUDHandler.updateMainPhoneOnAcc(Trigger.new, null);	
     }	
     	
     if(Trigger.isAfter && Trigger.isUpdate){	
         ContactCRUDHandler.updateVerificationDates(Trigger.new, Trigger.oldMap);	
         ContactCRUDHandler.updateMainPhoneOnAcc(Trigger.new, Trigger.oldMap);	
     }	
     	
}