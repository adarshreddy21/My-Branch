/**
* @description       : 
* @author            : Raghav
* @group             : 
* @last modified on  : 
* @last modified by  : 
* Modifications Log
* Ver   Date         Author           Modification
* 1.0   01-10-2024   Raghav   Initial Version
**/
public without sharing class FinancialTriggerHandler implements ITriggerHandler {
	private static Financialhandler financialHandler = new Financialhandler();
	/* This class implements ITriggerHander. This sample shows how to 
	 * retrieve the metadata type and set the isDisabled flag
	*/
    public Trigger_Settings__mdt triggerMeta = new Trigger_Settings__mdt();
    
    //create a constructor to get the metadatatype
    public FinancialTriggerHandler() { 
          //Retrive the metadata type 
    	triggerMeta = [SELECT DeveloperName, Is_Active__c, Object_API__c,RecordType__c FROM Trigger_Settings__mdt WHERE Object_API__c = 
        'Financials__c' AND DeveloperName ='Financials' LIMIT 1] ;
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
       
    }
 
    public void BeforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
      
    }
 
    public void BeforeDelete(Map<Id, SObject> oldItems) {
       
    }
 
    public void AfterInsert(Map<Id, SObject> newItems) {
        financialHandler.updateOCRQuarterFlipEligibility(newItems, null);
    }
 
    public void AfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        financialHandler.updateOCRQuarterFlipEligibility(newItems, oldItems);
    }
 
    public void AfterDelete(Map<Id, SObject> oldItems) {}
 
    public void AfterUndelete(Map<Id, SObject> oldItems) {}
}