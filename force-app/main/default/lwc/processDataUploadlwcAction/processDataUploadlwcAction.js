/**
 * @description       : 
 * @author            : Suresh Beniwal
 * @group             : 
 * @last modified on  : 07-18-2022
 * @last modified by  : Suresh Beniwal
 * Modifications Log
 * Ver   Date         Author           Modification
 * 1.0   07-08-2022   Suresh Beniwal   Initial Version
**/
import { LightningElement, api, wire, track } from 'lwc';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import { getRecordNotifyChange } from "lightning/uiRecordApi";
import invokeBatch from "@salesforce/apex/ProcessOrganizationDataBatch.invokeBatch";

export default class ProcessDataUploadlwcAction extends LightningElement {
    @api recordId;
    @api async invoke() {
        await invokeBatch({
            recordId: this.recordId
        }).then(result => {
            this.showToast();
        }).catch(error => {
            console.log(error);
        });
    }

    showToast() {
        const successToast = new ShowToastEvent({
            title : "Success!",
            message : "Batch job process started !",
            variant : 'success'
        });
        this.dispatchEvent(successToast);
    }
}