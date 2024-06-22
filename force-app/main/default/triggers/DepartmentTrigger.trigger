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
trigger DepartmentTrigger on Organization_Department__c (before insert) {
    TriggerDispatcher.Run(new DepartmentTriggerHandler());
}