@isTest
public class CloneLogActivityControllerTest {
	@testSetup
    public static void setupData(){
        LCC_JSMQueryResultServiceTest.loadObjectInfoByIdTest();
    }
    
    @isTest
    public static void unitTest(){
        CloneLogActivityController.cloneLogActivity(
        	[
                SELECT Id FROM Task
            ][0].Id
        );
    }
}