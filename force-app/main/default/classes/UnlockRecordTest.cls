@isTest
public with sharing class UnlockRecordTest {



    @isTest
    public static void CanUnlockRecord () {

       SIC_VALIDATION_SETTING__c svsObj = new SIC_VALIDATION_SETTING__c();
        svsObj.name = 'SIC_VALIDATION_SETTING';
        svsObj.SIC_VALIDATION_FLAG__c = true;
        insert svsObj;
         TERRITORY_MANAGEMENT__c tmgObj = new TERRITORY_MANAGEMENT__c();
        tmgObj.name = 'TERRITORY_MGMT_SETTING';
        tmgObj.TM_FLAG__c = true;
        insert tmgObj;

        //create record

        Account testAct1 = new Account();
        testAct1.Name = 'testAccount1';
        testAct1.CS_EPA_ID__c = 'Pending';
        insert testAct1;

        
        //lock it
        Approval.lock(testAct1.Id);

        //call UnlockRecord
        UnlockRecord.Request testReq = new UnlockRecord.Request();
        testReq.recordId = testAct1.Id;
       
        List<UnlockRecord.Request> reqList = new List<UnlockRecord.Request>();
        reqList.add(testReq);

        List<UnlockRecord.Response> unlockResponseList = UnlockRecord.Unlock(reqList);
         
        //inspect result

        System.assertEquals(unlockResponseList[0].isSuccess,true);
        System.assertEquals(Approval.isLocked(testAct1.Id), false);


    }

}