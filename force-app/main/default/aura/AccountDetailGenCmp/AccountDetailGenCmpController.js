({
	doInit : function(component, event, helper) {
        let recordId = component.get('v.recordId');
        $A.get("e.force:closeQuickAction").fire();
		window.open(window.location.origin + '/apex/AccountGenLinks?id=' + recordId, recordId,'top=50,left=200,width=900,height=720');
    }
})