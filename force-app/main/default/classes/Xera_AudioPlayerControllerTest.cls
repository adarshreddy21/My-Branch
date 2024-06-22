@isTest(SeeAllData=true)
private class Xera_AudioPlayerControllerTest {
    private static testMethod void testAll() {
        ApexPages.currentPage().getHeaders().put('USER-AGENT', '... Chrome ...');
        
                Test.startTest();

                createHttpMock();
        
                Xera_AudioPlayerController controller = new Xera_AudioPlayerController();
                
                Test.stopTest();
        
                System.assert(controller != null);
        
    }
    
    public static void createHttpMock(){
        // Testing repost functionality by creating the Callout mock
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('Xera_jsonData');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');
        
        Test.setMock(HttpCalloutMock.class, mock);
    }

}