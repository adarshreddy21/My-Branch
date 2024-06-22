global class Users
{
    @InvocableMethod(callout=true label='Default Operating Segment and PSP as per User Primary Business') 
    public static List<UserWrapperObject> getDefaultOSandPSP(List<Id> userId) {
        User u = [select id,Primary_Business__c from user where Id in :userId limit 1];
        List<UserWrapperObject> wrapObjects = new List<UserWrapperObject>();
        List<User_Field_Mapping__mdt> mcs = User_Field_Mapping__mdt.getall().values();
        for(User_Field_Mapping__mdt mapping : mcs)
        {
          if(mapping.Primary_Business__c == u.Primary_Business__c){
            UserWrapperObject wo = new UserWrapperObject();
            wo.OperatingSegment = mapping.Operating_Segment__c;
            wo.PrimaryServiceProvider = mapping .Primary_Service_Provider__c;
            wrapObjects.add(wo);  
            break;        
          }
        } 
        
        return wrapObjects;
    }  
   global class UserWrapperObject 
   {
     @InvocableVariable(label='OperatingSegment')
    public string OperatingSegment;
        
    @InvocableVariable(label='PrimaryServiceProvider')
    public string PrimaryServiceProvider;
   }
}