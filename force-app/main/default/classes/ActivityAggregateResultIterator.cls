global class ActivityAggregateResultIterator Implements Iterator<AggregateResult>{
    AggregateResult [] results {get;set;} 
    Integer index {get;set;} 
    
    global ActivityAggregateResultIterator(Boolean isEvent){
        Id taskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Activity').getRecordTypeId();
        string salesProfile = [SELECT Profile_Names__c FROM Sales_Profile__mdt where DeveloperName = 'Sales_Profile_for_IS_Ranking'].Profile_Names__c;
        set<string> salesProfileSet = new set<string>();
        salesProfileSet.addAll(salesProfile.split('@'));

        index = 0;
		String query;
        if(isEvent == true){
        	query = 'select accountId, Max(Event_Start_Date__c)maxActivityDate From Event'+
            			' where (Owner.Profile.Name in:salesProfileSet)'+ 
                        ' And (Who.Type=\'Contact\' Or What.Type IN (\'Account\', \'Opportunity\'))'+
                        ' And (account.owner.UserRole.DeveloperName = \'SK_INS_BPS_AM\' OR account.owner.UserRole.DeveloperName = \'SK_INS_SKE_AM\')' +
                        ' And (account.RecordType.DeveloperName = \'Customer\' OR account.RecordType.DeveloperName = \'Customer_Location\')'+
                        ' AND account.Status__c = \'Active\' AND account.win_id__c != null'+
            			' AND Event_Start_Date__c >= LAST_N_DAYS:90'+
            			' AND (Event_Type__c != \'Internal Discussion\' AND Event_Type__c != \'Security Response\')'+
                        ' Group By accountId'; 
        }else if (isEvent == false){
            query = 'select accountId, Max(Event_Start_Date__c)maxActivityDate From Task'+
            			' where RecordTypeId = :taskRecordTypeId'+
                		' AND (Owner.Profile.Name in:salesProfileSet)'+ 
                        ' And (Who.Type=\'Contact\' Or What.Type IN (\'Account\', \'Opportunity\'))'+
                        ' And (account.owner.UserRole.DeveloperName = \'SK_INS_BPS_AM\' OR account.owner.UserRole.DeveloperName = \'SK_INS_SKE_AM\')' +
                        ' And (account.RecordType.DeveloperName = \'Customer\' OR account.RecordType.DeveloperName = \'Customer_Location\')'+
                        ' AND account.Status__c = \'Active\' AND account.win_id__c != null'+
                		' AND Event_Start_Date__c >= LAST_N_DAYS:90'+
                        ' Group By accountId';
        }
        results = Database.query(query);
        system.debug('results size----'+results.size());
    } 
    
    global boolean hasNext(){ 
        return results !=null && !results.isEmpty() && index < results.size(); 
    } 
    
    global AggregateResult next(){ 
        return results[index++]; 
    } 
    
}