/**
 * @description       : 
 * @author            : Suresh Beniwal
 * @group             : 
 * @last modified on  : 07-15-2022
 * @last modified by  : Suresh Beniwal
 * Modifications Log
 * Ver   Date         Author           Modification
 * 1.0   06-28-2022   Suresh Beniwal   Initial Version
**/
import { LightningElement, api, track, wire } from 'lwc';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import { getRecordNotifyChange } from "lightning/uiRecordApi";
import softDeleteAction from "@salesforce/apex/HeaderLessQuickActionlwcController.softDeleteAction";
export default class HeaderLessQuickActionlwc extends LightningElement {
    @api recordId;
    @api async invoke() {
        await this.handleConfirmSoftDelete();
        // await this.sleep(2000);
        // this.showToast();
    }

    sleep(ms) {
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        return new Promise((resolve) => setTimeout(resolve, ms));
    }

    handleConfirmSoftDelete() {
        var msg ='Are you sure you want to delete this item ?';
        if (!confirm(msg)) {
            console.log('No');
            return false;
        } else {
            console.log('Yes');
            this.softDeleteHandle();
            //Write your confirmed logic
        }
    }
    
    softDeleteHandle() {
        softDeleteAction({
            recordId: this.recordId
        }).then(result => {
            this.showToast();
            getRecordNotifyChange([{ recordId: this.recordId }]);
           
        }).catch(error => {
            console.log(error);
        })
    }

    showToast() {
        const successToast = new ShowToastEvent({
            title : "Success!",
            message : "Record has been updated successfully !",
            variant : 'success'
        });
        this.dispatchEvent(successToast);
    }
   }