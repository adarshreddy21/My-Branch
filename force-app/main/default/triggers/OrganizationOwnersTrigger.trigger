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
trigger OrganizationOwnersTrigger on Organization_Owners__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    
    TriggerDispatcher.Run(new OrganizationOwnersTriggerHandler());
}