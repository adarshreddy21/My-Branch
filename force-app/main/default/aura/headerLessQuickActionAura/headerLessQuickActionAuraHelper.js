/**
 * @description       : 
 * @author            : Suresh Beniwal
 * @group             : 
 * @last modified on  : 07-15-2022
 * @last modified by  : Suresh Beniwal
 * Modifications Log
 * Ver   Date         Author           Modification
 * 1.0   07-15-2022   Suresh Beniwal   Initial Version
**/
({
    handleConfirmSoftDelete: function (component, event, helper) {
        var msg ='Are you sure you want to delete item ?';
        if (!confirm(msg)) {
            console.log('No');
            // Close the action panel
            helper.closeQuickActions(component, event, helper, '');
        } else {
            console.log('Yes');
            var recordId = component.get("v.recordId");
            helper.closeQuickActions(component, event, helper, recordId);
            //Write your confirmed logic
        }
    },

    closeQuickActions: function (component, event, helper, recordId) {

        var action = component.get("c.softDeleteAction");
        action.setParams({
            recordId: recordId
        });

        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                // Display the total in a "toast" status message

                if (recordId != '') {
                    var resultsToast = $A.get("e.force:showToast");
                    resultsToast.setParams({
                        "title": "Success",
                        "type": "success",
                        "message": "Record has been updated successfully !"
                    });
                    resultsToast.fire();
                }
            }

            // Close the action panel
            var dismissActionPanel = $A.get("e.force:closeQuickAction");
            dismissActionPanel.fire();
        });

        $A.enqueueAction(action);

    }
})