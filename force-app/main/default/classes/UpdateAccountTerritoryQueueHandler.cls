public class UpdateAccountTerritoryQueueHandler implements Queueable{
    Set<Id> corporateAccountIdsSet;
    
    public UpdateAccountTerritoryQueueHandler(Set<Id> corporateAccountIdsSet){
        this.corporateAccountIdsSet = corporateAccountIdsSet;
    }
    
    public void execute(QueueableContext context) {
        Database.executeBatch(new UpdateAccountTerritoryBatch(corporateAccountIdsSet, true));
    }
}