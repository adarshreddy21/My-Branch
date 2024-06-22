/*
Author: Sireesha
Date: 22nd June, 2020
Description: Handler class for the Competitor Capture Trigger
*/

public class CompetitorCaptureCRUDHandler {
	
    
    public static void updateCreatedOwnerAlias(List<Competitor_Capture__c> newList){
        
        Profile intProfile = [Select Id, Name from Profile where Name  = 'Integration' LIMIT 1];
        
        Id profileId = UserInfo.getProfileId();
        Id userId = UserInfo.getUserId();
        
        if(profileId != intProfile.Id){
            
            String aliasName = [Select Id, Name, Alias from User where Id =:userId].Alias;
            
            for(Competitor_Capture__c cc : newList){
                
                if(aliasName != NULL){
                    cc.CreatedBy_Username__c = aliasName;
                }
            }
        }
    }        
}