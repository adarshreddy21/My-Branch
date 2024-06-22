({
	intilalize : function(component, event, helper) {
		let action = component.get("c.getUserDetails");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                let userRec = response.getReturnValue();
                
                let linkDetails = [
                    {
                        'linkName': 'My Sales Budget App', 
                        'url': 'https://winwebtest.cleanharbors.com/SalesBudget/BudgetView?salesvsopsamname='+userRec.EmployeeNumber,
                        'target': '_blank'
                    },
                    {
                        'linkName': 'AR Aging Sales Dashboard', 
                        'url': 'https://app.powerbi.com/Redirect?action=OpenApp&appId=9cbdf08f-afc0-4739-bc51-942805fda9eb&ctid=c6d29e44-c3b2-4a22-8d73-b3e4c195a383',
                        'target': '_blank'
                    },
                    {
                        'linkName': 'Account Manager Book of Account Search', 
                        'url': window.location.origin + '/apex/AccountSearchVf',
                        'target': '_blank'
                    },
					{
                        'linkName': 'Active Accounts on Credit Hold', 
                        'url': window.location.origin + $A.get("$Label.c.Active_Accounts_on_Credit_Hold"),
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