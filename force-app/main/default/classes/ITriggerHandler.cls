/**
 * @description       : 
 * @author            : Suresh Beniwal
 * @group             : 
 * @last modified on  : 05-30-2022
 * @last modified by  : Suresh Beniwal 
 * Modifications Log
 * Ver   Date         Author           Modification
 * 1.0   05-30-2022   Suresh Beniwal   Initial Version
**/

public interface ITriggerHandler {
    void BeforeInsert(List<SObject> newItems);
    
    void BeforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems);
    
    void BeforeDelete(Map<Id, SObject> oldItems);
    
    void AfterInsert(Map<Id, SObject> newItems);
    
    void AfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems);
    
    void AfterDelete(Map<Id, SObject> oldItems);
    
    void AfterUndelete(Map<Id, SObject> oldItems);
    
    Boolean IsDisabled();
}