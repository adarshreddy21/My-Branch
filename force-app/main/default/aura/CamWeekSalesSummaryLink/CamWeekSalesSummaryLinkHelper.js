({
	intilalize : function(component, event, helper) {
		let action = component.get("c.getUserDetails");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                let userRec = response.getReturnValue();
                
                let linkDetails = [
                    {
                        'linkName': 'Create / View / Edit CAM Weekly Sales Summary Notes', 
                        'url': window.location.origin + '/apex/CAMWeeklyReport',
                        'target': '_blank'
                    },
                    {
                        'linkName': 'View My Team\'s CAM Weekly Sales Summary Notes', 
                        'url': window.location.origin + '/apex/ViewMyCAMTeamWeeklyReport',
                        'target': '_blank'
                    }
                ];
                
                component.set('v.quickAccessLinkDetails', linkDetails);
            }
            
            component.set('v.showSpinner', false);
        });
        
        $A.enqueueAction(action);
	}
})