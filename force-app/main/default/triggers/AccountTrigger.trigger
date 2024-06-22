/**
* Trigger on Account object.
* 
* @author       Jerome Liwanag, Cloud Sherpas
* @createddate  29-Oct-2015 
*/ 
trigger AccountTrigger on Account (before insert, before update,after insert, after update, after delete) {
    
     if(FeatureManagement.checkPermission('Bypass_Trigger')){
        return;
    }
    // the validation rules should not be triggered for Integration user
    User userObject= AccountCRUDHandler.getLoggedInUser();
    if(CHConstants.INTEGRATION_PROFILE_NAME == userObject.Profile.Name || CHConstants.APIINTEGRATION_PROFILE_NAME == userObject.Profile.Name || FeatureManagement.checkPermission('Skip_Validations_for_Super_users_cp')) {
        AccountCRUDHandler.SKIP_VALIDATION = true;
    }
    if(Trigger.isBefore){
        if(!AccountCRUDHandler.IS_SKIP_TRIGGER){
            if(Trigger.isInsert) {
                AccountCRUDHandler.insertShippingAddressWhenLeadConverted (Trigger.New);
                AccountCRUDHandler.updateZipMaster(trigger.new);
                AccountCRUDHandler.populateAccountFields(Trigger.new, NULL);
                // invoke the validation rules only when SKIP_VALIDATION flag is false
                if(!AccountCRUDHandler.SKIP_VALIDATION){
                    AccountCRUDHandler.validateBusinessRules(Trigger.new,null);
                    AccountCRUDHandler.updateAccountPrimaryBusiness(trigger.new);               
                }
                        
                AccountCRUDHandler.updateTerritoryLookup(trigger.new);       
                AccountCRUDHandler.UpdateAccountOwnerSalesBranch(trigger.new);
                AccountCRUDHandler.validateAndCopyBillingAddress(trigger.new, null);
                AccountCRUDHandler.updatePrimaryBranchName(Trigger.New, NULL);
                AccountCRUDHandler.CopyCorpAsManifest(trigger.new,NULL);
				AccountCRUDHandler.copyCorpAsPayToAddress(trigger.new,NULL);
                AccountCRUDHandler.updateCustEngManager(trigger.new, NULL);
                AccountCRUDHandler.validateHybridLOB(trigger.new, NULL);
                AccountCRUDHandler.updateSecondaryOwner(trigger.new, NULL);
                AccountCRUDHandler.handleAccountOwnershipChanges(trigger.new, NULL);
                AccountCRUDHandler.handlePrBusinessHPCIndust(trigger.new, NULL);
                AccountCRUDHandler.organizationCategoryMandatory(Trigger.new, null);
                AccountCRUDHandler.updateMissingContactType(Trigger.new, null);
                AccountCRUDHandler.updateWinValidateNewToTrue(trigger.new);
            }
            if(Trigger.isUpdate) {
                // unlock all records those were locked but have received an updated from Beacon
                // records coming in from Beacon will have the profile as Integration
                if(CHConstants.INTEGRATION_PROFILE_NAME == userObject.Profile.Name  || CHConstants.APIINTEGRATION_PROFILE_NAME == userObject.Profile.Name ){
                    List<account> accountIdsToUnlock = new List<Account>();
                    Map<Id,Boolean> lockedStatuses= Approval.isLocked(Trigger.new);
                    for(account a : trigger.new){
                        if(lockedStatuses.get(a.Id) && (trigger.oldMap.get(a.id).win_validated__c  && !a.win_validated__c)|| (trigger.oldMap.get(a.id).win_validate_new__c  && !a.win_validate_new__c) && !a.Inactivate_Reactivate_In_Progress__c){
                            accountIdsToUnlock.Add(a);
                        }
                    }
                    if(!accountIdsToUnlock.isEmpty()){
                    AccountCRUDHandler.unlockAccountRecords(accountIdsToUnlock);  
                    }
                }
                if(checkRecursive_AccountTrigger.check()){
                    
                    if(!AccountCRUDHandler.SKIP_VALIDATION){
                        AccountCRUDHandler.validateBusinessRules(Trigger.new, Trigger.oldMap);
                        AccountCRUDHandler.validateAndCopyBillingAddress(trigger.new, trigger.OldMap);
                        AccountCRUDHandler.CopyCorpAsManifest(trigger.new,trigger.oldMap);
						AccountCRUDHandler.copyCorpAsPayToAddress(trigger.new,trigger.oldMap);
                    }
                    AccountCRUDHandler.populateAccountFields(Trigger.new, Trigger.OldMap);
                    AccountCRUDHandler.updateZipMaster(trigger.new);
                    AccountCRUDHandler.updateTerritoryLookup(trigger.new);
                    AccountCRUDHandler.UpdateAccountOwnerSalesBranch(trigger.new);
                    AccountCRUDHandler.updateAccountPrimaryBusiness(trigger.new);
                    AccountCRUDHandler.updatePrimaryBranchName(Trigger.New, Trigger.OldMap);
                    AccountCRUDHandler.updateCustEngManager(Trigger.new, Trigger.OldMap);
                    AccountCRUDHandler.validateHybridLOB(trigger.new, Trigger.OldMap);
                    AccountCRUDHandler.updateSecondaryOwner(trigger.new, Trigger.OldMap);
                    AccountCRUDHandler.handleAccountOwnershipChanges(trigger.new, Trigger.OldMap);
                    AccountCRUDHandler.handlePrBusinessHPCIndust(trigger.new, Trigger.oldMap);
                    AccountCRUDHandler.checkDraftStatusChangeForOrganization(Trigger.new, Trigger.oldMap);
                    AccountCRUDHandler.organizationCategoryMandatory(Trigger.new, Trigger.oldMap);
                    AccountCRUDHandler.updateMissingContactType(trigger.new, trigger.OldMap);
                }            
            }
        }
        if(Trigger.isUpdate) {
            AccountCRUDHandler.toggleWinValidateFlagBasedOnAccountTypes(Trigger.new);
            AccountCRUDHandler.retainTeamMemberOnOwnerChange(trigger.new, Trigger.oldMap);
            AccountCRUDHandler.resetParentIdforcustAccountsMappedtoRegional(Trigger.new,Trigger.oldmap);
            AccountCRUDHandler.setTerritoryOverrideFields(trigger.newMap, Trigger.OldMap);
            AccountCRUDHandler.handleNonCriticalAndCriticalFieldsUpdate(Trigger.New, Trigger.OldMap);
        }
        if(Trigger.isInsert){
            AccountCRUDHandler.toggleWinValidateFlagBasedOnAccountTypes(Trigger.new);
        }
    }
    if(Trigger.isAfter && !AccountCRUDHandler.IS_SKIP_TRIGGER){
        if(AccountCRUDHandler.isAfterAccount){
            If(Trigger.isInsert){
                AccountCRUDHandler.checkAndValidateAccountWithoutWinId(trigger.newMap,NULL);
                AccountCRUDHandler.RollUpCustomerARtoCorp(trigger.new, NULL);
                AccountCRUDHandler.createMainContact(Trigger.New);
                AccountCRUDHandler.insertTaxDoc(Trigger.new);
				AccountCRUDHandler.createAccountPlatformEvents(Trigger.new);
            }
        
            If(Trigger.isUpdate){
                AccountCRUDHandler.updateChildKAMSupport(trigger.newMap,trigger.oldMap);
                AccountCRUDHandler.InsertNewAccountCase(trigger.new,trigger.oldMap);
				AccountCRUDHandler.createCaseForUpdateAccount(trigger.newmap,trigger.oldMap);		
                AccountCRUDHandler.checkAndValidateAccountWithWinId(trigger.newMap, trigger.oldMap);	 	
                AccountCRUDHandler.checkAndValidateAccountWithoutWinId(trigger.newMap,trigger.oldMap);
                AccountCRUDHandler.UpdateBeaconMainContactList(trigger.new);
                AccountCRUDHandler.RollUpCustomerARtoCorp(trigger.new, trigger.OldMap);
                AccountCRUDHandler.updateAccountTerritory(trigger.newMap, Trigger.OldMap);
                AccountCRUDHandler.handleParentAccountChange(trigger.newMap, Trigger.oldMap); 
            }
        
        If(Trigger.isDelete){
            AccountCRUDHandler.RollUpCustomerARtoCorp(trigger.old, NULL);
        }
        AccountCRUDHandler.isAfterAccount=false;
    }
     if(Trigger.isInsert){
        AccountCRUDHandler.trackAccountsForWinIdGeneration(Trigger.new); 
	 }		
  }
     if(Trigger.isAfter && Trigger.isUpdate){ 
       AccountCRUDHandler.createAccountTeamMembers();
       AccountCRUDHandler.handleUpdateShipGenRecordOnCustomerOwnerChange(Trigger.new, Trigger.oldMap);
	   AccountCRUDHandler.handleUpdateRelatedChildRecords(Trigger.new, Trigger.oldMap);
	   AccountCRUDHandler.trackAccountsForWinIdGeneration(Trigger.new);  
       AccountCRUDHandler.createAccountPlatformEvents(Trigger.new); 
  }
}