({
	doInit : function(component, event, helper) {
        var action = component.get("c.getCaseDetails");
        action.setParams({ caseId : component.get("v.recordId") });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log("From server: " + response.getReturnValue());
                
                let record = response.getReturnValue()[0];
                window.open('/apex/caseAccountDetails?id=' + record.AccountId, 'top=100,left=200,width=900,height=720');
                
                var dismissActionPanel = $A.get("e.force:closeQuickAction");
                dismissActionPanel.fire();
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                 errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
		
        $A.enqueueAction(action);
	}
})