({
	doInit : function(component, event, helper) {
        component.set('v.showSpinner', true);
		let oliId = component.get('v.recordId');
        
        if(!oliId){
            
            component.set('v.showSpinner', false);
        	alert("Please select an opportunity product");    
        }else{
           
        	let action = component.get("c.getOppLineItemDetails");
            action.setParams({
                'oppLineRecId': oliId
            });
        
            action.setCallback(this, function(response) {
                let state = response.getState();
                if (state === "SUCCESS") {
                    let result = response.getReturnValue();
                    console.log("From server: ", result);
                   
                    let oppItemRecords = result.oppLineItemRst;
                    let schdRecords = result.oppLineItemSch;
                    let oliId = component.get('v.recordId');
                    let deleteSchedules = [];
                    component.set('v.oliDetails', result);
                    if(schdRecords.length == 0){
                       
                        component.set('v.showSpinner', false);
                        parent.window.location = window.location.origin + '/lightning/r/OpportunityLineItem/'+oliId+'/edit?navigationLocation=DETAIL&backgroundContext=%2Flightning%2Fr%2FOpportunityLineItem%2F'+oliId+'%2Fview';
                    }else{
                        
                       for(let sch of schdRecords){
                            deleteSchedules.push(sch.Id);
                        }
                        let action = component.get("c.deleteSchedules");
                        action.setParams({
                            'schIds': deleteSchedules
                        });
                        action.setCallback(this, function(response) {
                        	let result = response.getReturnValue();
                            let oliDetails = component.get('v.oliDetails');
                            let oliId = component.get('v.recordId');
                    		console.log("From server: ", result);
                            
                            if(result.length > 0){
                                alert("Failed: " + result.successCount + "\nSucceeded: " + result.errorCount + " \n Due to: " + result.errorMessages.join("\n"));
                            }else{
                                window.location.href = window.location.origin + '/lightning/r/OpportunityLineItem/'+oliId+'/edit?navigationLocation=DETAIL&backgroundContext=%2Flightning%2Fr%2FOpportunityLineItem%2F'+oliId+'%2Fview';
                            }
                            
                            component.set('v.showSpinner', false);
                        });
                        
                        $A.enqueueAction(action);
                    }
                }
            });
            
            $A.enqueueAction(action);    
        }
	}
})