({
	onInit : function(cmp, event, helper) {
		var createRecordEvent = $A.get("e.force:createRecord");
        createRecordEvent.setParams({
            "entityApiName": "Task",
            "defaultFieldValues": {
                'WhatId' : cmp.get('v.recordId'),
                'RecordTypeId' : '0124Q000001dVolQAE'
            }
        });
        createRecordEvent.fire();
	}
})