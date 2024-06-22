public class Taxcontroller {

    Public TaxWrapper wrapper{
      get;
      set;
    }

    Public void getdata() {
        String WinId = ApexPages.currentPage().getParameters().get('Companycode');
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(TAX_SERVICE__c.getInstance('TAX SERVICE').End_point_url__c);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        // Set the body as a JSON object
        HttpResponse response;
        try{
            request.setBody('{"Companycode":"'+WinId+'"}');
            System.debug(request);
            response = http.send(request);
            System.debug(response.getBody());
            // Parse the JSON Response
            wrapper = (TaxWrapper) JSON.deserializeStrict(response.getBody(), TaxWrapper.class);
            If (wrapper.Details.isEmpty())
            {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, '**NO RECORDS FOUND**'));
            } 
            
        }
        catch(Exception e){
            system.debug(LoggingLevel.ERROR, e.getStackTraceString());
        }
        
    }
}