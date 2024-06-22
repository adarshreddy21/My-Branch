/**
* @description       : 
* @author            : Gantla Adarsh Reddy
* @group             : 
* @last modified on  : 
* @last modified by  :  
* Modifications Log
* Ver   Date         Author           Modification
* 1.0   02-05-2024   Gantla Adarsh Reddy  Initial Version 
**/
global class AutomatePostRefreshActivities  implements SandboxPostCopy {

    global AutomatePostRefreshActivities () {
    }

    global void runApexClass(SandboxContext context) {

        // Instantiate and schedule your batch classes here
       
            CreateWinIdsAccountsBatch winIdCreationBatch = new CreateWinIdsAccountsBatch();
            Database.executeBatch(winIdCreationBatch, 150);
        
        // Schedule the new OwnershipChangeRequestSchduler to run every 2 hours
        	String twoHourlyCronExp = '0 0 0/2 1/1 * ? *'; // every 2 hours
        	System.schedule('Ownership Change Request Schedule Job', twoHourlyCronExp, new OwnershipChangeRequestSchduler(''));

        	System.schedule('Tokenise Account Fields Batch Schedule', twoHourlyCronExp, new TokeniseAccountFieldsBatch()); 
            
            PushTopic pushTopic = new PushTopic();
            pushTopic.Name = 'ContactUpdates1';
            pushTopic.Query = 'SELECT Id,name,FirstName,LastName,Email,WIN_ID__c,AccountId FROM Contact where CS_Ecomm__c=true';
            pushTopic.ApiVersion = 57.0;
            pushTopic.NotifyForOperationCreate = true;
            pushTopic.NotifyForOperationUpdate = true;
            pushTopic.NotifyForFields = 'Referenced';
            insert pushTopic;
        
    }
}