/**
 * @description       : 
 * @author            : Suresh Beniwal
 * @group             : 
 * @last modified on  : 08-24-2022
 * @last modified by  : Suresh Beniwal
 * Modifications Log
 * Ver   Date         Author           Modification
 * 1.0   08-24-2022   Suresh Beniwal   Initial Version
**/
trigger LocationTrigger on Location (after insert, after update, before insert, before update) {
    TriggerDispatcher.Run(new LocationTriggerHandler());
}