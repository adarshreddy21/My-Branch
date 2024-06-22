({
	doInit : function(component, event, helper) {
        let recordId = component.get('v.recordId');
        $A.get("e.force:closeQuickAction").fire();
        var device = $A.get("$Browser.formFactor");
        if(device == 'PHONE'){
            let redURL = window.location.origin + '/apex/AccountCustomLinks?id=' + recordId;
            var urlEvent = $A.get("e.force:navigateToURL");
            urlEvent.setParams({
                "url": redURL
            });
            urlEvent.fire();
        }else{
         	window.open(window.location.origin + '/apex/AccountCustomLinks?id=' + recordId, recordId,'top=50,left=200,width=900,height=720');   
        }
    }
})