public with sharing class Xera_Constants {

    public static final Integer HTTP_STATUS_OK = 200;
    public static final Integer HTTP_NOT_FOUND = 404;
    public static final Integer HTTP_INTERNAL_ERROR = 500;
 
    public static final String RETRY_FREQUENCY = 'RETRY_FREQUENCY';
    public static final String RETRY_FREQUENCY_VALUE = '15';
    
    public static final String MAX_RETRIES = 'MAX_RETRIES';
    public static final String MAX_RETRIES_VALUE = '3';

    public static final String LOGIN_URL = 'LOGIN_URL';
    public static final String LOGIN_URL_VALUE = 'https://login.salesforce.com/services/oauth2/token';
    
    public static final String API_VERSION = 'API_VERSION';
    public static final String API_VERSION_VALUE = 'v29.0';
    
    public static final String NAMED_CREDENTIAL = 'NAMED_CREDENTIAL'; 
    public static final String NAMED_CREDENTIAL_VALUE = 'callout:SPC_Named_Credential';
     
    public static final String SPC_CONTEXT = 'SPC_CONTEXT';
    public static final String SPC_CONTEXT_VALUE = '/spc/entity';

    public static final String CALL_RECORDING = '/callrecording';
    public static final String PLAY_CALL_RECORDING = '/spc/jb/playcallrecording';

}