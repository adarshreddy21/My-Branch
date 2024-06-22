/**
 * Trigger on Work Notes. This is required for Integrations as Integrations
 * currently are not able to address which record they need to work on.
 * 
 * To facilitate Integration, a flag WIN Validated is used, which is always
 * set to TRUE whenever an insert is made from SFDC UI. A TRUE value
 * indicates Beacon to pull such record. 
 * 
 * A worknote once created will never be updated (restricted for updates from security settings)
 * 
 * Beacon will always set this flag value as FALSE.
 * 
 * @author	Cloud Sherpas
 * @created	09-Nov-2015
 */ 
trigger WorkNotesTrigger on Work_Notes__c (before insert) {

    /*
     * For integration the WIN Validated flag is used. 
     * If the flag value is TRUE, Beacon pulls the records for syncing
     * If the flag value is FALSE, Beacon does not pull such records
     * 
     * Beacon will always update the flag to FALSE during any inserts, but any
     * changes made in SFDC UI should be sent back for sync. Even though the method will
     * be always triggered from UI, the code has been bulkified, if a System Administrator
     * loads additional data.
     */ 
    Id profileId = UserInfo.getProfileId();
    String profileName = [Select Id, Name from Profile where Id = :profileId].Name;
    
    if(!CHConstants.INTEGRATION_PROFILE_NAME.equalsIgnoreCase(profileName) && !CHConstants.APIINTEGRATION_PROFILE_NAME.equalsIgnoreCase(profileName)) {
        WorkNotesCRUDHandler.updateWINValidatedFlag(Trigger.new);
    }
}