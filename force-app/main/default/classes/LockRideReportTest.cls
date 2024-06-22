@isTest
private class LockRideReportTest {

    @testSetup
    static void setup() {  
        // create test data for the test methods
        List<Ride_Report__c> reports = new List<Ride_Report__c>();
        for (Integer i = 0; i < 5; i++) {
            reports.add(new Ride_Report__c());     
        }
        insert reports;
    }

    @isTest
    static void testLockRideReport() {
        // retrieve the ride reports to lock
        List<Ride_Report__c> reports = [SELECT Id, Status__c FROM Ride_Report__c LIMIT 5];
        List<Id> reportIds = new List<Id>();
        for (Ride_Report__c report : reports) {
            reportIds.add(report.Id);
        }
        
        // call the LockRideReport invocable method
        LockRideReport.LockRideReport(reportIds);
        
        // assert that the ride reports are now locked
        List<Ride_Report__c> lockedReports = [SELECT Id, Status__c FROM Ride_Report__c WHERE Id IN :reportIds];
        for (Ride_Report__c report : lockedReports) {
            System.assertEquals('Draft', report.Status__c);
        }
    }
}