/**
 * @description       : 
 * @author            : Irfan Khan
 * @group             : 
 * @last modified on  : 01-09-2023
 * @last modified by  : Irfan Khan
**/
@isTest
public class TestTaxController {
    @testSetup static void setupRecords() {
        TAX_SERVICE__c endpoint = new TAX_SERVICE__c();
        endpoint.Name = 'TAX SERVICE';
        endpoint.End_point_url__c = 'https://websvctest.cleanharbors.com/CrmServices/Api/TaxInfo/TAX';
        insert endpoint;
        
    }
    private static testMethod void testTaxRequirement()
    {
        PageReference pg = new PageReference('apex/Tax_requirements');
        System.currentPageReference().getParameters().put('Companycode', 'PRA200');
    
        Test.setCurrentPage(pg);
         TaxController tc=new Taxcontroller();
        TaxWrapper tw=new TaxWrapper();
        //List<td> t=new List<td>();
        TestMockHttpResponseGenerator fakeResponse = new TestMockHttpResponseGenerator(200,'Complete','{"Details":[{"ExemptCertId":"192562","CertificateNum":"EXEMPT","CustNum":"PRA200","LastUpdateDate":"02-18-2014","LastUpdateby":"-1","FromDate":"01-01-2014","ToDate":"","Long_Code":"Direct Pay Permit","Status":"Active","CertUse":"Blanket","Region":"CONNECTICUT","authority":""}]}');
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, fakeResponse);
        tc.getdata(); 
        tw=tc.wrapper; 
        for(TaxWrapper.TaxDet t:tw.Details)
        {
           System.assertEquals('Blanket',t.CertUse);
            System.assertEquals('192562',t.ExemptCertId);
            System.assertEquals('EXEMPT',t.CertificateNum);
            System.assertEquals('Active',t.Status);
            System.assertEquals('PRA200',t.CustNum);
            System.assertEquals('Direct Pay Permit',t.Long_Code);
            System.assertEquals('02-18-2014',t.LastUpdateDate);
            System.assertEquals('CONNECTICUT',t.Region);
            System.assertEquals('',t.authority);
            System.assertEquals('',t.ToDate);
            System.assertEquals('01-01-2014',t.FromDate);
        }
        Test.stopTest();
    }

}