public class checkRecursive_AccountTrigger {
    private static boolean canRun=true;
    public static boolean check(){
        if(canRun){  canRun=false;return true;} return false;  }

    public static void reset(){
        canRun=true;
    }
}