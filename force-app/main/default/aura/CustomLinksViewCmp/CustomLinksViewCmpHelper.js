({
	intilalize : function(component, event, helper) {
		let action = component.get("c.getUserDetails");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                let userRec = response.getReturnValue();
                
                let linkDetails = [
                    {
                        'linkName': 'Help Group', 
                        'url': 'https://cleanharbors.my.salesforce.com/_ui/core/chatter/groups/GroupProfilePage?g=0F9j0000000XZCr',
                        'target': '_blank'
                    },
                    {
                        'linkName': 'Quote Pricing Calculator', 
                        'url': 'https://winwebtest.cleanharbors.com/quote/PricingCalculatorUIWrapper.aspx',
                        'target': '_blank'
                    },
                    {
                        'linkName': 'Manifest Search', 
                        'url': 'https://winwebtest.cleanharbors.com/inventory/WSMNFHST.aspx',
                        'target': '_blank'
                    },
                    {
                        'linkName': 'Dash - All Sales Opportunities', 
                        'url': window.location.origin + '/01Zj0000000hx4r',
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