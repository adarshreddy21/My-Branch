/**
 * Trigger on Beacon Call Notes.
 * 
 * @author	Cloud Sherpas
 * @created	08-Nov-2015
 */ 
trigger BeaconCallNotesTrigger on Beacon_Call_Notes__c (before insert, before update) {

    /*
     * For integration the WIN Validated flag is used. 
     * If the flag value is TRUE, Beacon pulls the records for syncing
     * If the flag value is FALSE, Beacon does not pull such records
     * 
     * Beacon will always update the flag to FALSE during any insert/updates, but any
     * changes made in SFDC UI should be sent back for sync. Even though the method will
     * be always triggered from UI, the code has been bulkified, if a System Administrator
     * loads additional data.
     */ 
    Id profileId = UserInfo.getProfileId();
    String profileName = [Select Id, Name from Profile where Id = :profileId].Name;
    
    if(!CHConstants.INTEGRATION_PROFILE_NAME.equalsIgnoreCase(profileName) && !CHConstants.APIINTEGRATION_PROFILE_NAME.equalsIgnoreCase(profileName)) {
        BeaconCallNotesCRUDHandler.updateWINValidatedFlag(Trigger.new);
    }
}