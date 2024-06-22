({
    execute : function(component, event, helper) {
        let recordId = component.get('v.recordId');
        console.log('recordId ', recordId);
        if (component.get('v.sObjectInfo.Expired__c') == false) {
            let action = component.get("c.redirectToNewLocation");
            action.setParams({ recordId : recordId });
            
            action.setCallback(this, function(response) {
                let state = response.getState();
                if (state === "SUCCESS") {
                    let result = response.getReturnValue();
                    console.log("From server: ", result);
                    
                    // TODO: Review the migrated code
                    if(result.isSuccess){
                        /*let createAcountEvent = $A.get("e.force:editRecord");
                        createAcountEvent.setParams({
                            "recordId": result.newLocationId
                        });
                        createAcountEvent.fire();*/
                       	window.open(window.location.origin + '/lightning/r/Account/'+result.newLocationId+'/edit?navigationLocation=DETAIL' + '&backgroundContext=%2Flightning%2Fr%2FAccount%2F'+ result.newLocationId +'%2Fview&count=1');
                    }else{
                        helper.gotoURL(component, 
                                      '/apex/accountMessages?accountId=' + component.get('v.recordId') 
                                        + '&msg=' + result.errorMsg 
                                        + '&isError=true');
                    }                    
                    
                    $A.get("e.force:closeQuickAction").fire();
                    
                }
            });
            
            $A.enqueueAction(action);
        }else {
            window.alert('Cannot create New Locations on expired accounts');
            window.location.reload();
        }
    }
})