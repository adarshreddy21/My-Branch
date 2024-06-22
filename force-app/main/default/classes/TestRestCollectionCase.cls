@isTest
public class TestRestCollectionCase {
@isTest
	static void test(){
        string Dt = '1/23/20 06:00 AM';

String[] str = dt.split(' ');
String[] dts = str[0].split('/');



        
          Case c1 = new Case();
          c1.subject = 'subject';
          c1.status = 'New';
          c1.WIN_Id__c = 'GIL210';                     
            c1.Business_Unit__c = 'CHES';
            c1.Follow_up_action__c = '1stcontact';
            c1.Keyword_1__c = 'LEGAL';
            c1.Keyword_2__c = '';
            c1.Keyword_3__c = '';
            c1.SETID__c = 'CHI';
            c1.Type='LEGAL';
            c1.PROMISE_AMT__c=0;
            c1.Description = 'Testcase type';
            c1.OPRID__c = 'SIDDABN1';
            c1.REFERENCES__c='';
           c1.CONVER_DT__c =date.newinstance(Integer.valueOf('20'+dts[2]), Integer.valueOf(dts[0]), Integer.valueOf(dts[1]));
            c1.Follow_up_date__c = date.newinstance(Integer.valueOf('20'+dts[2]), Integer.valueOf(dts[0]), Integer.valueOf(dts[1]));
           c1.Conver_DateTime__c=date.newinstance(Integer.valueOf('20'+dts[2]), Integer.valueOf(dts[0]), Integer.valueOf(dts[1]));
            c1.Promise_DT__c=date.newinstance(Integer.valueOf('20'+dts[2]), Integer.valueOf(dts[0]), Integer.valueOf(dts[1]));

        insert c1;
		
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/CollectionCase'; 
        //req.params.put('startDate','05-10-2019T11:30 AM');
        //req.params.put('endDate','05-10-2019T11:40 AM');
        req.httpMethod = 'GET';
        req.addHeader('Content-Type', 'application/json'); 
        
        RestContext.request = req;
        RestContext.response = res;
        RestCollectionCase.getCase();
		
        RestRequest req1 = new RestRequest(); 
        RestResponse res1 = new RestResponse();
        req1.requestURI = '/services/apexrest/CollectionCase';
        req1.httpMethod = 'POST';
        RestContext.request = req1;	
        RestContext.response = res1;
        test.startTest();
        RestCollectionCase.createnewcase('GIL210', 'CHES', '1st Contact', '2020-01-23','SKNOPO','2020-01-23', '2020-01-23','0','LEGAL', 'Test Comments', 'LEGAL2', 'LEGAL2', 'SIDDABN1', '','SIDDABN1' ,'0','Test Reference', '2020-01-23 06:00:00 AM',null,'0',null);        
        test.stopTest();
		
	}
}