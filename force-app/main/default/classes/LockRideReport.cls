public class LockRideReport {  
    
    @InvocableMethod (label='Lock Ride Report') 
    public Static void LockRideReport(List<Id> listRideReportIds){
        for (Id reportToLock : listRideReportIds){    
            Approval.lock(reportToLock);
        }
    }
    
}