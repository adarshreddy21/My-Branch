@isTest
public class checkRecursive_AccountTriggerTest {
    @isTest
    static void checkMethod(){
        boolean first=checkRecursive_AccountTrigger.check();
        system.assertEquals(True, first);
        
    }
     @isTest
    static void checkMethod1(){
        checkRecursive_AccountTrigger.reset();
        
    }


}