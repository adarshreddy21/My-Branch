@isTest
public class checkRecursive_OpportunityTriggerTest {
    @isTest
    static void checkMethod(){
        boolean first=checkRecursive_OpportunityTrigger.check();
        system.assertEquals(True, first);
        
    }
     @isTest
    static void checkMethod1(){
        checkRecursive_OpportunityTrigger.reset();
        
    }


}