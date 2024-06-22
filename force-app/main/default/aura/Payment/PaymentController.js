({
	init : function(component, event, helper) {
      //window.open("http://winwebtest.cleanharbors.com/PowerPage?GenCode="+component.get("v.simpleRecord.WIN_ID__c"),'_blank');
	    var action = component.get("c.returnAccount");
        action.setParams({
        Id : component.get("v.recordId")}); 
        var tempVars;
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {tempVars = response.getReturnValue();
                 if(tempVars!='')
                 { 
                     $A.get("e.force:closeQuickAction").fire();
                     window.open("https://icptest.cleanharbors.com?win_id="+tempVars); 
                 }
                else{
                    $A.get("e.force:closeQuickAction").fire(); 
                    alert("A Win ID is required to complete the requested Action.")
                  }
                }   
         });
         $A.enqueueAction(action);
      }      
    })