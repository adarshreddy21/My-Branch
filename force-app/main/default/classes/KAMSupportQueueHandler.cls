public class KAMSupportQueueHandler implements Queueable {
    public Set<Id> KAMSupportAccountIds;
    
    public KAMSupportQueueHandler(Set<Id> KAMSupportAccountIds){
        this.KAMSupportAccountIds = KAMSupportAccountIds;
    }
    
	public void execute(QueueableContext context) {
        Database.executeBatch(new KAMSupportProcessBatch(this.KAMSupportAccountIds));        
    }
}