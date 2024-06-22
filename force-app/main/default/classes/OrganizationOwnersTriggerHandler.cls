/**
 * @description       : 
 * @author            : Suresh Beniwal
 * @group             : 
 * @last modified on  : 08-26-2022
 * @last modified by  : Suresh Beniwal
 * Modifications Log
 * Ver   Date         Author           Modification
 * 1.0   05-30-2022   Suresh Beniwal   Initial Version
**/
public without sharing class OrganizationOwnersTriggerHandler implements ITriggerHandler
{
	/* This class implements ITriggerHander. This sample shows how to 
	 * retrieve the metadata type and set the isDisabled flag
	*/
    public Trigger_Settings__mdt triggerMeta = new Trigger_Settings__mdt();
    
    //create a constructor to get the metadatatype
    public OrganizationOwnersTriggerHandler() {
          //Retrive the metadata type
    	triggerMeta = [SELECT DeveloperName, Is_Active__c, Object_API__c,RecordType__c FROM Trigger_Settings__mdt WHERE Object_API__c = 
        'Organization_Owners__c' AND DeveloperName ='Organization_Owners' LIMIT 1] ;
        /*triggerMeta = Trigger_Settings__mdt.getInstance('Organization_Owners');*/
        OrganizationOwnersServiceHandler.recordType=triggerMeta.RecordType__c;
        
    
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
        
        OrganizationOwnersServiceHandler.beforeInsert(newItems);
    }
 
    public void BeforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        OrganizationOwnersServiceHandler.beforeUpdate(newItems, oldItems);
    }
 
    public void BeforeDelete(Map<Id, SObject> oldItems) {
        
    }
 
    public void AfterInsert(Map<Id, SObject> newItems) {
        //OrganizationOwnersServiceHandler.afterInsert(newItems);
        //OrganizationOwnersServiceHandler.recordType = triggerMeta.RecordType__c;
        OrganizationOwnersServiceHandler.setOrgStatusToProspect(newItems.values());
       
    }
 
    public void AfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        OrganizationOwnersServiceHandler.setOrgStatusToProspect(newItems.values());
    }
 
    public void AfterDelete(Map<Id, SObject> oldItems) {}
 
    public void AfterUndelete(Map<Id, SObject> oldItems) {}
}