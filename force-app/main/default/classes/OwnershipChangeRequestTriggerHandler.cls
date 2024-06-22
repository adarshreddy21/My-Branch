/**
 * @description       : 
 * @author            : Vikram simha
 * @group             : 
 * @last modified on  : 11-25-2022
 * @last modified by  : Vikram simha
 * Modifications Log 
 * Ver   Date         Author           Modification
 * 1.0   05-30-2022   Suresh Beniwal   Initial Version 
**/ 
public without sharing class OwnershipChangeRequestTriggerHandler implements ITriggerHandler {
	private static OwnershipChangeRequestHandler ownershiptriggerreq = new OwnershipChangeRequestHandler();
	/* This class implements ITriggerHander. This sample shows how to 
	 * retrieve the metadata type and set the isDisabled flag
	*/ 
    public Trigger_Settings__mdt triggerMeta = new Trigger_Settings__mdt(); 
    
    //create a constructor to get the metadatatype
    public OwnershipChangeRequestTriggerHandler() { 
          //Retrive the metadata type 
    	triggerMeta = [SELECT DeveloperName, Is_Active__c, Object_API__c,RecordType__c FROM Trigger_Settings__mdt WHERE Object_API__c = 
        'Ownership_Change_Request__c' AND DeveloperName ='Ownership_Change_Request' LIMIT 1] ;
    }
    
    //read the custom metadata and look for the customer permission
    public Boolean IsDisabled()
    {
		// return IsDisabled= true if the metadata setting isActive = false or
		// the user has the Bypass Trigger custom permission
        if (triggerMeta.Is_Active__c || FeatureManagement.checkPermission('Bypass_Trigger')) 
        	return false;
        else 
        	return true;
    } 
 
    public void BeforeInsert(List<SObject> newItems) {
        ownershiptriggerreq.setUserLookupFields(newItems);
        ownershiptriggerreq.checkDuplicateOwnershipRequest(newItems);
        ownershiptriggerreq.updateNewOwnerUserLookupFields(Trigger.New,new Map<id,Sobject>());
		ownershiptriggerreq.updateOCRQuarterFlipEligibility(newItems );
        ownershiptriggerreq.validateNewAccountOwnerOCR(Trigger.New,null);
    }
 
    public void BeforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        ownershiptriggerreq.checkDuplicateOwnershipRecord(newItems,oldItems);
        ownershiptriggerreq.checkOperatingSegmentChange(newItems,oldItems);
        ownershiptriggerreq.updateNewOwnerUserLookupFields(Trigger.New, Trigger.OldMap);
        ownershiptriggerreq.checkSKRoutetoBPS(Trigger.New,Trigger.OldMap);
        ownershiptriggerreq.validateNewAccountOwnerOCR(Trigger.New,Trigger.OldMap);
    }
 
    public void BeforeDelete(Map<Id, SObject> oldItems) {
        ownershiptriggerreq.allowDeleteifDraftandCreatedBy(oldItems);
    }
 
    public void AfterInsert(Map<Id, SObject> newItems) {
    }
 
    public void AfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
    }
 
    public void AfterDelete(Map<Id, SObject> oldItems) {}
 
    public void AfterUndelete(Map<Id, SObject> oldItems) {}
}