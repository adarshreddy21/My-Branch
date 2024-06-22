public with sharing class Xera_AudioPlayerController {
    
    private static final String APPLICATION_JSON  = 'application/json';
    private static final String CONTENT_TYPE_HEADER  = 'Content-Type';
    private static final Integer REQUEST_TIMEOUT = 120000;
    private static final String METHOD = 'GET';
       
    private String accessToken {get;set;} 
    public String audioUrl {get;set;}
    
    public Xera_AudioPlayerController(ApexPages.StandardSetController setController) {
        // StandardSetController constructor 
    }
    
    public Xera_AudioPlayerController(){
        final CallRecordingModel callRecModel = getCallRecModel();
        informSpc(callRecModel);
        this.audioUrl = createAudioUrl();
    }   
    
    private CallRecordingModel getCallRecModel(){
        String callId = ApexPages.currentPage().getParameters().get('callId');
        String userAgent = ApexPages.currentPage().getHeaders().get('USER-AGENT');
        final Boolean isIE = (!(userAgent.contains('Firefox')) && !(userAgent.contains('Chrome'))) ? true : false;
        
        final CallRecordingModel callRecordingModel = new CallRecordingModel();
        callRecordingModel.sessionId = callId;
        callRecordingModel.tenantId = getCustomSettingValue('TenantId');
        callRecordingModel.isDownload = false; 
        callRecordingModel.isIE = isIE;
        return callRecordingModel;
    }
    
    private void informSpc(final CallRecordingModel callRecModel){
        String endpoint = getSpcEndpoint() + Xera_Constants.CALL_RECORDING;
        String jsonData = JSON.serialize(callRecModel);
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setHeader(CONTENT_TYPE_HEADER, APPLICATION_JSON);
        req.setTimeout(REQUEST_TIMEOUT);
        req.setMethod(METHOD);
        req.setBody(jsonData);
        
        // Show request message
        System.debug(String.format('Sending following message to spc endpoint {0} by method {1}', new List<String>{endpoint, METHOD}));
        
        Http http = new Http();
        HttpResponse res = http.send(req);
        
        if(res.getStatusCode() != 200){
            ApexPages.Message msg = new ApexPages.Message(Apexpages.Severity.ERROR, System.Label.Xera_BE_Server_Down);
            ApexPages.addMessage(msg);
        }
        this.accessToken = res.getBody();
    }
    
    private String createAudioUrl(){
        final NamedCredential nc = [SELECT Endpoint FROM NamedCredential limit 1];
        return String.format('{0}{1}?accessToken={2}',new List<String>{nc.Endpoint, Xera_Constants.PLAY_CALL_RECORDING, this.accessToken});
    }
    
    private String getSpcEndpoint(){
        return String.format('{0}{1}',new List<String>{Xera_Constants.NAMED_CREDENTIAL_VALUE, Xera_Constants.SPC_CONTEXT_VALUE});
    }
    
    private String getCustomSettingValue(String name){
        Map<String, Xera_Configuration__c> values  = Xera_Configuration__c.getAll();
        return (values != null && !values.isEmpty() && Xera_Configuration__c.getValues(name) != null) ? Xera_Configuration__c.getValues(name).Value__c : '';
    }
    public class CallRecordingModel{
        public String sessionId {get;set;}
        public String tenantId {get;set;}
        public Boolean isDownload {get;set;}
        public Boolean isIE {get;set;}
    }
}