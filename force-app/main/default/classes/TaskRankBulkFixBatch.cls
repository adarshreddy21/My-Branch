global class TaskRankBulkFixBatch implements Database.Batchable<AggregateResult>, Database.Stateful{
    global integer total =0;
    
    global Iterable<AggregateResult> start(Database.BatchableContext BC){ 
        return new ActivityAggregateResultIterable(false); 
    } 
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        total += Scope.size();
        system.debug('total--'+total);
        List <Account>accUpdateList = new List <Account>();
        
        for(AggregateResult aggr:(List<AggregateResult>)scope){
            Account a = new Account();
            a.id = (id)aggr.get('accountId');
            a.Latest_Sales_Task_Date_for_IS_Rank__c = (date)aggr.get('maxActivityDate');
            accUpdateList.add(a);    
        }
        
        if(accUpdateList.size() >0){
            Database.SaveResult[] SaveResultList = Database.update(accUpdateList,false);
            ExceptionLogHelper.logException(true, SaveResultList, 'Account', accUpdateList, 'TaskRankBulkFixBatch', 'execute');
        }
        
    }
    
    global void finish(Database.BatchableContext BC){
    }
    
    
    
}