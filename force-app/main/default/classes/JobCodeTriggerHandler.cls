/**
 * @description       : 
 * @author            : Suresh Beniwal
 * @group             : 
 * @last modified on  : 06-28-2022
 * @last modified by  : Suresh Beniwal
 * Modifications Log
 * Ver   Date         Author           Modification
 * 1.0   06-28-2022   Suresh Beniwal   Initial Version
**/
public with sharing class JobCodeTriggerHandler implements ITriggerHandler {
   /* This class implements ITriggerHander. This sample shows how to 
	 * retrieve the metadata type and set the isDisabled flag
	*/
    public Trigger_Settings__mdt triggerMeta = new Trigger_Settings__mdt();
    
    //create a constructor to get the metadatatype
    public JobCodeTriggerHandler() {
          //Retrive the metadata type
        triggerMeta = Trigger_Settings__mdt.getInstance('Job_Codes');
    
    }
    
    //read the custom metadata and look for the customer permission
    public Boolean IsDisabled()
    {
		// return IsDisabled= true if the metadata setting isActive = false or
		// the user has the Bypass Trigger custom permission
        // || FeatureManagement.checkPermission('Bypass_Trigger')
        if (triggerMeta.Is_Active__c) {
        	return false;
        } else { 
        	return true;
        }
    } 
 
    public void BeforeInsert(List<SObject> newItems) {
        JobCodeServiceHandler.updateOrganization(newItems);
    }
 
    public void BeforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
    }
 
    public void BeforeDelete(Map<Id, SObject> oldItems) {}
 
    public void AfterInsert(Map<Id, SObject> newItems) {
    }
 
    public void AfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {}
 
    public void AfterDelete(Map<Id, SObject> oldItems) {}
 
    public void AfterUndelete(Map<Id, SObject> oldItems) {}
}