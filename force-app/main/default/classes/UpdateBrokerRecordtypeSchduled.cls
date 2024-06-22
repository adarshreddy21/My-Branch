global class UpdateBrokerRecordtypeSchduled implements Schedulable

{

     global void execute(SchedulableContext sc)

     {

     UpdateRelatedAccountRecordsBatch batch = new UpdateRelatedAccountRecordsBatch('BrokerRecordTypeUpdate');

       database.executeBatch(batch, 100);

     }

}