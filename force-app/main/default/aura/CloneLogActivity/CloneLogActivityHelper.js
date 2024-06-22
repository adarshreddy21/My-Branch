({
	initializeData : function(cmp, event, helper) {
		let action = cmp.get("c.cloneLogActivity");
        action.setParams({
            recordId : cmp.get("v.recordId") 
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log("From server: ", response.getReturnValue());
                
                var createAcountContactEvent = $A.get("e.force:createRecord");
                createAcountContactEvent.setParams({
                    "entityApiName": "Task",
                    "defaultFieldValues": response.getReturnValue()
                });
                
                createAcountContactEvent.fire();
                
                
            }else if (state === "ERROR") {
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