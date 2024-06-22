/**
 * Helper class invoked from Trigger.
 * 
 * @author	Cloud Sherpas
 * @created	09-Nov-2015
 */ 
public class WorkNotesCRUDHandler {

    /*
     * This method updates the WIN Validated flag to TRUE. Invoked from Trigger.
     * 
     * @param	list of beacon work notes to be updated 
     */ 
    public static void updateWINValidatedFlag(List<Work_Notes__c> workNotesList) {
        for(Work_Notes__c wn : workNotesList) {
            wn.WIN_Validated__c = true;
        }
    }
}