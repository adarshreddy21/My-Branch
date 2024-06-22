@isTest
public with sharing class GetRecordLockStatusTest {
    

    @isTest
    public static void CanGetRecordLockStatus () {
        
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

        //call GetRecordLockStatus
        GetRecordLockStatus.Request testReq = new GetRecordLockStatus.Request();
        testReq.recordId = testAct1.Id;
       
        List<GetRecordLockStatus.Request> reqList = new List<GetRecordLockStatus.Request>();
        reqList.add(testReq);

        List<GetRecordLockStatus.Response> getstatusResponseList = GetRecordLockStatus.GetStatus(reqList);
         
        //inspect result

        System.assertEquals(getstatusResponseList[0].locked,true);
       


    }

}