({
	doInit : function(component, event, helper) {
        let recordId = component.get('v.recordId');
        
        window.location.href = window.location.origin + '/lightning/o/Case/new?count=2&nooverride=1&useRecordTypeCheck=1&backgroundContext=%2F'+ recordId + '&save_new_url=%2F500%2Fe%3FretURL%3D%252F' + recordId + '%26def_account_id%3D' + recordId + '&defaultFieldValues=AccountId=' + recordId ;
	}
})