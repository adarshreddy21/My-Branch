@isTest
public class TestRestNewCase {
@isTest
	static void test(){
        string Dt = '11/28/14 06:00 AM';

String[] str = dt.split(' ');
String[] dts = str[0].split('/');



        
        Case c1 = new Case();
        c1.subject = 'subject';
        c1.status = 'New';
        c1.WIN_Id__c = 'GIL210';           
        c1.Balance_Amount__c = 5000;
        c1.CurrentSpendAmount__c = 5000;
        c1.PO_Amount__c = 4500;
        c1.PONumber__c = '12345';
        c1.Inserted_By__c = 'padigen1';
        c1.Sales_Order_Number__c = '12345';
        c1.Description = 'Test';
        c1.Cust_PO_Master_ID__c = '7845';
        c1.PO_Notify_Email__c = 'padigela.nikhil@cleanharbors.com';
        c1.Priority = 'High';
        c1.Reason = 'New Problem';
        c1.PO_Expiration_Date__c = date.newinstance(Integer.valueOf('20'+dts[2]), Integer.valueOf(dts[0]), Integer.valueOf(dts[1]));
        c1.PO_Activation_Date__c = date.newinstance(Integer.valueOf('20'+dts[2]), Integer.valueOf(dts[0]), Integer.valueOf(dts[1]));
        c1.PO_Case_Auto_Create__c = true;
        c1.Unbilled_Amount__c = 5000;
            
            
        insert c1;
		
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/NewCase'; 
        //req.params.put('startDate','05-10-2019T11:30 AM');
        //req.params.put('endDate','05-10-2019T11:40 AM');
        req.httpMethod = 'GET';
        req.addHeader('Content-Type', 'application/json'); 
        
        RestContext.request = req;
        RestContext.response = res;
        RestNewCase.getCase();
		
        RestRequest req1 = new RestRequest(); 
        RestResponse res1 = new RestResponse();
        req1.requestURI = '/services/apexrest/NewCase';
        req1.httpMethod = 'POST';
        RestContext.request = req1;	
        RestContext.response = res1;
        test.startTest();
        RestNewCase.createnewcase(c1.subject, c1.status, 'GIL210', c1.Balance_Amount__c, c1.CurrentSpendAmount__c,c1.PO_Amount__c,
                                      c1.PONumber__c, c1.Sales_Order_Number__c, c1.Description, 'Test Name', c1.Cust_PO_Master_ID__c,c1.PO_Notify_Email__c, c1.Priority, c1.Reason,
                                  	  '2020-01-23 06:00:00 AM', '2020-01-23 06:00:00 AM', true, 5000);
        test.stopTest();
		
	}
}