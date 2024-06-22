({
	execute : function(component, event, helper) {
		if (component.get('v.sObjectInfo.CS_Ecomm__c')){
			helper.gotoURL(component, 'https://winwebtest.cleanharbors.com/chosportal/loginbeacon.aspx?username='+component.get('v.sObjectInfo.Email')+'');
			$A.get("e.force:closeQuickAction").fire();
        }else {
			$A.get("e.force:closeQuickAction").fire();
        	alert('This customer contact is not setup as an Ecomm/CHOS user. Click the ecomm flag and save to establish the account access to CHOS.');    
        } 
	}
})