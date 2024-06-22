({
    submitForApproval : function(component, event, helper) {
        
        
        var action = component.get("c.submitForApprovalTax");
        action.setParams({
            "taxRecId" : component.get('v.recordId'),
            "comments" : component.get('v.comments')
        });
        action.setCallback(this, function(response){
            var state = response.getState(); // get the response state
            if(state == 'SUCCESS') {
                
                var resp = response.getReturnValue();
                
                var resultsToast = $A.get("e.force:showToast");
                
                if(resp == 'success'){
                    resultsToast.setParams({ 
                        "title": "Success!" , 
                        "type" : 'success',
                        "mode" : 'sticky',
                        "message": "Tax Documents have been submitted for Approval"             
                    }); 
                }
                else{
                    resultsToast.setParams({ 
                        "title": "Error!" , 
                        "type" : 'error',
                        "mode" : 'sticky',
                        "message": "Please attach tax documents to proceed for approval submission"             
                    }); 
                } 
                resultsToast.fire(); 
                
                setTimeout($A.getCallback(function() {
                    // Close the action panel         
                    var dismissActionPanel = $A.get("e.force:closeQuickAction");        
                    dismissActionPanel.fire();
                    $A.get("e.force:refreshView").fire();
                }), 2000);
                
            }
        });
        $A.enqueueAction(action);
    }
})