@isTest
public class OwnershipChangeRequestSchdulerTests {
@isTest
    private static void testScheduler() { 
        Test.startTest();
        OwnershipChangeRequestSchduler scheduler = new OwnershipChangeRequestSchduler('');
        scheduler.execute(null);
        Test.stopTest();
	} 
}