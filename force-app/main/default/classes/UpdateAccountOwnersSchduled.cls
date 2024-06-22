global class UpdateAccountOwnersSchduled implements Schedulable

{

     global void execute(SchedulableContext sc)

     {

     UpdateRelatedAccountRecordsBatch batch = new UpdateRelatedAccountRecordsBatch('Ownerupdate');

       database.executeBatch(batch, 100);

     }

}