global class OpportunityRankScheduler implements Schedulable {
    global void execute(SchedulableContext sc) {
        OpportunityRankBatch oppbt = new OpportunityRankBatch(); 
        database.executebatch(oppbt,50);
    }
}