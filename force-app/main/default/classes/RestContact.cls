@RestResource(urlMapping = '/ManageContact/*')
global class RestContact {
@HttpGet
    global static List <Contact> getContact()
    { 
        List<Contact> c = [select id, WIN_ID__c,FirstName,LastName,Salutation,Contact_Type__c,Phone,Email from Contact limit 1];
                        //where createddate > startDate and createddate < enddate
                       return c;
    }  
    @HttpPost
    global static void doPost(String FirstName,String LastName,String WINID,String ContactType, String Phone, String Email, String Salutation,String Title,String Receieveemail, String SFcontactId, String UpdatedBy, String UpdatedDt)
    { Contact ct;
       Account a=[Select ID from Account where WIN_ID__C=:WINID];
         If(SFcontactId== '' )
    {
        ct=new Contact();     
    }ELSE{
        ct=[Select ID from Contact where Id=:SFcontactId];     
    }
     try{
            ct.FirstName=FirstName;
            ct.LastName=LastName;
            ct.Salutation=Salutation;
            ct.Phone=Phone;
            ct.Email=Email;
            ct.Title=Title;
            ct.AccountId=a.Id;
             if(ContactType == 'EXP')
             {
                 ct.Expired__c = True; 
             }
         else 
             if(ContactType == 'MAN'){
                 ct.Contact_Type__c = 'MANI'; 
             }
         else 
             if(ContactType == 'ACNT'){
             ct.Contact_Type__c = 'ACCT'; }
         else 
             if(ContactType == 'CSSR'){
             ct.Contact_Type__c = 'CUST'; }
             else
             { 
                 ct.Contact_Type__c=ContactType;
             }
         ct.Update_Date__c=Datetime.Now();
         if(SFcontactId==''){ 
             insert ct;
         }
         else {
             update ct;  
         }
      RestContext.response.responseBody = Blob.valueOf('{"contact_id" :"' +ct.Id +'","Error":""}');
        } catch (Exception e){
            RestContext.response.responseBody = Blob.valueOf('{"contact_id":"","Error": "'+ e.getMessage()+'"}');
            System.debug('Error Message'+ e.getMessage());
        }
}
}