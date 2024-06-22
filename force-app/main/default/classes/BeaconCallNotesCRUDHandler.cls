/**
 * Helper class invoked from Trigger.
 * 
 * @author	Cloud Sherpas
 * @created	08-Nov-2015
 */ 
public class BeaconCallNotesCRUDHandler {

    /*
     * This method updates the WIN Validated flag to TRUE. Invoked from Trigger.
     * 
     * @param	list of beacon call notes to be updated 
     */ 
    public static void updateWINValidatedFlag(List<Beacon_Call_Notes__c> beaconCallNotesList) {
        for(Beacon_Call_Notes__c bc : beaconCallNotesList) {
            bc.WIN_Validated__c = true;
        }
    }
}