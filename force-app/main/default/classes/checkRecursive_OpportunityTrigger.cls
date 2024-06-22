public class checkRecursive_OpportunityTrigger {
    private static boolean canRun=true;
    public static boolean check(){
        if(canRun){  canRun=false;return true;} return false;  }

    public static void reset(){
        canRun=true;
    }
}